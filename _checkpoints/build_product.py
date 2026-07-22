# -*- coding: utf-8 -*-
"""product.html 생성 스크립트 v2 — 히어로 카드 + 컴팩트 그리드 2단 위계.

v1(카드 30장 전부 교차) → v2 변경점:
- 대분류마다 [히어로 카드 1장(교차 유지)] + [컴팩트 그리드]로 위계 부여
- 스케줄·수업일지·루틴·식단 히어로는 "연결형 듀얼 목업"(폰⇄태블릿 흐름)
- 누락 기능 5개 추가: 출석 처리 / 첫 상담 기록 / AI 체형분석 / 웰니스 / 공유 메모장
- 스티키 앵커 바(대분류 길찾기), 대분류 번호(01~) 부여
- 워딩: 라포 유사 문구 교체, 설명 "가치 1문장+방법 1문장" 압축, 히어로 2줄
- 출력: product-new.html (검토 후 기존 meta 이식하여 product.html 교체)

실행: python3 _checkpoints/build_product.py
"""
import re

BASE = '/Users/jinhunjung/ssentif-redesign'
src = open(BASE + '/product.html', encoding='utf-8').read()
NAV    = re.search(r'<nav class="nav".*?</div>\n</nav>', src, re.S).group(0)
MOBILE = re.search(r'<div class="nav-mobile-menu".*?\n</div>', src, re.S).group(0)
CTA    = re.search(r'<section class="cta-band">.*?</section>', src, re.S).group(0)
FOOTER = re.search(r'<footer class="footer">.*?</footer>', src, re.S).group(0)
SCRIPT = re.search(r'<script>.*?</script>', src, re.S).group(0)

