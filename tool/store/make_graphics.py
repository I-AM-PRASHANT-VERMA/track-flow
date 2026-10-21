"""Builds the Play Store / GitHub graphics from the real app icon and a real
screenshot, so the listing always matches the app.

Usage (from the repo root):
    python tool/store/make_graphics.py <canvas_screenshot.png> <out_dir>

Writes playstore_icon_512.png, feature_graphic_1024x500.png and
banner_github_1280x640.png into <out_dir>.
"""
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFilter, ImageFont

ROOT = Path(__file__).resolve().parents[2]
ICON = ROOT / "assets" / "images" / "app_logo.png"
FONTS = Path("C:/Windows/Fonts")
BG_TOP = (6, 8, 14)
BG_BOTTOM = (20, 24, 58)
WHITE = (244, 244, 245)
MUTED = (160, 160, 176)
ACCENT = (27, 179, 131)


def font(name, size):
    return ImageFont.truetype(str(FONTS / name), size)


def gradient(size):
    w, h = size
    img = Image.new("RGB", size)
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / max(1, h - 1)
        draw.line([(0, y), (w, y)], fill=tuple(int(a + (b - a) * t) for a, b in zip(BG_TOP, BG_BOTTOM)))
    return img


def rounded(img, radius):
    mask = Image.new("L", img.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, img.size[0] - 1, img.size[1] - 1], radius, fill=255)
    out = img.convert("RGBA")
    out.putalpha(mask)
    return out


def paste_with_shadow(base, item, pos, blur=18, offset=8):
    shadow = Image.new("RGBA", (item.width + blur * 4, item.height + blur * 4), (0, 0, 0, 0))
    shadow.paste((0, 0, 0, 170), (blur * 2, blur * 2, blur * 2 + item.width, blur * 2 + item.height), item.split()[3])
    shadow = shadow.filter(ImageFilter.GaussianBlur(blur))
    base.paste(shadow, (pos[0] - blur * 2, pos[1] - blur * 2 + offset), shadow)
    base.paste(item, pos, item)


def play_icon(out):
    icon = Image.open(ICON).convert("RGBA")
    # Fill the transparent rounded corners with the icon's own edge colour:
    # Google Play applies its own corner mask to a full square.
    edge = icon.getpixel((icon.width // 2, 6))
    square = Image.new("RGBA", icon.size, edge[:3] + (255,))
    square.alpha_composite(icon)
    square.convert("RGB").resize((512, 512), Image.LANCZOS).save(out / "playstore_icon_512.png", optimize=True)


def promo(size, canvas_shot, out_path):
    w, h = size
    scale = h / 500
    img = gradient(size).convert("RGBA")

    # Real UI on the right: the 365-day canvas card from a release screenshot.
    shot = Image.open(canvas_shot).convert("RGBA")
    card = shot.crop((44, 684, 1036, 1160))
    card_w = int(w * 0.46)
    card = card.resize((card_w, int(card.height * card_w / card.width)), Image.LANCZOS)
    card = rounded(card, int(18 * scale))
    paste_with_shadow(img, card, (w - card_w - int(48 * scale), (h - card.height) // 2))

    # Brand on the left.
    icon_size = int(112 * scale)
    icon = Image.open(ICON).convert("RGBA").resize((icon_size, icon_size), Image.LANCZOS)
    x0 = int(56 * scale)
    y0 = int(96 * scale)
    paste_with_shadow(img, icon, (x0, y0), blur=10, offset=4)

    draw = ImageDraw.Draw(img)
    draw.text((x0, y0 + icon_size + int(26 * scale)), "TrackFlow", font=font("segoeuib.ttf", int(64 * scale)), fill=WHITE)
    draw.text((x0, y0 + icon_size + int(110 * scale)), "Build habits that stick.", font=font("segoeuib.ttf", int(28 * scale)), fill=ACCENT)
    draw.text(
        (x0, y0 + icon_size + int(152 * scale)),
        "Offline. One-tap check-ins.\nStreaks and a year at a glance.",
        font=font("segoeui.ttf", int(21 * scale)),
        fill=MUTED,
        spacing=int(6 * scale),
    )
    img.convert("RGB").save(out_path, optimize=True)


def main():
    canvas_shot, out = Path(sys.argv[1]), Path(sys.argv[2])
    out.mkdir(parents=True, exist_ok=True)
    play_icon(out)
    promo((1024, 500), canvas_shot, out / "feature_graphic_1024x500.png")
    promo((1280, 640), canvas_shot, out / "banner_github_1280x640.png")
    for f in sorted(out.glob("*.png")):
        print(f.name, Image.open(f).size)


if __name__ == "__main__":
    main()
