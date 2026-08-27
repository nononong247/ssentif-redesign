/* 마크다운 → HTML 변환기 — 운영지원실 아티클 본문 전용.
   관리자 미리보기(admin/lab.html)와 공개 페이지(article.html)가 이 파일을 함께 쓴다.
   둘이 같은 렌더러를 써야 "쓸 때 본 모양 = 실제 발행된 모양"이 어긋나지 않는다.

   보안: 블록 구조를 먼저 해석한 뒤 텍스트를 이스케이프하므로,
   본문에 <script> 같은 태그를 적어도 글자 그대로 출력될 뿐 실행되지 않는다. */
(function (global) {
  'use strict';

  function esc(s) {
    return String(s)
      .replace(/&/g, '&amp;').replace(/</g, '&lt;')
      .replace(/>/g, '&gt;').replace(/"/g, '&quot;');
  }

  /* javascript: 같은 실행 가능한 스킴을 막는다. 허용한 형태가 아니면 무해한 #으로 바꾼다. */
  function safeUrl(u) {
    var t = String(u).trim();
    return /^(https?:\/\/|\/|\.\/|#|mailto:)/i.test(t) ? t : '#';
  }

  /* 인라인 서식. 입력은 이미 이스케이프된 문자열이어야 한다. */
  function inline(s) {
    return s
      /* 이미지를 링크보다 먼저 — ![]() 가 []() 규칙에 먼저 잡히면 안 된다 */
      .replace(/!\[([^\]]*)\]\(([^)\s]+)\)/g, function (m, alt, src) {
        return '<img src="' + safeUrl(src) + '" alt="' + alt + '" loading="lazy">';
      })
      .replace(/\[([^\]]+)\]\(([^)\s]+)\)/g, function (m, txt, href) {
        var u = safeUrl(href);
        var external = /^https?:\/\//i.test(u);
        return '<a href="' + u + '"' + (external ? ' target="_blank" rel="noopener"' : '') + '>' + txt + '</a>';
      })
      .replace(/`([^`]+)`/g, '<code>$1</code>')
      .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
      .replace(/(^|[^*])\*([^*\n]+)\*/g, '$1<em>$2</em>');
  }

  var RE_HR      = /^\s*(-{3,}|\*{3,})\s*$/;
  var RE_HEAD    = /^(#{1,4})\s+(.*)$/;
  var RE_QUOTE   = /^>\s?/;
  var RE_UL      = /^\s*[-*+]\s+/;
  var RE_OL      = /^\s*\d+\.\s+/;

  function isBlockStart(line) {
    return RE_HR.test(line) || RE_HEAD.test(line) || RE_QUOTE.test(line) ||
           RE_UL.test(line) || RE_OL.test(line);
  }

  function renderMarkdown(src) {
    var lines = String(src || '').replace(/\r\n?/g, '\n').split('\n');
    var out = [], i = 0, buf, line, h, lv;

    while (i < lines.length) {
      line = lines[i];

      if (!line.trim()) { i++; continue; }

      /* 구분선 — 목록(- 항목)보다 먼저 검사해야 --- 가 목록으로 새지 않는다 */
      if (RE_HR.test(line)) { out.push('<hr>'); i++; continue; }

      h = line.match(RE_HEAD);
      if (h) {
        /* 본문 최상위 제목은 h2부터 — 페이지의 h1(아티클 제목)과 겹치지 않게 한 단계 내린다 */
        lv = Math.min(h[1].length + 1, 5);
        out.push('<h' + lv + '>' + inline(esc(h[2])) + '</h' + lv + '>');
        i++; continue;
      }

      if (RE_QUOTE.test(line)) {
        buf = [];
        while (i < lines.length && RE_QUOTE.test(lines[i])) { buf.push(lines[i].replace(RE_QUOTE, '')); i++; }
        out.push('<blockquote>' + inline(esc(buf.join(' '))) + '</blockquote>');
        continue;
      }

      if (RE_UL.test(line)) {
        buf = [];
        while (i < lines.length && RE_UL.test(lines[i]) && !RE_HR.test(lines[i])) {
          buf.push(lines[i].replace(RE_UL, '')); i++;
        }
        out.push('<ul>' + buf.map(function (t) { return '<li>' + inline(esc(t)) + '</li>'; }).join('') + '</ul>');
        continue;
      }

      if (RE_OL.test(line)) {
        buf = [];
        while (i < lines.length && RE_OL.test(lines[i])) { buf.push(lines[i].replace(RE_OL, '')); i++; }
        out.push('<ol>' + buf.map(function (t) { return '<li>' + inline(esc(t)) + '</li>'; }).join('') + '</ol>');
        continue;
      }

      /* 문단 — 빈 줄이나 다른 블록이 시작될 때까지. 문단 안 줄바꿈은 <br>로 살린다 */
      buf = [];
      while (i < lines.length && lines[i].trim() && !isBlockStart(lines[i])) { buf.push(lines[i]); i++; }
      out.push('<p>' + inline(esc(buf.join('\n'))).replace(/\n/g, '<br>') + '</p>');
    }

    return out.join('\n');
  }

  global.renderMarkdown = renderMarkdown;
})(window);