# ─────────────────────────── CSS ───────────────────────────
CSS = '''
/* ═══════════ 제품 페이지 v2 ═══════════ */

/* ── 히어로 ── */
.pd-hero { padding: 150px 0 64px; text-align: center;
  background: linear-gradient(180deg, #EAFBF6 0%, var(--white) 88%); }
.pd-hero .badge { display: inline-block; padding: 7px 16px; border-radius: 999px;
  background: var(--accent-light); color: var(--accent-dark);
  font-size: 13px; font-weight: 800; margin-bottom: 22px; }
.pd-hero h1 { font-size: clamp(2rem, 4.6vw, 3.2rem); line-height: 1.26;
  letter-spacing: -0.03em; margin-bottom: 18px; }
.pd-hero h1 .hl { color: var(--accent-dark); }
.pd-hero .sub { max-width: 560px; margin: 0 auto 32px; font-size: 16px;
  color: var(--gray-600); line-height: 1.75; }
.pd-hero-jump { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
.pd-jump { display: inline-flex; align-items: center; gap: 8px;
  padding: 13px 24px; border-radius: 999px; font-size: 14.5px; font-weight: 800;
  text-decoration: none; transition: transform 0.15s, box-shadow 0.15s; }
.pd-jump:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.pd-jump.light { background: var(--white); color: var(--black);
  border: 1.5px solid var(--border); }
.pd-jump.dark { background: var(--black); color: var(--white); }

/* ── 묶음 헤더 ── */
.pd-part { padding: 76px 0 8px; }
.pd-part .part-label { font-size: 13px; font-weight: 900; letter-spacing: 0.1em;
  text-transform: uppercase; color: var(--accent-dark); margin-bottom: 12px; }
.pd-part h2 { font-size: clamp(1.6rem, 3.2vw, 2.3rem); letter-spacing: -0.02em;
  line-height: 1.3; margin-bottom: 14px; }
.pd-part .part-sub { font-size: 15.5px; color: var(--gray-600); line-height: 1.75;
  max-width: 620px; }

/* ── 대분류 ── */
.pd-cat { padding: 64px 0 6px; scroll-margin-top: 24px; }
.pd-cat .cat-label { display: flex; align-items: center; gap: 10px;
  font-size: 12.5px; font-weight: 900; letter-spacing: 0.08em;
  color: var(--gray-400); text-transform: uppercase; margin-bottom: 10px; }
.pd-cat .cat-label i { font-style: normal; font-size: 12px; font-weight: 900;
  color: var(--accent-dark); }
.pd-cat h3 { font-size: clamp(1.35rem, 2.6vw, 1.8rem); letter-spacing: -0.02em;
  line-height: 1.35; }

/* ── 히어로 카드 (교차) ── */
.pf-card { display: grid; grid-template-columns: 1fr 1.15fr; gap: 52px;
  align-items: center; padding: 42px 0 34px; }
.pf-card.rev { grid-template-columns: 1.15fr 1fr; }
.pf-card.rev .pf-text { order: 2; }
.pf-card.rev .pf-visual { order: 1; }
.pf-tag { display: inline-flex; align-items: center; gap: 6px;
  padding: 5px 13px; border-radius: 999px; font-size: 12.5px; font-weight: 800;
  margin-bottom: 16px; margin-right: 6px; }
.pf-tag.trainer { background: var(--accent-light); color: var(--accent-dark); }
.pf-tag.member  { background: #EAF1FE; color: #2E5FC0; }
.pf-tag.both    { background: var(--gray-100); color: var(--gray-700); }
.pf-tag.admin   { background: rgba(31,219,168,0.12); color: #1FDBA8; }
.pf-tag.ai      { background: #E6FBF5; color: #15B88E; }
.pf-text .fn { font-size: 13px; font-weight: 800; color: var(--gray-400);
  margin-bottom: 8px; }
.pf-text h4 { font-size: clamp(1.3rem, 2.4vw, 1.65rem); letter-spacing: -0.02em;
  line-height: 1.4; margin-bottom: 14px; }
.pf-text p { font-size: 15px; color: var(--gray-600); line-height: 1.8; }
.pf-visual { min-width: 0; }

/* ── 컴팩트 그리드 ── */
.pc-grid { display: grid; grid-template-columns: repeat(2, 1fr); gap: 14px;
  padding-bottom: 14px; }
.pc-grid.single { grid-template-columns: 1fr; }
.pc-card { display: flex; gap: 15px; align-items: flex-start;
  background: var(--white); border: 1px solid var(--border);
  border-radius: 16px; padding: 20px; }
.pc-ico { flex-shrink: 0; width: 42px; height: 42px; border-radius: 12px;
  background: var(--gray-100); display: flex; align-items: center;
  justify-content: center; font-size: 19px; }
.pc-body .pf-tag { margin-bottom: 8px; padding: 3px 10px; font-size: 11.5px; }
.pc-body h5 { font-size: 15.5px; font-weight: 800; letter-spacing: -0.01em;
  margin-bottom: 5px; color: var(--black); }
.pc-body p { font-size: 13.5px; color: var(--gray-600); line-height: 1.65; }

/* ── 다크 묶음 (관리자) ── */
.pd-dark { background: #0D0F12; }
.pd-dark .pd-part { padding-top: 88px; }
.pd-dark .pd-part .part-label { color: #1FDBA8; }
.pd-dark .pd-part h2 { color: var(--white); }
.pd-dark .pd-part .part-sub { color: #9AA5B4; }
.pd-dark .pd-cat .cat-label { color: #718096; }
.pd-dark .pd-cat .cat-label i { color: #1FDBA8; }
.pd-dark .pd-cat h3 { color: var(--white); }
.pd-dark .pf-text h4 { color: var(--white); }
.pd-dark .pf-text p { color: #9AA5B4; }
.pd-dark .pf-text .fn { color: #718096; }
.pd-dark .pc-card { background: #151A21; border-color: #262D38; }
.pd-dark .pc-ico { background: #1E2433; }
.pd-dark .pc-body h5 { color: var(--white); }
.pd-dark .pc-body p { color: #9AA5B4; }
.pd-dark-end { height: 80px; }

/* ── 목업 프레임 ── */
.mk-tablet { background: var(--black); border-radius: 18px; padding: 8px;
  box-shadow: var(--shadow-lg); }
.mk-tablet .mk-screen { background: #F7F7F7; border-radius: 12px;
  padding: 18px; font-size: 12px; }
.mk-phone { width: min(300px, 88%); margin: 0 auto; background: var(--black);
  border-radius: 26px; padding: 7px 6px; box-shadow: var(--shadow-lg); }
.mk-phone .mk-screen { background: #F7F7F7; border-radius: 20px;
  padding: 16px 13px; font-size: 12px; }
.mk-desk { background: #1E2433; border-radius: 14px; padding: 0;
  box-shadow: var(--shadow-lg); overflow: hidden; border: 1px solid #2D3748; }
.mk-desk .mk-bar { display: flex; gap: 6px; padding: 11px 14px; }
.mk-desk .mk-bar i { width: 9px; height: 9px; border-radius: 50%;
  background: #4A5568; }
.mk-desk .mk-screen { background: #F7F7F7; padding: 18px; font-size: 12px; }

/* 연결형 듀얼 목업 */
.mk-duo { display: grid; grid-template-columns: 1.35fr auto 1fr;
  align-items: center; gap: 10px; }
.mk-duo .mk-phone { width: 100%; margin: 0; }
.mk-duo .mk-tablet { padding: 7px; }
.mk-duo .mk-tablet .mk-screen { padding: 13px; }
.duo-arrow { width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
  background: var(--accent-light); color: var(--accent-dark);
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; font-weight: 900; box-shadow: var(--shadow-sm); }

/* 목업 내부 공통 */
.mk-head { display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 12px; }
.mk-head b { font-size: 13px; color: #282828; }
.mk-head span { font-size: 10.5px; color: #9AA5B4; }
.mk-block { background: #FFFFFF; border-radius: 10px; padding: 12px;
  margin-bottom: 10px; border: 1px solid #EEEEF0; }
.mk-block .bk-title { display: flex; justify-content: space-between;
  font-size: 12px; font-weight: 800; color: #282828; margin-bottom: 8px; }
.mk-block .bk-title i { font-style: normal; font-weight: 700; color: #9AA5B4; }
.mk-sub { font-size: 11px; color: #4A5568; line-height: 1.55; }
.mk-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.mk-table th { text-align: left; color: #9AA5B4; font-weight: 700;
  padding: 3px 6px; border-bottom: 1px solid #EEEEF0; }
.mk-table td { padding: 4px 6px; color: #2D3748; border-bottom: 1px solid #F5F5F7; }
.mk-btn-row { display: flex; gap: 8px; margin: 4px 0 10px; }
.mk-chip { flex: 1; text-align: center; padding: 8px 0; border-radius: 8px;
  font-size: 11px; font-weight: 800; background: #FFFFFF;
  border: 1px solid #E2E8F0; color: #4A5568; }
.mk-chip.ai { background: #E6FBF5; border-color: #BFF0E2; color: #15B88E; }
.mk-chip.dark { background: #282828; border-color: #282828; color: #FFFFFF; }
.mk-comment { background: #FFFFFF; border-radius: 10px; padding: 11px 12px;
  border: 1px solid #EEEEF0; font-size: 11.5px; color: #4A5568; line-height: 1.6; }
.mk-comment b { display: block; font-size: 11px; color: #282828; margin-bottom: 4px; }
.mk-save { margin-top: 10px; text-align: center; padding: 10px 0;
  border-radius: 9px; background: #282828; color: #FFFFFF;
  font-size: 12px; font-weight: 800; }
.mk-arrive { display: flex; gap: 10px; align-items: center; background: #FFFFFF;
  border-radius: 12px; padding: 12px; border: 1px solid #EEEEF0; margin-bottom: 10px; }
.mk-arrive .av { width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
  background: #E6FBF5; display: flex; align-items: center; justify-content: center;
  font-size: 15px; }
.mk-arrive b { display: block; font-size: 12px; color: #282828; }
.mk-arrive span { font-size: 10.5px; color: #9AA5B4; }
.mk-filters { display: flex; gap: 6px; margin-bottom: 10px; flex-wrap: wrap; }
.mk-filters span { padding: 5px 11px; border-radius: 999px; font-size: 10.5px;
  font-weight: 700; background: #FFFFFF; border: 1px solid #E2E8F0; color: #718096; }
.mk-filters span.on { background: #282828; border-color: #282828; color: #FFFFFF; }
.mk-row { display: flex; align-items: center; gap: 9px; background: #FFFFFF;
  border: 1px solid #EEEEF0; border-radius: 10px; padding: 10px 12px;
  margin-bottom: 8px; font-size: 11.5px; }
.mk-row .nm { font-weight: 800; color: #282828; }
.mk-row .mt { color: #9AA5B4; flex: 1; }
.mk-row .ac { padding: 5px 10px; border-radius: 7px; background: #F1F5F9;
  color: #4A5568; font-size: 10.5px; font-weight: 800; }
.mk-row .ac.warn { background: #FFE4D9; color: #C65A2E; }
.mk-stats { display: flex; gap: 8px; margin-bottom: 10px; }
.mk-stat { flex: 1; background: #FFFFFF; border: 1px solid #EEEEF0;
  border-radius: 10px; padding: 10px 8px; text-align: center; }
.mk-stat b { display: block; font-size: 15px; color: #282828; }
.mk-stat.mint b { color: #15B88E; }
.mk-stat span { font-size: 10px; color: #9AA5B4; }
.mk-bars { background: #FFFFFF; border: 1px solid #EEEEF0; border-radius: 10px;
  padding: 12px; }
.mk-bars .br { display: flex; align-items: center; gap: 8px; margin: 7px 0;
  font-size: 10.5px; color: #4A5568; }
.mk-bars .br em { font-style: normal; width: 52px; flex-shrink: 0; }
.mk-bars .br i { height: 8px; border-radius: 4px; background: #282828; }
.mk-bars .br i.mint { background: #1FDBA8; }
.mk-bars .br b { font-size: 10.5px; color: #282828; }
.mk-chat { display: flex; flex-direction: column; gap: 7px; }
.mk-bubble { max-width: 82%; padding: 9px 12px; border-radius: 13px;
  font-size: 11.5px; line-height: 1.5; }
.mk-bubble.me { align-self: flex-end; background: #282828; color: #FFFFFF;
  border-bottom-right-radius: 4px; }
.mk-bubble.you { align-self: flex-start; background: #FFFFFF; color: #2D3748;
  border: 1px solid #EEEEF0; border-bottom-left-radius: 4px; }
.mk-bubble.aians { align-self: flex-start; background: #E6FBF5; color: #14523F;
  border: 1px solid #BFF0E2; border-bottom-left-radius: 4px; }
.mk-photos { display: flex; gap: 8px; }
.mk-photo { flex: 1; aspect-ratio: 3/4; border-radius: 9px;
  background: linear-gradient(160deg, #E2E8F0, #CBD5E0);
  display: flex; align-items: center; justify-content: center;
  font-size: 10px; color: #718096; font-weight: 700; }

@media (max-width: 860px) {
  .pf-card, .pf-card.rev { grid-template-columns: 1fr; gap: 26px; padding: 30px 0 24px; }
  .pf-card.rev .pf-text { order: 1; }
  .pf-card.rev .pf-visual { order: 2; }
  .pc-grid { grid-template-columns: 1fr; }
  .mk-duo { grid-template-columns: 1fr; }
  .duo-arrow { transform: rotate(90deg); margin: 0 auto; }
}
'''

