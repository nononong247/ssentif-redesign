#!/usr/bin/env python3
"""로컬 개발 서버 — 캐시 없이 항상 최신 파일을 준다.

`python3 -m http.server` 는 Cache-Control 헤더를 보내지 않아서, 브라우저가
HTML을 멋대로 캐싱한다. 그러면 파일을 고쳐도 탭을 전환할 때 옛날 화면이
그대로 뜨는 일이 생긴다. (라이브(Vercel)는 vercel.json 의 must-revalidate
덕분에 이 문제가 없다 — 로컬 미리보기에서만 생기는 증상이다.)

사용법:
    python3 dev-server.py          # → http://127.0.0.1:8990
    python3 dev-server.py 9000     # 포트 지정
"""

import sys
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

PORT = int(sys.argv[1]) if len(sys.argv) > 1 else 8990


class NoCacheHandler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cache-Control', 'no-store, no-cache, must-revalidate, max-age=0')
        self.send_header('Pragma', 'no-cache')
        self.send_header('Expires', '0')
        super().end_headers()

    def log_message(self, fmt, *args):
        # 요청 로그는 조용히 (에러만 보고 싶을 때 주석 해제)
        pass


if __name__ == '__main__':
    handler = partial(NoCacheHandler, directory='.')
    with ThreadingHTTPServer(('127.0.0.1', PORT), handler) as httpd:
        print(f'개발 서버 실행 중 (캐시 비활성) → http://127.0.0.1:{PORT}')
        print('종료: Ctrl+C')
        try:
            httpd.serve_forever()
        except KeyboardInterrupt:
            print('\n종료됨')
