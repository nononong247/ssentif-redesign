# -*- coding: utf-8 -*-
"""product.html 생성 스크립트 v3 — 목업 통합형.

v2 → v3 변경점:
- 컴팩트 카드 그리드 폐기. 대분류당 [텍스트 | 목업] 1덩어리로 통합.
  세부 기능은 텍스트 카드가 아니라 목업 화면 안에 시각적으로 배치한다.
- 기능 태그 나열 없음(사용자 지시).
- 개념 프레임을 회원 생애주기(등록→적응→정체→재등록) 관점으로 교체.
- 히어로 / Part 헤드라인 신규 카피.

실행: python3 _checkpoints/build_product.py   → product-new.html
"""
import re

BASE = '/Users/jinhunjung/Code/ssentif-redesign'
src = open(BASE + '/product.html', encoding='utf-8').read()
NAV    = re.search(r'<nav class="nav".*?</div>\n</nav>', src, re.S).group(0)
MOBILE = re.search(r'<div class="nav-mobile-menu".*?\n</div>', src, re.S).group(0)
CTA    = re.search(r'<section class="cta-band">.*?</section>', src, re.S).group(0)
FOOTER = re.search(r'<footer class="footer">.*?</footer>', src, re.S).group(0)
SCRIPT = re.search(r'<script>.*?</script>', src, re.S).group(0)