# ─────────────────────── 조립 헬퍼 ───────────────────────
TAG = {
    'trainer': '<span class="pf-tag trainer">🏋️ 강사</span>',
    'member':  '<span class="pf-tag member">👤 회원</span>',
    'both':    '<span class="pf-tag both">🏋️👤 함께</span>',
    'admin':   '<span class="pf-tag admin">🏢 관리자</span>',
    'ai':      '<span class="pf-tag ai">✨ AI</span>',
}

def hero_card(rev, tags, fn, h4, p, visual):
    tag_html = ''.join(TAG[t] for t in tags)
    cls = ' rev' if rev else ''
    return f'''  <div class="pf-card{cls}">
    <div class="pf-text">
      {tag_html}
      <div class="fn">{fn}</div>
      <h4>{h4}</h4>
      <p>{p}</p>
    </div>
    <div class="pf-visual">{visual}</div>
  </div>'''

def pc(ico, tags, h5, p):
    tag_html = ''.join(TAG[t] for t in tags)
    return f'''    <div class="pc-card">
      <div class="pc-ico">{ico}</div>
      <div class="pc-body">{tag_html}<h5>{h5}</h5><p>{p}</p></div>
    </div>'''

def cat(cid, num, label, h3, hero, compacts):
    grid = ''
    if compacts:
        single = ' single' if len(compacts) == 1 else ''
        grid = f'\n  <div class="pc-grid{single}">\n' + '\n'.join(compacts) + '\n  </div>'
    return f'''<div class="container">
  <div class="pd-cat" id="{cid}">
    <div class="cat-label"><i>{num}</i>{label}</div>
    <h3>{h3}</h3>
  </div>

{hero}{grid}
</div>'''

