#!/usr/bin/env python3
"""앱 캡처에서 부분 영역을 잘라 세로로 합성해 STEP 카드용 이미지를 만든다.

좌표는 computer-use 전체화면 스크린샷(1372x882) 기준으로 적는다.
창 원점(152,117) / 스케일 2.494 로 실제 캡처 좌표에 변환된다.
"""
from PIL import Image, ImageDraw

S = 2.494
OX, OY = 152, 117
BG = (247, 247, 245)


def R(sx, sy):
    return round((sx - OX) * S), round((sy - OY) * S)


def piece(src, x0, y0, x1, y1, radius=0):
    a, b = R(x0, y0), R(x1, y1)
    im = Image.open(src).convert('RGB').crop((*a, *b))
    if radius:
        im = round_corners(im, radius)
    return im


def round_corners(im, r):
    im = im.convert('RGBA')
    mask = Image.new('L', im.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle([0, 0, im.size[0] - 1, im.size[1] - 1],
                                           radius=r, fill=255)
    out = Image.new('RGBA', im.size, (0, 0, 0, 0))
    out.paste(im, (0, 0), mask)
    return out


def stack(pieces, width, gap=26, pad=26, bg=BG):
    """조각들을 width에 맞춰 확대/축소한 뒤 세로로 쌓는다."""
    scaled = []
    inner = width - pad * 2
    for p in pieces:
        w, h = p.size
        nh = round(h * inner / w)
        scaled.append(p.resize((inner, nh), Image.LANCZOS))
    total = pad * 2 + sum(p.size[1] for p in scaled) + gap * (len(scaled) - 1)
    canvas = Image.new('RGB', (width, total), bg)
    y = pad
    for p in scaled:
        if p.mode == 'RGBA':
            canvas.paste(p, (pad, y), p)
        else:
            canvas.paste(p, (pad, y))
        y += p.size[1] + gap
    return canvas


def row(pieces, width, gap=20, pad=26, bg=BG):
    """조각들을 가로로 나란히 (높이 통일)."""
    inner = width - pad * 2
    unit = (inner - gap * (len(pieces) - 1)) // len(pieces)
    scaled = [p.resize((unit, round(p.size[1] * unit / p.size[0])), Image.LANCZOS)
              for p in pieces]
    h = max(p.size[1] for p in scaled)
    canvas = Image.new('RGB', (width, h + pad * 2), bg)
    x = pad
    for p in scaled:
        if p.mode == 'RGBA':
            canvas.paste(p, (x, pad), p)
        else:
            canvas.paste(p, (x, pad))
        x += unit + gap
    return canvas
