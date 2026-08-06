# 사용 가이드 페이지(guide.html / guide-admin.html / guide-member.html) — 작업 체크포인트

> **목적**: 컨텍스트가 압축되거나 세션이 바뀌어도 이어받을 수 있게 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-08-06 (§10 관리자 모드 전면 태블릿 재작업 — 공통 8개를 세로 폰 재사용에서 태블릿 가로 캡처로 교체)

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇을 만들고 있나**: 강사·관리자·회원 세 모드의 사용 가이드.
  - `www.ssentif.kr/guide.html` (**강사 모드**) — 실제 앱 화면 33장 삽입 완료. **이 파일·`assets/guide/`(최상위) 원본은 이번 작업에서 건드리지 않았다.**
  - `www.ssentif.kr/guide-admin.html` (**관리자 모드**) — **2026-08-06 전면 태블릿 재작업 완료(§10)**. 공통 8개(회원가입/계정관리·워크스페이스생성·모드전환·프로필·앱설정·채팅·공지·메모)를 guide.html 세로 폰 재사용에서 **전부 태블릿 가로 캡처로 교체**, `assets/guide/admin/`에 독립 저장(총 21장, admin 전용). 관리자 전용 13장은 그대로. 4개(mode-switch·notice-stats·member-analytics·assign-coach) 중 3개는 텍스트만(assign-coach는 여전히 스킵), mode-switch는 태블릿 사이드레일 이미지를 새로 붙였다.
  - `www.ssentif.kr/guide-member.html` (**회원 모드**) — 실제 앱 화면 15장 삽입 완료(2026-08-06). 이번 작업 범위 밖.
- **핵심 파일**: `guide.html` + `assets/guide/` 33장(원본, 무변경) / `guide-admin.html` + `assets/guide/admin/` **21장 전량**(공통 8 + 관리자 전용 13, admin 전용 폴더로 완전 분리) / `guide-member.html` + `assets/guide/member/` 15장.
- **지금 어디까지**: guide-admin.html **이미지 전부 태블릿 가로(landscape)로 통일 완료** + §9 관점 점검 3건 발견·수정(notice-stats/member-analytics "준비 중" 안내로 정정, all-members 필터 설명이 구 단일칩에서 현재 2축 드롭다운 UI로 정정, mode-switch 전환 방법을 실제 사이드레일 스위치/프로필 더블탭으로 정정). **관리자 전용 13장 중 alerts.png·revenue.png 2장만 예외적으로 세로(카드 위젯이라 원래부터 세로형, §10 참조)**. 회원 모드는 이번 범위 밖(§9 점검 미착수). 커밋 안 함.
- **다음 할 일**:
  1. (선택) alerts/revenue 카드도 landscape로 바꾸려면 위젯 자체를 다른 형태로 재설계해야 한다 — 사용자 확인 후 진행.
  2. assign-coach 이미지 보완(여전히 스킵 — fixture 비용 큼).
  3. tofu 2건 수정 후 이미지 2장 재캡처(`14-products.png`/`23-class-log.png`, guide.html §4, 이번 범위 밖).
  4. §9 점검을 회원 모드(guide-member.html)로 확장.
  5. 배포(사용자가 "배포해줘" 할 때만).

---

## 1. 이 폴더의 파일

| 파일 | 내용 | 여는 법 / 실행법 |
|------|------|-----------------|
| `capture/guide_docs_capture_test.dart` | **가이드 전용 캡처 테스트 원본.** 앱 폴더에 복사해 넣고 실행한다 | 아래 §5 "재캡처 절차" |
| `capture/screenshot_harness.patched.dart` | 하네스 패치본 — **실사진 주입**(`SCREENSHOT_PHOTO_DIR`) 기능이 들어있다 | 앱의 `test_screenshots/screenshot_harness.dart` 로 덮어씀 |
| `capture/flutter_test_config.patched.dart` | 폰트 별칭 패치본 — `monospace`/`FlutterTest` 추가 | 앱의 동명 파일로 덮어씀 |
| `capture/build_guide_assets2.py` | 캡처 PNG → 가이드 에셋 변환(barrier 트림·크롭·리사이즈) | `python3 build_guide_assets2.py <캡처폴더> <출력폴더>` |
| `photos/*.png` | 실사진 픽스처 6장(식단·벤치·스쿼트·정면·측면·후면) | 캡처 시 `SCREENSHOT_PHOTO_DIR` 로 지정 |

> ⚠️ **`capture/` 안의 3개 dart 파일이 이 폴더의 존재 이유다.** 사용자가 `GRIP_NOTE-main` 을
> 최신 앱으로 교체하면 **`test_screenshots/` 폴더가 통째로 덮어써져** 그 안의 내 파일이
> 사라진다. 실제로 2026-08-05에 한 번 날아갔다. 앱을 업데이트했다는 말이 나오면
> **가장 먼저 이 3개를 다시 복사**할 것.

---

## 2. 작업 구조

### 홈페이지 (`~/ssentif-redesign`, git repo)

- `guide.html` — 강사 모드 가이드. 구조: 나비 → 히어로(모드 탭 3개) → `guide-layout`(좌 목차 / 우 본문).
  - 본문은 `<section class="g-section">` 6개: **공통 · 시작하기 · 상품(수강권) 관리 · 일정 관리 · 운동 라이브러리 · 회원 관리**.
  - 항목은 `<article class="g-item" id="...">`, 좌측 목차 `.toc-link` 의 `href` 와 id 가 1:1.
  - 이미지는 `<figure class="g-shot">` — 클래스로 폭 제한: `.phone`(280px) / `.narrow`(460) / `.mid`(620) / 없음(전폭). `.g-shot-row` 는 2열.
- `guide-admin.html` — 관리자 모드 가이드(2026-08-06 이미지 채움 완료, §8 참조). 구조는
  `guide.html` 과 동일(나비 → 히어로 → `guide-layout`). 본문 `<section class="g-section">` 6개:
  **공통 · 시작하기 · 운영 대시보드 · 회원관리 · 팀원관리 · 스케줄 관리 · AI**.
- `guide-member.html` — 회원 모드 가이드(§7 참조).
- 스타일은 각 파일 내부 `<style>` 에 있다(`style.css` 아님) — `.g-shot*` 규칙은 세 파일이 각자
  갖고 있어 규칙을 하나 고치면 세 곳 다 확인해야 한다.

### 앱 (`~/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-coach`)

- 화면 캡처는 **Flutter 위젯 테스트 하네스**(`test_screenshots/`)로 뽑는다. 실기기·시뮬레이터 불필요.
- `screenshot_harness.dart` 의 `captureScreenshot(...)` 이 실제 테마·폰트·그림자로 렌더 후 PNG 저장.

---

## 3. 결정과 그 이유 (되돌리지 말 것)

