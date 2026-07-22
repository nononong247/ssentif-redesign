# SSENTIF 홈페이지 — 작업 체크포인트

> **목적**: 컨텍스트가 압축되거나 세션이 바뀌어도 흐름이 끊기지 않도록 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-07-22 저녁 (배포 최신 커밋 `2494eaf` / **미커밋 변경 있음 — §0 참조**)

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇**: SSENTIF(센티프) — PT센터 AI 운영 워크스페이스 SaaS의 마케팅 홈페이지. 순수 정적 HTML/CSS/JS.
- **어디**: `/Users/jinhunjung/ssentif-redesign/` → GitHub `nononong247/ssentif-redesign` → Vercel 자동배포
- **라이브**: https://www.ssentif.kr · **백오피스**: https://www.ssentif.kr/admin/login.html
- **지금 상태**: 가격 24,900원 배포 완료. 슬랙 알림 새 채널로 정상 동작 확인.

### ⚠️ 미커밋 변경 3건 (다음 세션에서 처리 필요)

| 파일 | 내용 | 상태 |
|---|---|---|
| `consulting.html` | ① 성공화면 레이아웃 버그 수정 ② 문의내용 필수화 | **검증 완료, 배포만 남음** |
| `product-new.html` (untracked) | product 페이지에 설득 논리 층(개념 프레임+브리지) 추가한 시안 | **사용자 점검 대기** |
| `_checkpoints/build_product.py` | 위 시안을 만든 생성 스크립트 v3 | 시안과 세트 |
| `supabase/functions/notify-slack/` | 죽은 코드 삭제(`git rm` 완료) | 커밋만 남음 |

> `product-new.html`은 **사용자가 "점검하고 나중에 배포하자"고 보류**한 상태. 나머지 3건은 바로 배포 가능.

---

## 로컬 개발

```bash
cd ~/ssentif-redesign && python3 dev-server.py   # → http://127.0.0.1:8990
```

- ⚠️ **`python3 -m http.server` 쓰지 말 것** — Cache-Control 미전송으로 옛 HTML이 캐시에서 뜬다. `dev-server.py`가 no-store 헤더를 붙인 대체 서버.
- style.css는 `?v=N` 캐시버스팅 (**현재 v=2**). 수정 시 HTML들의 `?v=` 함께 올릴 것.
- **배치 커밋 원칙**: 사용자가 "배포해줘"라고 할 때만 commit+push.
- **카피 작업 원칙**: 반드시 제안 먼저, 승인 후 구현.

---

## 1. 문의 폼 → 슬랙 알림 구조 ★ 이번 세션 최대 수확

### 실제 파이프라인 (오해하기 쉬움)

```
consulting.html 폼 제출
  → Supabase inquiries INSERT
  → 트리거 on_inquiry_insert_notify_slack (AFTER INSERT, ROW)
  → DB 함수 notify_slack_on_inquiry()      ← 슬랙 URL이 여기 하드코딩
  → pg_net(net.http_post) → 슬랙 직접 POST
```

- 🔴 **`supabase/functions/notify-slack/`(Edge Function)은 이 흐름에 없다.** 배포는 돼 있었지만 아무도 호출하지 않는 죽은 코드였고, 이번에 **삭제함**. 이것 때문에 "Edge Function Secrets를 바꾸면 된다"고 오진해 시간을 크게 낭비했다. 다시 만들지 말 것.
- 슬랙 채널을 바꾸려면 → **`notify_slack_on_inquiry` 함수 안의 URL을 교체**하는 것이 유일한 방법.
  (Slack Incoming Webhook URL은 발급 시 채널이 고정으로 묶임)

### 채널 변경 절차 (다음에 또 필요하면)

1. 슬랙 앱(`도입문의_알림`, App ID `A0BJK1407E3`) → Incoming Webhooks → Add New Webhook → 채널 선택 → URL 복사
2. Supabase SQL Editor에서 `create or replace function notify_slack_on_inquiry()` 전체 재작성,
   `slack_url text := '...'` 한 줄에 새 URL 삽입 (현재 함수 형태가 이미 이 구조)