# ─────────────────────────── CSS ───────────────────────────
CSS = '''
/* ═══════════ 제품 페이지 v3 ═══════════ */

/* ── 히어로 ── */
.pd-hero { padding: 150px 0 66px; text-align: center;
  background: linear-gradient(180deg, #EAFBF6 0%, var(--white) 88%); }
.pd-hero .badge { display: inline-block; padding: 7px 16px; border-radius: 999px;
  background: var(--accent-light); color: var(--accent-dark);
  font-size: 13px; font-weight: 800; margin-bottom: 22px; }
.pd-hero h1 { font-size: clamp(2rem, 4.6vw, 3.2rem); line-height: 1.26;
  letter-spacing: -0.03em; margin-bottom: 18px; }
.pd-hero h1 .hl { color: var(--accent-dark); }
.pd-hero .sub { max-width: 580px; margin: 0 auto 32px; font-size: 16px;
  color: var(--gray-600); line-height: 1.75; }
.pd-hero-jump { display: flex; gap: 12px; justify-content: center; flex-wrap: wrap; }
.pd-jump { display: inline-flex; align-items: center; gap: 8px;
  padding: 13px 24px; border-radius: 999px; font-size: 14.5px; font-weight: 800;
  text-decoration: none; transition: transform 0.15s, box-shadow 0.15s; }
.pd-jump:hover { transform: translateY(-2px); box-shadow: var(--shadow-md); }
.pd-jump.light { background: var(--white); color: var(--black);
  border: 1.5px solid var(--border); }
.pd-jump.dark { background: var(--black); color: var(--white); }

/* ── 개념 프레임: 회원 생애주기 ── */
.pd-concept { padding: 84px 0 10px; }
.pd-concept .cc-head { text-align: center; max-width: 680px; margin: 0 auto 46px; }
.pd-concept h2 { font-size: clamp(1.55rem, 3.1vw, 2.2rem); letter-spacing: -0.025em;
  line-height: 1.34; margin-bottom: 16px; }
.pd-concept .cc-sub { font-size: 15.5px; color: var(--gray-600); line-height: 1.8; }
.pd-concept .cc-sub b { color: var(--black); font-weight: 800; }

.cc-life { position: relative; display: grid; grid-template-columns: repeat(4, 1fr);
  gap: 14px; }
.cc-life::before { content: ''; position: absolute; left: 3%; right: 3%; top: 27px;
  height: 2px; background: linear-gradient(90deg,
    var(--accent) 0%, var(--accent) 30%, #FE9971 65%, #F65271 100%); opacity: 0.35; }
.cc-node { position: relative; text-align: center; }
.cc-dot { position: relative; width: 54px; height: 54px; margin: 0 auto 16px;
  border-radius: 50%; background: var(--white); border: 2px solid var(--border);
  display: flex; align-items: center; justify-content: center; font-size: 21px; }
.cc-node.risk .cc-dot { border-color: #FE9971; }
.cc-node.end  .cc-dot { border-color: #F65271; }
.cc-when { display: block; font-size: 11.5px; font-weight: 900; letter-spacing: 0.04em;
  color: var(--gray-400); margin-bottom: 6px; }
.cc-node h4 { font-size: 16.5px; font-weight: 800; letter-spacing: -0.015em;
  margin-bottom: 8px; }
.cc-node p { font-size: 13.5px; color: var(--gray-600); line-height: 1.7;
  margin-bottom: 12px; }
.cc-risk { display: inline-block; font-size: 12.5px; font-weight: 700;
  line-height: 1.55; color: var(--gray-500);
  border-top: 1px dashed var(--gray-300); padding-top: 11px; }
.cc-risk b { color: #C65A2E; font-weight: 800; }
.cc-tie { text-align: center; margin-top: 40px; font-size: 16px;
  font-weight: 800; color: var(--black); letter-spacing: -0.015em; }
.cc-tie em { font-style: normal; color: var(--accent-dark); }

/* ── 묶음 헤더 ── */
.pd-part { padding: 80px 0 8px; }
.pd-part .part-label { font-size: 13px; font-weight: 900; letter-spacing: 0.1em;
  text-transform: uppercase; color: var(--accent-dark); margin-bottom: 12px; }
.pd-part h2 { font-size: clamp(1.6rem, 3.2vw, 2.3rem); letter-spacing: -0.02em;
  line-height: 1.3; margin-bottom: 14px; }
.pd-part .part-sub { font-size: 15.5px; color: var(--gray-600); line-height: 1.75;
  max-width: 620px; }

/* ── 기능 블록 (텍스트 | 목업) ── */
.pf-block { display: grid; grid-template-columns: 0.85fr 1.15fr; gap: 60px;
  align-items: center; padding: 74px 0; }
.pf-block.rev { grid-template-columns: 1.15fr 0.85fr; }
.pf-block.rev .pf-text { order: 2; }
.pf-block.rev .pf-visual { order: 1; }
.pf-num { font-size: 12.5px; font-weight: 900; letter-spacing: 0.08em;
  color: var(--accent-dark); margin-bottom: 12px; }
.pf-text h3 { font-size: clamp(1.5rem, 2.9vw, 2rem); letter-spacing: -0.025em;
  line-height: 1.32; margin-bottom: 16px; }
.pf-text p { font-size: 15.5px; color: var(--gray-600); line-height: 1.85; }
.pf-visual { min-width: 0; }

/* ── 다크 묶음 (관리자) ── */
.pd-dark { background: #0D0F12; }
.pd-dark .pd-part { padding-top: 92px; }
.pd-dark .pd-part .part-label { color: #1FDBA8; }
.pd-dark .pd-part h2 { color: var(--white); }
.pd-dark .pd-part .part-sub { color: #9AA5B4; }
.pd-dark .pf-num { color: #1FDBA8; }
.pd-dark .pf-text h3 { color: var(--white); }
.pd-dark .pf-text p { color: #9AA5B4; }
.pd-dark-end { height: 84px; }

/* ── 브리지 섹션 (기록 → 데이터) ── */
.pd-bridge { background: var(--gray-50); border-top: 1px solid var(--border);
  padding: 76px 0; }
.pd-bridge .bg-head { text-align: center; max-width: 620px; margin: 0 auto 36px; }
.pd-bridge h2 { font-size: clamp(1.45rem, 2.9vw, 2rem); letter-spacing: -0.025em;
  line-height: 1.36; margin-bottom: 14px; }
.pd-bridge .bg-sub { font-size: 15px; color: var(--gray-600); line-height: 1.8; }
.bg-conv { display: grid; grid-template-columns: 1fr auto 1fr;
  gap: 20px; align-items: center; }
.bg-side { background: var(--white); border: 1px solid var(--border);
  border-radius: 16px; padding: 20px; }
.bg-side .bs-label { font-size: 11.5px; font-weight: 900; letter-spacing: 0.06em;
  text-transform: uppercase; color: var(--gray-400); margin-bottom: 13px; }
.bg-chips { display: flex; flex-wrap: wrap; gap: 7px; }
.bg-chips span { font-size: 12.5px; font-weight: 700; color: var(--gray-700);
  background: var(--gray-100); border-radius: 8px; padding: 7px 11px; }
.bg-side.out { border-color: var(--black); }
.bg-side.out .bs-label { color: var(--black); }
.bg-out-row { display: flex; justify-content: space-between; align-items: baseline;
  padding: 9px 0; border-bottom: 1px solid var(--gray-100); font-size: 13px; }
.bg-out-row:last-child { border-bottom: none; }
.bg-out-row span { color: var(--gray-600); }
.bg-out-row b { font-size: 14.5px; letter-spacing: -0.01em; }
.bg-out-row b.warn { color: #C65A2E; }
.bg-out-row b.mint { color: var(--accent-dark); }
.bg-arrow { width: 40px; height: 40px; border-radius: 50%; background: var(--black);
  color: var(--white); display: flex; align-items: center; justify-content: center;
  font-size: 17px; font-weight: 900; box-shadow: var(--shadow-md); }

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
.mk-desk .mk-bar i { width: 9px; height: 9px; border-radius: 50%; background: #4A5568; }
.mk-desk .mk-screen { background: #F7F7F7; padding: 18px; font-size: 12px; }

/* 듀얼(폰⇄태블릿 흐름) */
.mk-duo { display: grid; grid-template-columns: 1.3fr auto 1fr;
  align-items: center; gap: 10px; }
.mk-duo .mk-phone { width: 100%; margin: 0; }
.mk-duo .mk-tablet { padding: 7px; }
.duo-arrow { width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
  background: var(--accent-light); color: var(--accent-dark);
  display: flex; align-items: center; justify-content: center;
  font-size: 16px; font-weight: 900; box-shadow: var(--shadow-sm); }

/* 목업 내부 공통 */
.mk-head { display: flex; justify-content: space-between; align-items: center;
  margin-bottom: 12px; }
.mk-head b { font-size: 13px; color: #282828; }
.mk-head span { font-size: 10.5px; color: #9AA5B4; }
.mk-sec { font-size: 10.5px; font-weight: 900; letter-spacing: 0.06em;
  color: #9AA5B4; text-transform: uppercase; margin: 14px 0 7px; }
.mk-sec:first-child { margin-top: 0; }
.mk-block { background: #FFFFFF; border-radius: 10px; padding: 12px;
  margin-bottom: 8px; border: 1px solid #EEEEF0; }
.mk-block .bk-title { display: flex; justify-content: space-between;
  font-size: 12px; font-weight: 800; color: #282828; margin-bottom: 8px; }
.mk-block .bk-title i { font-style: normal; font-weight: 700; color: #9AA5B4; }
.mk-sub { font-size: 11px; color: #4A5568; line-height: 1.55; }
.mk-table { width: 100%; border-collapse: collapse; font-size: 11px; }
.mk-table th { text-align: left; color: #9AA5B4; font-weight: 700;
  padding: 3px 6px; border-bottom: 1px solid #EEEEF0; }
.mk-table td { padding: 4px 6px; color: #2D3748; border-bottom: 1px solid #F5F5F7; }
.mk-btn-row { display: flex; gap: 8px; margin: 4px 0 8px; }
.mk-chip { flex: 1; text-align: center; padding: 8px 0; border-radius: 8px;
  font-size: 11px; font-weight: 800; background: #FFFFFF;
  border: 1px solid #E2E8F0; color: #4A5568; }
.mk-chip.ai { background: #E6FBF5; border-color: #BFF0E2; color: #15B88E; }
.mk-chip.dark { background: #282828; border-color: #282828; color: #FFFFFF; }
.mk-chip.off { opacity: .42; }
.mk-comment { background: #FFFFFF; border-radius: 10px; padding: 11px 12px;
  border: 1px solid #EEEEF0; font-size: 11.5px; color: #4A5568; line-height: 1.6; }
.mk-comment b { display: block; font-size: 11px; color: #282828; margin-bottom: 4px; }
.mk-save { margin-top: 8px; text-align: center; padding: 10px 0;
  border-radius: 9px; background: #282828; color: #FFFFFF;
  font-size: 12px; font-weight: 800; }
.mk-arrive { display: flex; gap: 10px; align-items: center; background: #FFFFFF;
  border-radius: 12px; padding: 12px; border: 1px solid #EEEEF0; margin-bottom: 8px; }
.mk-arrive .av { width: 34px; height: 34px; border-radius: 50%; flex-shrink: 0;
  background: #E6FBF5; display: flex; align-items: center; justify-content: center;
  font-size: 15px; }
.mk-arrive b { display: block; font-size: 12px; color: #282828; }
.mk-arrive span { font-size: 10.5px; color: #9AA5B4; }
.mk-filters { display: flex; gap: 6px; margin-bottom: 9px; flex-wrap: wrap; }
.mk-filters span { padding: 5px 11px; border-radius: 999px; font-size: 10.5px;
  font-weight: 700; background: #FFFFFF; border: 1px solid #E2E8F0; color: #718096; }
.mk-filters span.on { background: #282828; border-color: #282828; color: #FFFFFF; }
.mk-row { display: flex; align-items: center; gap: 9px; background: #FFFFFF;
  border: 1px solid #EEEEF0; border-radius: 10px; padding: 10px 12px;
  margin-bottom: 7px; font-size: 11.5px; }
.mk-row .nm { font-weight: 800; color: #282828; }
.mk-row .mt { color: #9AA5B4; flex: 1; }
.mk-row .ac { padding: 5px 10px; border-radius: 7px; background: #F1F5F9;
  color: #4A5568; font-size: 10.5px; font-weight: 800; }
.mk-row .ac.warn { background: #FFE4D9; color: #C65A2E; }
.mk-row .ac.mint { background: #E6FBF5; color: #15B88E; }
.mk-stats { display: flex; gap: 8px; margin-bottom: 8px; }
.mk-stat { flex: 1; background: #FFFFFF; border: 1px solid #EEEEF0;
  border-radius: 10px; padding: 10px 8px; text-align: center; }
.mk-stat b { display: block; font-size: 15px; color: #282828; }
.mk-stat.mint b { color: #15B88E; }
.mk-stat.warn b { color: #C65A2E; }
.mk-stat span { font-size: 10px; color: #9AA5B4; }
.mk-bars { background: #FFFFFF; border: 1px solid #EEEEF0; border-radius: 10px;
  padding: 12px; margin-bottom: 8px; }
.mk-bars .br { display: flex; align-items: center; gap: 8px; margin: 7px 0;
  font-size: 10.5px; color: #4A5568; }
.mk-bars .br em { font-style: normal; width: 52px; flex-shrink: 0; }
.mk-bars .br i { height: 8px; border-radius: 4px; background: #282828; }
.mk-bars .br i.mint { background: #1FDBA8; }
.mk-bars .br i.blue { background: #4F8EF7; }
.mk-bars .br b { font-size: 10.5px; color: #282828; }
.mk-chat { display: flex; flex-direction: column; gap: 7px; }
.mk-bubble { max-width: 84%; padding: 9px 12px; border-radius: 13px;
  font-size: 11.5px; line-height: 1.5; }
.mk-bubble.me { align-self: flex-end; background: #282828; color: #FFFFFF;
  border-bottom-right-radius: 4px; }
.mk-bubble.you { align-self: flex-start; background: #FFFFFF; color: #2D3748;
  border: 1px solid #EEEEF0; border-bottom-left-radius: 4px; }
.mk-bubble.aians { align-self: flex-start; background: #E6FBF5; color: #14523F;
  border: 1px solid #BFF0E2; border-bottom-left-radius: 4px; }
.mk-photos { display: flex; gap: 7px; }
.mk-photo { flex: 1; aspect-ratio: 3/4; border-radius: 9px;
  background: linear-gradient(160deg, #E2E8F0, #CBD5E0);
  display: flex; align-items: center; justify-content: center;
  font-size: 10px; color: #718096; font-weight: 700; }
.mk-photo.wide { aspect-ratio: 16/9; }
.mk-push { background: #FFFFFF; border: 1px solid #E2E8F0;
  border-radius: 12px; padding: 11px 12px; margin-bottom: 8px; }
.mk-push .ph { display: flex; justify-content: space-between; font-size: 10px;
  color: #9AA5B4; margin-bottom: 5px; font-weight: 700; }
.mk-push b { font-size: 11.5px; color: #282828; display: block; margin-bottom: 2px; }
.mk-push span { font-size: 11px; color: #4A5568; line-height: 1.5; }
.mk-donut-wrap { display: flex; gap: 8px; }
.mk-donut-card { flex: 1; background: #FFFFFF; border: 1px solid #EEEEF0;
  border-radius: 10px; padding: 11px; text-align: center; }
.mk-donut-card b { display: block; font-size: 10.5px; color: #282828; margin-bottom: 8px; }
.mk-donut { width: 64px; height: 64px; border-radius: 50%; margin: 0 auto 7px;
  position: relative; }
.mk-donut::after { content: ''; position: absolute; inset: 15px;
  border-radius: 50%; background: #FFFFFF; }
.mk-donut.d1 { background: conic-gradient(#282828 0 42%, #4F8EF7 42% 100%); }
.mk-donut.d2 { background: conic-gradient(#1FDBA8 0 38%, #282828 38% 72%, #9AA5B4 72% 100%); }
.mk-legend { font-size: 9.5px; color: #718096; line-height: 1.6; }

/* ── 실물 재현 컴포넌트 (2026-07-23 앱 캡처 기반) ── */
/* 주간 캘린더 (강사 일정) */
.mk-cal { background:#FFF; border:1px solid #EEEEF0; border-radius:10px; overflow:hidden; }
.mk-cal-legend { display:flex; gap:9px; flex-wrap:wrap; padding:8px 10px; font-size:9px; color:#718096; }
.mk-cal-legend i { display:inline-block; width:6px; height:6px; border-radius:50%; margin-right:3px; }
.mk-cal-head { display:grid; grid-template-columns:30px repeat(5,1fr); border-top:1px solid #EEEEF0;
  border-bottom:1px solid #EEEEF0; }
.mk-cal-head div { text-align:center; padding:5px 0; font-size:9.5px; color:#9AA5B4; }
.mk-cal-head div b { display:block; font-size:11.5px; color:#282828; }
.mk-cal-head div.today b { background:#282828; color:#FFF; width:17px; height:17px; line-height:17px;
  border-radius:50%; margin:1px auto 0; }
.mk-cal-body { display:grid; grid-template-columns:30px repeat(5,1fr); position:relative; }
.mk-cal-time { border-right:1px solid #F1F5F9; }
.mk-cal-time span { display:block; height:26px; font-size:8.5px; color:#9AA5B4; text-align:right;
  padding-right:4px; }
.mk-cal-col { border-right:1px solid #F5F5F7; position:relative; }
.mk-cal-col:last-child { border-right:none; }
.mk-ev { position:absolute; left:2px; right:2px; border-radius:5px; padding:4px 5px;
  font-size:8.5px; line-height:1.3; color:#FFF; overflow:hidden; }
.mk-ev b { display:block; font-size:9px; font-weight:800; }
.mk-ev.pt { background:#4CAF8E; }
.mk-ev.pt2 { background:#8FD4BB; }
.mk-ev.etc { background:#8A8F98; }
/* 지표 카드 (체성분) */
.mk-metrics { display:grid; grid-template-columns:repeat(4,1fr); gap:6px; margin-bottom:9px; }
.mk-metric { background:#FFF; border:1px solid #EEEEF0; border-radius:9px; padding:9px 8px; }
.mk-metric.on { border-color:#1FDBA8; background:#F2FDF9; }
.mk-metric .mh { display:flex; justify-content:space-between; align-items:baseline; margin-bottom:3px; }
.mk-metric .mh span { font-size:9px; color:#718096; }
.mk-metric .mh em { font-style:normal; font-size:8.5px; color:#9AA5B4; }
.mk-metric .mh em.dn { color:#F65271; }
.mk-metric b { font-size:14px; color:#282828; }
.mk-metric b u { text-decoration:none; font-size:9px; color:#9AA5B4; font-weight:600; }
/* 라인 차트 */
.mk-line { background:#FFF; border:1px solid #EEEEF0; border-radius:9px; padding:10px 8px 6px;
  margin-bottom:9px; }
.mk-line svg { display:block; width:100%; height:64px; }
.mk-line-x { display:flex; justify-content:space-between; padding:4px 6px 0; font-size:8.5px; color:#9AA5B4; }
/* 체형 사진 3분할 */
.mk-pose { display:flex; gap:5px; }
.mk-pose figure { flex:1; margin:0; aspect-ratio:3/4; border-radius:6px; position:relative;
  background:linear-gradient(165deg,#E6EAEF,#CBD5E0); overflow:hidden; }
.mk-pose figure span { position:absolute; left:4px; bottom:4px; background:rgba(40,40,40,.72);
  color:#FFF; font-size:8px; font-weight:700; padding:2px 5px; border-radius:3px; }
.mk-pose figure svg { position:absolute; inset:0; width:100%; height:100%; }
/* 데스크톱 테이블 (전체 회원) */
.mk-dt { width:100%; border-collapse:collapse; font-size:10.5px; }
.mk-dt th { text-align:center; color:#9AA5B4; font-weight:700; padding:6px 4px;
  border-bottom:1px solid #EEEEF0; }
.mk-dt td { text-align:center; padding:7px 4px; color:#4A5568; border-bottom:1px solid #F5F5F7; }
.mk-dt td.nm { font-weight:800; color:#282828; }
.mk-dt .st { padding:2px 7px; border-radius:999px; font-size:9px; font-weight:800; }
.mk-dt .st.on { background:#4CAF8E; color:#FFF; }
.mk-dt .st.wait { background:#FE9971; color:#FFF; }
/* 급여 카드 */
.mk-pay-sum { background:#FFF; border:1px solid #EEEEF0; border-radius:10px; padding:12px;
  display:flex; justify-content:space-between; align-items:flex-end; margin-bottom:9px; }
.mk-pay-sum .l span { display:block; font-size:10.5px; font-weight:800; color:#282828; }
.mk-pay-sum .l em { font-style:normal; font-size:9px; color:#9AA5B4; }
.mk-pay-sum .r { font-size:15px; font-weight:800; color:#282828; }
.mk-pay-grid { display:grid; grid-template-columns:1fr 1fr; gap:7px; }
.mk-pay-card { background:#FFF; border:1px solid #EEEEF0; border-radius:10px; padding:10px; }
.mk-pay-card .ph { display:flex; align-items:center; gap:6px; margin-bottom:7px; }
.mk-pay-card .av { width:22px; height:22px; border-radius:50%; background:#4A5568; color:#FFF;
  font-size:9px; font-weight:800; display:flex; align-items:center; justify-content:center; }
.mk-pay-card .ph b { font-size:11px; color:#282828; }
.mk-pay-card .ph em { font-style:normal; font-size:8.5px; color:#9AA5B4; display:block; }
.mk-pay-row { display:flex; justify-content:space-between; font-size:9.5px; color:#4A5568;
  padding:3px 0; }
.mk-pay-card .tot { border-top:1px solid #F1F5F9; margin-top:6px; padding-top:6px; }
.mk-pay-card .tot span { font-size:8.5px; color:#9AA5B4; display:block; }
.mk-pay-card .tot b { font-size:13px; color:#282828; }
/* 회원앱 홈 (주간 캘린더 + 기록) */
.mk-week { display:flex; justify-content:space-between; margin-bottom:11px; }
.mk-week div { text-align:center; font-size:9px; color:#9AA5B4; }
.mk-week div b { display:block; font-size:11px; color:#4A5568; margin-top:3px; }
.mk-week div.on b { background:#282828; color:#FFF; width:20px; height:20px; line-height:20px;
  border-radius:50%; margin:3px auto 0; }
.mk-rec { display:flex; align-items:center; gap:9px; background:#FFF; border:1px solid #EEEEF0;
  border-radius:10px; padding:10px 11px; margin-bottom:6px; }
.mk-rec .ic { width:26px; height:26px; border-radius:7px; background:#F1F5F9; display:flex;
  align-items:center; justify-content:center; font-size:13px; flex-shrink:0; }
.mk-rec b { font-size:11.5px; color:#282828; display:block; }
.mk-rec em { font-style:normal; font-size:9.5px; color:#9AA5B4; }
.mk-rec .ar { margin-left:auto; color:#CBD5E0; font-size:11px; }

@media (max-width: 860px) {
  .pf-block, .pf-block.rev { grid-template-columns: 1fr; gap: 28px; padding: 44px 0; }
  .pf-block.rev .pf-text { order: 1; }
  .pf-block.rev .pf-visual { order: 2; }
  .cc-life { grid-template-columns: repeat(2, 1fr); gap: 24px 14px; }
  .cc-life::before { display: none; }
  .bg-conv { grid-template-columns: 1fr; }
  .bg-arrow { transform: rotate(90deg); margin: 0 auto; }
  .mk-duo { grid-template-columns: 1fr; }
  .duo-arrow { transform: rotate(90deg); margin: 0 auto; }
}
'''

