#!/usr/bin/env python3
"""Regenerate About and screensaver Unicode artwork from example.png."""

from collections import Counter
from pathlib import Path
import subprocess


HERE = Path(__file__).resolve().parent
SOURCE = HERE.parent / "example.png"

# The image already contains the desired colors. Preserve its dominant flat
# shades instead of mapping them onto the old reference's palette.
original = subprocess.check_output(["magick", str(SOURCE), "-depth", "8", "rgba:-"])
counts = Counter(
    tuple(original[i:i + 3])
    for i in range(0, len(original), 4)
    if original[i + 3] == 255
)
palette = [color for color, _ in counts.most_common(8)]


def render(width, rows, padding=0):
    image_width = width - 2 * padding
    image_height = rows * 2 - 2 * padding
    resize = ["-resize", f"{image_width}x{image_height}!"]
    if padding:
        resize += ["-bordercolor", "none", "-border", f"{padding}x{padding}"]
    data = subprocess.check_output([
        "magick", str(SOURCE), "-filter", "box",
        *resize, "-depth", "8", "rgba:-",
    ])
    assert len(data) == width * rows * 2 * 4

    def pixel(x, y):
        offset = (y * width + x) * 4
        red, green, blue, alpha = data[offset:offset + 4]
        if alpha < 80:
            return None
        sample = (red, green, blue)
        return min(
            palette,
            key=lambda color: sum((a - b) ** 2 for a, b in zip(sample, color)),
        )

    plain_lines, colored_lines = [], []
    for y in range(0, rows * 2, 2):
        plain, colored = [], []
        previous = None
        for x in range(width):
            top, bottom = pixel(x, y), pixel(x, y + 1)
            plain.append(" ▀▄█"[(top is not None) + 2 * (bottom is not None)])
            if top is None and bottom is None:
                character, foreground, background = " ", None, None
            elif top is None:
                character, foreground, background = "▄", bottom, None
            elif bottom is None:
                character, foreground, background = "▀", top, None
            elif top == bottom:
                character, foreground, background = "█", top, None
            else:
                character, foreground, background = "▀", top, bottom
            style = (foreground, background)
            if style != previous:
                codes = ["22"]
                codes.append("39" if foreground is None else
                             "38;2;" + ";".join(map(str, foreground)))
                codes.append("49" if background is None else
                             "48;2;" + ";".join(map(str, background)))
                colored.append("\033[" + ";".join(codes) + "m")
                previous = style
            colored.append(character)
        plain_lines.append("".join(plain).rstrip())
        colored_lines.append("".join(colored) + "\033[0m")
    return "\n".join(plain_lines) + "\n", "\n".join(colored_lines) + "\n"


# Iosevka's cells here are 8 × 20 px. A 50 × 40 half-cell raster
# therefore displays square, with a small transparent border on every side.
plain, colored = render(54, 22, padding=2)
(HERE / "about.txt").write_text(plain)
(HERE / "about-colored.txt").write_text(colored)

# At the screensaver's larger font size, this grid keeps the square reference
# proportional while fitting comfortably within the display's height.
plain, _ = render(80, 32)
(HERE / "screensaver.txt").write_text(plain)
print("Updated About (54 × 22) and screensaver (80 × 32) from example.png.")