3. 검증: `select prosrc like '%hooks.slack.com%' from pg_proc where proname='notify_slack_on_inquiry';`

### 진단 도구

```sql
-- 슬랙 전송 결과 (200 ok = 슬랙이 받음 = 채널만 다른 것)
select id, status_code, left(coalesce(content,error_msg,'(없음)'),120), created
from net._http_response order by id desc limit 5;
```

### 이번에 고친 버그 2개 (함수 재작성으로 해결)

- 🔴 **문의 유실**: 슬랙 전송 실패 시 트리거 오류가 INSERT를 롤백시켜 **문의 자체가 저장되지 않았음.**
  → `exception when others then raise warning ...; return new;` 추가. 이제 슬랙이 죽어도 문의는 저장된다. **이 예외 블록을 제거하지 말 것.**
- 삭제된 `관심 플랜` 필드를 알림에 계속 출력하던 것 제거.

### 슬랙 앱 현황

| 앱 | App ID | 상태 |
|---|---|---|
| `도입문의_알림` | A0BJK1407E3 | **현재 사용 중** |
| `도입상담 문의_알림` | A0BDQ90FLVB | 옛 앱 — 폐기 처리함 |

---

## 2. 함정·주의 ★ 반드시 읽을 것

### RLS로 인한 오진 (이번에 실제로 당함)

`inquiries` 테이블은 **anon이 INSERT만 되고 SELECT는 불가**:

```sql
create policy "누구나 문의 등록 가능"   on inquiries for insert with check (true);
create policy "관리자만 조회/수정 가능" on inquiries for select using (auth.role() = 'authenticated');
```

→ **anon key로 조회하면 항상 `[]`가 나온다.** 이걸 보고 "문의 0건"이라 오판했으나 실제로는 권한 문제였다.
데이터 존재 여부를 anon 조회로 판단하지 말 것. 백오피스나 SQL Editor를 쓸 것.

### 기타

- **복제 블록 동기화**: 가이드 공통 섹션(2파일), 구조 스트립(3파일), FAQ(pricing+consulting), CTA 밴드(4파일) — 한쪽만 고치면 깨짐. 해시 대조로 검증.
- **Flutter SDK 미설치** — 앱 소스는 grep으로 문자열 확인만. 앱 기능·문구는 반드시 `~/Desktop/작업파일/GRIP_NOTE-main/` 소스로 검증(추측 금지).
- **앱 소스는 git 아님** — 수정 금지(개발자 담당), 롤백 불가.
- 작업 폴더 밖 대량 수정은 자동 승인 정책에 차단됨 — 우회 말고 사용자에게 알릴 것.
- Supabase SQL Editor는 **결과 셀이 길면 잘려서 표시**된다. 긴 함수 본문을 읽으려 하지 말고 통째로 재작성하는 편이 빠르다.
- SQL의 자리표시자(`PASTE_URL_HERE` 등)를 치환하지 않고 실행하면 그 문자열이 그대로 들어간다. 실행 전 확인 필수.

---

## 3. 확정 정책 (되돌리면 안 됨)

### 요금제 (2026-07-22 가격 조정)
- 워크스페이스 인원 1명당 **24,900원/월** (구 25,900원), owner 포함 전원 과금. 월 선불, 연간 플랜 없음.
- 1인: 무료/유료 선택(무료 = 조회 최근 30일 제한, 기능 차이 없음). 2인 이상: 무조건 유료.
- 명칭 Free/Pro/Enterprise("Starter" 재사용 금지). **"14일 무료 체험"은 없는 정책** — 재등장 금지.
- 가격 변경 시 `pricing.html` 10곳(메타5·카드2·계산기 초기값·수식2·**JS 상수 `SEAT_PRICE`**) + 문서 2곳 전부 확인.

### 워딩 톤 (가이드 3종 적용 완료)
- 어미는 **`~합니다` 체**. `~해주세요` 요청문은 유지.
- **강한 수식어 금지**: 완전히·절대·영구히·가장 강력한. 설명문에 감탄 이모지 금지.
- **삭제·탈퇴 경고는 수식어 대신 구체성으로**: 삭제 항목 명시 + "삭제된 데이터는 복구되지 않습니다".
- product.html은 마케팅 페이지라 가치 카피 톤 허용(용어 통일은 동일 적용).