# ─────────────────────── 조립 헬퍼 ───────────────────────
def block(idx, num, h3, p, visual):
    """대분류 1개 = 텍스트 + 목업 한 덩어리. 짝수/홀수로 좌우 교차."""
    rev = ' rev' if idx % 2 == 1 else ''
    return f'''<div class="container">
  <div class="pf-block{rev}" id="{num[1]}">
    <div class="pf-text">
      <div class="pf-num">{num[0]}</div>
      <h3>{h3}</h3>
      <p>{p}</p>
    </div>
    <div class="pf-visual">{visual}</div>
  </div>
</div>'''

def tablet(inner):  return f'<div class="mk-tablet"><div class="mk-screen">{inner}</div></div>'
def phone(inner):   return f'<div class="mk-phone"><div class="mk-screen">{inner}</div></div>'
def desk(inner):    return f'<div class="mk-desk"><div class="mk-bar"><i></i><i></i><i></i></div><div class="mk-screen">{inner}</div></div>'
def duo(l, r):      return f'<div class="mk-duo">{l}<div class="duo-arrow">→</div>{r}</div>'

# ─────────────────────── 목업 (정보 통합형) ───────────────────────

# 01 스케줄 — 예약요청/확정 + 그룹수업 + 출석 + 기타일정 + 리마인드
MK_SCH_L = phone('''
  <div class="mk-head"><b>수업 예약</b><span>박준형 강사</span></div>
  <div class="mk-btn-row"><div class="mk-chip">10:00</div><div class="mk-chip off">11:00</div></div>
  <div class="mk-btn-row"><div class="mk-chip dark">19:00</div><div class="mk-chip">20:00</div></div>
  <div class="mk-save">예약 요청하기</div>
  <div class="mk-push" style="margin-top:10px"><div class="ph"><span>SSENTIF</span><span>오후 7:00</span></div>
    <b>내일 수업 리마인드</b><span>내일 19:00 개인수업이 있어요 👟</span></div>''')
