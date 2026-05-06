import sys
import struct
import zlib
import binascii
import argparse


NEIGHBOR_OFFSETS = (
    (-1, -1), (0, -1), (1, -1),
    (-1, 0),            (1, 0),
    (-1, 1),  (0, 1),  (1, 1),
)


def paeth(a, b, c):
    pr = a + b - c
    pa = abs(pr - a)
    pb = abs(pr - b)
    pc = abs(pr - c)
    if pa <= pb and pa <= pc:
        return a
    elif pb <= pc:
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
    plte = None
    trns = None
    idat_data = b""
    while i < len(data):
        length = int.from_bytes(data[i:i + 4], 'big')
        ctype = data[i + 4:i + 8]
        chunk = data[i + 8:i + 8 + length]
        chunks.append((ctype, chunk))
        if ctype == b'IHDR':
            ihdr = chunk
        elif ctype == b'PLTE':
            plte = chunk
        elif ctype == b'tRNS':
            trns = chunk
        elif ctype == b'IDAT':
            idat_data += chunk
        elif ctype == b'IEND':
            break
        i += 12 + length

    if ihdr is None:
        raise ValueError("PNG missing IHDR")
    if plte is None:
        raise ValueError("Indexed PNG missing PLTE")

    w, h, bitdepth, colortype, comp, flt, interlace = struct.unpack('>IIBBBBB', ihdr)
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

    return chunks, rows, plte, trns


def png_chunk(ctype, chunk):
    return (
        len(chunk).to_bytes(4, 'big') +
        ctype +
        chunk +
        binascii.crc32(ctype + chunk).to_bytes(4, 'big')
    )


def make_palette_triplets(plte_chunk):
    if len(plte_chunk) % 3 != 0:
        raise ValueError("Invalid PLTE length")

    colors = []
    for i in range(0, len(plte_chunk), 3):
        colors.append((plte_chunk[i], plte_chunk[i + 1], plte_chunk[i + 2]))

    if len(colors) < 256:
        colors.extend([(0, 0, 0)] * (256 - len(colors)))

    return colors[:256]


def make_transparent_set(trns_chunk, transparent_idx):
    transparent = {transparent_idx}
    if trns_chunk is None:
        return transparent

    for idx, alpha in enumerate(trns_chunk):
        if alpha == 0:
            transparent.add(idx)

    return transparent


def remap_rows(rows, start_idx=200, end_idx=207, offset=-8):
    changed = 0
    for y, row in enumerate(rows):
        for x, value in enumerate(row):
            if start_idx <= value <= end_idx:
                row[x] = value + offset
                changed += 1
    return changed


def average_neighbor_rgb(original_rows, x, y, start_idx, end_idx, transparent_indices, palette):
    width = len(original_rows[0])
    height = len(original_rows)
    rgb_values = []

    for dx, dy in NEIGHBOR_OFFSETS:
        nx = x + dx
        ny = y + dy
        if nx < 0 or ny < 0 or nx >= width or ny >= height:
            continue

        value = original_rows[ny][nx]
        if value in transparent_indices:
            continue
        if start_idx <= value <= end_idx:
            continue

        rgb_values.append(palette[value])

    if not rgb_values:
        return None

    count = len(rgb_values)
    return tuple(sum(rgb[i] for rgb in rgb_values) / count for i in range(3))


def nearest_palette_index(target_rgb, palette, start_idx, end_idx, transparent_indices):
    best_index = None
    best_distance = None

    for idx, rgb in enumerate(palette):
        if idx in transparent_indices:
            continue
        if start_idx <= idx <= end_idx:
            continue

        distance = (
            (rgb[0] - target_rgb[0]) ** 2 +
            (rgb[1] - target_rgb[1]) ** 2 +
            (rgb[2] - target_rgb[2]) ** 2
        )
        if best_distance is None or distance < best_distance:
            best_distance = distance
            best_index = idx

    return best_index


