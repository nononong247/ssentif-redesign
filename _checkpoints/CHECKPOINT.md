# SSENTIF 홈페이지 — 작업 체크포인트

> **목적**: 컨텍스트가 압축되거나 세션이 바뀌어도 흐름이 끊기지 않도록 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-07-21

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇**: SSENTIF(센티프) — PT센터 AI 운영 워크스페이스 SaaS의 마케팅 홈페이지. 순수 정적 HTML/CSS/JS.
- **핵심 파일**: `/Users/jinhunjung/ssentif-redesign/index.html` (156KB, 작업 대부분 여기), `style.css` (전역 공용)
- **지금 상태**: **index.html 전 섹션 리디자인 완료.** 커밋 `ed6a305`까지 전부 배포 완료 — 미배포 변경 없음(clean tree).
- **다음 할 일**: (1) 나머지 페이지(product/consulting/lab/cases) 카피 검토, (2) Supabase 백엔드 연동 → 백오피스 완성

---

## 1. 프로젝트 파일 구조

| 경로 | 내용 |
|------|------|
| `index.html` | **메인 랜딩** — 작업 대부분 집중. CSS/JS가 인라인 `<style>`/`<script>`에 있음 |
| `style.css` | **전역 공용** — nav, footer, btn, `.cta-band` 등. 수정 시 전 페이지 영향 |
| `product.html` | 제품 소개 (관리자/강사/회원 3관점) |
| `pricing.html` | 요금제 (Free / Pro ₩22,900 / Enterprise) |
| `consulting.html` | 맞춤 도입 상담 폼 — **Supabase 연동 예정** |
| `lab.html` | 운영지원실 (아티클) — **Supabase 연동 예정** |
| `cases.html` | 고객 사례 (별도 페이지, 자체 CSS 완비) |
| `admin/` | **백오피스 프로토타입** (login·dashboard·inquiries·settings·lab, 5개 108KB). 어디에도 링크 안 됨 — 완성 예정 작업물이므로 삭제 금지 |
| `assets/members/member-01~49.jpg` | 실제 회원 인증 사진 49장 (4:5, 480×600) |
| `assets/icons/`, `assets/logo/` | 글래스 3D 아이콘 3종, 로고 |
| `design/design-system.html` | 홈페이지 디자인 시스템 참고 문서 (링크 안 됨, 내부용) |
| `supabase/`, `supabase-client.js`, `supabase-schema.sql` | 백엔드 연동용 (예정) |
| `_checkpoints/CHECKPOINT.md` | 이 문서 |
| `_checkpoints/OPERATION_PROCESS_HANDOFF.md` | 2026-07-15 이전 세션 인계 문서 — 내용 대부분 반영 완료, 참고용 |

---

## 2. 기술 스택 및 배포

- **스택**: 순수 정적 HTML/CSS/JS (프레임워크 없음, 빌드 없음)
- **배포**: GitHub push → Vercel 자동 배포
- **GitHub**: https://github.com/nononong247/ssentif-redesign
- **라이브**: https://www.ssentif.kr (커스텀 도메인)
- **로컬 프리뷰**: `python3 -m http.server 8990` → `http://127.0.0.1:8990`

### ⚠️ 배치 커밋 원칙 (사용자 지정, 반드시 준수)
> **"하나하나 수정할 때마다 커밋·배포하면 토큰 낭비야. 내가 중간에 배포 한번씩 해달라고 할 테니까, 그 전까지는 파일만 업데이트해줘."**
> → 매 수정마다 git 건드리지 말 것. **파일 저장만 하고, 사용자가 "배포해줘"라고 명시할 때만 commit + push.**

### DNS (가비아) — 완료, 변경 불필요
| 타입 | 호스트 | 값 |
|------|--------|-----|
| CNAME | www | `a5ff7d6bd217cf51.vercel-dns-017.com` |
| A | @ | `216.198.79.1` |
| TXT | _vercel | `vc-domain-verify=ssentif.kr,45751fc637099ced2f5f` |

---

## 3. 앱 소스 = 카피 검증의 근거 (경로 변경됨)

**2026-07-20부터 `GRIP_NOTE-main` 모노레포가 기준.** 이전에 쓰던 `SSENTIF DESIGN/`은 구버전.

```
/Users/jinhunjung/Desktop/작업파일/GRIP_NOTE-main/
├── grip_note_coach/    # 코치(강사/관리자) 앱 — payroll, manager_dashboard, consultation 등
├── grip_note_members/  # 회원 앱 ★이번에 처음 확보 (session_log, stats, activity_upload)
├── grip_note_web/      # Next.js 관리자 웹
├── backend/            # Kotlin 서버
└── supabase/           # DB 스키마
```