MK_SCH_R = tablet('''
  <div class="mk-head"><b>스케줄</b><span>7월 20일 – 7월 26일</span></div>
  <div class="mk-cal">
    <div class="mk-cal-legend">
      <span><i style="background:#4CAF8E"></i>개인수업</span><span><i style="background:#4F8EF7"></i>그룹수업</span>
      <span><i style="background:#FE9971"></i>상담</span><span><i style="background:#8A8F98"></i>센터 일정</span>
    </div>
    <div class="mk-cal-head">
      <div></div>
      <div>월<b>20</b></div><div>화<b>21</b></div><div>수<b>22</b></div>
      <div class="today">목<b>23</b></div><div>금<b>24</b></div>
    </div>
    <div class="mk-cal-body">
      <div class="mk-cal-time"><span>14</span><span>16</span><span>18</span><span>20</span><span>21</span></div>
      <div class="mk-cal-col"><div class="mk-ev pt2" style="top:56px;height:24px"><b>현세빈</b>17:30</div>
        <div class="mk-ev pt" style="top:100px;height:24px"><b>유민지</b>20:30</div></div>
      <div class="mk-cal-col"></div>
      <div class="mk-cal-col"><div class="mk-ev pt2" style="top:78px;height:24px"><b>유민지</b>19:00</div>
        <div class="mk-ev pt2" style="top:104px;height:22px"><b>유민지</b>20:30</div></div>
      <div class="mk-cal-col"><div class="mk-ev pt" style="top:2px;height:24px"><b>현세빈</b>14:00</div>
        <div class="mk-ev etc" style="top:56px;height:20px">소방점검</div></div>
      <div class="mk-cal-col"><div class="mk-ev pt" style="top:92px;height:24px"><b>유민지</b>20:00</div></div>
    </div>
  </div>''')