1. **이미지는 HTML 목업이 아니라 Flutter 하네스 캡처다.** 사용자가 처음엔 "HTML을 크롬 헤드리스로 렌더" 방식을 제안했지만, 앱에 이미 캡처 하네스가 있어 **실제 앱 위젯을 실제 렌더링 엔진으로** 그리는 쪽이 더 정확하고 빠르다. 목업으로 되돌리지 말 것.
2. **사진은 실사진을 주입한다.** 하네스의 네트워크 mock 이 회색 placeholder 를 주던 것을, `SCREENSHOT_PHOTO_DIR` 환경변수가 있으면 **URL 마지막 조각과 같은 이름의 파일**을 응답하도록 확장했다. 픽스처 URL 을 `https://photos.test/diet.png` 로 두면 그 사진이 렌더된다. 환경변수를 안 주면 기존 동작과 완전히 같아 다른 캡처 테스트에 영향 없다.
3. **앱에 없는 기능 3종은 가이드에서 삭제·대체**(사용자 승인). `운동루틴 처방`(기능 없음) 삭제 / `PT 성과 데이터·인사이트 탭` → 실제인 **수업 탭 성과 분석**으로 교체 / 상품 `만료처리` → **유효기간 수정·삭제**로 정정.
4. **작업 범위는 `guide.html`(강사 모드)만**(사용자 선택). 관리자·회원 가이드는 나중에.
5. **커밋은 사용자가 "배포해줘"라고 할 때만.** 프로젝트 `CLAUDE.md` 의 배치 커밋 규칙.
6. **카피 변경은 제안 후 승인.** 같은 `CLAUDE.md` 규칙. 이번 개편은 승인받고 진행했다.
7. **활동 탭은 합성이 아니라 실제 탭을 렌더**한다. 구 캡처(`activity_tab_capture_test.dart`)는 캘린더 위젯만 따로 조립한 합성이라 실제 화면과 달랐다 — 사용자가 이를 지적했다.

---

## 4. 다음 할 일 (우선순위순)

1. **'강사 모드와 관리자 모드' 절에 전환 방법 추가** ← 사용자가 마지막에 요청, 아직 미반영
   - 태블릿/PC: **좌하단 전환 버튼**
   - 모바일: **프로필 탭을 연속 두 번 클릭**
   - 위치: `guide.html` 의 `<article class="g-item" id="modes">`
2. **tofu 2건 수정 후 이미지 재캡처** — 아래 §5 함정 참조. 작업 칩(별도 세션)이 폰트 수정 중.
   - 대상: `14-products.png`(신규 상품 생성) · `23-class-log.png`(+ 운동 추가)
   - 지금은 해당 영역을 잘라내고 캡션으로 위치를 설명해 둔 상태.
3. (선택) `guide-admin.html` · `guide-member.html` 도 같은 방식으로 개편.
4. 배포 — `git add . && git commit && git push` (Vercel 자동 반영). **사용자 지시 후에만.**

### 별도 세션에 넘긴 앱 이슈 2건

- **계정 관리 화면 3개 메뉴가 전부 `onTap: () {}`** — 연락처 변경·비밀번호 변경·**계정 탈퇴**가 눌러도 아무 동작 없음. 앱스토어 심사 필수 요건이라 출시 전 필요. 가이드는 이 경로를 안내 중.
- **`FilledButton.styleFrom(textStyle:)` 폰트 미지정으로 한글 tofu** — `products_screen.dart` 등.

---

## 5. 함정 · 주의사항

### 앱 폴더 교체 시 (가장 중요)

사용자가 `GRIP_NOTE-main` 을 최신 앱으로 갈아끼우면 `test_screenshots/` 가 통째로 덮어써진다. **매번 이 세 파일을 다시 복사해야 한다.**

```bash
CP=~/ssentif-redesign/_checkpoints/guide-page/capture
APP="$HOME/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-coach/test_screenshots"
cp "$CP/guide_docs_capture_test.dart" "$APP/"
cp "$CP/screenshot_harness.patched.dart" "$APP/screenshot_harness.dart"
cp "$CP/flutter_test_config.patched.dart" "$APP/flutter_test_config.dart"
```

⚠️ 단, 하네스·config 는 **앱 쪽에서도 바뀔 수 있다.** 덮어쓰기 전에 diff 를 보고, 앱 쪽 변경이 있으면 **패치 내용(사진 주입·폰트 별칭)만 다시 얹는 쪽**이 안전하다. 패치는 각각 한 덩어리라 찾기 쉽다:
- `screenshot_harness.dart`: `_photoBytesFor` 함수 + `_FakeRequest(this._url)` + `_FakeResponse([Uint8List? photo])`
- `flutter_test_config.dart`: alias 목록에 `monospace`/`Menlo`/`Courier`/`FlutterTest` 추가

### 재캡처 절차

```bash
export PATH="$HOME/development/flutter/bin:$PATH"     # flutter 는 PATH 에 없다
cd "$HOME/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-coach"
CP=~/ssentif-redesign/_checkpoints/guide-page
SCREENSHOT_DIR=/tmp/shots SCREENSHOT_PHOTO_DIR="$CP/photos" \
  flutter test test_screenshots/            # 전체(약 5분) 또는 guide_docs_capture_test.dart 만
python3 "$CP/capture/build_guide_assets2.py" /tmp/shots ~/ssentif-redesign/assets/guide
```

### 캡처 하네스의 알려진 제약

- **`cached_network_image` 를 쓰는 화면은 테스트에서 멈춘다**(sqflite 네이티브 의존). 체형 사진 등록 다이얼로그가 여기 걸려 캡처를 포기했다 — 10분 타임아웃. 대신 활동 탭 월별 그리드가 체형 사진을 보여준다.
- **`Scaffold` 없이 위젯만 렌더하면 모든 텍스트에 노란 이중밑줄**이 그려진다(Flutter 의 "Material 없음" 디버그 표시). 캡처 대상은 항상 `Scaffold(body: ...)` 로 감쌀 것.
- **`FilledButton.styleFrom(textStyle:)` 로 폰트를 지정하지 않은 버튼은 한글이 □□ 로 찍힌다.** 폰트 별칭으로도 해결 안 된다(family 가 `null` 이라 별칭이 못 걸린다). 앱 코드 수정이 유일한 해법.
- 다이얼로그 캡처는 바깥 barrier 가 화면의 절반 이상이라 **`build_guide_assets2.py` 의 `trim_barrier` 로 잘라낸다.** 단 하단 시트처럼 네 모서리 색이 다르면 자동 트림이 안 걸려 `crop` 비율을 직접 준다.

### 홈페이지 확인

```bash
cd ~/ssentif-redesign && python3 -m http.server 8990
open -a "Google Chrome" http://127.0.0.1:8990/guide.html
```

- 헤드리스 렌더로 검수할 땐 `--window-size=1280,28000` 정도로 크게 잡아야 lazy 이미지가 로드된다.
- **`http://127.0.0.1:*` 는 Browser 패널(도구)로 못 연다** — 정책 차단. 크롬 앱으로 열거나 헤드리스 스크린샷으로 확인한다.

---

## 6. 참고 링크 / 외부 상태

- 라이브: https://www.ssentif.kr/guide.html (Vercel, `main` push 시 자동 반영)
- GitHub: https://github.com/nononong247/ssentif-redesign
- 앱 기능 검증 기준: `~/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/` (`ssentif-coach` 코치앱)
- 프로젝트 규칙: `~/ssentif-redesign/CLAUDE.md` (배치 커밋 · 카피 승인 규칙)
- 원본 사진: `~/Desktop/` 의 `식단 사진.jpg`, `벤치프레스 하는 사진.png`, `스쿼트 하는 사진.png`, `회원 정면.png`, `측면 사진.png`, `후면 사진.png`



## 7. 회원 모드 가이드(`guide-member.html`) — 2026-08-06 완성

### 30초 요약

`guide-member.html` 은 본문 텍스트는 이미 다 있었고 이미지가 0장이었다. 회원앱
(`ssentif-members`, 패키지명 `ssentif_members`)에는 강사앱과 별개의 자체 캡처
하네스가 `test_screenshots/` 에 이미 있었다 — 그걸 그대로 따라 13개 g-item 전부에
이미지 15장을 채웠다.

### 결과물