def tablet(inner):  return f'<div class="mk-tablet"><div class="mk-screen">{inner}</div></div>'
def phone(inner):   return f'<div class="mk-phone"><div class="mk-screen">{inner}</div></div>'
def desk(inner):    return f'<div class="mk-desk"><div class="mk-bar"><i></i><i></i><i></i></div><div class="mk-screen">{inner}</div></div>'
def duo(left, right):
    return f'<div class="mk-duo">{left}<div class="duo-arrow">→</div>{right}</div>'

# ─────────────────────── 목업 정의 ───────────────────────
# 듀얼용 슬림 목업 (블록 수를 줄여 좁은 폭에서도 읽히게)
DUO_SCH_L = phone('''
  <div class="mk-head"><b>수업 예약</b><span>박준형 강사</span></div>
  <div class="mk-btn-row"><div class="mk-chip">10:00</div><div class="mk-chip" style="opacity:.4">11:00</div></div>
  <div class="mk-btn-row"><div class="mk-chip dark">19:00</div><div class="mk-chip">20:00</div></div>
  <div class="mk-save">예약 요청하기</div>''')
DUO_SCH_R = tablet('''
  <div class="mk-head"><b>예약 요청</b><span>1건 대기</span></div>
  <div class="mk-block">
    <div class="bk-title">김민지 회원님 <i>7/23 (수) 19:00</i></div>
    <div class="mk-btn-row" style="margin:6px 0 0"><div class="mk-chip">거절</div><div class="mk-chip dark">수락</div></div>
  </div>
  <div class="mk-row"><span class="nm">확정</span><span class="mt">회원에게 알림이 발송됩니다</span></div>''')

