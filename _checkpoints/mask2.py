#!/usr/bin/env python3
"""STEP 캡처용 마스킹 — 좌표는 computer-use 스크린샷(1372x882) 기준."""
from PIL import Image, ImageDraw, ImageFont
from compose import R

FONT = '/System/Library/Fonts/AppleSDGothicNeo.ttc'


def put(im, sx0, sy0, sx1, sy1, text, size, bold=True,
        color=(40, 40, 40), bg=(255, 255, 255)):
    d = ImageDraw.Draw(im)
    x0, y0 = R(sx0, sy0)
    x1, y1 = R(sx1, sy1)
    d.rectangle([x0, y0, x1, y1], fill=bg)
    if not text:
        return
    f = ImageFont.truetype(FONT, size, index=6 if bold else 2)
    a = d.textbbox((0, 0), text, font=f)
    ty = y0 + ((y1 - y0) - (a[3] - a[1])) // 2 - a[1]
    d.text((x0, ty), text, font=f, fill=color)


# ── 회원 기본 정보 탭 ──
im = Image.open('member_info.png').convert('RGB')
put(im, 428, 306, 478, 326, '현O빈', 30)                      # 이름 값
put(im, 429, 345, 512, 361, '010-4015-****', 30)              # 연락처 값
put(im, 735, 316, 800, 341, '현O빈', 26, bg=(244, 244, 245))                      # 상담기록 이름
im.save('member_info_m.png')

# ── 회원 활동 탭 ──
im = Image.open('member_activity.png').convert('RGB')
put(im, 838, 358, 863, 368, '현O빈', 20, bg=(255, 255, 255))
im.save('member_activity_m.png')

# ── 급여 정산 ──
im = Image.open('payroll.png').convert('RGB')
put(im, 246, 345, 274, 355, '정O훈', 20, bg=(255, 255, 255))
put(im, 437, 345, 465, 355, '손O준', 20, bg=(255, 255, 255))
im.save('payroll_m.png')
print('masked2')
