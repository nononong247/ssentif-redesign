# -*- coding: utf-8 -*-
"""센티프 1.0 이전 안내 페이지용 이미지 빌드.

/tmp/shots 의 캡처를 잘라 ~/ssentif-redesign/assets/guide/migration/ 으로 넣는다.
"""
import sys
from pathlib import Path
from PIL import Image

SRC = Path('/tmp/shots')
DST = Path.home() / 'ssentif-redesign/assets/guide/migration'
DST.mkdir(parents=True, exist_ok=True)

MAX_W, MAX_H = 1200, 1800


def trim_barrier(im, tol=12):
    """다이얼로그 캡처 바깥의 반투명 barrier 를 잘라낸다."""
    rgb = im.convert('RGB')
    w, h = rgb.size
    bg = rgb.getpixel((2, 2))
    corners = [rgb.getpixel(p) for p in
               [(2, 2), (w - 3, 2), (2, h - 3), (w - 3, h - 3)]]
    if any(sum(abs(a - b) for a, b in zip(c, bg)) > tol for c in corners):
        return im  # 네 모서리 색이 다르면 barrier 가 아니다
    left, right, top, bottom = 0, w - 1, 0, h - 1
    def row_is_bg(y):
        return all(sum(abs(a - b) for a, b in zip(rgb.getpixel((x, y)), bg)) <= tol
                   for x in range(0, w, 4))
    def col_is_bg(x):
        return all(sum(abs(a - b) for a, b in zip(rgb.getpixel((x, y)), bg)) <= tol
                   for y in range(0, h, 4))
    while top < bottom and row_is_bg(top): top += 1
    while bottom > top and row_is_bg(bottom): bottom -= 1
    while left < right and col_is_bg(left): left += 1
    while right > left and col_is_bg(right): right -= 1
    pad = 6
    return im.crop((max(0, left - pad), max(0, top - pad),
                    min(w, right + 1 + pad), min(h, bottom + 1 + pad)))


def trim_bottom_blank(im, tol=6, keep=40):
    """세로 폰 캡처 아래쪽 빈 여백을 줄인다(하단 CTA 는 남긴다)."""
    return im  # 하단 액션바가 있어 자르지 않는다


# (원본, 결과, barrier 트림, 트림 후 가로 비율 크롭(x0,x1) 또는 None)
JOBS = [
    # 3·4 단계는 같은 캡처를 나눠 쓴다 — 설정 전체 / 가져오기 패널
    ('workspace_settings_v1_import_light.png', '03-settings.png',    True, None),
    ('workspace_settings_v1_import_light.png', '04-import-menu.png', True, (0.33, 1.0)),
    ('guide_migration_05_identity.png',        '05-email.png',       False, None),
    ('guide_migration_06_members.png',         '06-members.png',     False, None),
    ('v1_import_result_light.png',             '07-done.png',        False, None),
]

for src, out, trim, xcrop in JOBS:
    p = SRC / src
    if not p.exists():
        print('없음:', p); sys.exit(1)
    im = Image.open(p)
    if trim:
        im = trim_barrier(im)
    if xcrop:
        w, h = im.size
        im = im.crop((int(w * xcrop[0]), 0, int(w * xcrop[1]), h))
    im.thumbnail((MAX_W, MAX_H), Image.LANCZOS)
    im = im.convert('RGB')
    target = DST / out
    im.save(target, 'PNG', optimize=True)
    print(f'{out:22s} {im.size[0]}x{im.size[1]}  {target.stat().st_size // 1024}KB')