def remap_rows_neighbor_average(rows, palette, start_idx=200, end_idx=207, transparent_indices=None):
    if transparent_indices is None:
        transparent_indices = {0}

    original_rows = [row[:] for row in rows]
    changed = 0
    unresolved = 0

    for y, row in enumerate(rows):
        for x, value in enumerate(row):
            if not (start_idx <= value <= end_idx):
                continue

            avg_rgb = average_neighbor_rgb(
                original_rows,
                x,
                y,
                start_idx,
                end_idx,
                transparent_indices,
                palette,
            )
            if avg_rgb is None:
                unresolved += 1
                continue

            replacement = nearest_palette_index(
                avg_rgb,
                palette,
                start_idx,
                end_idx,
                transparent_indices,
            )
            if replacement is None:
                unresolved += 1
                continue

            row[x] = replacement
            changed += 1

    return changed, unresolved


def write_png(path, chunks, rows):
    new_raw = bytearray()
    for row in rows:
        new_raw.append(0)  # no filter
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


if __name__ == '__main__':
    parser = argparse.ArgumentParser(
        description='Remap reserved palette indices in an indexed PNG.'
    )
    parser.add_argument('input_png', help='Input PNG path')
    parser.add_argument('output_png', nargs='?', help='Output PNG path')
    parser.add_argument(
        '--mode',
        choices=('shift', 'neighbor-average'),
        default='shift',
        help='Remap strategy: shift the reserved range by its width, or replace each reserved pixel from surrounding non-reserved neighbors'
    )
    parser.add_argument(
        '--remap-side',
        choices=('lower', 'higher'),
        default='lower',
        help='Shift the reserved range downward or upward by its own width (used by --mode shift)'
    )
    parser.add_argument('--start-idx', type=int, default=200, help='Start of reserved range (inclusive)')
    parser.add_argument('--end-idx', type=int, default=207, help='End of reserved range (inclusive)')
    parser.add_argument(
        '--transparent-idx',
        type=int,
        default=0,
        help='Palette index treated as transparent and ignored by --mode neighbor-average (default: 0)'
    )

    args = parser.parse_args()

    src = args.input_png
    dst = args.output_png if args.output_png else src.rsplit('.', 1)[0] + '_fixed.png'

    if args.start_idx < 0 or args.end_idx > 255 or args.start_idx > args.end_idx:
        raise ValueError('start-idx/end-idx must be between 0 and 255 and start-idx <= end-idx')
    if args.transparent_idx < 0 or args.transparent_idx > 255:
        raise ValueError('transparent-idx must be between 0 and 255')

    chunks, rows, plte, trns = parse_indexed_png(src)

    if args.mode == 'shift':
        range_width = args.end_idx - args.start_idx + 1
        if args.remap_side == 'lower':
            offset = -range_width
        else:
            offset = range_width

        shifted_start = args.start_idx + offset
        shifted_end = args.end_idx + offset

        if shifted_start < 0 or shifted_end > 255:
            raise ValueError(
                f"Cannot remap '{args.remap_side}' for range {args.start_idx}-{args.end_idx}; "
                f'shifted range {shifted_start}-{shifted_end} is out of 0-255'
            )

        changed = remap_rows(rows, args.start_idx, args.end_idx, offset)
        summary = (
            f'Remapped {changed} pixels from indices '
            f'{args.start_idx}-{args.end_idx} to {shifted_start}-{shifted_end} '
            f'by shifting {offset:+d}'
        )
    else:
        palette = make_palette_triplets(plte)
        transparent_indices = make_transparent_set(trns, args.transparent_idx)
        changed, unresolved = remap_rows_neighbor_average(
            rows,
            palette,
            args.start_idx,
            args.end_idx,
            transparent_indices,
        )
        summary = (
            f'Remapped {changed} pixels from indices {args.start_idx}-{args.end_idx} '
            f'using neighbor-average mode; left {unresolved} pixels unchanged with no valid neighbors'
        )

    write_png(dst, chunks, rows)
    print(summary)
    print(f'Wrote {dst}')
