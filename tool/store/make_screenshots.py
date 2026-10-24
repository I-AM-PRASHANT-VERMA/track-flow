"""Turns the raw release screenshots into Play Store phone screenshots:
dark gradient background, a headline, and the real screen inside a phone frame.
Nothing in the UI is redrawn: the screen is the untouched screenshot with only
the status bar (clock, other apps' icons) cropped off.

Usage (from the repo root):
    python tool/store/make_screenshots.py <raw_shots_dir> <out_dir>

Reads 01_*.png ... 05_*.png (1080 x 1920) from <raw_shots_dir> and writes
1080 x 1920 PNGs with the same names to <out_dir>.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

FONTS = Path("C:/Windows/Fonts")
W, H = 1080, 1920
BG_TOP = (6, 8, 14)
BG_BOTTOM = (18, 22, 54)
WHITE = (244, 244, 245)
MUTED = (166, 168, 186)
BEZEL = (10, 11, 16)
BEZEL_EDGE = (58, 62, 82)
STATUS_BAR = 128  # px cropped from the top of every raw screenshot

# name prefix -> (headline line 1, headline line 2 in accent colour, subline, accent colour)
CAPTIONS = {
    "01": ("Check in", "with one tap", "Morning, deep work, evening: your whole day at a glance.", (27, 179, 131)),
    "02": ("Your week", "in one table", "Every habit, the last seven days, plus monthly consistency.", (108, 99, 255)),
    "03": ("A whole year", "as one heatmap", "Rest days are shown differently from missed days.", (27, 179, 131)),
    "04": ("Habits that", "fit your week", "Pick the weekdays, time of day, target, icon and colour.", (69, 160, 240)),
    "05": ("Private.", "Offline. Yours.", "No account, no ads, no internet. Back up as plain text.", (232, 160, 40)),
}


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def background(accent):
    img = Image.new("RGB", (W, H))
    draw = ImageDraw.Draw(img)
    for y in range(H):
        t = y / (H - 1)
        draw.line([(0, y), (W, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))
    glow = Image.new("RGBA", (W, H), (0, 0, 0, 0))
    ImageDraw.Draw(glow).ellipse([W // 2 - 520, 1000, W // 2 + 520, 1900], fill=accent + (70,))
    glow = glow.filter(ImageFilter.GaussianBlur(160))
    out = img.convert("RGBA")
    out.alpha_composite(glow)
    return out


def rounded_mask(size, radius):
    mask = Image.new("L", size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=255)
    return mask


def phone(shot, width):
    screen = shot.convert("RGB").crop((0, STATUS_BAR, shot.width, shot.height))
    height = round(screen.height * width / screen.width)
    screen = screen.resize((width, height), Image.LANCZOS)
    bezel, radius = 16, 70
    size = (width + bezel * 2, height + bezel * 2)
    body = Image.new("RGBA", size, (0, 0, 0, 0))
    d = ImageDraw.Draw(body)
    d.rounded_rectangle([0, 0, size[0] - 1, size[1] - 1], radius, fill=BEZEL_EDGE)
    d.rounded_rectangle([3, 3, size[0] - 4, size[1] - 4], radius - 3, fill=BEZEL)
    inner = screen.convert("RGBA")
    inner.putalpha(rounded_mask(screen.size, radius - bezel))
    body.alpha_composite(inner, (bezel, bezel))
    return body


def shadowed(base, item, pos):
    blur = 40
    shadow = Image.new("RGBA", (item.width + blur * 4, item.height + blur * 4), (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 190), (blur * 2, blur * 2, blur * 2 + item.width, blur * 2 + item.height), item.split()[3])
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    base.alpha_composite(shadow, (pos[0] - blur * 2, pos[1] - blur * 2 + 24))
    base.alpha_composite(item, pos)


def centered(draw, y, text, fnt, fill):
    box = draw.textbbox((0, 0), text, font=fnt)
    draw.text(((W - (box[2] - box[0])) // 2 - box[0], y), text, font=fnt, fill=fill)


def build(raw_path, out_path):
    line1, line2, sub, accent = CAPTIONS[raw_path.name[:2]]
    img = background(accent)
    draw = ImageDraw.Draw(img)
    bold = font("segoeuib.ttf", 92)
    centered(draw, 92, line1, bold, WHITE)
    centered(draw, 200, line2, bold, accent)
    centered(draw, 330, sub, font("segoeui.ttf", 36), MUTED)
    frame = phone(Image.open(raw_path), 780)
    shadowed(img, frame, ((W - frame.width) // 2, 440))
    img.convert("RGB").save(out_path, optimize=True)


def main():
    raw, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    for path in sorted(raw.glob("0[1-5]_*.png")):
        build(path, out / path.name)
        print(path.name, Image.open(out / path.name).size)


if __name__ == "__main__":
    main()