MK_SCHEDULE = duo(MK_SCH_L, MK_SCH_R)

# 02 수업일지 — 작성(AI초안)/도착 + 이전기록 + 상담기록
MK_LOG_L = tablet('''
  <div class="mk-head"><b>수업 기록 · 현세빈 회원님</b><span>방금 저장됨</span></div>
  <div class="mk-sec">바벨 벤치프레스 <span style="font-weight:600;color:#9AA5B4">가슴</span></div>
  <table class="mk-table" style="margin-bottom:8px">
    <tr><th>Set</th><th>지난</th><th>무게 (kg)</th><th>횟수 (회)</th></tr>
    <tr><td>1</td><td style="color:#9AA5B4">40×10</td><td><b>60</b></td><td><b>12</b></td></tr>
    <tr><td>2</td><td style="color:#9AA5B4">40×10</td><td><b>65</b></td><td><b>10</b></td></tr>
    <tr><td>3</td><td style="color:#9AA5B4">40×10</td><td><b>70</b></td><td><b>8</b></td></tr>
  </table>
  <div class="mk-comment"><b>운동 메모 <span style="float:right;color:#15B88E">✨ AI 향상</span></b>벤치 70kg 첫 성공! 어깨 안정성이 눈에 띄게 좋아졌어요.</div>
  <div class="mk-sec">이전 기록</div>
  <div class="mk-row"><span class="nm">7/18</span><span class="mt">11회차 · 가슴·삼두</span></div>
  <div class="mk-row"><span class="nm">첫 상담</span><span class="mt">목표 체지방 -5% · 허리 부상 이력</span></div>''')
MK_LOG_R = phone('''
  <div class="mk-head"><b>2026년 7월</b><span>🔔</span></div>
  <div class="mk-week">
    <div>일<b>19</b></div><div>월<b>20</b></div><div>화<b>21</b></div>
    <div>수<b>22</b></div><div class="on">목<b>23</b></div><div>금<b>24</b></div><div>토<b>25</b></div>
  </div>
  <div class="mk-arrive"><div class="av">📝</div><div><b>수업일지가 도착했습니다</b><span>박준형 강사 · 방금 전</span></div></div>
  <div class="mk-sec">오늘의 기록</div>
  <div class="mk-rec"><div class="ic">🥗</div><div><b>식단</b><em>오늘 먹은 식단 인증</em></div><span class="ar">›</span></div>
  <div class="mk-rec"><div class="ic">🏃</div><div><b>운동</b><em>개인 운동 기록</em></div><span class="ar">›</span></div>
  <div class="mk-rec"><div class="ic">⚖️</div><div><b>체성분</b><em>체중·골격근량 측정</em></div><span class="ar">›</span></div>''')
MK_CLASSLOG = duo(MK_LOG_L, MK_LOG_R)

# 03 루틴 — 처방 + 수행체크 + 커스텀 운동 DB
MK_RTN_L = tablet('''
  <div class="mk-head"><b>루틴 처방</b><span>수 · 금 반복</span></div>
  <div class="mk-row"><span class="nm">스쿼트</span><span class="mt">3세트 × 12회</span><span class="ac">영상 ▶</span></div>
  <div class="mk-row"><span class="nm">런지</span><span class="mt">3세트 × 10회</span><span class="ac">영상 ▶</span></div>
  <div class="mk-row"><span class="nm">밴드 사이드워크</span><span class="mt">내 운동 DB</span><span class="ac mint">커스텀</span></div>
  <div class="mk-save">루틴 보내기</div>''')
MK_RTN_R = phone('''
  <div class="mk-head"><b>오늘의 루틴</b><span>2/3 완료</span></div>
  <div class="mk-block">
    <div class="bk-title">스쿼트 <i>3세트</i></div>
    <div class="mk-photos" style="margin-bottom:8px"><div class="mk-photo wide">동작 영상 ▶</div></div>
    <div class="mk-btn-row" style="margin:0"><div class="mk-chip dark">12</div><div class="mk-chip dark">11</div><div class="mk-chip">—</div></div>
  </div>
  <div class="mk-row"><span class="nm">런지</span><span class="mt">완료 ✓</span></div>''')
MK_ROUTINE = duo(MK_RTN_L, MK_RTN_R)

# 04 식단 — 업로드 + 피드백 + 누적 모아보기(체중 연관)
MK_DIET_L = phone('''
  <div class="mk-head"><b>오늘의 식단</b><span>7/22 (화)</span></div>
  <div class="mk-block"><div class="bk-title">점심 <i>12:40</i></div>
    <div class="mk-photos"><div class="mk-photo">🥗</div><div class="mk-photo">🍗</div></div></div>
  <div class="mk-block"><div class="bk-title">저녁 <i>미기록</i></div>
    <div class="mk-sub">사진 한 장이면 기록 완료</div></div>''')
MK_DIET_R = tablet('''
  <div class="mk-sec">식단 피드백</div>
  <div class="mk-comment" style="margin-bottom:8px"><b>내 코멘트</b>단백질 구성 좋아요 👍 저녁 탄수화물만 조금 줄여볼까요?</div>
  <div class="mk-sec">최근 4주 · 체중 변화와 함께</div>
  <div class="mk-bars">
    <div class="br"><em>1주</em><i style="width:78%"></i><b>기록 6/7일</b></div>
    <div class="br"><em>2주</em><i style="width:52%"></i><b>4/7일</b></div>
    <div class="br"><em>3주</em><i class="mint" style="width:88%"></i><b>7/7일</b></div>
  </div>
  <div class="mk-row"><span class="nm">체중</span><span class="mt">기록률 높은 주에 감소폭 큼</span><span class="ac mint">-1.2kg</span></div>''')
MK_DIET = duo(MK_DIET_L, MK_DIET_R)

