#!/usr/bin/env python3
"""창 단위 캡처 — 다른 창에 가려져 있어도 해당 창의 버퍼만 찍는다.
usage: capwin.py <owner-name-substring> <out.png>
       capwin.py --list
"""
import sys
import Quartz
from Quartz import (
    CGWindowListCopyWindowInfo,
    kCGWindowListOptionOnScreenOnly,
    kCGWindowListExcludeDesktopElements,
    kCGNullWindowID,
)


def windows():
    opts = kCGWindowListOptionOnScreenOnly | kCGWindowListExcludeDesktopElements
    return CGWindowListCopyWindowInfo(opts, kCGNullWindowID) or []


def main():
    if sys.argv[1] == '--list':
        for w in windows():
            b = w.get('kCGWindowBounds', {})
            print(f"{w.get('kCGWindowNumber')}\t{w.get('kCGWindowOwnerName')}\t"
                  f"{w.get('kCGWindowName')}\t{int(b.get('Width',0))}x{int(b.get('Height',0))}"
                  f"\tlayer={w.get('kCGWindowLayer')}")
        return

    import unicodedata

    def norm(s):
        return unicodedata.normalize('NFC', s or '').lower()

    needle, out = norm(sys.argv[1]), sys.argv[2]
    cands = [w for w in windows()
             if needle in norm(w.get('kCGWindowOwnerName')) + ' ' + norm(w.get('kCGWindowName'))
             and w.get('kCGWindowLayer') == 0
             and w.get('kCGWindowBounds', {}).get('Width', 0) > 200]
    if not cands:
        print('no window found', file=sys.stderr)
        sys.exit(1)
    cands.sort(key=lambda w: -(w['kCGWindowBounds']['Width'] * w['kCGWindowBounds']['Height']))
    wid = cands[0]['kCGWindowNumber']

    img = Quartz.CGWindowListCreateImage(
        Quartz.CGRectNull,
        Quartz.kCGWindowListOptionIncludingWindow,
        wid,
        Quartz.kCGWindowImageBoundsIgnoreFraming | Quartz.kCGWindowImageNominalResolution
        if False else Quartz.kCGWindowImageBoundsIgnoreFraming,
    )
    if img is None:
        print('capture failed', file=sys.stderr)
        sys.exit(2)

    url = Quartz.CFURLCreateWithFileSystemPath(None, out, Quartz.kCFURLPOSIXPathStyle, False)
    dest = Quartz.CGImageDestinationCreateWithURL(url, 'public.png', 1, None)
    Quartz.CGImageDestinationAddImage(dest, img, None)
    Quartz.CGImageDestinationFinalize(dest)
    print(f'{out} {Quartz.CGImageGetWidth(img)}x{Quartz.CGImageGetHeight(img)}')


main()