DUO_LOG_L = tablet('''
  <div class="mk-head"><b>김민지 회원님 · 12회차</b><span>1분 전 저장됨</span></div>
  <div class="mk-block">
    <div class="bk-title">벤치프레스 <i>3세트</i></div>
    <table class="mk-table">
      <tr><th>세트</th><th>무게(kg)</th><th>횟수(회)</th></tr>
      <tr><td>1</td><td>60</td><td>12</td></tr>
      <tr><td>2</td><td>70</td><td>8</td></tr>
    </table>
  </div>
  <div class="mk-btn-row" style="margin:0"><div class="mk-chip ai">✨ AI 작성 제안</div></div>''')
DUO_LOG_R = phone('''
  <div class="mk-arrive"><div class="av">📝</div><div><b>수업일지가 도착했습니다</b><span>박준형 강사 · 방금 전</span></div></div>
  <div class="mk-comment"><b>코치 코멘트</b>오늘 벤치 70kg 첫 성공! 어깨 안정성이 좋아졌어요 💪</div>''')

DUO_RTN_L = tablet('''
  <div class="mk-head"><b>루틴 처방</b><span>김민지 회원님</span></div>
  <div class="mk-row"><span class="nm">스쿼트</span><span class="mt">3세트 × 12회</span></div>
  <div class="mk-row"><span class="nm">런지</span><span class="mt">3세트 × 10회</span></div>
  <div class="mk-save">루틴 보내기</div>''')
DUO_RTN_R = phone('''
  <div class="mk-head"><b>오늘의 루틴</b><span>1/2 완료</span></div>
  <div class="mk-block">
    <div class="bk-title">스쿼트 <i>영상 ▶</i></div>
    <div class="mk-btn-row" style="margin:0"><div class="mk-chip dark">12</div><div class="mk-chip dark">11</div><div class="mk-chip">—</div></div>
  </div>
  <div class="mk-row"><span class="nm">런지</span><span class="mt">완료 ✓</span></div>''')

DUO_DIET_L = phone('''
  <div class="mk-head"><b>오늘의 식단</b><span>7/22 (화)</span></div>
  <div class="mk-block"><div class="bk-title">점심 식단 기록 <i>12:40</i></div>
    <div class="mk-photos"><div class="mk-photo">🥗</div><div class="mk-photo">🍗</div></div></div>''')
DUO_DIET_R = tablet('''
  <div class="mk-head"><b>식단 피드</b><span>김민지 회원님</span></div>
  <div class="mk-comment"><b>내 코멘트</b>단백질 구성 좋아요! 👍 저녁엔 탄수화물을 조금만 줄여볼까요?</div>
  <div class="mk-btn-row" style="margin-top:8px"><div class="mk-chip">👍</div><div class="mk-chip">🔥</div><div class="mk-chip dark">코멘트</div></div>''')

MK_REPORT = tablet('''
  <div class="mk-head"><b>인사이트 · 김민지 회원님</b><span>PT 성과 리포트</span></div>
  <div class="mk-stats">
    <div class="mk-stat"><b>24회</b><span>수업 진행</span></div>
    <div class="mk-stat mint"><b>+18%</b><span>운동 볼륨</span></div>
    <div class="mk-stat mint"><b>-3.2%p</b><span>체지방률</span></div>
  </div>
  <div class="mk-bars">
    <div class="br"><em>5월</em><i style="width:72%"></i><b>25.0%</b></div>
    <div class="br"><em>6월</em><i style="width:63%"></i><b>23.4%</b></div>
    <div class="br"><em>7월</em><i class="mint" style="width:55%"></i><b>21.8%</b></div>
  </div>''')

MK_CHAT = phone('''
  <div class="mk-head"><b>박준형 강사</b><span>1:1 채팅</span></div>
  <div class="mk-chat">
    <div class="mk-bubble me">쌤 오늘 좀 늦을 것 같아요! 10분만요 🙏</div>
    <div class="mk-bubble you">네 천천히 오세요~ 도착하면 폼롤러로 몸 풀고 있어요.</div>
    <div class="mk-bubble me">넵! 어제 루틴도 다 했어요 💪</div>
    <div class="mk-bubble you">확인했어요. 플랭크 자세 많이 좋아졌던데요?</div>
  </div>''')