# 05 성장 데이터 — 인바디/체형 + AI분석 + 회원 통계 + 웰니스
MK_GROW_L = tablet('''
  <div class="mk-head"><b>체성분 · 현세빈 회원님</b><span>전체보기 ›</span></div>
  <div class="mk-metrics">
    <div class="mk-metric on"><div class="mh"><span>체중</span><em class="dn">-0.2</em></div><b>46.1<u> kg</u></b></div>
    <div class="mk-metric"><div class="mh"><span>골격근량</span><em class="dn">-0.1</em></div><b>19.5<u> kg</u></b></div>
    <div class="mk-metric"><div class="mh"><span>체지방량</span><em>0.0</em></div><b>12.9<u> kg</u></b></div>
    <div class="mk-metric"><div class="mh"><span>체지방률</span><em class="dn">-2.9</em></div><b>21.8<u> %</u></b></div>
  </div>
  <div class="mk-line">
    <svg viewBox="0 0 300 64" preserveAspectRatio="none">
      <defs><linearGradient id="gfill" x1="0" y1="0" x2="0" y2="1">
        <stop offset="0%" stop-color="#1FDBA8" stop-opacity=".22"/>
        <stop offset="100%" stop-color="#1FDBA8" stop-opacity="0"/></linearGradient></defs>
      <path d="M14 12 L104 30 L194 40 L284 46 L284 64 L14 64 Z" fill="url(#gfill)"/>
      <path d="M14 12 L104 30 L194 40 L284 46" stroke="#1FDBA8" stroke-width="2" fill="none"/>
      <circle cx="14" cy="12" r="3.5" fill="#FFF" stroke="#1FDBA8" stroke-width="2"/>
      <circle cx="104" cy="30" r="3.5" fill="#FFF" stroke="#1FDBA8" stroke-width="2"/>
      <circle cx="194" cy="40" r="3.5" fill="#FFF" stroke="#1FDBA8" stroke-width="2"/>
      <circle cx="284" cy="46" r="4" fill="#1FDBA8"/>
    </svg>
    <div class="mk-line-x"><span>07.13</span><span>07.14</span><span>07.19</span><span>07.21</span></div>
  </div>
  <div class="mk-sec">체형 사진 · AI 자세 분석</div>
  <div class="mk-pose">
    <figure><svg viewBox="0 0 60 80" fill="none" stroke="#7BE0B8" stroke-width="1.2"><circle cx="30" cy="12" r="5"/><path d="M30 17v26M30 22l-11 9M30 22l11 9M30 43l-8 22M30 43l8 22M22 65l-2 8M38 65l2 8"/><circle cx="19" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="41" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="30" cy="43" r="1.6" fill="#7BE0B8"/></svg><span>정면</span></figure>
    <figure><svg viewBox="0 0 60 80" fill="none" stroke="#7BE0B8" stroke-width="1.2"><circle cx="30" cy="12" r="5"/><path d="M30 17v26M30 22l-11 9M30 22l11 9M30 43l-8 22M30 43l8 22M22 65l-2 8M38 65l2 8"/><circle cx="19" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="41" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="30" cy="43" r="1.6" fill="#7BE0B8"/></svg><span>측면</span></figure>
    <figure><svg viewBox="0 0 60 80" fill="none" stroke="#7BE0B8" stroke-width="1.2"><circle cx="30" cy="12" r="5"/><path d="M30 17v26M30 22l-11 9M30 22l11 9M30 43l-8 22M30 43l8 22M22 65l-2 8M38 65l2 8"/><circle cx="19" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="41" cy="31" r="1.6" fill="#7BE0B8"/><circle cx="30" cy="43" r="1.6" fill="#7BE0B8"/></svg><span>후면</span></figure>
  </div>''')
MK_GROW_R = phone('''
  <div class="mk-head"><b>내 성장</b><span>최근 3개월</span></div>
  <div class="mk-bars">
    <div class="br"><em>5월</em><i style="width:72%"></i><b>25.0%</b></div>
    <div class="br"><em>6월</em><i style="width:63%"></i><b>23.4%</b></div>
    <div class="br"><em>7월</em><i class="mint" style="width:55%"></i><b>21.8%</b></div>
  </div>
  <div class="mk-sec">오늘의 웰니스</div>
  <div class="mk-stats" style="margin:0">
    <div class="mk-stat"><b>7.2h</b><span>수면</span></div>
    <div class="mk-stat"><b>1.8L</b><span>수분</span></div>
    <div class="mk-stat mint"><b>8,420</b><span>걸음</span></div>
  </div>''')
MK_GROWTH = duo(MK_GROW_L, MK_GROW_R)

# 06 소통 — 1:1 채팅 + 공지 발송/열람률 + 공유 메모
MK_COMM_L = phone('''
  <div class="mk-head"><b>박준형 강사</b><span>1:1 채팅</span></div>
  <div class="mk-chat">
    <div class="mk-bubble me">쌤 오늘 10분만 늦을게요 🙏</div>
    <div class="mk-bubble you">네 천천히 오세요~ 폼롤러로 풀고 있어요.</div>
    <div class="mk-bubble me">넵! 어제 루틴도 다 했어요 💪</div>
  </div>''')
MK_COMM_R = tablet('''
  <div class="mk-sec">공지 발송</div>
  <div class="mk-block"><div class="bk-title">8월 여름휴가 휴무 안내</div>
    <div class="mk-sub">8/11~8/13 휴무입니다. 보강 예약 잡아드릴게요.</div></div>
  <div class="mk-stats">
    <div class="mk-stat"><b>48</b><span>발송</span></div>
    <div class="mk-stat"><b>41</b><span>열람</span></div>
    <div class="mk-stat mint"><b>85%</b><span>열람율</span></div>
  </div>
  <div class="mk-sec">팀 공유 메모</div>
  <div class="mk-row"><span class="nm">기구 점검</span><span class="mt">3번 러닝머신 수리 완료</span></div>''')
MK_COMMUNICATION = duo(MK_COMM_L, MK_COMM_R)

# B1 운영 대시보드 — 업무알림 + 매출 + 위험도 + 공지성과
MK_DASH = desk('''
  <div class="mk-head"><b>운영 대시보드</b><span>2026년 7월</span></div>
  <div class="mk-sec">업무 알림 · 오늘 12건</div>
  <div class="mk-filters"><span class="on">전체 12</span><span>이탈 3</span><span>만료 5</span><span>신규 4</span></div>
  <div class="mk-row"><span class="nm">김O은</span><span class="mt">최근 14일 미출석 · 이탈 위험</span><span class="ac warn">채팅</span></div>
  <div class="mk-row"><span class="nm">이O호</span><span class="mt">수강권 3회 남음 · 만료 임박</span><span class="ac">정산 입력</span></div>
  <div class="mk-sec">이번 달 매출 · 운영 위험도</div>
  <div class="mk-stats">
    <div class="mk-stat"><b>845만</b><span>판매(원)</span></div>
    <div class="mk-stat"><b>20건</b><span>시설6 · 수업14</span></div>
    <div class="mk-stat warn"><b>1,230만</b><span>잠재부채</span></div>
  </div>
  <div class="mk-sec">공지 성과</div>
  <div class="mk-bars" style="margin:0">
    <div class="br"><em>열람율</em><i class="mint" style="width:66%"></i><b>80%</b></div>
    <div class="br"><em>액션율</em><i class="blue" style="width:29%"></i><b>34%</b></div>
  </div>''')