| 항목(id) | 이미지 | 소스 |
|---|---|---|
| m-signup | `01-signup.png` | 기존 `signup_capture_test.dart` 재사용 |
| m-connect | `02-connect.png` | 기존 `my_link_code_capture_test.dart` 재사용 |
| m-home | `03-home.png` | 신규 — `HomeScreen` |
| m-schedule | `04-schedule.png` | 기존 `schedule_tab_capture_test.dart` 재사용 |
| m-log | `05-log.png` | 기존 `session_log_detail_capture_test.dart`(`capture full`) 재사용, 상단 빈 영역 크롭 |
| m-activity | `06-activity.png` | 기존 `exercise_recording_capture_test.dart`(운동 구성 화면) 재사용 |
| m-diet | `07-diet.png` | 신규 — `DietUploadScreen`, **실사진 주입**(식단 사진) |
| m-body | `08-body-composition.png` + `09-body-photo.png` | 신규 — `BodyCompositionUploadScreen` / `BodyPhotoUploadScreen`(정면·측면·후면 **실사진 3장** 주입) |
| m-stats | `10-stats.png` | 기존 `stats_body_composition_capture_test.dart` 재사용(전체 `StatsScreen`) |
| m-chat | `11-chat.png` | 기존 `chat_empty_capture_test.dart` 재사용 |
| m-notice | `12-notice.png` | 신규 — `NoticeListScreen` |
| m-products | `13-products.png` | 신규 — `MyProductsScreen` |
| m-profile | `14-profile.png` + `15-withdrawal.png` | 신규 — `SettingsScreen` / `WithdrawalScreen` |

13개 g-item 전부 캡처 성공. **스킵 0건.**

### 새로 만든 파일 (앱 폴더 교체 시 유실 위험 — 강사 모드와 동일한 함정)

| 파일 | 내용 |
|---|---|
| `capture/guide_member_capture_test.dart` | 회원 모드 전용 통합 캡처 테스트 원본. `ssentif-members/test_screenshots/` 에 복사해 실행 |
| `capture/members_screenshot_harness.patched.dart` | 회원앱 하네스 패치본 — **실사진 주입**(`SCREENSHOT_PHOTO_DIR`) + **로컬 File 이미지 precache**(`precacheFiles`, 아래 §함정 참조) 두 기능이 들어있다. `screenshot_harness.dart` 로 덮어씀 |
| `capture/build_member_assets.py` | 캡처 PNG → `assets/guide/member/` 변환(강사 모드 `build_guide_assets2.py` 와 같은 패턴, JOBS 목록만 다름) |

⚠️ **사용자가 `ssentif-members` 폴더를 교체하면 `test_screenshots/` 가 통째로 덮어써진다.**
그때 가장 먼저 이 3개(위 표)를 다시 복사할 것. 회원앱은 이미 강사앱과 별개의
캡처 하네스·테스트를 자체적으로 갖고 있었으므로(로그인/가입/홈/일정/채팅/통계/기록
등), 그것들까지 사라지면 `guide_member_capture_test.dart` 가 재사용하는 6개 소스
테스트(`signup_capture_test.dart`·`my_link_code_capture_test.dart`·
`schedule_tab_capture_test.dart`·`session_log_detail_capture_test.dart`·
`exercise_recording_capture_test.dart`·`stats_body_composition_capture_test.dart`)도
함께 사라진다는 뜻이다 — 이건 앱 저장소 자체의 것이라 이 체크포인트 폴더에 백업이
없다. 재발하면 git 이력이나 원본 개발자에게 확인이 필요하다.

### 결정과 함정

1. **회원앱 하네스는 강사앱과 달리 실사진 주입이 없었다.** `screenshot_harness.dart`
   를 열어 확인 후, 강사 모드 패치본(`_photoBytesFor`/`_FakeRequest(url)`/
   `_FakeResponse(photo)`)을 그대로 이식했다. 환경변수(`SCREENSHOT_PHOTO_DIR`) 없이
   실행하면 기존 동작과 완전히 같아 다른 캡처 테스트에 영향이 없다(강사 모드와 동일 원칙).
2. **CachedNetworkImage(원격 URL) 는 여전히 쓸 수 없다** — sqflite 네이티브 의존
   테스트 트랩은 회원앱에도 동일하게 존재한다(`gn_photo_strip.dart`·
   `gn_body_photo_slot.dart` 의 `existingUrls`/`existingUrl` 경로). 그래서 실사진은
   **원격 URL 이 아니라 로컬 `File`**(피커로 이미 고른 사진 상태)로 주입했다 —
   `Image.file` 은 플러그인 의존이 없어 안전하다.
3. **`Image.file` 도 codec 디코드가 진짜 async 라 fake-async 프레임만으로는 완성되지
   않는다** — `precacheAssets`(AssetImage 전용)로는 못 잡아 하네스에 **`precacheFiles`
   파라미터를 신설**했다(`tester.runAsync(() => precacheImage(FileImage(file), ...))`).
   이걸 빼먹으면 사진 슬롯에 X 버튼만 뜨고 사진 자체는 빈 회색으로 찍힌다(실제로
   한 번 이 증상이 났다 — `SCREENSHOT_SAVED` 는 성공해도 그림이 비어 있었다).
4. **`Image.asset` 클레이 아이콘도 `precacheAssets` 가 필요하다** — 홈 화면의
   퀵 기록 4종 아이콘(`ic_diet.png`/`ic_dumbbell.png`/`ic_bodyweight_clay.png`/
   `ic_bodyshape_clay.png`)과 수업일지 카드 아이콘(`ic_memo_clay.png`), 내 상품
   화면의 분류 아이콘 6종(`ic_personal_lesson.png` 등)을 캡처 전에 명시적으로
   precache 하지 않으면 빈 회색 원으로 찍힌다.
5. **대부분의 provider 는 override 없이도 동작했다** — 회원앱 mock 리포지토리
   (`MockSessionLogRepository`/`MockMemberNoticeRepository`/
   `MockMyMembershipRepository`)가 이미 그럴듯한 샘플 데이터를 반환하므로,
   `xxxRepositoryProvider.overrideWithValue(const MockXxxRepository())` 한 줄이면
   충분했다. 다만 **`AppEnv.useMockMemberApis` 기본값이 `false`** 로 바뀌어 있어
   (백엔드 완성 후 전환, `app_env.dart` 참조) 오버라이드 없이 그냥 실행하면 실제
   Dio 네트워크 호출을 시도하다가 (서버가 없으니) 에러로 떨어진다 — 화면이 깨지진
   않지만 빈 상태로 찍힌다. `exerciseRecordsProvider`/`dietEntriesProvider`/
   `bodyCompositionsProvider`/`bodyPhotosProvider` 처럼 **mock 리포지토리 자체가
   없는** provider 는 그냥 빈 리스트를 반환하는 로컬 override(`AsyncNotifier`
   subclass)로 대체했다 — 홈 화면 구조를 보여주는 데는 충분하고, 실패해도 크래시
   없이 에러 상태로 넘어가므로 무리하게 채우지 않았다.
6. **`linkedCentersProvider` 는 항상 override 가 필요하다**(강사 모드 회원 fixture와
   동일한 이유) — 실제 백엔드 호출뿐이라 mock 스위치가 없다.
7. **회원 fixture 이름은 "김지훈"** 으로 강사 모드 가이드(코치 "박성훈")와는 다른
   인물을 썼다 — 회원앱은 회원 1인칭 시점이 자연스러워, 강사 모드가 쓰던 코치 이름
   대신 새 회원 이름을 골랐다. 단, 재사용한 기존 테스트(`my_link_code_capture_test.dart`
   등)는 그 파일 고유의 fixture("김회원")를 그대로 썼다 — 공용 fixture로 통일하려면
   그 테스트 파일 자체를 고쳐야 해서 범위 밖으로 남겼다(사소한 이름 불일치, 가이드
   내용에는 영향 없음).
