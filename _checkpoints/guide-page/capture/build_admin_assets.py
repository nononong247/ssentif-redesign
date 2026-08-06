import sys
from pathlib import Path
from PIL import Image

SRC = Path(sys.argv[1])
DST = Path(sys.argv[2])
DST.mkdir(parents=True, exist_ok=True)

MAX_W = 1600
MAX_H = 2200


def trim_barrier(im, tol=10):
    rgb = im.convert("RGB")
    w, h = rgb.size
    bg = rgb.getpixel((2, 2))
    corners = [
        rgb.getpixel((2, 2)),
        rgb.getpixel((w - 3, 2)),
        rgb.getpixel((2, h - 3)),
        rgb.getpixel((w - 3, h - 3)),
    ]
    if any(sum(abs(a - b) for a, b in zip(c, bg)) > tol for c in corners):
        return im
    px = rgb.load()

    def row_bg(y):
        return all(sum(abs(a - b) for a, b in zip(px[x, y], bg)) <= tol
                   for x in range(0, w, 4))

    def col_bg(x):
        return all(sum(abs(a - b) for a, b in zip(px[x, y], bg)) <= tol
                   for y in range(0, h, 4))

    top = 0
    while top < h - 1 and row_bg(top):
        top += 1
    bottom = h - 1
    while bottom > top and row_bg(bottom):
        bottom -= 1
    left = 0
    while left < w - 1 and col_bg(left):
        left += 1
    right = w - 1
    while right > left and col_bg(right):
        right -= 1

    pad = 28
    box = (max(0, left - pad), max(0, top - pad),
           min(w, right + 1 + pad), min(h, bottom + 1 + pad))
    if box[2] - box[0] < 80 or box[3] - box[1] < 80:
        return im
    return im.crop(box)


def flatten_on_white(im):
    """RGBA → RGB. 카드 위젯(size: 캡처)은 라운드 모서리 바깥이 실제로
    투명이라 alpha 를 그냥 버리면(PIL 기본 convert) 그 자리 RGB 저장값(보통
    0,0,0)이 그대로 남아 모서리가 검게 나온다 — 흰 배경에 먼저 합성한다."""
    if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
        rgba = im.convert("RGBA")
        bg = Image.new("RGB", rgba.size, (255, 255, 255))
        bg.paste(rgba, mask=rgba.split()[-1])
        return bg
    return im.convert("RGB")


def build(name, out, trim=False, crop=None):
    src = SRC / f"{name}.png"
    if not src.exists():
        print(f"  MISSING {name}")
        return False
    im = flatten_on_white(Image.open(src))
    if trim:
        im = trim_barrier(im)
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
    print(f"{dst.name:26s} {im.width}x{im.height}  {dst.stat().st_size // 1024}KB")
    return True


JOBS = [
    ("guide_admin_dashboard", "dashboard-overview", {}),
    ("guide_admin_alerts", "alerts", {}),
    ("guide_admin_revenue", "revenue", {}),
    ("guide_admin_risk", "risk", {}),
    ("guide_admin_members", "all-members", {}),
    # 아래 4개는 콘텐츠가 화면 상단 일부만 채우고 나머지가 빈 배경으로 남아
    # trim 으로 실제 콘텐츠 영역까지 좁힌다(2026-08-06).
    ("guide_admin_products", "products", {"trim": True}),
    ("guide_admin_staff", "staff", {"trim": True}),
    ("guide_admin_staff_detail", "staff-detail", {}),
    ("guide_admin_payroll", "payroll", {}),
    ("guide_admin_payslip", "payslip", {"trim": True}),
    ("guide_admin_schedule_scope", "schedule-scope", {}),
    ("guide_admin_center_hours", "center-hours", {"trim": True}),
    ("guide_admin_ai_agent", "ai-agent", {}),
    # 공통 8개 — 2026-08-06 전면 태블릿 재작업(guide-admin.html 전용, guide.html 원본 미변경)
    ("login_screen", "login", {}),
    ("signup_landscape", "signup", {}),
    ("workspace_create_landscape", "workspace-create", {}),
    ("guide_admin_modes_tablet", "modes", {}),
    ("guide_admin_settings_tablet", "profile", {"trim": True}),
    ("guide_admin_account_settings_tablet", "account-settings", {}),
    ("guide_admin_chat_tablet", "chat", {}),
    ("guide_admin_memo_tablet", "memo", {}),
    ("member_notices_screen", "notice", {}),
]

missing = [name for name, out, opts in JOBS if not build(name, out, **opts)]
print("\nMISSING:", missing or "none")