**Why**: 홈페이지에 앱 기능·수치를 쓸 때 추정으로 쓰면 안 됨. 실제 코드로 검증한 사례:
- 잠재부채/안정성 등급 → `grip_note_coach/lib/domain/models/manager_risk.dart`
- 원천징수 3.3% 계산식 → `.../business_logic/payroll_calculator.dart` (`taxable = 기본급+개인+그룹+기타`, `netPay = taxable − floor(taxable×33/1000)`)
- 체형분석 정면/측면/후면 → `.../features/consultation/widgets/consultation_posture.dart`
- 잔여세션 3회 경고 → `app_config.dart`의 `warningSessionCount = 3`

**앱 디자인 시스템**: `GRIP_NOTE-main/ssentif-design-system.html` (구 `SSENTIF DESIGN/design/prototype/ssentif_color_standard.html`)
시맨틱 컬러: `success #5ABE8E` / `warning #FE9971` / `danger #F65271` / `info #4F8EF7` / `event #9C27B0`
→ **"디자인 컴포넌트 기준에 맞게"라는 지시가 나오면 이 팔레트 헥사코드만 사용할 것.**

---

## 4. index.html 섹션 구성 (위→아래, 전부 완료)

1. **히어로** — "만족도는 높이고 / 운영은 지속 가능하게" + 대시보드 목업 자리표시자
2. **result-cards** — 신규 유입 / 재등록률 / 회원 만족도 (글래스 3D 아이콘)
3. **차별화된 회원관리** — "이 센터 진짜 좋다" 손글씨 stroke-reveal 애니메이션(clip-path)
4. **소셜 프루프** — 실제 회원 49장 2줄 마퀴 + "수많은 회원이 써보고 증명한 결과입니다"
5. **모드 소개** — 회원앱(폰)·관리자웹(브라우저)·강사앱(**태블릿**) 목업 3열
6. **벤토 그리드 5카드** — 카드마다 다른 시맨틱 컬러 + 계속 도는 UI 애니메이션
   - bc-1 이탈방지(danger 핑크) / bc-2 잠재부채 ₩1.32억(warning 오렌지) / bc-3 AI매니저(민트)
   - bc-4 자동알림(info 블루, iOS 푸시 스타일) / bc-5 페이롤(**event 퍼플**, 세로 계산식)
7. **도입 전/후 비교표** — 다크 배경 + 격자. 6항목 4열 그리드(`120px 1fr 24px 1.15fr`)
8. **주요 기능 6 STEP** — 좌우 교대 카드, 세그먼트 진행바
9. **기본 기능 8종** — 목업 비주얼 4×2 그리드 (헤딩: "더 전문적인. 더 체계적인.")
10. **고객 사례** — 유튜브 인터뷰 영상 6개 + **페이지 내 라이트박스**
11. **CTA 밴드** — 격자 + 민트 오로라, 흰색 버튼 단일

---

## 5. 결정과 그 이유 (되돌리지 말 것)

### 카피 원칙 ⚠️ (CLAUDE.md에도 명시)
> **반드시 제안 먼저, 승인 후 구현.** 임의 변경 금지. 선택지를 제시하고 고른 뒤에만 수정.
> 디자인 큰 변경도 여러 안을 먼저 보여주는 패턴이 반복 확인됨.
> **주의**: 제안이 여러 번 거절되면 같은 프레임 안에서 변주하지 말고 **완전히 다른 각도**로 전환할 것. (이번 세션에서 9개 안이 연속 거절된 뒤에야 사용자가 진짜 의도 — "관리자는 '강사들이 잘 쓸까?'를 걱정한다" — 를 밝힘)

### 이번 세션 주요 결정
- **bc-2 잠재부채 = ₩1.32억, 회당 6만원 기준.** 강사 3명(241/185/132회)이 총량을 채우지 않고 "외 7명 더보기"로 더 있음을 암시 — 사용자 지시.
- **bc-5 페이롤 = event 퍼플**(`#9C27B0`). 실제 앱 계산식 그대로: 기본급+개인수업+그룹수업+기타−사업소득세(3.3%) = 실지급액. **원천징수는 error 색 금지**(앱 스펙 §2.2: 계산식 고정항목이라 중립색).
- **주요 기능 4개 → 6 STEP으로 확장.** AI 비서를 빼고 운영 위험도를 메인으로 승격(AI는 이미 사이트 곳곳에 노출돼 중복). 순서는 페인 강도순: 신뢰→소통→감지→운영진단→자동화→실행확인.
- **고객 사례를 인터뷰 영상으로 전면 교체.** 기존 특집사례·필터탭·사례카드 6개는 **검증되지 않은 가상 수치(+12%, 95% 등)** 포함이라 제거.
- **라이트박스 재생** — 새 창 대신 페이지 내. 닫을 때 `iframe src`를 비워야 소리가 멈춤. `youtube-nocookie.com` 사용. JS 미동작 시 `href` 폴백 유지.
- **CTA 버튼 흰색 단일.** 보조 버튼과 보증 문구(체크 3종)는 만들었다가 사용자 요청으로 제거 — "CTA는 하나만".