8. **`session_log_detail_capture_test.dart` 의 `capture full`** 은 teardown 단계에서
   `databaseFactory not initialized`(sqflite_common_ffi) 에러로 **테스트 자체는
   fail** 하지만, **PNG 저장은 이미 끝난 뒤라 스크린샷은 정상**이다(`SCREENSHOT_SAVED`
   로그 확인). 무시하고 그 파일을 그대로 썼다.

### 재캡처 절차 (회원 모드)

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
CP=~/ssentif-redesign/_checkpoints/guide-page
APP="$HOME/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-members"

# 앱 폴더가 교체됐다면 먼저 복구
cp "$CP/capture/guide_member_capture_test.dart" "$APP/test_screenshots/"
cp "$CP/capture/members_screenshot_harness.patched.dart" "$APP/test_screenshots/screenshot_harness.dart"

cd "$APP"
mkdir -p /tmp/member_shots
SCREENSHOT_DIR=/tmp/member_shots SCREENSHOT_PHOTO_DIR="$CP/photos" \
  flutter test test_screenshots/guide_member_capture_test.dart

# 재사용하는 6개 기존 테스트도 같은 SCREENSHOT_DIR 로 함께 실행
SCREENSHOT_DIR=/tmp/member_shots SCREENSHOT_PHOTO_DIR="$CP/photos" \
  flutter test test_screenshots/signup_capture_test.dart \
    test_screenshots/my_link_code_capture_test.dart \
    test_screenshots/schedule_tab_capture_test.dart \
    test_screenshots/chat_empty_capture_test.dart \
    test_screenshots/session_log_detail_capture_test.dart \
    test_screenshots/exercise_recording_capture_test.dart \
    test_screenshots/stats_body_composition_capture_test.dart

# exercise_recording_capture_test.dart 는 outputDir 를 자체 하드코딩한다
cp /tmp/grip_note_screenshots/exercise_recording_overview.png /tmp/member_shots/

python3 "$CP/capture/build_member_assets.py" /tmp/member_shots ~/ssentif-redesign/assets/guide/member
```

### 회원 모드 하네스의 알려진 제약 (강사 모드와 공유)

- `cached_network_image`(원격 URL) 화면은 sqflite 네이티브 의존으로 테스트가 멈춘다 —
  회원 모드 캡처에서는 원격 URL 프리필을 아예 쓰지 않아 이 함정을 피했다.
- `Scaffold` 없이 위젯만 렌더하면 노란 이중밑줄 + tofu 위험 — 이번 캡처 대상은
  전부 화면 최상위 위젯(자체 `Scaffold` 보유)이라 별도 래핑이 필요 없었다.
- `FilledButton.styleFrom(textStyle:)` 폰트 미지정 tofu 함정은 이번 캡처 범위에서는
  발견되지 않았다(캡처된 15장 전부 육안 검수 완료, tofu 0건).

---

## 8. 관리자 모드 가이드(`guide-admin.html`) — 2026-08-06 완성

### 30초 요약

`guide-admin.html` 은 본문 텍스트(25개 g-item)는 이미 다 있었고 이미지가 0장이었다.
공통 8개(account/workspace/modes/profile/app-settings/chat/notice/memo)는
`guide.html`(강사 모드)이 쓰는 이미지를 그대로 재사용하고, 관리자 전용 17개 중
13개를 강사앱(`ssentif-coach`) 캡처 하네스로 신규 캡처했다. 4개는 실제 화면이 없거나
(notice-stats·member-analytics — 대시보드에 `_ReservedCard` 빈 자리만 있고 위젯
자체가 미구현) 캡처 픽스처 구성이 시간 대비 이득이 낮아(mode-switch·assign-coach)
텍스트만 유지했다.

### 결과물 — 관리자 전용 13장 (`assets/guide/admin/`)

| 항목(id) | 이미지 | 소스 위젯 |
|---|---|---|
| alerts | `alerts.png` | `ManagerActionAlertsCard` |
| revenue | `revenue.png` | `ManagerRevenueCard` |
| risk | `risk.png` | `ManagerRiskCard` |
| all-members | `all-members.png` | `AllMembersScreen` |
| products | `products.png` | `ProductsScreen` |
| staff | `staff.png` | `StaffManagementScreen`(팀원 목록) |
| staff-detail | `staff-detail.png` | `StaffManagementScreen` → 팀원 탭 → 고용 정보(interact 로 탭 열기) |
| payroll | `payroll.png` | `PayrollPeriodPanel`(정산 기간 패널 — 개인/그룹수업 정산·원천징수 상세 에디터는 미캡처, 아래 §한계 참조) |
| payslip | `payslip.png` | `openPayslipPreview` 다이얼로그(`PayrollDetail` 픽스처로 interact 오픈) |
| schedule-scope | `schedule-scope.png` | `ScheduleTeamView`(팀 전체 월간 뷰) |
| center-hours | `center-hours.png` | `OperationsSettingsTab` |
| ai-agent | `ai-agent.png` | `AiAgentChatScreen` |
| (보너스, 미사용) | `dashboard-overview.png` | `ManagerDashboardScreen` 전체 — 개별 카드 3장(alerts/revenue/risk)의 원본. HTML에는 안 씀, 필요 시 재사용 |

공통 8개는 `guide.html` 이미지를 **경로만 그대로**(`assets/guide/01-login.png` 등) 참조한다 —
별도 admin 폴더 복사 없음. 매핑: account→`02-signup.png`+`06-account.png`(가입 화면 1개 +
계정 삭제 화면 1개, guide-admin 은 이 두 절이 한 g-item 에 합쳐져 있어 캡처 2장이 붙는다) /
workspace→`03-workspace-create.png` / modes→`04-modes.png` / profile→`05-profile.png` /
app-settings→`06-account.png` / chat→`07-chat.png` / notice→`08-notice.png` /
memo→`09-memo.png`.

### 스킵한 4건과 사유

| id | 사유 |
|---|---|
| **mode-switch** | 강사 모드 전환 토글 자체가 사이드레일 하단 스위치/프로필 탭 더블탭이라 정적 스크린샷 하나로 담기 어렵고, `guide.html` 의 `modes` 절이 이미 같은 내용(전환 방법 문구)을 다룬다. 텍스트만 유지 |
| **notice-stats** | 대시보드 코드(`manager_dashboard_screen.dart`)를 확인한 결과 발송/열람/액션 통계 카드는 **아직 구현되지 않았다** — 자리는 `_ReservedCard`(빈 `DecoratedBox`)로 예약만 돼 있다. 실제 화면이 없어 캡처 불가, 텍스트만 유지 |
| **member-analytics** | 위와 동일 이유 — 대시보드에 회원 구성/상품 분포 도넛 카드가 없다(같은 `_ReservedCard` 자리). 텍스트만 유지 |
| **assign-coach** | `showAssignCoachSheet` 이 `ref.read(workspaceRepositoryProvider).getStaff(...)` 를 **provider 가 아니라 리포지토리 메서드를 직접 호출**해서, Riverpod `overrideWith` 만으로는 fixture 주입이 안 된다. `BackendWorkspaceRepository` 를 상속해 `getStaff` 만 오버라이드하려 해도 `ApiClient` 생성자가 `AppEnv`/`TokenStorage`/콜백 다수를 요구해 fixture 구성 비용이 다른 13개보다 훨씬 크다. 시간 대비 효율이 낮아 스킵 — 전체 회원 화면(`all-members.png`)이 담당 강사 배정의 진입 지점(미배정 필터)까지는 보여주므로 문서 이해에 치명적이지 않다 |

### 새로 만든/수정한 파일

| 파일 | 내용 |
|---|---|
| `test_screenshots/guide_admin_capture_test.dart`(앱 폴더) | 기존 3개 testWidgets(대시보드·전체회원·팀원관리)에 **9개 신규 testWidgets** 추가(alerts/revenue/risk/products/staff-detail/payroll/payslip/schedule-scope/center-hours/ai-agent — staff 캡처도 `workspaceStaffListProvider` fixture 를 추가해 보강). 하네스·provider override 패턴은 강사 모드 파일과 동일 |
| `capture/guide_admin_capture_test.dart`(체크포인트, 신규 백업) | 위 파일의 백업본 — 앱 폴더 교체 시 유실 대비 |
| `capture/build_admin_assets.py`(체크포인트, 신규) | 캡처 PNG → `assets/guide/admin/` 변환. `build_guide_assets2.py` 와 같은 `trim_barrier`/리사이즈 로직이지만 **JOBS 목록이 범용이 아니라 이번 13장 전용**이다 — 새 항목을 캡처하면 이 스크립트의 `JOBS` 리스트에 직접 추가해야 한다(구 스크립트처럼 강사 모드 33장 전용 매핑을 그대로 씀) |

⚠️ **`test_screenshots/guide_admin_capture_test.dart` 는 강사 모드와 같은 유실 위험을 안는다.**
`GRIP_NOTE-main` 앱 폴더가 교체되면 이 파일도 사라진다 — `capture/guide_admin_capture_test.dart`
에서 다시 복사할 것. harness·config 패치본은 강사 모드와 **완전히 동일**(§5 참조, 이번 작업에서
diff 0 확인 — 이미 패치돼 있었다).

### 결정과 함정

1. **`ManagerRiskCard`/`ManagerActionAlertsCard`/`ManagerRevenueCard` 는 대시보드 위젯을
   개별 캡처했다** — `ManagerDashboardScreen` 전체를 캡처하면 카드 3장이 한 이미지에 다
   들어가 각 g-item 에 붙이기엔 너무 크고 다른 카드가 함께 보여 시선이 분산된다. 개별 위젯
   캡처는 각 카드가 이미 `SectionCard` 로 자기 완결적이라 별도 `Scaffold` 래핑 없이 그대로
   `captureScreenshot(child: const XxxCard())` 로 찍힌다.
2. **`payroll.png` 는 정산 화면 전체가 아니라 상단 기간 패널뿐이다.** guide-admin 본문은
   개인수업 정산(단가제/비율제)·그룹수업 정산·원천징수 3개 하위 절을 설명하는데, 그 상세
   에디터는 `StaffManagementScreen` 의 `_tab == 1`(급여 정산) 내부 상태에 깊이 얽혀 있고
   (선택된 팀원·월·정산 라인별 provider 다수) 짧은 시간 안에 fixture 를 완전히 갖추기
   어려워 **`PayrollPeriodPanel`(정산 진입 화면) 만** 캡처했다. 본문 카피는 그대로 두었으므로
   상세 에디터 캡처는 여유 있을 때 보완 대상이다.
3. **`payslip.png` 는 `openPayslipPreview` 다이얼로그를 `interact` 훅으로 열어서 찍었다** —
   그 함수가 `showGeneralDialog` 를 직접 호출하는 톱레벨 함수라, 호스트 `Scaffold` 에 버튼을
   하나 두고 `tester.tap` 으로 여는 방식이 가장 간단했다(직접 `_PayslipPreviewScreen` 위젯을
   인스턴스화하려 하면 private 클래스라 불가능).
4. **`staff-detail.png` 는 팀원 목록에서 이름을 탭해 상세로 진입한 뒤 캡처**한다
   (`interact: (tester) => tester.tap(find.text('이수민'))`) — 강사 모드의
   `staff_detail_capture_test.dart` 와 동일한 패턴. `staffAssignedMembersProvider`/
   `staffTenureStintsProvider` 를 빈 리스트로 override 해 재직 이력·담당 회원 로딩을
   확정 상태로 고정했다(안 하면 provider 미override 시 무한 로딩 상태로 캡처될 수 있다).
5. **fixture 인물은 강사 모드와 동일**(대표 박성훈 · 코치 이수민, 워크스페이스
   "센티프 피트니스 강남점") — 이미 guide.html 의 33장이 이 이름들로 캡처돼 있어, 관리자
   모드에서 다른 이름을 쓰면 두 가이드를 오가는 사용자가 "다른 센터인가"라고 오해할 수
   있다는 판단으로 통일했다.
6. **`.g-shot` 크기 클래스는 원본 캡처 크기에 맞춰 골랐다** — alerts/revenue/risk 는
   860px 폭 카드 캡처라 `.narrow`(460)로는 과도하게 축소돼 `.mid`(620)로 조정, 나머지
   전체화면 캡처(태블릿 1600px 폭)는 클래스 없음(전폭)을 그대로 썼다(강사 모드 08-notice
   와 동일 관례).

### 재캡처 절차 (관리자 모드)

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd "$HOME/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-coach"
CP=~/ssentif-redesign/_checkpoints/guide-page

# 앱 폴더가 교체됐다면 먼저 복구(하네스·config 는 강사 모드와 공용 — §5 참조)
cp "$CP/capture/guide_admin_capture_test.dart" test_screenshots/
cp "$CP/capture/screenshot_harness.patched.dart" test_screenshots/screenshot_harness.dart
cp "$CP/capture/flutter_test_config.patched.dart" test_screenshots/flutter_test_config.dart

SCREENSHOT_DIR=/tmp/admin_shots SCREENSHOT_PHOTO_DIR="$CP/photos" \
  flutter test test_screenshots/guide_admin_capture_test.dart

python3 "$CP/capture/build_admin_assets.py" /tmp/admin_shots ~/ssentif-redesign/assets/guide/admin
```

