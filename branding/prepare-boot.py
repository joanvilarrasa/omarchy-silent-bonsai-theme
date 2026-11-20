#!/usr/bin/env python3
"""Prepare a separate Plymouth theme and Limine wallpaper without root access."""

from pathlib import Path
import shutil
import subprocess
import tomllib


root = Path(__file__).resolve().parent.parent
output = root / "branding" / "boot"
theme = output / "plymouth"
stock = Path("/usr/share/plymouth/themes/omarchy")
colors = tomllib.loads((root / "colors.toml").read_text())
theme.mkdir(parents=True, exist_ok=True)

for name in ("entry.png", "lock.png", "bullet.png", "progress_box.png", "progress_bar.png"):
    shutil.copy2(stock / name, theme / name)
shutil.copy2(root / "example.png", theme / "logo.png")

background = tuple(int(colors["background"][i:i + 2], 16) / 255 for i in (1, 3, 5))
color_arguments = ", ".join(f"{channel:.6f}" for channel in background)
script = (stock / "omarchy.script").read_text()
for position in ("Top", "Bottom"):
    original = f"Window.SetBackground{position}Color(0.101, 0.105, 0.149);"
    assert original in script
    script = script.replace(original, f"Window.SetBackground{position}Color({color_arguments});")
script = script.replace(
    'logo.image = Image("logo.png");',
    'logo.image = Image("logo.png");\n'
    'logo_size = Window.GetHeight() * 0.30;\n'
    'if (logo_size > 360) logo_size = 360;\n'
    'logo.image = logo.image.Scale(logo_size, logo_size);',
)
script = script.replace(
    "logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2);",
    "logo.sprite.SetY(Window.GetHeight() / 2 - logo.image.GetHeight() / 2 - 44);",
)
(theme / "silent-bonsai.script").write_text(script)
(theme / "silent-bonsai.plymouth").write_text(
    "[Plymouth Theme]\n"
    "Name=Silent Bonsai\n"
    "Description=Colored bonsai boot and disk-unlock splash.\n"
    "ModuleName=script\n\n"
    "[script]\n"
    "ImageDir=/usr/share/plymouth/themes/silent-bonsai\n"
    "ScriptFile=/usr/share/plymouth/themes/silent-bonsai/silent-bonsai.script\n"
    f"ConsoleLogBackgroundColor=0x{colors['background'][1:]}\n"
    "MonospaceFont=Cantarell 11\n"
    "Font=Cantarell 11\n"
)
subprocess.run([
    "magick", str(stock / "progress_bar.png"), "-channel", "RGB",
    "-fill", colors["color2"], "-colorize", "100", "+channel",
    str(theme / "progress_bar.png"),
], check=True)
subprocess.run([
    "magick", "-size", "2560x1440", f"xc:{colors['background']}",
    "(", str(root / "example.png"), "-resize", "480x480", ")",
    "-geometry", "+1800+480", "-compose", "Over", "-composite",
    "-alpha", "off", "-depth", "8", f"PNG24:{output / 'limine-bonsai.png'}",
], check=True)
header = {
    "interface_branding": "Silent Bonsai",
    "interface_branding_color": colors["accent"][1:],
    "interface_help_color": colors["color2"][1:],
    "interface_help_color_bright": colors["accent"][1:],
    "wallpaper": "boot():/silent-bonsai.png",
    "wallpaper_style": "stretched",
    "backdrop": colors["background"][1:],
    "term_background": "ff" + colors["background"][1:],
    "term_foreground": colors["foreground"][1:],
    "term_foreground_bright": colors["foreground"][1:],
    "term_background_bright": colors["selection_background"][1:],
    "term_palette": ";".join(colors[f"color{i}"][1:] for i in range(8)),
    "term_palette_bright": ";".join(colors[f"color{i}"][1:] for i in range(8, 16)),
}
(output / "limine-appearance.conf").write_text(
    "".join(f"{key}: {value}\n" for key, value in header.items())
)
print(f"Prepared boot artwork and custom Plymouth theme in {output}")