# B2 회원 관리 — 전체조회 + 배정 + 구성분석
MK_MEMBERS = desk('''
  <div class="mk-head"><b>데이즈 피트니스 전체 회원</b><span>총 128명</span></div>
  <div class="mk-filters"><span class="on">전체</span><span>활성</span><span>일시정지</span><span>만료</span><span>미배정</span></div>
  <table class="mk-dt">
    <tr><th style="text-align:left">이름</th><th>담당강사</th><th>연락처</th><th>시설이용권</th><th>개인수업</th><th>회원 상태</th></tr>
    <tr><td class="nm" style="text-align:left">김O지</td><td>박준형</td><td>010-1234-****</td><td>D-31</td><td>잔여 10회</td><td><span class="st on">활성</span></td></tr>
    <tr><td class="nm" style="text-align:left">현O빈</td><td>박준형</td><td>010-4015-****</td><td>D-5</td><td>잔여 10회</td><td><span class="st on">활성</span></td></tr>
    <tr><td class="nm" style="text-align:left">유O지</td><td>최유나</td><td>010-3323-****</td><td>D-47</td><td>잔여 8회</td><td><span class="st on">활성</span></td></tr>
    <tr><td class="nm" style="text-align:left">박O훈</td><td style="color:#C65A2E;font-weight:800">미배정</td><td>—</td><td>—</td><td>—</td><td><span class="st wait">대기</span></td></tr>
  </table>
  <div class="mk-sec">회원 구성</div>
  <div class="mk-donut-wrap">
    <div class="mk-donut-card"><b>성별 · 연령</b><div class="mk-donut d1"></div>
      <div class="mk-legend">■ 남 42% · <span style="color:#4F8EF7">■</span> 여 58%</div></div>
    <div class="mk-donut-card"><b>상품 유형</b><div class="mk-donut d2"></div>
      <div class="mk-legend"><span style="color:#1FDBA8">■</span> 개인 38% · ■ 시설 34% · <span style="color:#9AA5B4">■</span> 그룹 28%</div></div>
  </div>''')

# B3 정산과 팀 — 급여계산 + 명세서 + 팀원권한
MK_PAYROLL = desk('''
  <div class="mk-head"><b>급여 정산</b><span>2026년 7월 · 정산 중</span></div>
  <div class="mk-pay-sum">
    <div class="l"><span>총 예정 실지급액</span><em>데이즈 피트니스 직원의 당월 실수령 합계</em></div>
    <div class="r">1,900,400원</div>
  </div>
  <div class="mk-sec">직원별 급여 · 2명</div>
  <div class="mk-pay-grid">
    <div class="mk-pay-card">
      <div class="ph"><div class="av">정</div><div><b>정O훈</b><em>정규직 · 강사</em></div></div>
      <div class="mk-pay-row"><span>기본급</span><span>1,200,000원</span></div>
      <div class="mk-pay-row"><span>수업(개인+그룹)</span><span>420,000원</span></div>
      <div class="tot"><span>예정 실지급액 · 3.3% 반영</span><b>1,566,540원</b></div>
    </div>
    <div class="mk-pay-card">
      <div class="ph"><div class="av">손</div><div><b>손O준</b><em>정규직 · 소유자</em></div></div>
      <div class="mk-pay-row"><span>기본급</span><span>500,000원</span></div>
      <div class="mk-pay-row"><span>수업(개인+그룹)</span><span>240,000원</span></div>
      <div class="tot"><span>예정 실지급액</span><b>740,000원</b></div>
    </div>
  </div>''')

# B4 AI — 자연어 질문 + 팀 가시성
MK_AI = desk('''
  <div class="mk-head"><b>AI 어시스턴트</b><span>센터 데이터 연결됨</span></div>
  <div class="mk-chat" style="margin-bottom:12px">
    <div class="mk-bubble me">이번 달 매출 왜 줄었어?</div>
    <div class="mk-bubble aians">재등록이 전월 대비 4건 줄었습니다. 만료 예정 5명 중 3명이 미응답이에요. 이 3명부터 연락해보시는 걸 권장합니다. → 회원 보기</div>
    <div class="mk-bubble me">박준형 강사 이번 달 수업 몇 건이야?</div>
    <div class="mk-bubble aians">42건 완료, 예정 6건입니다. 작성률 96%예요.</div>
  </div>
  <div class="mk-sec">강사별 현황</div>
  <div class="mk-row"><span class="nm">박준형</span><span class="mt">완료 42건 · 담당 18명</span><span class="ac">작성률 96%</span></div>
  <div class="mk-row"><span class="nm">김태호</span><span class="mt">완료 21건 · 담당 9명</span><span class="ac warn">작성률 71%</span></div>''')

# ─────────────────────── 페이지 조립 ───────────────────────
HERO = '''
<section class="pd-hero">
  <div class="container">
    <div class="badge">제품 소개</div>
    <h1>회원이 떠나기 전에,<br><span class="hl">센터가 먼저 압니다</span></h1>
    <p class="sub">수업에서 남긴 기록이 회원의 경험이 되고, 그 데이터가 원장님의 판단 근거가 됩니다.</p>
    <div class="pd-hero-jump">
      <a class="pd-jump light" href="#part-a">🏋️ 강사와 회원 경험 보기</a>
      <a class="pd-jump dark" href="#part-b">🏢 관리자 경험 보기</a>
    </div>
  </div>
</section>
'''

CONCEPT = '''
<section class="pd-concept">
  <div class="container">
    <div class="cc-head">
      <h2>회원이 떠나는 건<br>어느 날 갑자기가 아닙니다</h2>
      <p class="cc-sub">이탈은 만료일에 일어나지만, 신호는 <b>훨씬 앞에서</b> 시작됩니다. 각 시점의 공백이 다음 단계로 넘어갈지를 결정합니다.</p>
    </div>
    <div class="cc-life">
      <div class="cc-node">
        <div class="cc-dot">🔥</div>
        <span class="cc-when">1주차</span>
        <h4>등록 직후</h4>
        <p>의욕이 가장 높은 시기. 무엇을 위해 시작했는지가 분명합니다.</p>
        <span class="cc-risk">목표를 기록하지 않으면 <b>방향이 사라집니다</b></span>
      </div>
      <div class="cc-node">
        <div class="cc-dot">🌱</div>
        <span class="cc-when">1개월</span>
        <h4>습관 형성기</h4>
        <p>수업 외의 시간에 무엇을 하느냐로 결과가 갈립니다.</p>
        <span class="cc-risk">수업 없는 날이 비면 <b>리듬이 끊깁니다</b></span>
      </div>
      <div class="cc-node risk">
        <div class="cc-dot">😐</div>
        <span class="cc-when">3개월</span>
        <h4>정체기</h4>
        <p>"효과가 있나?" 의심이 드는 구간. 출석이 흔들리기 시작합니다.</p>
        <span class="cc-risk">변화를 못 보여주면 <b>확신이 사라집니다</b></span>
      </div>
      <div class="cc-node end">
        <div class="cc-dot">🤔</div>
        <span class="cc-when">만료 전</span>
        <h4>재등록 결정</h4>
        <p>지난 3개월이 값어치를 했는지 스스로 계산합니다.</p>
        <span class="cc-risk">근거가 없으면 <b>가격 얘기만 남습니다</b></span>
      </div>
    </div>
    <p class="cc-tie">센티프는 이 네 시점에 <em>각각 개입합니다.</em></p>
  </div>
</section>
'''

