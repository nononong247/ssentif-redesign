# SSENTIF 프로젝트 브리핑

## 프로젝트 개요
- **서비스명**: SSENTIF (센티프)
- **서비스 유형**: 피트니스 센터를 위한 AI 운영 워크스페이스 (SaaS)
- **타겟**: 트레이너 3~5명 규모의 PT 센터 원장님
- **핵심 메시지**: 현장 데이터 기반 회원 이탈 방지, 재등록률 향상, 운영 자동화

## 브랜드 톤
- 데이터 기반, 실용적, 결과 중심
- 과장 없이 직접적인 표현
- 키워드: 재등록률, 현장 데이터, 이탈 신호, 체계적 회원관리

## 기술 스택
- 순수 정적 HTML/CSS/JS (프레임워크 없음)
- 파일: index.html, product.html, pricing.html, consulting.html, lab.html, cases.html, style.css

## 배포 정보
- **GitHub**: https://github.com/nononong247/ssentif-redesign
- **라이브 사이트**: https://www.ssentif.kr (커스텀 도메인, Vercel)
- **로컬 개발**: `python3 -m http.server 8990` → `http://127.0.0.1:8990`
- **배포 방법**: `git add . && git commit -m "..." && git push` → Vercel 자동 반영
- ⚠️ 로컬 확인 시 **`Cmd + Shift + R`(하드 새로고침)** 필수 — 일반 새로고침은 style.css를
  캐시에서 읽어 변경이 반영 안 된 것처럼 보임(이 문제로 여러 번 혼선 발생)

## 작업 방식 (중요)
- **배치 커밋**: 수정할 때마다 커밋하지 말고 파일만 저장. 사용자가 "배포해줘"라고
  명시할 때만 `git commit + push` 실행
- **앱 기능 검증 기준**: `/Users/jinhunjung/Desktop/작업파일/GRIP_NOTE-main/`
  (`grip_note_coach` 코치앱 / `grip_note_members` 회원앱 / `grip_note_web` 관리자웹 / `backend`)
  홈페이지에 앱 기능·수치를 쓸 때는 이 소스로 검증할 것

## 요금제 구조
- **Free**: 무료 / 트레이너 1인 / 회원 30명
- **Pro**: ₩22,900/월 / 트레이너 5인 / 회원 무제한
- **Enterprise**: 맞춤 견적

## 카피 작업 원칙 (중요)
- **반드시 제안 먼저, 승인 후 구현** — 절대 임의로 카피 변경 금지
- 선택지를 제시하고 유저가 고른 후에만 파일 수정

## 완료된 작업 (index.html 전 섹션 리디자인 완료, 2026-07-21)
- 히어로 / result-cards / 차별화된 회원관리(손글씨 애니메이션) / 소셜 프루프(실제 회원 49장 마퀴)
- 모드 소개 섹션 (회원앱·관리자웹·강사 태블릿 목업)
- **벤토 그리드 5카드** — 이탈방지/잠재부채/AI매니저/자동알림/페이롤, 앱 시맨틱 컬러 기반
- **도입 전/후 비교표** — 6항목 가로 그리드, 취소선 애니메이션 (이탈 조짐 최상단)
- **주요 기능 6 STEP** — 신뢰→소통→감지→운영진단→자동화→실행확인, 세그먼트 진행바
- **기본 기능 8종** — 매출 인사이트/공유 캘린더/AI 체형분석/회원 전용 앱/앱 푸시 공지/
  업무 채팅방/운동 라이브러리/공동 메모장 (목업 비주얼 4×2 그리드)
- **고객 사례** — 실사용자 인터뷰 영상 6개, 페이지 내 라이트박스 재생(새 창 X)
- **CTA 밴드** — 격자+민트 오로라 배경, 흰색 버튼 단일 구성
- 전 페이지 미사용 CSS 정리 완료(6개 페이지 죽은 클래스 0건)
- 커스텀 도메인·SEO(Google/Naver 등록, OG 이미지) 완료

## 미완료 작업 (카피/디자인)
- product.html, consulting.html, lab.html, cases.html 카피 검토

## 다음 세션 작업 (백엔드)
순서대로 진행:
1. Supabase 테이블 구조 확정
2. Supabase 프로젝트 세팅
3. consulting.html 폼 → Supabase 연동
4. lab.html 뉴스레터 → Supabase 연동
5. 백오피스 완성 (`admin/` 에 login·dashboard·inquiries·settings·lab 프로토타입 존재)
6. Supabase free tier 유지 — cron-job.org 등으로 주기적 ping