MK_ALERTS = desk('''
  <div class="mk-head"><b>업무 알림</b><span>오늘 12건</span></div>
  <div class="mk-filters"><span class="on">전체 12</span><span>이탈 3</span><span>만료 5</span><span>신규 4</span></div>
  <div class="mk-row"><span class="nm">김O은</span><span class="mt">최근 14일 미출석 · 이탈 위험</span><span class="ac warn">채팅</span></div>
  <div class="mk-row"><span class="nm">이O호</span><span class="mt">수강권 3회 남음 · 만료 임박</span><span class="ac">정산 입력</span></div>
  <div class="mk-row"><span class="nm">박O아</span><span class="mt">PT 20회권 신규 발급</span><span class="ac">확인</span></div>''')

MK_ALLMEMBERS = desk('''
  <div class="mk-head"><b>전체 회원</b><span>총 128명</span></div>
  <div class="mk-filters"><span class="on">전체</span><span>활성</span><span>일시정지</span><span>만료</span><span>미배정</span></div>
  <table class="mk-table">
    <tr><th>이름</th><th>담당강사</th><th>시설이용권</th><th>개인수업</th></tr>
    <tr><td>김민지</td><td>박준형</td><td>~9/30</td><td>8/20회</td></tr>
    <tr><td>이서연</td><td>최유나</td><td>~8/15</td><td>3/10회</td></tr>
    <tr><td>박지훈</td><td><b style="color:#C65A2E">미배정</b></td><td>~10/02</td><td>—</td></tr>
  </table>''')

MK_PAYROLL = desk('''
  <div class="mk-head"><b>급여 정산 · 박준형</b><span>7월분</span></div>
  <div class="mk-block"><div class="bk-title">개인수업 정산 <i>단가제</i></div>
    <div class="mk-sub">회당 35,000원 × 완료 42회 = <b style="color:#282828">1,470,000원</b></div></div>
  <div class="mk-block"><div class="bk-title">사업소득세 원천징수 <i>3.3% 적용</i></div>
    <div class="mk-sub">공제 예상액 <b style="color:#C65A2E">-81,510원</b></div></div>
  <div class="mk-save">명세서 발송</div>''')

MK_AI = desk('''
  <div class="mk-head"><b>AI 어시스턴트</b><span>센터 데이터 연결됨</span></div>
  <div class="mk-chat">
    <div class="mk-bubble me">이번 달 매출 왜 줄었어?</div>
    <div class="mk-bubble aians">재등록이 전월 대비 4건 줄었습니다. 만료 예정 회원 5명 중 3명이 아직 미응답이에요. 이 3명부터 연락해보시는 걸 권장합니다. → 회원 보기</div>
    <div class="mk-bubble me">박준형 강사 이번 달 수업 몇 건이야?</div>
    <div class="mk-bubble aians">42건 완료, 예정 6건입니다. 작성률은 96%예요.</div>
  </div>''')

# ─────────────────────── 페이지 조립 ───────────────────────
HERO = '''
<section class="pd-hero">
  <div class="container">
    <div class="badge">제품 소개</div>
    <h1>수업, 운동, 그리고 <span class="hl">운영까지</span><br>센티프 하나로 연결됩니다</h1>
    <p class="sub">강사와 회원은 기록으로 이어지고, 관리자는 그 데이터로 센터를 운영합니다.</p>
    <div class="pd-hero-jump">
      <a class="pd-jump light" href="#part-a">🏋️ 강사와 회원 경험 보기</a>
      <a class="pd-jump dark" href="#part-b">🏢 관리자 경험 보기</a>
    </div>
  </div>
</section>
'''

PART_A = '''
<section class="pd-part" id="part-a">
  <div class="container">
    <div class="part-label">Part 1 · 강사와 회원</div>
    <h2>수업의 모든 순간이<br>기록으로 이어집니다</h2>
    <p class="part-sub">예약부터 수업일지, 루틴과 식단, 성장 데이터까지 — 강사가 남긴 기록이 회원의 경험이 되고, 회원의 기록이 강사의 다음 수업이 됩니다.</p>
  </div>
</section>
'''

