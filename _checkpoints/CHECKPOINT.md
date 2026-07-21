# SSENTIF 홈페이지 — 작업 체크포인트

> **목적**: 컨텍스트가 압축되거나 세션이 바뀌어도 흐름이 끊기지 않도록 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-07-21 (커밋 `569d94c` 배포 완료, clean tree)

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇**: SSENTIF(센티프) — PT센터 AI 운영 워크스페이스 SaaS의 마케팅 홈페이지. 순수 정적 HTML/CSS/JS.
- **어디**: `/Users/jinhunjung/ssentif-redesign/` → GitHub `nononong247/ssentif-redesign` → Vercel 자동배포
- **라이브**: https://www.ssentif.kr
- **지금 상태**: **index + pricing + consulting 리디자인 완료·배포됨.** admin 백오피스 정합화 완료. 성능 최적화 적용됨. 미배포 변경 없음.
- **다음 할 일**: (1) product/lab/cases 카피 검토, (2) Supabase 백엔드 연동 → admin 완성

## 로컬 개발

```bash
cd ~/ssentif-redesign && python3 -m http.server 8990   # → http://127.0.0.1:8990
```

- style.css는 `?v=N` 캐시버스팅 (**현재 v=2**). style.css 수정 시 6개 HTML의 `?v=` 번호를 함께 올릴 것.
- 확인 시 `Cmd+Shift+R` 하드 새로고침 병행.
- **배치 커밋 원칙**: 사용자가 "배포해줘"라고 할 때만 commit+push.

## 1. 확정 정책 (되돌리면 안 됨)

### 요금제 (2026-07-21 확정)
- 워크스페이스 인원 1명당 **25,900원/월**, owner 포함 전원 과금. 월 선불, 연간 플랜 없음.
- **1인**: 무료/유료 선택. 무료 = 조회 최근 30일 제한(기록은 보존), 유료 = 전체 기간. **기능 차이 없음, 조회 기간이 유일한 차이.**
- **2인 이상**: 무조건 유료 (결제일 시점 인원 기준 재계산).
- 결제수단 미등록 시 2번째 인원 초대 발송 자체가 불가.
- 플랜 명칭 **Free / Pro / Enterprise** — "Starter"는 폐기됨, 재사용 금지.
- **"14일 무료 체험"은 존재하지 않는 정책** — 사이트 전체에서 제거됨. 재등장 금지.

### 사이트 전역 용어 (전 페이지 통일)
- 네비/푸터: **"도입 절차"** (구 "맞춤 도입") · 모든 CTA 버튼: **"도입 상담 신청"**
- CTA 밴드 4페이지(index/pricing/product/cases) **문자 단위 동일**: "차이를 만드는 선택, 센티프와 시작해보세요"
- 가격 표기: `₩` 기호 금지, 숫자 뒤 **'원'** (`25,900원`)

### 카피 작업 원칙
- **반드시 제안 먼저, 승인 후 구현.** 임의 카피 변경 금지.
- 제안 2회 연속 거절 시 → 변주를 멈추고 "어떤 걱정을 해소해야 하나"를 물을 것.

## 2. 페이지별 현재 구조

### pricing.html ✅
1. 히어로 "센터 운영에 필요한 하나의 도구" (서브 없음)
2. **팀/개인 토글 — 팀이 기본.** 팀 = Pro(BEST, 25,900원/1인당·매월) + Enterprise(맞춤 견적) / 개인 = Free + Pro
3. 개인 뷰 두 카드: 기능 12줄 동일, 첫 줄 조회기간(최근 30일 vs 전체 기간)만 다름 — 이 대비가 의도
4. 인원 계산기(슬라이더) → FAQ 7문항 → CTA 밴드

### consulting.html ✅ (이번 세션 전면 개편)
1. 히어로 `.intro-hero`: 좌 "혼자 시작하지 않으셔도 됩니다" + 민트보더 리드 / 우 일러스트 webp
2. 걱정 2×2 `.worry-grid`: 이모지 원 + 따옴표 장식. 수치는 사용자 제공값(실사용률 100%, 신규문의 83%·재등록률 90%·회원 편의성 95%) — 임의 수정 금지
3. 프로세스 5카드 `.proc-grid`: 고스트 넘버 + 마지막 다크 카드
   ① 1:1 도입 상담 ② 데이터 이전 ③ 온보딩 교육 ④ 전담 케어 ⑤ **시스템 정착**(사용률 100%)