### 용어 통일 (전 페이지 적용 완료)

| 개념 | **확정 용어** | 폐기 |
|---|---|---|
| 수업하는 사람 | **강사** | 트레이너, 코치 |
| 회원↔강사 연결 | **연동** | 매칭 |
| 프로필 연결 상태 | **미연동 / 연동 완료** | 생성회원 / 매칭회원 |
| 워크스페이스 구성원 | **팀원** | 직원 |
| 판매 상품 | **상품(수강권)** → 이후 **상품** | 회원권 |

- "매칭"·"생성회원"은 **앱에 없는 말**. 재사용 금지.
- **예외**: Supabase `articles` 게시물 콘텐츠는 손대지 않음. lab.html 썸네일 매핑 키도 DB값 그대로 `'트레이너 팁'` 유지(DB와 정확히 일치해야 함).
- **앱 코드는 개발자 담당, 수정 금지.** 전달 문서: `APP_TERMINOLOGY_HANDOFF.md`

### 사이트 전역
- 네비/푸터 "도입 절차" · CTA "도입 상담 신청" · CTA 밴드 4페이지 문자 단위 동일
- 가격 표기: `₩` 금지, 숫자 뒤 '원'

---

## 4. product.html 현황

### 배포된 버전 (커밋 `6b69914`)
```
히어로 → Part1 강사와회원(라이트, 대분류6·히어로카드+컴팩트그리드)
       → Part2 관리자(다크 #0D0F12, 대분류4) → CTA
```
- 히어로 카드 10 + 컴팩트 카드 22. 연결형 듀얼 목업 4개(폰⇄태블릿).
- **관리자를 뒤에 배치**한 이유(한 번 앞으로 바꿨다 되돌림): ① 기록→데이터 인과 서사 ② 원장의 구매장벽은 "강사·회원이 쓸까"라 그 해소가 먼저 ③ 구매자 가치가 CTA 직전에.
- 수치는 전부 가안. 목업은 추후 실제 이미지로 교체 예정.

### 미배포 시안 `product-new.html` — **사용자 점검 대기**
라포 운영리포트 레퍼런스를 참고해 **기능 나열 사이에 비기능 설득 요소**를 삽입:
- **개념 프레임**(히어로 직후): "회원 관리는 수업 시간에만 일어나지 않습니다" — 수업(주2시간) / 수업 아닐 때(주166시간) / 소통(언제든) 3단계
- **브리지**(Part1→Part2 사이): "기록이 쌓이면 판단 근거가 됩니다" — 낱개 기록 칩 → 화살표 → 대시보드 지표

### 재생성 스크립트
`_checkpoints/build_product.py` — **product 페이지 전체를 이 스크립트가 생성한다.**
구조 변경은 HTML 직접 수정보다 스크립트를 고쳐 재실행하는 편이 안전(순서 실험 때 즉시 원복한 전례).
```bash
python3 _checkpoints/build_product.py   # → product-new.html 생성
```

---

## 5. 사용 가이드 3종 (안정화 완료)

```
guide.html 강사 25항목 · guide-admin.html 관리자 24항목 · guide-member.html 회원 13항목
```
- **히어로 구조 스트립**: 기기 중심 SVG(폰/태블릿/모니터) 카드 3장. **3페이지 바이트 단위 동일**해야 함(MD5 대조).
- **공통은 단일 블록**: `sec-common` 하나(8개 아티클)가 강사·관리자 본문 맨 앞에 동일하게. 별도 탭·분산 배치는 폐기된 안.
- 목차 라벨은 **`.toc-group-label`만** 사용(`.toc-cat`은 CSS 정의 없던 버그 클래스, 제거됨).

**검증 3종 세트**: ① 목차 앵커=본문 id 순서 일치 ② 죽은 CSS + 정의 없는 클래스(양방향) ③ 공통 섹션·구조 스트립 MD5 페이지 간 동일

---

## 6. Supabase

