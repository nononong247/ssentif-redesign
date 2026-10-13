"""가이드 이미지 빌드 v3 (2026-09-17) — 세 가이드(강사/관리자/회원) 공용.

원칙: 쓸데없는 여백 없음. 모든 이미지는 캡처 후
  1) 다이얼로그는 바깥 barrier 를 잘라내고(trim)
  2) 비율 크롭(crop)을 적용한 뒤
  3) 가장자리의 단색 배경을 자동으로 걷어낸다(autotrim, pad 로 숨 쉴 여백만 남김)

실행:
  python3 build_guide_v3.py <coach_shots...> --member <member_shots> --out ~/ssentif-redesign/assets/guide
  캡처 폴더는 여러 개를 줄 수 있고 앞의 폴더가 우선한다.
"""

import argparse
import sys
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

MAX_W = 1600
MAX_H = 2200

ap = argparse.ArgumentParser()
ap.add_argument("coach", nargs="+")
ap.add_argument("--member", nargs="+", default=[])
ap.add_argument("--out", required=True)
ap.add_argument("--only", default=None, help="guide|admin|member")
ap.add_argument("--font", default=None, help="Pretendard-Bold.otf 경로(공유 다이얼로그 버튼 보정)")
args = ap.parse_args()
OUT = Path(args.out)


def find(dirs, name):
    for d in dirs:
        p = Path(d) / f"{name}.png"
        if p.exists():
            return p
    return None


def flatten_on_white(im):
    if im.mode in ("RGBA", "LA") or (im.mode == "P" and "transparency" in im.info):
        rgba = im.convert("RGBA")
        bg = Image.new("RGB", rgba.size, (255, 255, 255))
        bg.paste(rgba, mask=rgba.split()[-1])
        return bg
    return im.convert("RGB")


def _close(a, b, tol):
    return sum(abs(x - y) for x, y in zip(a, b)) <= tol