⚠️ **`가이드(관리자) — 운영 대시보드` 테스트는 실행 중 RenderFlex 오버플로/`No Material
widget found` 예외를 던지지만 스크린샷 자체는 정상 저장된다**(`SCREENSHOT_SAVED` 로그로
확인) — `ManagerDashboardScreen` 안 `_ReservedCard`/`HomeNoticeList` 쪽의 기존(이번 작업과
무관한) 레이아웃 이슈로 보이며, 관리자 가이드 이미지 자체에는 영향이 없었다(육안 검수 완료).
재캡처 시 이 테스트만 "실패"로 표시돼도 당황하지 말 것 — PNG 파일 존재 여부로 판단한다.

### 검증

`python3 -m http.server 8990` 로 로컬 서빙 후 `assets/guide/*` 전체 image src 를 `curl` 로
200 확인 + 헤드리스 Chrome 풀페이지 스크린샷(`--window-size=1400,34000`)으로 25개 g-item
전체를 육안 검수(공통 8 + 관리자 13 + 텍스트만 4). 깨진 이미지·레이아웃 붕괴 없음 확인.

---

## 9. "화면이 제대로 구현 안 된 부분" 점검 (2026-08-06, 사용자 요청, 진행 중)

### 30초 요약

사용자가 "강사모드 보면 화면이 제대로 구현이 안된 부분들이 있다"며 찾아서 개선을 요청.
확인 결과 **guide.html(강사 모드) 문서 페이지**를 보고 한 말이었다(앱 자체가 아니라 —
`AskUserQuestion` 으로 범위를 먼저 확인함). 즉 이 점검의 성격은 두 가지 중 하나로 갈린다:

1. **가이드가 앱을 오해하게 만드는 문구** — 실제로는 안 되는 기능을 되는 것처럼 서술
2. **캡처 자체가 잘못된 화면을 담은 경우** — 엉뚱하거나 빈 스크린샷을 재사용

**강사 모드(guide.html)만 훑었고 2건 발견·전부 수정 완료.** 관리자·회원 모드는
같은 관점으로 아직 점검 전 — 다음 세션에서 이어갈 것(§0 다음 할 일 참조).

### 발견·수정 2건