PART_A = '''
<section class="pd-part" id="part-a">
  <div class="container">
    <div class="part-label">Part 1 · 강사와 회원</div>
    <h2>주 2회 만나는 회원을,<br>주 7일 관리합니다</h2>
    <p class="part-sub">예약부터 수업일지, 루틴과 식단, 성장 데이터까지 — 강사가 남긴 기록이 회원의 경험이 되고, 회원의 기록이 강사의 다음 수업이 됩니다.</p>
  </div>
</section>
'''

A1 = block(0, ('01 스케줄', 'cat-sch'), '묻지 않아도 맞춰지는 수업 일정',
  '강사가 열어둔 시간에 회원이 직접 예약을 요청하고, 수락 한 번으로 확정됩니다. 그룹수업 정원과 출석 체크, 개인 일정 보호, 하루 전 리마인드까지 캘린더 하나에서 처리됩니다.',
  MK_SCHEDULE)

A2 = block(1, ('02 수업일지', 'cat-log'), '적는 수업에서, 남는 수업으로',
  '템플릿과 AI 초안으로 수업 후 1분이면 기록이 끝납니다. 그 기록이 회원 앱에 그대로 도착하고, 지난 기록과 첫 상담 목표는 다음 수업의 준비 자료가 됩니다.',
  MK_CLASSLOG)

A3 = block(2, ('03 루틴 처방', 'cat-rtn'), '수업 없는 날에도 관리는 계속됩니다',
  '강사가 보낸 루틴이 회원의 오늘 할 일이 됩니다. 동작 영상을 보며 따라하고 세트를 체크하면 수행 여부가 강사에게 공유됩니다. 우리 센터만의 운동도 직접 등록해 쓸 수 있습니다.',
  MK_ROUTINE)

A4 = block(3, ('04 식단', 'cat-diet'), '사진 한 장으로 이어지는 식단 코칭',
  '끼니마다 사진 한 장이면 기록이 끝납니다. 강사는 코멘트로 바로 반응하고, 쌓인 기록은 체중 변화와 나란히 놓여 무엇이 결과를 만들었는지 보여줍니다.',
  MK_DIET)

A5 = block(4, ('05 성장 데이터', 'cat-grow'), '느낌이 아니라 숫자로 보여주는 변화',
  '인바디 수치와 3각도 사진이 시간순으로 쌓이고, AI가 체형 밸런스를 분석합니다. 회원은 자기 변화를 그래프로 확인하고, 강사는 정리된 성과를 재등록 상담의 근거로 씁니다.',
  MK_GROWTH)

A6 = block(5, ('06 소통', 'cat-comm'), '연락처 공개 없이, 채널 하나로',
  '일정 조율부터 운동 질문까지 앱 안에서 끝납니다. 공지는 푸시로 보내고 열람률까지 확인되며, 팀 공유 메모로 인수인계가 한곳에 모입니다.',
  MK_COMMUNICATION)

BRIDGE = '''
<section class="pd-bridge">
  <div class="container">
    <div class="bg-head">
      <h2>강사와 회원의 기록이 쌓이면,<br>원장님의 판단 근거가 됩니다</h2>
      <p class="bg-sub">수업일지 한 건, 출석 한 번은 낱개의 기록입니다. 모이면 이탈 신호가 되고, 매출 예측이 됩니다.</p>
    </div>
    <div class="bg-conv">
      <div class="bg-side">
        <div class="bs-label">현장에 쌓이는 기록</div>
        <div class="bg-chips">
          <span>수업일지 240건</span><span>출석 960회</span><span>체성분 88건</span>
          <span>루틴 수행 412회</span><span>식단 사진 1,204장</span><span>채팅 3,400건</span>
        </div>
      </div>
      <div class="bg-arrow">→</div>
      <div class="bg-side out">
        <div class="bs-label">대시보드에 뜨는 판단 재료</div>
        <div class="bg-out-row"><span>이탈 위험 회원</span><b class="warn">3명</b></div>
        <div class="bg-out-row"><span>이번 달 재등록률</span><b class="mint">82%</b></div>
        <div class="bg-out-row"><span>잠재부채</span><b>1,230만원</b></div>
        <div class="bg-out-row"><span>강사별 일지 작성률</span><b>92%</b></div>
      </div>
    </div>
  </div>
</section>
'''

PART_B = '''
<section class="pd-part" id="part-b">
  <div class="container">
    <div class="part-label">Part 2 · 관리자</div>
    <h2>감이 아니라 숫자로<br>센터를 운영합니다</h2>
    <p class="part-sub">강사와 회원이 주고받은 모든 기록이 관리자의 대시보드로 모입니다. 출근하면 오늘 할 일이 정해져 있습니다.</p>
  </div>
</section>
'''

B1 = block(0, ('01 운영 대시보드', 'cat-dash'), '매일 아침, 센터의 상태가 한눈에',
  '출석이 끊긴 회원과 만료 임박 수강권을 앱이 먼저 알려줍니다. 이번 달 매출과 유형별 판매, 미소진 수업이 만든 잠재부채, 보낸 공지의 열람률까지 한 화면에 모입니다.',
  MK_DASH)

B2 = block(1, ('02 회원 관리', 'cat-members'), '담당이 없어도, 전체가 보입니다',
  '센터의 모든 회원을 상태별로 걸러보고 검색합니다. 미배정 회원은 강사별 담당 인원을 보며 배정하고, 성별·연령·상품 분포로 어떤 층에 무엇을 제안할지 판단합니다.',
  MK_MEMBERS)

B3 = block(2, ('03 정산과 팀', 'cat-payroll'), '월말 정산, 화면 안에서 끝냅니다',
  '완료된 수업이 자동 집계되어 단가제·비율제로 계산되고, 원천징수 3.3%까지 반영된 실지급액이 나옵니다. 명세서는 버튼 하나로 전달되고 팀원 권한도 같은 화면에서 관리합니다.',
  MK_PAYROLL)

B4 = block(3, ('04 AI 어시스턴트', 'cat-ai'), '물어보면 데이터로 답합니다',
  '매출과 회원에 대해 말로 물어보면 센터의 실제 데이터를 근거로 답하고, 답변에서 해당 화면으로 바로 이동합니다. 강사별 수업 건수와 일지 작성률도 함께 확인합니다.',
  MK_AI)

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
{CONCEPT}
{PART_A}
{A1}
{A2}
{A3}
{A4}
{A5}
{A6}

{BRIDGE}

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
print('생성 완료: %d줄 / 기능블록 %d개 / 생애주기 노드 %d개' % (
    page.count('\n'),
    len(re.findall(r'class="pf-block', page)),
    len(re.findall(r'class="cc-node', page))))
