import sys
import struct
import zlib
import binascii


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
    if len(sys.argv) not in (2, 3):
        print('Usage: python3 scripts/remap_reserved_palette.py input.png [output.png]')
        sys.exit(1)

    src = sys.argv[1]
    dst = sys.argv[2] if len(sys.argv) == 3 else src.rsplit('.', 1)[0] + '_fixed.png'

    chunks, rows = parse_indexed_png(src)
    changed = remap_rows(rows, 200, 207, 199)
    write_png(dst, chunks, rows)
    print(f'Remapped {changed} pixels from indices 200-207 to 199')
    print(f'Wrote {dst}')
