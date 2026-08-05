# 사용 가이드 페이지(guide.html) — 작업 체크포인트

> **목적**: 컨텍스트가 압축되거나 세션이 바뀌어도 이어받을 수 있게 현재 상태·결정·다음 할 일을 기록한 핸드오프 문서.
> **마지막 갱신**: 2026-08-05

---

## 0. 30초 요약 (새 세션에서 여기부터)

- **무엇을 만들고 있나**: `www.ssentif.kr/guide.html` (**강사 모드** 사용 가이드)를 최신 앱 기준으로 전면 개편하고, **실제 앱 화면 33장**을 넣어 완성형 가이드로 만드는 작업.
- **핵심 파일**: [`guide.html`](../../guide.html) + [`assets/guide/`](../../assets/guide) 33장.
- **지금 어디까지**: 본문 전면 재작성 완료 + 이미지 33장 삽입 완료. **최신 앱(2026-08-05 업데이트본) 기준으로 재캡처까지 끝남.** 커밋은 안 함.
- **다음 할 일**: ① '강사 모드와 관리자 모드' 절에 **모드 전환 방법** 추가 ② tofu 2건 수정 후 이미지 2장 재캡처 ③ 배포(사용자가 "배포해줘" 할 때만).

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
- `guide-admin.html` · `guide-member.html` — **이번 작업 범위 밖**(손대지 않음).
- 스타일은 `guide.html` 내부 `<style>` 에 있다(`style.css` 아님) — `.g-shot*` 규칙도 거기.

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