- 프로젝트: `eyjzurevdslukzfkimfg.supabase.co`
- **keepalive**: `.github/workflows/supabase-keepalive.yml` 매일 09:20 KST ping. `actions/checkout`은 **v5 이상**.
  - ⚠️ 잠들면 DNS부터 죽어 방문자로는 못 깨움 — 대시보드 수동 Restore만 가능.
  - ⚠️ GitHub은 60일 무활동 시 스케줄 워크플로 자동 비활성화.
- lab.html만 페이지 로드 시 Supabase 호출. **Vercel 트래픽 ≠ Supabase 활동.**
- 백오피스 `admin/`는 **프로토타입** — 로그인 인증·RLS 연동 미완.

---

## 7. 다음 할 일 (우선순위)

1. **미커밋 3건 배포** — consulting.html 수정 2건 + 죽은 코드 삭제 (§0 표 참조)
2. **`product-new.html` 점검 후 배포 결정** — 사용자가 보류한 상태. 확정 시 메타 이식 → `product.html` 교체 → `product-new.html` 삭제
3. **회원 모드 가이드 검토** — `시작하기` 3개만 사용자 검토 완료. 남은 10개: 수업(2) · 나의 기록(4) · 소통(2) · 내 정보(2)
4. **목업 이미지 재작업** (사용자 액션 대기) — 테스트플라이트 설치 후 실제 화면 캡처 → 가이드 3종 `📸 캡처 예정` + product.html HTML 목업 교체
5. **앱 용어 통일 전달** — `APP_TERMINOLOGY_HANDOFF.md`를 개발자님께
6. **카피 검토**: lab.html, cases.html (cases는 스톡사진+가상후기가 index 실영상과 충돌)
7. **백엔드 마무리**: 백오피스 로그인/RLS 완성, lab 뉴스레터 연동, `inquiries.plan` 컬럼 정리(폼에서 삭제된 필드)
8. **지표 통일 (미해결)** — 같은 개념이 페이지마다 다른 숫자:
   - 재등록률: index `60% 향상` / consulting `90%` / cases `+12%·+18%·92%`
   - 강사 사용률: index `99%` / consulting `100%`
   - consulting 수치는 **사용자 제공값이라 임의 수정 금지**. 어느 값으로 통일할지 사용자 결정 필요.
9. (정책 대기) Enterprise 가격, 다지점 구조, 인원 감소 반영 시점

---

## 8. 이번 세션 커밋 (2026-07-22)

```
2494eaf  요금제 인당 가격 24,900원으로 조정
6b69914  product.html 리디자인 — 히어로 카드 + 컴팩트 그리드 2단 위계
2460c6e  product.html 전면 재구성 — 경험 중심 2묶음 구조
81a7b51  가이드 3페이지 워딩 톤 정리
a5198cd  구조 스트립에서 앱 구분 라벨 제거
4dc859b  공통 기능을 목차·본문 모두 단일 블록으로 통합
b5c2b5c  가이드 목차 스타일 3페이지 통일 + 기기 중심 구조 스트립 + 로컬 캐시 해결
afebef6  가이드 히어로에 서비스 구조 스트립 추가
09737b0  keepalive Node20 경고 해소 / 75b3c02  keepalive 신설 / 1c922e0  용어 통일
```

## 9. 파일 지도 (`_checkpoints/`)

- `CHECKPOINT.md` — 이 문서
- `build_product.py` — product 페이지 생성 스크립트 (§4)
- `APP_TERMINOLOGY_HANDOFF.md` — 개발자 전달용 앱 용어 통일 조사 내역
- `OPERATION_PROCESS_HANDOFF.md` — (구) 운영 프로세스 문서

## 10. 참고 링크

- GitHub: https://github.com/nononong247/ssentif-redesign · Actions(keepalive) 탭
- 라이브: https://www.ssentif.kr · 백오피스: https://www.ssentif.kr/admin/login.html
- 앱 소스: `~/Desktop/작업파일/GRIP_NOTE-main/` (ssentif-coach / ssentif-members / grip_note_web / backend)
- 레퍼런스: 라포매니저 https://www.rappomanager.info/report · 이전 홈페이지 https://ssentif-fitness.imweb.me/
- 인터뷰 영상: https://www.youtube.com/@ssentif_official/videos
