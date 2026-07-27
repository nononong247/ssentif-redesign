#!/usr/bin/env python3
"""캡처 이미지의 실명을 가운데 글자 마스킹(김O지)으로 덮어쓴다."""
from PIL import Image, ImageDraw, ImageFont

FONT = '/System/Library/Fonts/AppleSDGothicNeo.ttc'


def f(size, idx=2):
    return ImageFont.truetype(FONT, size, index=idx)


def patch(d, box, text, size, color=(40, 40, 40), bg=(255, 255, 255), idx=2):
    """box=(x0,y0,x1,y1) 를 bg로 덮고 text를 좌측정렬로 다시 그린다."""
    x0, y0, x1, y1 = box
    d.rectangle([x0, y0 - 3, x1, y1 + 3], fill=bg)
    font = f(size, idx)
    # 세로 중앙 맞춤
    a = d.textbbox((0, 0), text, font=font)
    ty = y0 + ((y1 - y0) - (a[3] - a[1])) // 2 - a[1]
    d.text((x0, ty), text, font=font, fill=color)


# ── 관리자 대시보드 ──────────────────────────────
im = Image.open('admin_dashboard.png').convert('RGB')
d = ImageDraw.Draw(im)

ROWS = [269, 369, 469, 569, 669]          # 각 행 타이틀 상단 y (실측)
NAMES = ['현O빈', 'sss', 'sss', '현O빈', '유O지']
NAME_W = [58, 40, 40, 58, 58]

for y, nm, nw in zip(ROWS, NAMES, NAME_W):
    patch(d, (256, y, 313, y + 20), '손O준', 25, idx=6)   # 코치명
    patch(d, (370, y, 370 + nw, y + 20), nm, 25, idx=6)   # 회원명

im.save('admin_dashboard_m.png')

# ── 강사 홈 ──────────────────────────────────────
im = Image.open('coach_home.png').convert('RGB')
d = ImageDraw.Draw(im)

patch(d, (150, 118, 200, 140), '손O준', 21, color=(120, 120, 120), bg=(248, 248, 246))
patch(d, (1871, 601, 1933, 625), '현O빈', 27)
patch(d, (207, 1540, 267, 1566), '김O수', 27,
      color=(150, 150, 150), bg=(244, 244, 242))

# 프로필 사진 → 중립 회색 원
d.rectangle([1796, 592, 1862, 658], fill=(255, 255, 255))
d.ellipse([1800, 596, 1858, 654], fill=(214, 214, 216))

im.save('coach_home_m.png')
print('masked')