1. **`#app-settings`(프로필→계정 관리) — 안 되는 기능을 되는 것처럼 서술**
   - 원문: "[계정 관리]에는 연락처 변경 · 비밀번호 변경 · 계정 탈퇴가 있습니다."
   - 실제: `account_settings_screen.dart` 확인 결과 세 메뉴 전부 `onTap: () {}` —
     완전히 죽은 버튼(이미 §4 "별도 세션에 넘긴 앱 이슈"에 기록돼 있던 문제였는데,
     가이드 문구 자체는 안 고쳐져 있었다).
   - 수정: `g-step` 문구를 "메뉴가 보입니다"로 완화하고, `⚠️` 콜아웃을 추가해
     "연락처 변경·비밀번호 변경은 아직 준비 중 — 카카오톡 채널로 요청" 안내.
     기존에 있던 계정 탈퇴 콜아웃(`#account` 절)과 톤을 맞췄다. figcaption 도
     "연락처·비밀번호 변경은 준비 중입니다"로 갱신.
   - **패턴**: 카피만 고치면 되는 유형 — 앱 코드는 건드리지 않았다.

2. **`04-modes.png` — 빈 화면(placeholder)을 실제 화면인 것처럼 게재**
   - 증상: 캡션은 "강사 모드 하단 탭 구성"인데 이미지 본문이 완전히 빈 흰 화면
     (헤더 로고 + 하단 탭만 있고 콘텐츠 영역이 새하얗다) — 사용자가 스크린샷으로
     이 부분을 지적하며 재확인 요청.
   - 원인: 이미지 출처가 `portrait_nav_capture_test.dart`(`portrait_nav_coach_phone_light`)
     였는데, 그 테스트는 **의도적으로 본문을 빈 카드로 비워두는 앱 내부 회귀 테스트**다
     (주석: "실제 화면 본문 대신 헤더 골격만 둔다 — 하위 카드들의 네트워크 의존을
     캡처에 끌고 오지 않으면서 '햄버거 + 하단 네비' 관계를 그대로 보여준다"). 가이드
     제작 당시 이 회귀 테스트 산출물을 그대로 가져다 써서 생긴 불일치 — **앱 버그가
     아니라 가이드 제작 시 잘못된 소스를 골랐던 것.**
   - 수정: `coach_home_portrait_capture_test.dart`(앱, 강사 홈 세로 캡처 전용 파일)에
     가이드 전용 테스트 케이스를 새로 추가 — `AdaptiveScaffold(location: Routes.home,
     child: HomeScreen())` 로 **실제 홈 콘텐츠 + 하단 네비를 한 장에** 담았다. 그 파일이
     이미 갖고 있던 fixture(다음 세션 카드·회원 인증·업무 알림 등, 코치 박성훈 워크스페이스)를
     그대로 재사용해 다른 이미지들과 데이터 일관성 유지. 테스트명
     `강사 홈 세로 캡처 — 가이드용(네비 포함, light)` → PNG `guide_modes_nav.png` →
     `assets/guide/04-modes.png` 로 교체.
   - `_checkpoints/guide-page/capture/build_guide_assets2.py` 의 JOBS 매핑도
     `"portrait_nav_coach_phone_light"` → `"guide_modes_nav"` 로 갱신해뒀다(다음
     전체 재캡처 때 자동 반영).
   - **패턴**: 이 유형(회귀 테스트용 placeholder 캡처를 가이드에 잘못 재사용)이
     다른 이미지에도 있을 수 있다 — 관리자·회원 모드 점검 시 **`portrait_nav_*`,
     `*_placeholder_*`, 본문이 의도적으로 비어있다고 주석에 적힌 캡처 소스**를
     우선 의심할 것.

### 새로 생긴 백업 파일

| 파일 | 내용 |
|---|---|
| `capture/coach_home_portrait_capture_test.patched.dart` | 위 2번 수정이 반영된 `coach_home_portrait_capture_test.dart` 전체 백업. 앱 폴더 교체 시 `test_screenshots/coach_home_portrait_capture_test.dart` 로 다시 복사할 것(단, 이 파일은 강사 모드 33장 중 하나가 아니라 **다른 회귀 테스트 파일**이라 §5 "매번 복사할 3개" 목록에는 없다 — 앱 폴더가 통째로 바뀌면 이 파일도 함께 사라지므로 잊지 말고 복원할 것) |

### 점검 방법(재사용 가능한 절차)

1. `grep -n 'figure class="g-shot\|준비 중\|추후\|TODO' guide-*.html` 로 이미 알려진
   미구현 표시를 먼저 스캔.
2. 각 `<img src="assets/guide/...">` 를 Read 도구로 직접 열어 육안 확인 — 특히 빈 화면,
   비활성처럼 보이는 버튼, 크기가 유독 작거나(<700px 한 변) 종횡비가 이상한 것 우선.
3. 의심되는 화면은 캡션이 말하는 기능을 앱 소스에서 실제로 찾아 `onTap`/`onPressed`
   가 진짜 동작을 호출하는지 확인(`grep -n "onTap: () {}\|TODO\|미구현"`).
4. 이미지 소스를 `build_guide_assets2.py`(또는 admin/member 버전)의 JOBS 테이블에서
   역추적해 원본 캡처 테스트가 "의도적으로 비운 placeholder"인지 확인.
5. 카피 문제면 `guide-*.html` 텍스트만 수정. 캡처 문제면 §5/§7/§8의 재캡처 절차를
   따라 새 스크린샷을 만들고 해당 폴더의 build 스크립트 JOBS 매핑을 갱신.

---
## 10. 관리자 모드 전면 태블릿 재작업 (2026-08-06)

### 30초 요약

사용자 지적: "관리자 모드가 전체 전부 다 이상해. 관리자 모드는 전부 태블릿 레이아웃 규격으로
참고 이미지가 보일 수 있게 해줘." §8에서 만든 관리자 가이드는 공통 8개 항목에 **guide.html(강사
모드)의 세로 폰(1017×2200) 스크린샷을 그대로 재사용**하고 있었고, 관리자 전용 13개만 태블릿
가로였다 — 한 페이지 안에서 세로 긴 폰 화면과 가로 넓은 태블릿 화면이 섞여 있었다. 이번 작업으로
공통 8개를 전부 태블릿 가로 캡처로 교체해 페이지 전체가 시각적으로 통일됐다.

### 새로 캡처한 것 / 재사용한 것

| 항목(id) | 이미지 | 소스 |
|---|---|---|
| account(회원가입) | `assets/guide/admin/signup.png` | **재사용** — `signup_screen_capture_test.dart`의 `signup_landscape` 캡처(가로 태블릿, 기존 존재) |
| account(계정삭제) / app-settings | `assets/guide/admin/account-settings.png` | **신규** — `AccountSettingsScreen`을 `tabletLandscape` 기본 디바이스로 캡처(신규 testWidgets) |
| workspace | `assets/guide/admin/workspace-create.png` | **재사용** — `workspace_create_screen_capture_test.dart`의 `workspace_create_landscape`(기존 존재) |
| modes | `assets/guide/admin/modes.png` | **신규** — `AdaptiveScaffold(location: Routes.home, child: HomeScreen())`를 `tabletLandscape`로 캡처해 **좌측 사이드레일(하단 모드 전환 스위치 포함) + 실제 홈 콘텐츠**를 한 장에 담음. 이전 작업(§8)에서 "정적 스크린샷으로 담기 애매해서" 스킵했던 게 태블릿에서는 사이드레일이 상시 보여 충분히 캡처 가능했다 |
| profile | `assets/guide/admin/profile.png` | **신규** — `SettingsScreen`을 `tabletLandscape`로 캡처(좌 프로필 카드 + 우 설정 목록 분할 레이아웃이 자동으로 나타남) |
| chat | `assets/guide/admin/chat.png` | **신규** — `ChatSplitView`(좌 360px 목록 + 우 대화, 회원 미선택 상태로 캡처) |
| notice | `assets/guide/admin/notice.png` | **재사용** — `member_notices_screen_capture_test.dart`(원래도 `tabletLandscape` 기본값이라 이미 태블릿이었다. admin 폴더로 복사만) |
| memo | `assets/guide/admin/memo.png` | **신규** — `MemoScreen`(좌 목록 + 우 에디터 `SplitView`, `tabletLandscape`)로 재캡처. 기존 09-memo.png(guide.html 자산)는 `MemoEditorPanel` 단독을 720×620 박스로 찍은 것이라 좌측 목록이 없었다 — 이번에 전체 분할 뷰로 교체 |
| login(참고) | `assets/guide/admin/login.png` | `login_screen_capture_test.dart`의 `login_screen`(태블릿, 기존 존재) — HTML에는 미사용이나 `build_admin_assets.py` JOBS에는 등록해 둠(필요 시 사용) |

