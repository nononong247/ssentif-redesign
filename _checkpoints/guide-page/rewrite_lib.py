"""가이드 본문 재작성 도우미 (2026-10-15).

본문은 짧은 마크업으로 쓰고, 기존 그림은 원래 순서대로 {F0}, {F1} … 로 끼워 넣는다.
  P 문장          → g-intro 문단
  1. 문장         → g-step (번호는 줄 머리의 숫자)
  ## 제목         → h4.g-sub
  ! 문장          → 💡 callout
  !! 문장         → ⚠️ callout
  ? 질문 | 답     → '이럴 땐' 문답 (연속된 줄을 한 상자로 묶는다)
  {F0}            → 기존 그림 블록(단일 figure 또는 g-shot-row) 그대로
  **굵게** [버튼]  → <strong>
"""
import re

FAQ_CSS = '''
/* 이럴 땐 — 자주 막히는 절에만 붙는 문답 */
.g-faq { margin: 28px 0 0; padding: 18px 20px; border-radius: 14px; background: var(--gray-50); border: 1px solid var(--border); }
.g-faq-title { font-size: 13px; font-weight: 700; color: var(--gray-600); margin-bottom: 10px; }
.g-faq dl { margin: 0; }
.g-faq dt { font-size: 14.5px; font-weight: 700; color: var(--black); margin-top: 14px; }
.g-faq dt:first-child { margin-top: 0; }
.g-faq dd { margin: 4px 0 0; font-size: 14px; line-height: 1.7; color: var(--gray-700); }
'''


def inline(t):
    t = re.sub(r'\*\*(.+?)\*\*', r'<strong>\1</strong>', t)
    t = re.sub(r'(?<![\w>])(\[[^\]\n]+\])', r'<strong>\1</strong>', t)
    return t


def figures(article_html):
    """기존 그림 블록을 등장 순서대로 — g-shot-row 는 한 덩어리로."""
    rows = [(m.start(), m.end(), m.group(0)) for m in
            re.finditer(r'<div class="g-shot-row">.*?</figure>\s*</div>', article_html, re.S)]
    singles = [(m.start(), m.end(), m.group(0)) for m in
               re.finditer(r'<figure class="g-shot.*?</figure>', article_html, re.S)
               if not any(r0 <= m.start() < r1 for r0, r1, _ in rows)]
    return [blk for _, _, blk in sorted(rows + singles)]


def render(art_id, title, body, figs):
    I = '          '
    lines = [l.rstrip() for l in body.strip('\n').splitlines()]
    html, faq = [], []

    def flush():
        if faq:
            items = ''.join(f'\n{I}    <dt>{inline(q)}</dt>\n{I}    <dd>{inline(a)}</dd>' for q, a in faq)
            html.append(f'{I}<div class="g-faq">\n{I}  <div class="g-faq-title">이럴 땐</div>\n{I}  <dl>{items}\n{I}  </dl>\n{I}</div>')
            faq.clear()

    for raw in lines:
        l = raw.strip()
        if not l:
            continue
        if l.startswith('? '):
            q, a = l[2:].split(' | ', 1)
            faq.append((q, a))
            continue
        flush()
        if m := re.fullmatch(r'\{F(\d+)\}', l):
            html.append(I + figs[int(m.group(1))].strip())
        elif l.startswith('## '):
            html.append(f'{I}<h4 class="g-sub">{inline(l[3:])}</h4>')
        elif l.startswith('!! '):
            html.append(f'{I}<div class="g-callout warn">⚠️ <div>{inline(l[3:])}</div></div>')
        elif l.startswith('! '):
            html.append(f'{I}<div class="g-callout">💡 <div>{inline(l[2:])}</div></div>')
        elif m := re.match(r'(\d+)\. (.*)', l):
            html.append(f'{I}<div class="g-step"><span class="g-step-num">{m.group(1)}</span><p>{inline(m.group(2))}</p></div>')
        elif l.startswith('P '):
            html.append(f'{I}<p class="g-intro">{inline(l[2:])}</p>')
        else:
            raise ValueError(f'{art_id}: 알 수 없는 줄 — {l}')
    flush()
    return f'<article class="g-item" id="{art_id}">\n{I}<h3>{title}</h3>\n' + '\n'.join(html) + '\n        </article>'


def apply(path, articles, toc_titles=None):
    s = open(path, encoding='utf-8').read()
    for art_id, (title, body) in articles.items():
        a = s.index(f'<article class="g-item" id="{art_id}">')
        b = s.index('</article>', a) + len('</article>')
        figs = figures(s[a:b])
        need = {int(x) for x in re.findall(r'\{F(\d+)\}', body)}
        if need and max(need) >= len(figs):
            raise ValueError(f'{art_id}: 그림 {len(figs)}개뿐인데 F{max(need)} 요청')
        s = s[:a] + render(art_id, title, body, figs) + s[b:]
        new_toc = (toc_titles or {}).get(art_id, title)
        s = re.sub(rf'(<a class="toc-link" href="#{art_id}">)[^<]*(</a>)', rf'\g<1>{new_toc}\g<2>', s)
    if '.g-faq {' not in s:
        s = s.replace('</style>', FAQ_CSS + '</style>', 1)
    open(path, 'w', encoding='utf-8').write(s)
