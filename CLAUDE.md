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
- **라이브 사이트**: https://ssentif-redesign.vercel.app
- **로컬 개발**: `python3 -m http.server 8899` (localhost:8899)
- **배포 방법**: `git add . && git commit -m "..." && git push` → Vercel 자동 반영

## 요금제 구조
- **Free**: 무료 / 트레이너 1인 / 회원 30명
- **Pro**: ₩22,900/월 / 트레이너 5인 / 회원 무제한
- **Enterprise**: 맞춤 견적

## 카피 작업 원칙 (중요)
- **반드시 제안 먼저, 승인 후 구현** — 절대 임의로 카피 변경 금지
- 선택지를 제시하고 유저가 고른 후에만 파일 수정

## 완료된 작업
- index.html 히어로 섹션 카피 완성
- result-cards 섹션 (3D 아이콘, 신규 유입 증가 / 재등록률 향상 / 회원 만족도 상승)
- 차별화된 회원관리 섹션 (수업일지, 식단, 개인운동 피드백)
- 소셜 프루프 섹션 (포토 마퀴 + 스탯 벤토 카드)
- pricing.html: Free / Pro(₩22,900) / Enterprise 구조 반영
- 전 페이지 푸터 태그라인 "AI 운영 워크스페이스" 통일

## 미완료 작업 (카피/디자인)
- index.html: 벤토 그리드, Before/After, 기능 상세, 고객 사례, CTA 섹션
- product.html, consulting.html, lab.html, cases.html 카피 검토

## 다음 세션 작업 (백엔드)
순서대로 진행:
1. 백오피스 UI/UX 설계
2. Supabase 테이블 구조 확정
3. Supabase 프로젝트 세팅
4. consulting.html 폼 → Supabase 연동
5. lab.html 뉴스레터 → Supabase 연동
6. 백오피스 구현 (로그인, 문의 목록, 상태 관리)
7. 배포
