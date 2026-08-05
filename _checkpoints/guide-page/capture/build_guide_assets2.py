"""가이드 이미지 빌드 v2 — 최신 앱 캡처 기준.

- 다이얼로그 캡처의 바깥 barrier 를 자동으로 잘라낸다.
- 일부 이미지는 잘라낼 영역을 명시한다(헤더 tofu, 하단 버튼 tofu 등).
"""

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


def build(name, out, trim=False, crop=None):
    """crop: (left%, top%, right%, bottom%) 비율 크롭."""
    src = SRC / f"{name}.png"
    if not src.exists():
        print(f"  MISSING {name}")
        return False
    im = Image.open(src).convert("RGB")
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
    ("login_portrait_social_light", "01-login", {}),
    ("guide_signup", "02-signup", {}),
    # 카드 주변 여백이 화면의 절반이라 카드 기준으로 좁힌다.
    ("workspace_create_portrait", "03-workspace-create",
     {"crop": (0.146, 0.051, 0.854, 0.850)}),
    ("portrait_nav_coach_phone_light", "04-modes", {}),
    ("guide_settings", "05-profile", {}),
    ("guide_account_settings", "06-account", {}),
    ("guide_chat", "07-chat", {}),
    ("member_notices_screen", "08-notice", {}),
    ("memo_editor_attachments_light", "09-memo", {}),
    ("coach_home_screen_light", "10-home", {}),
    ("guide_member_add", "11-member-add", {"trim": True}),
    # 하단 시트 — barrier 가 위쪽만 검정이라 자동 트림이 걸리지 않는다.
    ("guide_member_link", "12-member-link", {"crop": (0.0, 0.0, 1.0, 0.415)}),
    ("info_tab_delete_light", "13-member-delete", {}),
    ("guide_products", "14-products", {}),
    ("guide_membership_issue", "15-membership-issue", {"trim": True}),
    ("membership_tab_light", "16-membership-tab", {}),
    ("membership_payment_edit_light", "17-membership-edit", {"trim": True}),
    ("schedule_create_dialog_light", "18-schedule-create", {"trim": True}),
    ("schedule_date_selection_repeat_light", "19-schedule-repeat", {"trim": True}),
    ("session_detail_dialog_light", "20-attendance", {"trim": True}),
    ("guide_exercise_library", "21-exercise-library", {}),
    ("custom_exercise_video_field_light", "22-custom-exercise", {"trim": True}),
    ("guide_class_log", "23-class-log", {}),
    ("previous_records_dialog_light", "24-previous-records", {"trim": True}),
    ("member_activity_feedback_tablet_light", "25-member-verify", {"trim": True}),
    ("guide_activity_daily", "26-activity-tab", {}),
    ("guide_activity_grid", "27-activity-grid", {}),
    ("session_tab_donut_light", "28-session-analysis", {}),
    ("session_journal_cards_light", "29-session-journal", {}),
    ("body_composition_charts_light", "30-body-composition", {}),
    ("consultation_entry_mode_light", "31-consultation-entry", {"trim": True}),
    ("consultation_goals_light", "32-consultation-report", {}),
    ("member_pause_dialog_light", "33-member-pause", {"trim": True}),
]

missing = [name for name, out, opts in JOBS if not build(name, out, **opts)]
print("\nMISSING:", missing or "none")
