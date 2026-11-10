#!/usr/bin/env python3
"""Build a 1024px RGB PNG icon with Python's standard library only."""
import binascii
import pathlib
import struct
import zlib

SIZE = 1024
OUT = pathlib.Path("HaiderAPK/Assets.xcassets/AppIcon.appiconset/AppIcon-1024.png")
OUT.parent.mkdir(parents=True, exist_ok=True)

FONT = {
    "A": ["01110", "10001", "10001", "11111", "10001", "10001", "10001"],
    "P": ["11110", "10001", "10001", "11110", "10000", "10000", "10000"],
    "K": ["10001", "10010", "10100", "11000", "10100", "10010", "10001"],
}

def rounded_rect(x, y, x0, y0, x1, y1, radius):
    if not (x0 <= x <= x1 and y0 <= y <= y1):
        return False
    xx = max(x0 + radius, min(x, x1 - radius))
    yy = max(y0 + radius, min(y, y1 - radius))
    return (x - xx) ** 2 + (y - yy) ** 2 <= radius ** 2

def is_apk_text(x, y):
    start_x, start_y, scale = 347, 781, 17
    if y < start_y or y >= start_y + 7 * scale:
        return False
    relative_x = x - start_x
    if relative_x < 0:
        return False
    stride = 6 * scale
    index = relative_x // stride
    if index > 2:
        return False
    column = (relative_x % stride) // scale
    if column >= 5:
        return False
    row = (y - start_y) // scale
    return FONT["APK"[index]][row][column] == "1"

rows = bytearray()
for y in range(SIZE):
    rows.append(0)  # PNG filter type 0
    for x in range(SIZE):
        rgb = (9, 11, 26)
        if rounded_rect(x, y, 48, 48, 975, 975, 202):
            t = (x + y) / (2 * SIZE)
            rgb = (int(20 + 116*t), int(183 - 104*t), int(251 - 8*t))
        if rounded_rect(x, y, 73, 73, 950, 950, 186):
            rgb = (13, 17, 37)
        if (250 <= y <= 723 and (272 <= x <= 391 or 632 <= x <= 751)) or (
            431 <= y <= 544 and 272 <= x <= 751
        ):
            t = x / SIZE
            rgb = (int(223 + 12*t), int(251 - 26*t), 255)
        if is_apk_text(x, y):
            rgb = (86, 215, 255)
        rows.extend(rgb)

def png_chunk(kind, content):
    return (struct.pack(">I", len(content)) + kind + content +
            struct.pack(">I", binascii.crc32(kind + content) & 0xFFFFFFFF))

payload = b"\x89PNG\r\n\x1a\n"
payload += png_chunk(b"IHDR", struct.pack(">IIBBBBB", SIZE, SIZE, 8, 2, 0, 0, 0))
payload += png_chunk(b"IDAT", zlib.compress(bytes(rows), 9))
payload += png_chunk(b"IEND", b"")
OUT.write_bytes(payload)
print(f"Generated {OUT} ({len(payload)} bytes)")
