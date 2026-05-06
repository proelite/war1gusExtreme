#!/usr/bin/env python3
import argparse
import binascii
import struct
import zlib


def paeth(a, b, c):
    pr = a + b - c
    pa = abs(pr - a)
    pb = abs(pr - b)
    pc = abs(pr - c)
    if pa <= pb and pa <= pc:
        return a
    if pb <= pc:
        return b
    return c


def parse_indexed_png(path):
    with open(path, 'rb') as f:
        data = f.read()

    if data[:8] != b"\x89PNG\r\n\x1a\n":
        raise ValueError("Not a PNG file")

    chunks = []
    i = 8
    ihdr = None
    idat_data = b""
    plte = None

    while i < len(data):
        length = int.from_bytes(data[i:i + 4], 'big')
        ctype = data[i + 4:i + 8]
        chunk = data[i + 8:i + 8 + length]
        chunks.append((ctype, chunk))

        if ctype == b'IHDR':
            ihdr = chunk
        elif ctype == b'PLTE':
            plte = chunk
        elif ctype == b'IDAT':
            idat_data += chunk
        elif ctype == b'IEND':
            break

        i += 12 + length

    if ihdr is None:
        raise ValueError("PNG missing IHDR")
    if plte is None:
        raise ValueError("Indexed PNG missing PLTE")

    w, h, bitdepth, colortype, _, _, _ = struct.unpack('>IIBBBBB', ihdr)
    if colortype != 3 or bitdepth != 8:
        raise ValueError("Expected 8-bit indexed PNG")

    raw = zlib.decompress(idat_data)
    rows = []
    p = 0
    prev = [0] * w

    for _ in range(h):
        ftype = raw[p]
        p += 1
        cur = list(raw[p:p + w])
        p += w

        if ftype == 1:
            for x in range(w):
                cur[x] = (cur[x] + (cur[x - 1] if x else 0)) & 255
        elif ftype == 2:
            for x in range(w):
                cur[x] = (cur[x] + prev[x]) & 255
        elif ftype == 3:
            for x in range(w):
                cur[x] = (cur[x] + ((cur[x - 1] if x else 0) + prev[x]) // 2) & 255
        elif ftype == 4:
            for x in range(w):
                a = cur[x - 1] if x else 0
                b = prev[x]
                c = prev[x - 1] if x else 0
                cur[x] = (cur[x] + paeth(a, b, c)) & 255

        rows.append(cur)
        prev = cur

    return chunks, rows, plte


def png_chunk(ctype, chunk):
    return (
        len(chunk).to_bytes(4, 'big') +
        ctype +
        chunk +
        binascii.crc32(ctype + chunk).to_bytes(4, 'big')
    )


def write_png(path, chunks, rows):
    new_raw = bytearray()
    for row in rows:
        new_raw.append(0)
        new_raw.extend(row)
    new_idat = zlib.compress(bytes(new_raw), level=9)

    out = bytearray(b"\x89PNG\r\n\x1a\n")
    wrote_idat = False
    for ctype, chunk in chunks:
        if ctype == b'IDAT':
            if not wrote_idat:
                out.extend(png_chunk(b'IDAT', new_idat))
                wrote_idat = True
            continue
        out.extend(png_chunk(ctype, chunk))

    with open(path, 'wb') as f:
        f.write(out)


def parse_indices_csv(text):
    vals = [v.strip() for v in text.split(',') if v.strip()]
    if not vals:
        raise ValueError("source-indices is empty")
    out = []
    for v in vals:
        i = int(v)
        if i < 0 or i > 255:
            raise ValueError(f"Invalid index {i}; must be 0..255")
        out.append(i)
    if len(out) > 8:
        raise ValueError("source-indices supports at most 8 indices")
    return out


def luminance(rgb):
    r, g, b = rgb
    return (0.2126 * r) + (0.7152 * g) + (0.0722 * b)


def make_palette_triplets(plte_chunk):
    if len(plte_chunk) % 3 != 0:
        raise ValueError("Invalid PLTE length")
    colors = []
    for i in range(0, len(plte_chunk), 3):
        colors.append((plte_chunk[i], plte_chunk[i + 1], plte_chunk[i + 2]))
    if len(colors) < 256:
        colors.extend([(0, 0, 0)] * (256 - len(colors)))
    return colors[:256]


def unique_used_indices(rows):
    used = set()
    for row in rows:
        used.update(row)
    return used


def remap_rows(rows, mapping):
    changed = 0
    for row in rows:
        for x, value in enumerate(row):
            if value in mapping:
                row[x] = mapping[value]
                changed += 1
    return changed


def main():
    parser = argparse.ArgumentParser(
        description='Map up to 8 source indices in an indexed PNG to player-color indices 200..207.'
    )
    parser.add_argument('input_png', help='Input indexed PNG path')
    parser.add_argument('output_png', nargs='?', help='Output PNG path (default: <input>_pc.png)')
    parser.add_argument(
        '--source-indices',
        help='Comma-separated source indices to map (example: 57,58,59,60,61,62,63,64). If omitted, auto-detects used indices (excluding transparent index).'
    )
    parser.add_argument(
        '--transparent-idx',
        type=int,
        default=0,
        help='Index treated as transparent and excluded from auto-detection (default: 0).'
    )
    parser.add_argument(
        '--sort-by',
        choices=('luminance', 'index'),
        default='luminance',
        help='Order source shades before mapping to 200..207. 200 is mapped to lightest.'
    )
    parser.add_argument(
        '--palette-from',
        metavar='REFERENCE_PNG',
        help='Use the palette of this indexed PNG for luminance sorting instead of the input image\'s own palette.'
    )

    args = parser.parse_args()

    if args.transparent_idx < 0 or args.transparent_idx > 255:
        raise ValueError('transparent-idx must be 0..255')

    src = args.input_png
    dst = args.output_png if args.output_png else src

    chunks, rows, plte = parse_indexed_png(src)

    if args.palette_from:
        _, _, ref_plte = parse_indexed_png(args.palette_from)
        colors = make_palette_triplets(ref_plte)
    else:
        colors = make_palette_triplets(plte)

    if args.source_indices:
        src_indices = parse_indices_csv(args.source_indices)
    else:
        used = unique_used_indices(rows)
        used.discard(args.transparent_idx)
        if len(used) == 0:
            raise ValueError('No non-transparent indices found to map')
        if len(used) > 8:
            show = ','.join(str(i) for i in sorted(used)[:20])
            raise ValueError(
                f'Auto-detected {len(used)} source indices (>8). '
                f'Provide --source-indices explicitly. First indices: {show}'
            )
        src_indices = sorted(used)

    # Stable de-dup in case user repeats values.
    seen = set()
    src_indices = [i for i in src_indices if not (i in seen or seen.add(i))]

    if args.sort_by == 'luminance':
        # 208 should be lightest, 211 darkest.
        src_indices = sorted(src_indices, key=lambda i: luminance(colors[i]), reverse=True)
    else:
        src_indices = sorted(src_indices)

    # Map up to eight shades from light->dark into 200..207.
    targets = [200, 201, 202, 203, 204, 205, 206, 207][:len(src_indices)]
    mapping = {s: t for s, t in zip(src_indices, targets)}

    changed = remap_rows(rows, mapping)
    write_png(dst, chunks, rows)

    pairs = ', '.join(f'{k}->{v}' for k, v in mapping.items())
    print(f'Mapped indices: {pairs}')
    print(f'Changed pixels: {changed}')
    print(f'Wrote {dst}')


if __name__ == '__main__':
    main()