A1 = cat('cat-sch', '01', '스케줄', '묻지 않아도 맞춰지는 수업 일정',
  hero_card(False, ['both'], '예약 요청 → 확정',
    '회원이 신청하고,<br>강사가 수락하면 끝',
    '강사가 열어둔 가능 시간에 회원이 직접 예약을 요청합니다. 수락 한 번으로 일정이 확정되고, 양쪽 모두에게 알림이 갑니다.',
    duo(DUO_SCH_L, DUO_SCH_R)),
  [
    pc('👥', ['trainer'], '그룹수업도 캘린더 하나로', '정원과 회원별 차감 상품까지 한 화면에서 관리합니다.'),
    pc('✅', ['trainer'], '출석 체크는 탭 한 번', '개인수업도 그룹수업도 회원별로 바로 처리합니다.'),
    pc('🔒', ['trainer'], '내 개인 시간은 자동으로 보호', '청소 · 개인운동을 등록하면 그 시간대 예약 요청이 막힙니다.'),
    pc('🔔', ['member'], '노쇼를 줄이는 하루 전 알림', '예약된 수업 전날, 리마인드가 자동 발송됩니다.'),
  ])

A2 = cat('cat-log', '02', '수업일지', '적는 수업에서, 남는 수업으로',
  hero_card(True, ['both'], '일지 작성 → 기록 도착',
    '강사가 1분 만에 쓰면,<br>회원에게 그대로 도착합니다',
    '템플릿과 AI 초안으로 수업 후 1분이면 기록이 끝납니다. 그 기록이 회원 앱에 도착해, 수업이 끝나도 관리받는 경험이 이어집니다.',
    duo(DUO_LOG_L, DUO_LOG_R)),
  [
    pc('📚', ['trainer'], '다음 수업 준비가 정확해집니다', '지난 기록을 훑으면 오늘 수업의 방향이 잡힙니다.'),
    pc('📋', ['trainer'], '첫날의 목표를 끝까지 기억합니다', '상담 기록을 남겨두면 담당이 바뀌어도 맥락이 유지됩니다.'),
  ])

A3 = cat('cat-rtn', '03', '루틴 처방', '수업 없는 날에도 관리는 계속됩니다',
  hero_card(False, ['both'], '루틴 처방 → 수행',
    "처방한 루틴이 회원의<br>'오늘 할 일'이 됩니다",
    '강사가 보낸 루틴이 회원 앱에 도착합니다. 회원은 동작 영상을 보며 따라하고, 카운터로 세트를 체크합니다.',
    duo(DUO_RTN_L, DUO_RTN_R)),
  [
    pc('👀', ['trainer'], '했는지, 안 했는지 보입니다', '회원의 수행 기록이 강사에게 공유됩니다.'),
    pc('🗂️', ['trainer'], '우리 센터만의 운동을 등록', '등록한 운동은 일지와 루틴에서 똑같이 검색됩니다.'),
  ])

A4 = cat('cat-diet', '04', '식단', '사진 한 장으로 이어지는 식단 코칭',
  hero_card(True, ['both'], '식단 업로드 → 피드백',
    '회원은 찍어 올리고,<br>강사는 바로 반응합니다',
    '끼니별 사진 한 장이면 기록이 끝납니다. 강사의 코멘트와 이모지가 달리고, 인증 요청으로 기록 습관까지 만듭니다.',
    duo(DUO_DIET_L, DUO_DIET_R)),
  [])

A5 = cat('cat-grow', '05', '성장 데이터', '느낌이 아니라 숫자로 보여주는 변화',
  hero_card(False, ['trainer'], '상담 근거',
    '재등록 대화가<br>쉬워집니다',
    '수업 · 체성분 · 기록이 쌓여 성과 리포트가 됩니다. 재등록 상담에서 말이 아니라 숫자로 보여줍니다.',
    MK_REPORT),
  [
    pc('📊', ['trainer'], '인바디와 3각도 사진이 시간순으로', '이전 기록과 나란히 비교하면 변화가 보입니다.'),
    pc('📈', ['member'], '내 변화를 그래프로', '수업 횟수 · 운동일 · 체성분 추이가 정리됩니다.'),
    pc('🤖', ['trainer', 'ai'], '사진에서 체형 밸런스를 읽어냅니다', '촬영한 체형 사진을 AI가 분석해 리포트로 만듭니다.'),
    pc('💧', ['member'], '컨디션 · 수면 · 수분 · 걸음까지', '매일의 몸 상태가 링 게이지로 쌓입니다.'),
  ])

A6 = cat('cat-comm', '06', '소통', '연락처 공개 없이, 채널 하나로',
  hero_card(True, ['both'], '1:1 채팅',
    '개인 연락처 없이<br>모든 대화가 앱 안에서',
    '일정 조율부터 운동 질문까지 채팅 하나로 해결합니다. 퇴근 후의 카톡 부담이 사라집니다.',
    MK_CHAT),
  [
    pc('📣', ['trainer'], '단체 문자 비용 없이 푸시로', '휴무 · 이벤트 소식을 보내고 열람까지 확인합니다.'),
    pc('🗒️', ['trainer'], '팀의 인수인계가 한곳에', '기구 점검 · 공유 사항을 워크스페이스 전체가 함께 봅니다.'),
  ])

