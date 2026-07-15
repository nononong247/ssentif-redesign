# SSENTIF 홈페이지 — 작업 체크포인트

> **목적**: 컨텍스트가 가득 차거나 세션이 바뀌어도 흐름이 끊기지 않도록 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-07-15

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇을 만들고 있나**: SSENTIF(센티프) — PT센터 AI 운영 워크스페이스 SaaS의 마케팅 홈페이지. 순수 정적 HTML/CSS/JS.
- **핵심 파일**: `/Users/jinhunjung/ssentif-redesign/index.html` (메인), `style.css` (전역 스타일)
- **지금 어디까지**: 홈페이지 전체 구현 완료 + 커스텀 도메인 연결 + SEO 등록 완료. 현재 라이브 운영 중.
- **다음 할 일**: 백엔드 연동 (Supabase - 문의 폼, 뉴스레터), 백오피스 구현

---

## 1. 프로젝트 파일 구조

| 파일 | 내용 |
|------|------|
| `index.html` | 메인 랜딩 페이지 |
| `product.html` | 제품 소개 페이지 |
| `pricing.html` | 요금제 페이지 |
| `consulting.html` | 맞춤 도입 상담 폼 페이지 |
| `lab.html` | 운영지원실 (아티클 목록, Supabase 연동) |
| `style.css` | 전역 스타일시트 |
| `robots.txt` | 검색 크롤러 설정 |
| `sitemap.xml` | 사이트맵 (5개 페이지) |
| `og-image.png` | SNS 공유 미리보기 이미지 (1200×630) |
| `googlea4b1a9e69bc722d8.html` | Google Search Console 인증 파일 |

---

## 2. 기술 스택 및 배포

- **스택**: 순수 정적 HTML/CSS/JS (프레임워크 없음)
- **데이터**: Supabase JS SDK via CDN (아티클, 문의 폼)
- **배포**: GitHub push → Vercel 자동 배포
- **GitHub**: https://github.com/nononong247/ssentif-redesign
- **라이브**: https://www.ssentif.kr
- **배포 명령**: `git add . && git commit -m "..." && git push`
- **도메인**: 가비아에서 구매한 `ssentif.kr` → Vercel 연결 완료

### DNS 설정 (가비아)
| 타입 | 호스트 | 값 |
|------|--------|-----|
| CNAME | www | `a5ff7d6bd217cf51.vercel-dns-017.com` |
| A | @ | `216.198.79.1` |
| TXT | _vercel | `vc-domain-verify=ssentif.kr,45751fc637099ced2f5f` |

---

## 3. 브랜드 & 디자인 시스템

### 컬러
| 변수 | 헥사코드 | 용도 |
|------|----------|------|
| `--accent` | `#1FDBA8` | 민트 (메인 브랜드 컬러) |
| `--accent-dark` | `#15B88E` | 민트 hover 상태 |
| `--accent-light` | `#E6FBF5` | 민트 배경 |
| `--black` | `#0D0F12` | 텍스트, 배경 |
| `--white` | `#FFFFFF` | 배경 |

### 폰트
- **Pretendard**: 전체 기본 폰트 (한글 + 영문)
- **Nanum Pen Script**: `"이 센터 진짜 좋다"` 손글씨 연출에만 사용

### 네비게이션
- 플로팅 pill 형태 + 글래스 효과 (backdrop-filter blur)
- 레퍼런스: bevel.health 스타일

---

## 4. 결정과 그 이유 (되돌리지 말 것)

### 카피 작업 원칙 ⚠️ 매우 중요
> **반드시 제안 먼저, 승인 후 구현 — 절대 임의로 카피 변경 금지**
> 선택지를 제시하고 유저가 고른 후에만 파일 수정. 이를 어기면 사용자가 즉시 롤백 요청함.

### 완료된 주요 결정
- **bc-2 벤토 카드**: 검은 배경 → 민트(`var(--accent)`) 배경으로 변경 (사용자 승인)
- **데이터 경영 섹션 헤드라인**: "운영이 선명해집니다." (사용자 승인 A안)
- **대량 섹션 리디자인 시도**: 사용자가 "너무 별로인데?"로 거부 → `git revert`로 롤백. 한 번에 너무 많은 변경은 위험.
- **URL**: 전체 `ssentif-redesign.vercel.app` → `https://www.ssentif.kr` 로 교체 완료

### 폐기한 접근
- 대규모 일괄 섹션 변경: 사용자 거부 이력 있음. 앞으로는 섹션 하나씩 제안 후 진행.

---

## 5. SEO 현황

| 항목 | 상태 |
|------|------|
| Google Search Console | ✅ 등록 완료, 사이트맵 제출 완료 |
| Naver 서치어드바이저 | ✅ 등록 완료, 사이트맵 + 수집 요청 완료 |
| Google 인증 메타태그 | `index.html` `<head>`에 삽입 완료 |
| Naver 인증 메타태그 | `index.html` `<head>`에 삽입 완료 |
| OG 이미지 | ✅ `og-image.png` 생성 및 배포 완료 |
| 색인 반영 예상 | Google 1~2주, Naver 3~7일 |

---

## 6. 다음 할 일 (우선순위순)

1. **Supabase 백엔드 연동**
   - `consulting.html` 문의 폼 → Supabase `inquiries` 테이블
   - `lab.html` 뉴스레터 구독 → Supabase 연동
   - 현재: consulting.html 폼 UI는 완성, Supabase 연동만 남음

2. **백오피스 구현**
   - 로그인 → 문의 목록 조회 → 상태 관리 (신규/확인/완료)
   - settings.html → 현재 localStorage 사용 중 → Supabase settings 테이블로 이전 예정

3. **Supabase free tier 유지**
   - 비활성 7일 시 프로젝트 중단됨
   - cron-job.org로 주기적 ping 설정 필요

4. **OG 이미지 개선** (선택)
   - 현재 Python Pillow로 생성한 기본형
   - 필요 시 더 정교한 디자인으로 교체 가능

---

## 7. 함정 · 주의사항

- **인앱 브라우저 프리뷰 블랭크**: Claude Code 인앱 브라우저에서 사이트가 빈 화면으로 나옴. JS로 요소 존재 확인(`document.querySelector`) + 라이브 배포 후 확인하는 것이 워크어라운드.
- **대량 변경 금지**: 이전 세션에서 5개 섹션 동시 변경 시도 → 사용자 거부 → git revert. 한 섹션씩 제안/승인 후 진행.
- **Vercel 도메인**: `ssentif.kr` (루트)은 `www.ssentif.kr`로 308 리다이렉트. 실제 서빙은 www.
- **Supabase 미연동**: 현재 문의 폼 제출 시 Supabase로 저장은 됨 (이전 구현). Slack webhook은 server-side pg_net trigger로 처리 (consulting.html에서 직접 호출 안 함).

---

## 8. 참고 링크

- **라이브 사이트**: https://www.ssentif.kr
- **GitHub**: https://github.com/nononong247/ssentif-redesign
- **Vercel 대시보드**: https://vercel.com (프로젝트: ssentif-redesign, 계정: nononong247-3414)
- **Google Search Console**: https://search.google.com/search-console (속성: https://www.ssentif.kr/)
- **Naver 서치어드바이저**: https://searchadvisor.naver.com
- **가비아 DNS**: https://dns.gabia.com (도메인: ssentif.kr)

---

## 9. 새 세션에서 재개하는 법

새 대화창에서 이렇게 말하면 됩니다:
> "ssentif-redesign 프로젝트 이어서 하자. `/Users/jinhunjung/ssentif-redesign/_checkpoints/CHECKPOINT.md` 읽어줘."