### 새로 만든 파일

| 파일 | 내용 |
|---|---|
| `test_screenshots/guide_admin_common_tablet_capture_test.dart`(앱 폴더) | 이번에 신규 캡처한 4개(profile/account-settings/chat/memo/modes — 정확히는 5개 testWidgets)를 담은 파일. `guide_docs_capture_test.dart`/`coach_home_screen_capture_test.dart`의 fixture 패턴(워크스페이스 `ws-1`·대표 박성훈)을 그대로 복제해 다른 가이드 이미지와 데이터 일관성 유지 |
| `capture/guide_admin_common_tablet_capture_test.dart`(체크포인트, 신규 백업) | 위 파일의 백업본 — 앱 폴더 교체 시 유실 대비. **§5 "매번 복사할 3개" 목록에는 없으므로 앱 폴더 교체 시 잊지 말고 직접 복원할 것** |
| `capture/build_admin_assets.py`(갱신) | JOBS에 공통 8개(login/signup/workspace-create/modes/profile/account-settings/chat/memo) + notice 매핑 9건 추가 |

### 재캡처 절차 (이번 작업 전체를 재현하려면)

```bash
export PATH="$HOME/development/flutter/bin:$PATH"
cd "$HOME/Desktop/센티프 SSENTIF/Product/GRIP_NOTE-main/ssentif-coach"
CP=~/ssentif-redesign/_checkpoints/guide-page

# 앱 폴더가 교체됐다면 먼저 복구(하네스·config는 강사 모드와 공용 — §5 참조)
cp "$CP/capture/guide_admin_capture_test.dart" test_screenshots/
cp "$CP/capture/guide_admin_common_tablet_capture_test.dart" test_screenshots/
cp "$CP/capture/screenshot_harness.patched.dart" test_screenshots/screenshot_harness.dart
cp "$CP/capture/flutter_test_config.patched.dart" test_screenshots/flutter_test_config.dart

SCREENSHOT_DIR=/tmp/admin_shots2 SCREENSHOT_PHOTO_DIR="$CP/photos" \
  flutter test test_screenshots/guide_admin_capture_test.dart \
    test_screenshots/guide_admin_common_tablet_capture_test.dart \
    test_screenshots/login_screen_capture_test.dart \
    test_screenshots/signup_screen_capture_test.dart \
    test_screenshots/workspace_create_screen_capture_test.dart \
    test_screenshots/member_notices_screen_capture_test.dart

python3 "$CP/capture/build_admin_assets.py" /tmp/admin_shots2 ~/ssentif-redesign/assets/guide/admin
```

⚠️ `guide_admin_capture_test.dart`의 "가이드(관리자) — 운영 대시보드" 테스트는 여전히 실행 중
예외를 던지지만 PNG는 정상 저장된다(§8 기존 함정과 동일, `dashboard-overview.png`는 실제로는
미사용 보너스 자산).

### 본문 점검(§9 관점)에서 발견·수정한 3건

1. **all-members(전체 회원 조회) — 필터 UI 설명이 구버전**: 본문이 "전체·활성·일시정지·만료·
   미배정으로 걸러볼 수 있습니다"(구 단일 칩 행)라고 서술했는데, 실제 코드
   (`.claude/rules/05-design-system.md` §관리자 회원 탭 — 필터 2축, 2026-07-29 개편)는
   **회원권 상태**(회원권 전체/활성/일시정지/만료)와 **담당 강사**(전체/미배정/강사별) **두 개의
   독립 드롭다운**으로 이미 바뀌어 있었다. 정렬 옵션도 "기본순(상태 우선)"이 추가된 상태였는데
   빠져 있었다. → 본문을 실제 2축 드롭다운 설명으로 정정.
2. **notice-stats(공지사항) — 미구현 통계를 구현된 것처럼 서술**: "발송·열람·액션 3가지 건수와
   열람율·액션율이 표시됩니다"라고 구체적으로 서술했지만, `ManagerDashboardScreen` 확인 결과
   그 자리는 여전히 `_ReservedCard`(빈 `DecoratedBox`) 하나뿐이고 실제로 렌더되는 것은
   `HomeNoticeList`(최근 공지 목록, 통계 아님)다. → 본문을 "공지사항 카드에서 최근 보낸 공지
   목록을 확인" + "발송·열람·액션 통계 카드는 아직 준비 중" 경고 콜아웃으로 정정.
3. **member-analytics(회원 구성 분석) — 존재하지 않는 그래프를 단계별로 안내**: "활성 회원
   구성"·"회원권 유형 분포" 두 그래프의 조작법을 3단계로 서술했지만 실제로는 어디에도 없다
   (같은 `_ReservedCard` 자리 후보). → 본문을 "아직 준비 중" 경고 + 전체 회원 조회로 유도하는
   대체 안내로 축소.
4. **mode-switch(관리자 모드 전환) — 실제와 다른 전환 방법**: "하단 [마이] 또는 홈 상단의 모드
   메뉴에서 [관리자 모드]를 선택"이라고 서술했지만 실제 전환 수단은 **태블릿·PC=사이드레일 하단
   스위치**, **모바일=프로필 탭 더블탭**(§design-system "모드 전환 칩"/"프로필 탭 더블탭") 뿐이고
   그런 메뉴 자체가 없다. → 본문을 실제 두 전환 방법으로 정정 + `modes.png`(사이드레일이 보이는
   태블릿 캡처) 이미지 신규 추가(이전엔 텍스트만이었다).

### 이미지 landscape 검증

`assets/guide/admin/` 전체를 Python PIL로 스캔한 결과, **21장 중 19장이 landscape(가로)**다.
예외 2장:

| 파일 | 크기 | 사유 |
|---|---|---|
| `alerts.png` | 860×1120 (세로) | `ManagerActionAlertsCard` 카드 위젯 자체를 `Size(430, 560)`로 캡처(§8에서 이미 그렇게 캡처된 기존 자산, 이번 작업 범위 밖) — 업무 알림 목록이 세로로 쌓이는 카드라 원래 세로형이다 |
| `revenue.png` | 860×1280 (세로) | `ManagerRevenueCard`를 `Size(430, 640)`로 캡처 — 분류 카드 7종 + 추이 차트가 세로로 쌓이는 카드라 원래 세로형이다 |

