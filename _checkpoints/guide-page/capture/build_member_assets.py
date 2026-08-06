import sys
from pathlib import Path
from PIL import Image

SRC = Path(sys.argv[1])
DST = Path(sys.argv[2])
DST.mkdir(parents=True, exist_ok=True)

MAX_W = 1600
MAX_H = 2200

def build(name, out, crop=None):
    src = SRC / f"{name}.png"
    if not src.exists():
        print(f"  MISSING {name}")
        return False
    im = Image.open(src).convert("RGB")
    if crop:
        l, t, r, b = crop
        im = im.crop((int(im.width * l), int(im.height * t),
                      int(im.width * r), int(im.height * b)))
    if im.height > im.width * 2.6:
        im = im.crop((0, 0, im.width, int(im.width * 2.6)))
    if im.width > MAX_W:
        im = im.resize((MAX_W, round(im.height * MAX_W / im.width)), Image.LANCZOS)
    if im.height > MAX_H:
        im = im.resize((round(im.width * MAX_H / im.height), MAX_H), Image.LANCZOS)
    dst = DST / f"{out}.png"
    im.save(dst, optimize=True)
    print(f"{dst.name:28s} {im.width}x{im.height}  {dst.stat().st_size // 1024}KB")
    return True

JOBS = [
    ("signup_light", "01-signup", None),
    ("my_link_code_light", "02-connect", None),
    ("guide_member_home", "03-home", None),
    ("schedule_tab_linked_light", "04-schedule", None),
    ("session_log_detail_full", "05-log", (0.0, 0.335, 1.0, 1.0)),
    ("exercise_recording_overview", "06-activity", None),
    ("guide_member_diet", "07-diet", None),
    ("guide_member_body_composition", "08-body-composition", None),
    ("guide_member_body_photo", "09-body-photo", None),
    ("stats_body_composition_light", "10-stats", None),
    ("chat_empty_light", "11-chat", None),
    ("guide_member_notice", "12-notice", None),
    ("guide_member_products", "13-products", None),
    ("guide_member_settings", "14-profile", None),
    ("guide_member_withdrawal", "15-withdrawal", (0.0, 0.0, 1.0, 0.93)),
]

missing = [name for name, out, crop in JOBS if not build(name, out, crop)]
print("\nMISSING:", missing or "none")
