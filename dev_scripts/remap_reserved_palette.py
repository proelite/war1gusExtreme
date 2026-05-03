import sys
import struct
import zlib
import binascii
import argparse


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
    idat_data = b""
    while i < len(data):
        length = int.from_bytes(data[i:i + 4], 'big')
        ctype = data[i + 4:i + 8]
        chunk = data[i + 8:i + 8 + length]
        chunks.append((ctype, chunk))
        if ctype == b'IHDR':
            ihdr = chunk
        elif ctype == b'IDAT':
            idat_data += chunk
        elif ctype == b'IEND':
            break
        i += 12 + length

    if ihdr is None:
        raise ValueError("PNG missing IHDR")

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

    return chunks, rows


def png_chunk(ctype, chunk):
    return (
        len(chunk).to_bytes(4, 'big') +
        ctype +
        chunk +
        binascii.crc32(ctype + chunk).to_bytes(4, 'big')
    )


def remap_rows(rows, start_idx=200, end_idx=207, replacement=199):
    changed = 0
    for y, row in enumerate(rows):
        for x, value in enumerate(row):
            if start_idx <= value <= end_idx:
                row[x] = replacement
                changed += 1
    return changed


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
        '--remap-side',
        choices=('lower', 'higher'),
        default='lower',
        help='Use lower neighbor index (default) or higher neighbor index'
    )
    parser.add_argument('--start-idx', type=int, default=200, help='Start of reserved range (inclusive)')
    parser.add_argument('--end-idx', type=int, default=207, help='End of reserved range (inclusive)')

    args = parser.parse_args()

    src = args.input_png
    dst = args.output_png if args.output_png else src.rsplit('.', 1)[0] + '_fixed.png'

    if args.start_idx < 0 or args.end_idx > 255 or args.start_idx > args.end_idx:
        raise ValueError('start-idx/end-idx must be between 0 and 255 and start-idx <= end-idx')

    if args.remap_side == 'lower':
        replacement = args.start_idx - 1
    else:
        replacement = args.end_idx + 1

    if replacement < 0 or replacement > 255:
        raise ValueError(
            f"Cannot remap '{args.remap_side}' for range {args.start_idx}-{args.end_idx}; "
            f'replacement index {replacement} is out of 0-255'
        )

    chunks, rows = parse_indexed_png(src)
    changed = remap_rows(rows, args.start_idx, args.end_idx, replacement)
    write_png(dst, chunks, rows)
    print(
        f'Remapped {changed} pixels from indices '
        f'{args.start_idx}-{args.end_idx} to {replacement} ({args.remap_side})'
    )
    print(f'Wrote {dst}')