두 장은 **화면 스크린샷이 아니라 대시보드 안 개별 위젯 카드**(risk.png/payroll.png와 같은
부류)라, "화면은 태블릿 가로여야 한다"는 요구사항의 대상(전체 화면 캡처)과 성격이 다르다.
`.mid`(620px) 클래스로 표시되어 실제 페이지에서는 큰 문제 없이 보이지만, **엄밀히는 세로
이미지가 남아 있다** — 완전히 없애려면 카드 위젯 자체를 다른 형태(예: 대시보드 전체
`ManagerDashboardScreen` 캡처 후 크롭)로 다시 잡아야 하며, 이번 작업에서는 손대지 않았다.
사용자가 이 2장도 landscape로 바꾸길 원하면 후속 작업으로 진행할 것.

### 검증 방법

```bash
cd ~/ssentif-redesign && python3 -m http.server 8990
```

- `curl` 로 `assets/guide/admin/*.png` 전체 200 확인.
- 헤드리스 Chrome(`--window-size=1400,20000 --screenshot=`)으로 풀페이지 캡처 후 구간별 크롭해
  육안 검수 — 공통 8개(계정/워크스페이스/모드전환/프로필/앱설정/채팅/공지/메모) 전부 태블릿
  가로 화면으로 통일된 것, notice-stats/member-analytics 경고 콜아웃이 정상 렌더된 것을 확인.
- Python PIL로 `guide-admin.html`이 참조하는 이미지 21장 전수 스캔 — landscape 19 / 세로 2
  (alerts/revenue, 위 표 참조).

## §11. 2026-08-06 — 관리자 모드 4건 시각 검수·수정 (사용자 승인 순서대로)

사용자가 "관리자 모드가 전체적으로 이상하다"고 지적 → 직접 헤드리스 Chrome 풀페이지 캡처로
`guide-admin.html`을 훑어 4건을 찾고, 사용자가 제시한 순서(①→④)대로 승인받아 진행했다.
전부 **캡처 fixture/하네스 버그**였다 — 앱 코드는 건드리지 않았다.

### ① 채팅(`chat.png`) — 검은 사각형

**원인**: `guide_admin_common_tablet_capture_test.dart`의 채팅 캡처가 `ChatSplitView`를
**Scaffold 없이 단독으로 캡처**했다. `ChatSplitView`는 실제 앱에서 `AdaptiveScaffold` 본문
안에 들어가 그 배경(`surfaceMain`)을 물려받는 전제로 만들어져 있어 자체 배경이 없다 — 캡처
하네스가 `size` 없이 `child`를 `MaterialApp(home: child)`로 바로 띄우면 Padding 여백이
배경색 없이 남아 캔버스 검정이 그대로 비쳤다(우측 상단 카드 위 여백 kChatPanelTopInset
자리).

**진단 경로**: `_FakeChatRooms`가 `chatRoomsProvider`만 오버라이드하고 `interact:` 훅이
없어, 캡처 시점에는 `ChatRoomScreen`이 아예 마운트되지 않고 우측이 항상 빈 상태
("대화를 선택해주세요")라는 것부터 확인(에이전트 위임 조사) → 그럼에도 검은 배경이 남는
이유는 `ChatMessagesNotifier` 네트워크 실패가 아니라 **배경색 자체가 없는 것**임을 실제
raw PNG를 열어 확인.

**수정**: 캡처 child를 `Builder`로 감싸 `Scaffold(backgroundColor: colors.surfaceMain, body:
ChatSplitView())`로 교체(`guide_admin_common_tablet_capture_test.dart` "가이드(관리자) —
채팅(태블릿 분할)" 테스트). `GnColors` import 추가 필요.

### ② risk.png / ai-agent.png — 카드 하단·화면 절반이 빈 여백

- **risk.png**: `ManagerRiskCard`를 `size: Size(430, 220)`로 고정 캡처했는데 실제 콘텐츠
  높이는 ~165pt뿐이라 하단 ~55pt가 빈 흰 여백으로 남았다. → `size`를 `Size(430, 175)`로
  콘텐츠에 맞게 축소(`guide_admin_capture_test.dart` "운영 위험도 카드").
- **ai-agent.png**: `AiAgentChatScreen`을 `ScreenshotDevice.tabletLandscape`(1180×820)
  풀사이즈로 캡처했는데 fixture 대화가 2턴뿐이라 화면 절반 이상이 빈 배경이었다(메시지
  리스트가 하단 정렬이라 위쪽에 빈 공간이 생기는 구조). 후처리 crop 대신 **캡처 디바이스
  자체를 줄이는** 근본 수정 — `ScreenshotDevice('ai_agent_short', Size(1180, 380), 2.0)`
  커스텀 디바이스로 교체(`guide_admin_capture_test.dart` "AI 운영 어시스턴트").

### ③ revenue.png — "월별" 탭인데 x축에 일별 날짜(7/11~7/16)

**진단**(에이전트 위임): `ManagerRevenueCard`의 일별/월별 토글·날짜 네비·차트 헤더는 전부
`managerRevenueWindowProvider`(별도 리버팟 provider, 기본값 `RevenueWindow.thisMonth()` =
월별)가 정하고, 주입한 `ManagerRevenue` fixture의 `period: 'day'` 필드는 렌더링 어디에서도
읽히지 않는다. 테스트가 `managerRevenueProvider`만 오버라이드하고 `managerRevenueWindowProvider`는
그대로 둬서 **기본값(월별)로 열렸는데 fixture의 series 라벨은 일별 날짜 문자열**이라
"월별 매출 추이" 헤더 아래 `7/11`~`7/16` 날짜가 찍히는 불일치가 났다.

**1차 수정 시도**(anchor=2026-07-16)로도 총액이 0원으로 깨짐 → `_dayView`가 series를
**라벨 문자열을 파싱하지 않고** `loadAnchor`(anchor가 속한 주의 **토요일**)에서 역산한
실제 날짜로 재색인한다는 것을 소스에서 확인. 2026-07-16은 **목요일**이라 `loadAnchor`가
그 주 토요일(7/18)로 밀리면서 series가 엉뚱한 요일에 배치돼 선택 버킷이 0원 항목과
맞아떨어진 것.

**최종 수정**: anchor를 **실제 토요일**인 `DateTime(2026, 7, 18)`로 지정
(`_FixedDailyRevenueWindow` 클래스 신설, `managerRevenueWindowProvider.overrideWith`).
이러면 `loadAnchor == anchor`가 성립해 fixture series 7개가 일~토 그대로 채워지고, 총액
740,000원·분류·전일 대비 +19%가 선택된 토요일 막대와 정확히 일치한다. **x축 라벨은
day view에서 항상 요일 문자(일/월/화/수/목/금/토)** 이지 날짜 문자열이 아니다 — 이번에
확인된 정상 동작.

### 검증

세 테스트를 개별 `flutter test --plain-name`으로 재실행 → 각 raw PNG를 직접 열어 확인 →
`/tmp/admin_shots2/`(기존 21종 원본 보관 폴더)의 해당 3개 파일만 교체 →
`python3 build_admin_assets.py /tmp/admin_shots2 ~/ssentif-redesign/assets/guide/admin`
재실행(`MISSING: none` 확인) → `guide-admin.html`을 실제 Chrome에 띄워 육안 확인.

수정된 테스트 파일 2종(`guide_admin_capture_test.dart`,
`guide_admin_common_tablet_capture_test.dart`)은 `$CP/capture/`에도 복사해뒀다 — §10의
"앱 폴더가 교체됐다면 먼저 복구" 절차가 이제 이 수정본을 사용한다.

### 남은 것(승인받지 않음, 착수 안 함)

- **D--36 이중 하이픈**: 전체회원 목록에서 만료 회원의 D-day 표기가 `D--36`처럼 겹쳐
  보이는 포맷 오류. 사용자가 우선순위 최하위로 미루고 진행하라 하지 않음 — **미착수**.
- 배포(`git commit`/`push`)는 하지 않았다 — 사용자가 "배포해줘"라고 말할 때까지 대기.