def _bounds(rgb, bg, tol, sides):
    """sides 방향마다 **그 가장자리의 색**을 배경으로 보고 걷어낸다.
    bg 를 주면 네 방향 모두 그 색을 쓴다(다이얼로그 barrier)."""
    w, h = rgb.size
    px = rgb.load()
    edge = {
        "t": bg or px[1, 1],
        "b": bg or px[1, h - 2],
        "l": bg or px[1, h // 2],
        "r": bg or px[w - 2, h // 2],
    }

    def row_bg(y, c):
        return all(_close(px[x, y], c, tol) for x in range(0, w, 3))

    def col_bg(x, c):
        return all(_close(px[x, y], c, tol) for y in range(0, h, 3))

    top, bottom, left, right = 0, h - 1, 0, w - 1
    if "t" in sides:
        while top < h - 1 and row_bg(top, edge["t"]):
            top += 1
    if "b" in sides:
        while bottom > top and row_bg(bottom, edge["b"]):
            bottom -= 1
    if "l" in sides:
        while left < w - 1 and col_bg(left, edge["l"]):
            left += 1
    if "r" in sides:
        while right > left and col_bg(right, edge["r"]):
            right -= 1
    return left, top, right, bottom


def trim_barrier(im, tol=12, pad=28):
    """다이얼로그 캡처 — 네 모서리가 같은 색(barrier)일 때만 그 색을 걷어낸다."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    bg = rgb.getpixel((2, 2))
    corners = [rgb.getpixel((w - 3, 2)), rgb.getpixel((2, h - 3)), rgb.getpixel((w - 3, h - 3))]
    if not all(_close(c, bg, tol) for c in corners):
        return im
    l, t, r, b = _bounds(rgb, bg, tol, "tblr")
    box = (max(0, l - pad), max(0, t - pad), min(w, r + 1 + pad), min(h, b + 1 + pad))
    if box[2] - box[0] < 80 or box[3] - box[1] < 80:
        return im
    return im.crop(box)


def whiten_barrier(im, tol=40):
    """barrier 를 잘라낸 뒤 카드 둘레에 남는 어두운 링을 흰색으로 메운다 —
    가장자리에서 이어진 barrier 색만 flood fill 하므로 카드 안쪽은 건드리지 않는다."""
    rgb = im.convert("RGB")
    w, h = rgb.size
    bg = rgb.getpixel((0, 0))
    if sum(bg) > 700:  # 이미 밝은 배경
        return rgb
    seeds = [(x, y) for x in range(0, w, 8) for y in (0, h - 1)] + \
            [(x, y) for y in range(0, h, 8) for x in (0, w - 1)]
    for sx, sy in seeds:
        if _close(rgb.getpixel((sx, sy)), bg, tol):
            ImageDraw.floodfill(rgb, (sx, sy), (255, 255, 255), thresh=tol)
    return rgb


def trim_sheet(im, tol=12):
    """하단 시트 — 위쪽 barrier(좌상단 색)만 걷어낸다."""
    rgb = im.convert("RGB")
    bg = rgb.getpixel((2, 2))
    l, t, r, b = _bounds(rgb, bg, tol, "t")
    return im.crop((0, max(0, t - 4), im.width, im.height))


def autotrim(im, tol=6, pad=0, sides="tblr"):
    """가장자리의 단색 배경(좌상단 색 기준)을 걷어낸다 — 빈 여백 제거."""
    rgb = im.convert("RGB")
    l, t, r, b = _bounds(rgb, None, tol, sides)
    w, h = im.size
    box = (max(0, l - pad), max(0, t - pad), min(w, r + 1 + pad), min(h, b + 1 + pad))
    if box[2] - box[0] < 60 or box[3] - box[1] < 60:
        return im
    return im.crop(box)


def fix_share_button(im):
    """회원앱 센터 공유 다이얼로그 — FilledButton 텍스트가 캡처에서 □ 로 찍히는
    (fontFamily 미지정) 자리에 실기기와 같은 '업로드' 를 다시 그린다."""
    if not args.font or not Path(args.font).exists():
        print("  (font 없음 — 공유 버튼 보정 생략)")
        return im
    rgb = im.convert("RGB")
    w, h = rgb.size
    px = rgb.load()
    mint = (31, 219, 168)
    # 화면 아래쪽 절반에서 민트 버튼의 bbox 를 찾는다(체크박스는 위쪽이라 제외).
    xs, ys = [], []
    for y in range(h // 2, h, 2):
        for x in range(0, w, 2):
            if _close(px[x, y], mint, 30):
                xs.append(x)
                ys.append(y)
    if not xs:
        return im
    l, t, r, b = min(xs), min(ys), max(xs), max(ys)
    if r - l < 120:
        return im
    # 버튼 안의 흰 글리프(□) 지우기
    draw = ImageDraw.Draw(rgb)
    inner = (l + 6, t + 6, r - 6, b - 6)
    for y in range(inner[1], inner[3]):
        for x in range(inner[0], inner[2]):
            if px[x, y][0] > 200 and px[x, y][1] > 200 and px[x, y][2] > 200:
                px[x, y] = mint
    font = ImageFont.truetype(args.font, 45)
    text = "업로드"
    bbox = draw.textbbox((0, 0), text, font=font)
    tw, th = bbox[2] - bbox[0], bbox[3] - bbox[1]
    draw.text(((l + r) / 2 - tw / 2 - bbox[0], (t + b) / 2 - th / 2 - bbox[1]), text, font=font, fill=(255, 255, 255))
    return rgb


def build(dirs, name, out, trim=False, sheet=False, crop=None, auto=True, pad=0, sides="tblr", post=None):
    src = find(dirs, name)
    if src is None:
        print(f"  MISSING {name}")
        return False
    im = flatten_on_white(Image.open(src))
    if trim:
        im = whiten_barrier(trim_barrier(im))
    if sheet:
        im = trim_sheet(im)
    if crop:
        l, t, r, b = crop
        im = im.crop((int(im.width * l), int(im.height * t), int(im.width * r), int(im.height * b)))
    if post:
        im = post(im)
    if auto:
        im = autotrim(im, pad=pad, sides=sides)
    if im.height > im.width * 2.6:
        im = im.crop((0, 0, im.width, int(im.width * 2.6)))
    if im.width > MAX_W:
        im = im.resize((MAX_W, round(im.height * MAX_W / im.width)), Image.LANCZOS)
    if im.height > MAX_H:
        im = im.resize((round(im.width * MAX_H / im.height), MAX_H), Image.LANCZOS)
    dst = OUT / out
    dst.parent.mkdir(parents=True, exist_ok=True)
    im.save(dst, optimize=True)
    print(f"{out:36s} {im.width}x{im.height}  {dst.stat().st_size // 1024}KB")
    return True


# 다이얼로그 캡처는 barrier 를 잘라낸 뒤 카드 그림자 여백까지 걷어낸다(pad 로 숨만).
D = {"trim": True, "pad": 10}
# 폰 전체 화면 — 좌우는 화면 그대로, 아래 빈 영역만 걷어낸다.
P = {"sides": "b"}

GUIDE = [
    ("login_portrait_social_light", "01-login.png", {"auto": False}),
    ("guide_signup", "02-signup.png", P),
    ("workspace_create_portrait", "03-workspace-create.png", {"crop": (0.0, 0.2, 1.0, 0.85), "pad": 24}),
    ("guide_modes_nav", "04-modes.png", {"auto": False}),
    ("guide_settings", "05-profile.png", P),
    ("guide_account_settings", "06-account.png", {"sides": "b", "pad": 36}),
    ("guide_chat", "07-chat.png", P),
    ("member_notices_screen", "08-notice.png", {"pad": 16}),
    ("guide_admin_memo_tablet", "09-memo.png", {}),
    ("coach_home_screen_light", "10-home.png", {}),
    ("guide_member_add", "11-member-add.png", D),
    ("guide_member_link_phone", "12-member-link.png", {"trim": True, "pad": 10}),
    ("guide_member_delete", "13-member-delete.png", D),
    ("guide_member_actions", "34-member-manage.png", D),
    ("grx_01_coach_editor", "35-rx-editor.png", P),
    ("grx_03_coach_comparison", "36-rx-compare.png", P),
    ("guide_products", "14-products.png", {"pad": 16}),
    ("guide_membership_issue", "15-membership-issue.png", D),
    ("membership_tab_light", "16-membership-tab.png", {"pad": 16}),
    ("guide_receipt_light", "17-membership-edit.png", {"crop": (772/2360, 40/1640, 1588/2360, 1600/1640), "post": whiten_barrier, "pad": 10}),
    ("schedule_create_dialog_light", "18-schedule-create.png", D),
    ("schedule_date_selection_repeat_light", "19-schedule-repeat.png", D),
    ("session_detail_dialog_light", "20-attendance.png", D),
    ("guide_exercise_library", "21-exercise-library.png", {"pad": 16}),
    ("custom_exercise_video_field_light", "22-custom-exercise.png", D),
    ("guide_class_log", "23-class-log.png", {"pad": 16}),
    ("previous_records_dialog_light", "24-previous-records.png", D),
    ("member_activity_feedback_tablet_light", "25-member-verify.png", D),
    ("guide_activity_daily", "26-activity-tab.png", {"pad": 16}),
    ("guide_activity_grid", "27-activity-grid.png", {"pad": 16}),
    ("session_tab_donut_light", "28-session-analysis.png", D),
    ("session_journal_cards_light", "29-session-journal.png", {**P, "pad": 12}),
    ("body_composition_charts_light", "30-body-composition.png", D),
    ("consultation_entry_mode_light", "31-consultation-entry.png", D),
    ("consultation_goals_light", "32-consultation-report.png", {"pad": 12}),
    ("member_pause_dialog_light", "33-member-pause.png", D),
]

ADMIN = [
    ("guide_admin_todo", "admin/todo.png", {"pad": 6}),
    ("guide_admin_alerts", "admin/alerts.png", {"pad": 6}),
    ("guide_admin_revenue", "admin/revenue.png", {"pad": 6}),
    ("guide_admin_members", "admin/all-members.png", {"pad": 16}),
    ("guide_deleted_members", "admin/deleted-members.png", {"sides": "b", "pad": 24}),
    ("guide_admin_products", "admin/products.png", {"pad": 16}),
    ("guide_admin_staff", "admin/staff.png", {"pad": 16}),
    ("guide_admin_staff_detail", "admin/staff-detail.png", {"pad": 16}),
    ("guide_admin_payroll", "admin/payroll.png", {"pad": 16}),
    ("guide_admin_payslip", "admin/payslip.png", {"pad": 16}),
    ("guide_admin_schedule_scope", "admin/schedule-scope.png", {"pad": 16}),
    ("guide_admin_center_hours", "admin/center-hours.png", {"pad": 16}),
    ("guide_admin_ai_agent", "admin/ai-agent.png", {"pad": 16}),
    ("signup_landscape", "admin/signup.png", {}),
    ("workspace_create_landscape", "admin/workspace-create.png", {"crop": (0.175, 0.195, 0.825, 0.87), "auto": False}),
    ("guide_admin_modes_tablet", "admin/modes.png", {}),
    ("guide_admin_settings_tablet", "admin/profile.png", {"pad": 16}),
    ("guide_admin_account_settings_tablet", "admin/account-settings.png", {"sides": "b", "pad": 36}),
    ("guide_admin_chat_tablet", "admin/chat.png", {"crop": (0.0, 0.0, 1.0, 0.62), "auto": False}),
    ("guide_admin_memo_tablet", "admin/memo.png", {}),
    ("member_notices_screen", "admin/notice.png", {"pad": 16}),
]

MEMBER = [
    ("signup_light", "member/01-signup.png", P),
    ("my_link_code_light", "member/02-connect.png", {**P, "pad": 24}),
    ("guide_member_home", "member/03-home.png", {"auto": False}),
    ("schedule_tab_linked_light", "member/04-schedule.png", P),
    ("guide_member_log", "member/05-log.png", {**P, "pad": 16}),
    ("exercise_recording_overview", "member/06-activity.png", P),
    ("guide_member_diet", "member/07-diet.png", P),
    ("guide_member_body_composition", "member/08-body-composition.png", P),
    ("guide_member_body_photo", "member/09-body-photo.png", P),
    ("stats_body_composition_light", "member/10-stats.png", P),
    ("chat_empty_light", "member/11-chat.png", P),
    ("guide_member_notice", "member/12-notice.png", {**P, "pad": 24}),
    ("guide_member_products", "member/13-products.png", {**P, "pad": 24}),
    ("guide_member_settings", "member/14-profile.png", P),
    ("guide_member_withdrawal", "member/15-withdrawal.png", P),
    ("guide_member_reserve", "member/16-reserve.png", P),
    ("guide_member_change", "member/17-change.png", D),
    ("guide_checkin_qr_light", "member/18-checkin.png", {"sheet": True}),
    ("guide_member_share", "member/19-share.png", D),
    ("grx_02_member_detail_pending", "member/20-rx-detail.png", P),
    ("grx_03b_member_detail_completed", "member/21-rx-done.png", P),
]

missing = []
if args.only in (None, "guide"):
    print("== guide.html")
    missing += [n for n, o, k in GUIDE if not build(args.coach, n, o, **k)]
if args.only in (None, "admin"):
    print("== guide-admin.html")
    missing += [n for n, o, k in ADMIN if not build(args.coach, n, o, **k)]
if args.only in (None, "member"):
    print("== guide-member.html")
    missing += [n for n, o, k in MEMBER if not build(args.member, n, o, **k)]
print("\nMISSING:", missing or "none")
sys.exit(1 if missing else 0)