4. 교육 사진 4장 `.field-photos` — **캡션 없음(넣지 말 것, "없어 보인다" 피드백)**
5. 폼: 성함*/직함/연락처*/이메일/센터명*/**센터규모*** /문의내용
   - 센터규모 선지: `1인 (개인 또는 혼자 운영)` / `2~5인` / `6~10인` / `11인 이상 · 다지점`
   - **관심플랜 필드·운영시간 배지는 삭제됨 — 복원 금지** (규모만 알면 담당자가 요금제 안내 가능하다는 결정)
6. FAQ(pricing과 공유) → CTA 밴드

### index.html ✅ (이전 세션)
히어로 → result-cards → 손글씨 → 회원 마퀴(49×2장, lazy) → 모드 소개 → 벤토 5카드 → 전/후 비교 → 6 STEP → 기본기능 8종 → 인터뷰 영상 6개(라이트박스) → CTA 밴드
- 고객사례 h2: "센티프는 시설이 아니라 회원을 관리하는 시스템이에요"

### admin/ ✅ 정합화됨 (프로토타입)
- inquiries/dashboard: **관심플랜 컬럼·모달·CSV 제거**, 센터규모 중심 전환
- settings: "도입 상담 폼" 용어 통일
- Supabase `inquiries.plan` 컬럼은 이제 항상 빈 값 — 백엔드 작업 때 정리

## 3. 성능 최적화 (적용됨)

- lazy: index 마퀴 100장 + cases 6장 (`loading="lazy" decoding="async"`)
- 히어로 일러스트 PNG 287KB → **WebP 42KB** (PNG 삭제됨, 원본은 Desktop/작업파일/자료 사진/)
- 교육 사진 4장: 800×600 JPEG q82 progressive (원본 PNG 2.0MB → 272KB)
- `vercel.json` 신설: `/assets/*` + `style.css` 1년 immutable / `*.html` must-revalidate
- 전 페이지 no-cache 메타 3종 제거

## 4. 함정·주의

- **FAQ는 pricing + consulting 두 파일에 복제** — 수정 시 양쪽 함께 (검증: 문자 단위 일치)
- **CTA 밴드는 4파일에 복제** — 마찬가지
- style.css 수정 → 6개 HTML의 `?v=` 올리기
- 애니메이션 섹션 스크린샷이 빈 화면으로 나오는 경우 있음 → DOM 검증(innerText/getBoundingClientRect)으로 대체
- `nth-child` 금지 관례 — 고유 클래스 + 인라인 `--d` 지연 사용
- 미사용 CSS 검사 스크립트: `<style>`에서 `.class` 추출 → 마크업 class 토큰 + `<script>` 본문에 없으면 죽은 클래스 (admin은 JS 템플릿 동적 클래스 오탐 있음: hold/badge/nav-badge)
- 앱 기능 검증 기준: `~/Desktop/작업파일/GRIP_NOTE-main/` (코치앱/회원앱/관리자웹/backend)
- 도입절차 걱정카드·프로세스의 "센티프 대표가 직접 교육" — STEP 3 "관리자·강사 교육 구분"과 표현 일관성 유지

## 5. 다음 할 일 (우선순위)

1. **product.html / lab.html / cases.html 카피 검토**
   - cases.html: unsplash 스톡사진 + 가상 후기 카드가 index의 실제 인터뷰 영상과 충돌 — 정리 필요
2. **Supabase 백엔드**: 테이블 확정 → consulting 폼 연동(이미 `db.from('inquiries').insert` 코드 있음) → lab 뉴스레터 → admin 완성(login/RLS)
   - `inquiries.plan` 컬럼 정리
3. Supabase free tier 유지 ping (cron-job.org)
4. (정책 대기) Enterprise 가격, 다지점 워크스페이스 구조, 코드 초대 결제 게이트, 인원 감소 반영 시점

## 6. 참고 링크

- GitHub: https://github.com/nononong247/ssentif-redesign
- 라이브: https://www.ssentif.kr
- 이전 홈페이지: https://ssentif-fitness.imweb.me/
- 인터뷰 영상 채널: https://www.youtube.com/@ssentif_official/videos
