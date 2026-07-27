#!/usr/bin/env python3
"""제품 페이지용 캡처 마스킹 (전체회원 테이블 / 강사홈 / 관리자 대시보드)."""
from PIL import Image, ImageDraw, ImageFont
from compose import R

FONT = '/System/Library/Fonts/AppleSDGothicNeo.ttc'


def put(im, sx0, sy0, sx1, sy1, text, size, bold=True, center=False,
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
    tx = x0 + ((x1 - x0) - (a[2] - a[0])) // 2 - a[0] if center else x0
    d.text((tx, ty), text, font=f, fill=color)


# ── 관리자 전체 회원 테이블 ───────────────────────
im = Image.open('admin_members.png').convert('RGB')
ROWS = [(258, 269), (283, 294), (309, 320), (335, 346), (361, 372),
        (387, 398), (413, 424), (439, 450), (465, 476), (491, 502)]
NAMES = ['sss', '김O지', '박O호', '손O화', '손O민',
         '양O지', '오O서', '이O현', '최O연', '현O빈']
COACH = ['손O준'] * 5 + ['정O훈'] * 2 + ['손O준'] * 3
PHONE = ['010-1234-****', '010-1234-****', '', '010-9436-****',
         '010-7788-****', '', '', '', '011-2345-****', '010-4015-****']

for (y0, y1), nm, co, ph in zip(ROWS, NAMES, COACH, PHONE):
    put(im, 296, y0, 346, y1, nm, 21, center=True)
    put(im, 462, y0, 497, y1, co, 20, center=True, color=(120, 120, 120))
    if ph:
        put(im, 578, y0, 656, y1, ph, 20, center=True, color=(90, 90, 90))
im.save('admin_members_m.png')

# ── 강사 홈(데이터 채워진 버전) ───────────────────
im = Image.open('coach_home2.png').convert('RGB')
put(im, 212, 165, 240, 175, '손O준', 18, color=(120, 120, 120), bg=(248, 248, 246))

# 업무 알림 5행 회원명 (제목 라인 실측)
for y0, nm in zip((359, 397, 435, 472, 510),
                  ('현O빈', '박O호', '손O민', '김O지', '이O현')):
    put(im, 604, y0 - 1, 634, y0 + 9, nm, 21)

# 회원 인증 — 이름 + 프로필 사진
put(im, 901, 358, 934, 369, '현O빈', 21)
d = ImageDraw.Draw(im)
d.rectangle([*R(870, 355), *R(899, 387)], fill=(255, 255, 255))
d.ellipse([*R(873, 358), *R(897, 382)], fill=(214, 214, 216))

# AI 입력창 플레이스홀더
put(im, 235, 738, 262, 750, '김O수', 21, color=(150, 150, 150), bg=(244, 244, 242))
im.save('coach_home2_m.png')
print('masked3')

# ── 관리자 대시보드(데이터 갱신본) ─────────────────
im = Image.open('admin_dash2.png').convert('RGB')
ROWS2 = [269, 369, 469, 569, 669]
NAMES2 = ['현O빈', 'sss', 'sss', '현O빈', '최O연']
WIDTH2 = [58, 40, 40, 58, 58]
d = ImageDraw.Draw(im)
f25 = ImageFont.truetype(FONT, 25, index=6)
for y, nm, nw in zip(ROWS2, NAMES2, WIDTH2):
    d.rectangle([256, y, 313, y + 20], fill=(255, 255, 255))
    d.text((256, y - 1), '손O준', font=f25, fill=(40, 40, 40))
    d.rectangle([370, y, 370 + nw, y + 20], fill=(255, 255, 255))
    d.text((370, y - 1), nm, font=f25, fill=(40, 40, 40))
im.save('admin_dash2_m.png')

# ── 수업 기록 / 신체변화 헤더 이름 ─────────────────
im = Image.open('class_record.png').convert('RGB')
put(im, 254, 165, 288, 179, '현O빈', 23, bg=(250, 250, 249))
im.save('class_record_m.png')

im = Image.open('member_body.png').convert('RGB')
put(im, 432, 164, 488, 187, '현O빈', 26)                       # 헤더 이름
put(im, 432, 187, 545, 200, '여성 · 010-4015-****', 17,
    bold=False, color=(120, 120, 120))                        # 성별·연락처
_d = ImageDraw.Draw(im)                                        # 아바타 이니셜 제거
_d.rectangle([*R(415, 163), *R(431, 200)], fill=(255, 255, 255))
_d.ellipse([*R(416, 166), *R(430, 195)], fill=(214, 214, 216))
im.save('member_body_m.png')

# ── 주간 일정 블록 이름 (흰 텍스트 실측 기준) ──────
im = Image.open('sched_week.png').convert('RGB')
BLOCKS = [(641.6, 325.9, '현O빈'), (248.2, 477.9, '현O빈'), (510.5, 542.8, '유O지'),
          (248.2, 608.2, '유O지'), (510.5, 608.2, '유O지'), (772.7, 586.1, '유O지')]
for bx, by, nm in BLOCKS:
    bg = im.getpixel(R(bx + 40, by + 1))          # 블록 배경색 샘플링
    put(im, bx - 1, by - 2, bx + 25, by + 9, nm, 16, color=(255, 255, 255), bg=bg)
im.save('sched_week_m.png')

# ── 회원 상세 공통 헤더(활동 탭) ───────────────────
im = Image.open('member_activity_m.png').convert('RGB')
put(im, 432, 164, 488, 187, '현O빈', 26)
put(im, 432, 187, 545, 200, '여성 · 010-4015-****', 17,
    bold=False, color=(120, 120, 120))
_d = ImageDraw.Draw(im)
_d.rectangle([*R(415, 163), *R(431, 200)], fill=(255, 255, 255))
_d.ellipse([*R(416, 166), *R(430, 195)], fill=(214, 214, 216))
im.save('member_activity_m.png')

print('masked3b')