### 폐기·되돌린 것
- 벤토 카드 색 통일 → 사용자가 "일부러 다채롭게 한 것"이라며 되돌림. **의도를 먼저 물을 것.**
- 상단 요약 다이어그램(6단계 루프/2단계 카드) → 만들었다가 전부 삭제. 개별 STEP 카드로만 흐름 표현.
- `.hero-pill`을 다크 섹션에 재사용 → 밝은 히어로용이라 흰 그라데이션·초록 그림자가 내장돼 탁해짐. 다크용은 별도 클래스로 만들 것.

---

## 6. 함정 · 주의사항 (반복해서 시간 잡아먹은 것들)

### 🔴 style.css 캐시 — 가장 많이 혼선을 준 문제
로컬에서 CSS 변경이 반영 안 된 것처럼 보이는 일이 여러 번 발생. HTML에 `?v=N`을 붙여도 **style.css는 따로 캐시됨.**
- **사용자 확인 시**: `Cmd + Shift + R` (하드 새로고침) 필수
- **자동화로 확인 시**: 아래 JS로 stylesheet만 강제 재로드
  ```js
  document.querySelectorAll('link[rel=stylesheet]').forEach(x=>{
    const u=new URL(x.href); u.searchParams.set('cb',Date.now()); x.href=u.toString();
  });
  ```
- **증상 판별법**: `<em>`이 이탤릭으로 보이거나 버튼 색이 예전 색이면 캐시된 상태. `getComputedStyle`로 실제 값 찍어볼 것.

### 🔴 스크린샷 캡처 실패
index.html **하단 섹션(CTA·인터뷰)에서 스크린샷이 흰 화면으로 반복 실패.** 무한 CSS 애니메이션이 많아 렌더러가 멈추는 것으로 보임.
- 대안: `getComputedStyle` / `getBoundingClientRect` / `innerText`로 DOM 검증
- 또는 해당 섹션만 분리한 임시 프리뷰 파일을 만들어 캡처(단, 인라인 `<style>`에 정의된 클래스는 안 딸려오니 주의)

### 기타
- **`nth-child` 인덱스 밀림** — 형제 요소를 추가/삭제하면 `nth-child` 선택자가 엉뚱한 걸 가리킴. 이번 세션에서 두 번 발생. 애니메이션 딜레이는 인라인 `style="--d:.06s"`로 주는 게 안전.
- **인라인 style이 클래스보다 우선** — 목업 색 오버라이드 시 인라인이 있으면 클래스 수정이 무의미.
- **`float-card` vs `ms-float-card`** — grep의 `\b`는 하이픈을 경계로 봐서 오탐. 클래스 사용 여부는 `class="..."`를 공백 분리해 **정확히 토큰 매칭**할 것.
- **cases.html은 자체 CSS 완비** — index.html에서 `.case-card` 등을 지워도 안전(인라인 `<style>`은 파일 간 공유 안 됨).
- **Desktop 폴더 접근 거부** 시 → 시스템 설정 → 개인정보 보호 → 파일 및 폴더에서 **Claude** 앱 권한 확인 후 **앱 완전 재시작**(Cmd+Q). 실행 중 토글 변경은 소급 적용 안 됨.

---

## 7. 다음 할 일 (우선순위순)

1. **나머지 페이지 카피 검토** — product / consulting / lab / cases. index.html 톤(과장 없는 서술형)에 맞추기
2. **Supabase 백엔드 연동**
   - 테이블 구조 확정 → 프로젝트 세팅
   - `consulting.html` 문의 폼 연동
   - `lab.html` 뉴스레터 연동
3. **백오피스 완성** — `admin/`에 프로토타입 5개 존재. 로그인·문의 목록·상태 관리 실동작 구현
4. **Supabase free tier 유지** — cron-job.org 등으로 주기적 ping
5. (선택) 히어로 `hero-dashboard-mockup` 자리표시자 → 실제 스크린샷 교체

---

## 8. 참고 링크

- **라이브**: https://www.ssentif.kr
- **GitHub**: https://github.com/nononong247/ssentif-redesign
- **Vercel**: https://vercel.com (프로젝트: ssentif-redesign, 계정: nononong247-3414)
- **이전 홈페이지(imweb)**: https://ssentif-fitness.imweb.me/ — nav "이전 홈페이지" 버튼에 링크됨. 인터뷰 영상 3개의 출처
- **공식 유튜브**: https://www.youtube.com/@ssentif_official/videos — 인터뷰 CTA 링크
- **앱 소스**: `/Users/jinhunjung/Desktop/작업파일/GRIP_NOTE-main/`

---

## 9. 새 세션에서 재개하는 법

새 대화창에서:
> "ssentif-redesign 프로젝트 이어서 하자. `/Users/jinhunjung/ssentif-redesign/_checkpoints/CHECKPOINT.md` 읽어줘."

현재 작업 트리는 clean(커밋 `ed6a305`까지 배포 완료)이므로 §7 "다음 할 일"부터 바로 시작하면 됩니다.