PART_B = '''
<section class="pd-part" id="part-b">
  <div class="container">
    <div class="part-label">Part 2 · 관리자</div>
    <h2>회원 관리의 경험이 쌓이면,<br>운영의 데이터가 됩니다</h2>
    <p class="part-sub">강사와 회원이 주고받은 모든 기록이 관리자의 대시보드로 모입니다. 출근하면 오늘 할 일이 정해져 있습니다.</p>
  </div>
</section>
'''

B1 = cat('cat-dash', '01', '운영 대시보드', '매일 아침, 센터의 상태가 한눈에',
  hero_card(False, ['admin'], '업무 알림',
    '이탈 · 만료 · 신규를<br>앱이 먼저 알려줍니다',
    '출석이 끊긴 회원, 만료 임박 수강권, 신규 발급을 매일 아침 알림으로 받습니다. 알림에서 정산 · 채팅으로 바로 이동합니다.',
    MK_ALERTS),
  [
    pc('💰', ['admin'], '이번 달 판매를 유형별로', '시설이용권 · 수업권 건수와 금액이 한 화면에 잡힙니다.'),
    pc('⚠️', ['admin'], '잠재부채까지 보입니다', '미소진 수업 금액이 자동 계산되어 환불 리스크를 미리 관리합니다.'),
    pc('📬', ['admin'], '보낸 공지가 읽혔는지 숫자로', '발송 · 열람 · 액션율이 집계됩니다.'),
  ])

B2 = cat('cat-members', '02', '회원 관리', '담당이 없어도, 전체가 보입니다',
  hero_card(True, ['admin'], '전체 회원 조회',
    '센터의 모든 회원을<br>한 화면에서',
    '활성 · 만료 · 미배정 필터로 걸러보고 이름으로 검색합니다. 담당 강사와 상품 현황이 목록에서 바로 보입니다.',
    MK_ALLMEMBERS),
  [
    pc('🤝', ['admin'], '미배정 회원을 강사에게 연결', '담당이 바뀌어도 기록은 그대로 이어집니다.'),
    pc('🧭', ['admin'], '누가, 어떤 상품으로 다니는지', '성별 · 연령 · 상품 분포가 그래프로 정리됩니다.'),
  ])

B3 = cat('cat-payroll', '03', '정산과 팀', '월말 정산, 화면 안에서 끝냅니다',
  hero_card(False, ['admin'], '급여 자동 계산',
    '수업 건수가<br>곧 정산입니다',
    '완료된 수업이 자동 집계되어 단가제 · 비율제로 계산됩니다. 원천징수 3.3%까지 반영된 실지급액이 나옵니다.',
    MK_PAYROLL),
  [
    pc('📨', ['admin'], '명세서는 버튼 하나로 전달', '발송 이력이 남아 서로 확인할 일이 없습니다.'),
    pc('🔑', ['admin'], '초대부터 권한까지 한곳에서', '고용 정보와 권한 등급으로 접근을 관리합니다.'),
  ])

B4 = cat('cat-ai', '04', 'AI 어시스턴트', '물어보면 데이터로 답합니다',
  hero_card(True, ['admin', 'ai'], '자연어 질문',
    '"이번 달 매출 왜 줄었어?"<br>물어보면 즉시',
    '센터의 실제 데이터를 근거로 답하고, 답변에서 해당 화면으로 바로 이동합니다.',
    MK_AI),
  [
    pc('🕒', ['admin'], '강사별 작성률과 팀 일정을 한눈에', '수업 완료 건수와 시간대별 배치까지 — 관리 공백이 보입니다.'),
  ])

page = f'''<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>제품 기능 — SSENTIF (신규 시안)</title>
<meta name="robots" content="noindex, nofollow">
<link rel="stylesheet" href="style.css?v=2">
<style>{CSS}</style>
</head>
<body>

{NAV}
{MOBILE}

{HERO}
{PART_A}
{A1}
{A2}
{A3}
{A4}
{A5}
{A6}

<div class="pd-dark">
{PART_B}
{B1}
{B2}
{B3}
{B4}
<div class="pd-dark-end"></div>
</div>

{CTA}

{FOOTER}

{SCRIPT}
</body>
</html>
'''
open(BASE + '/product-new.html', 'w', encoding='utf-8').write(page)
print('생성 완료: %d줄 / 히어로 카드 %d · 컴팩트 카드 %d' % (
    page.count('\n'),
    len(re.findall(r'<div class="pf-card', page)),
    len(re.findall(r'<div class="pc-card">', page))))
