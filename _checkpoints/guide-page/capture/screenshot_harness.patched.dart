// Screenshot capture harness — 가상 기기 없이 화면/위젯을 PNG로 추출한다.
//
// `flutter test`(호스트 헤드리스 렌더링) 위에서 실제 UI에 최대한 가깝게 렌더한 뒤
// RepaintBoundary.toImage 로 PNG 를 직접 파일로 저장한다 (골든 비교 아님).
//
// 실행: flutter test test_screenshots/<xxx>_capture_test.dart
// 출력: ~/Downloads/<name>.png (SCREENSHOT_DIR 환경변수로 변경 가능)
//
// 이 디렉토리는 test/ 밖에 있어 일반 `flutter test` 실행에 포함되지 않는다.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/core/theme/app_theme.dart';
import 'package:ssentif_coach/core/theme/gn_text_styles.dart';

/// 디바이스 프리셋 — 논리 사이즈(dp) + devicePixelRatio.
/// DPR 은 레이아웃 브레이크포인트/2x 에셋 선택/출력 해상도에 모두 반영된다.
class ScreenshotDevice {
  const ScreenshotDevice(this.name, this.size, this.dpr);

  final String name;
  final Size size;
  final double dpr;

  /// iPad Pro 11" 가로 (앱 기준 레이아웃, 1180×820pt) — 기본값
  static const tabletLandscape = ScreenshotDevice(
    'tablet_landscape',
    Size(1180, 820),
    2.0,
  );

  /// 낮은 가로 태블릿 (1024×768pt) — **좌측 컬럼이 가장 빡빡한** 기준 기기.
  /// 다음 수업 카드와 도구 카드 2종이 이 높이 안에서 스크롤 없이 서야 한다.
  static const smallTabletLandscape = ScreenshotDevice(
    'small_tablet_landscape',
    Size(1024, 768),
    2.0,
  );

  /// 더 낮은 가로 태블릿 (1024×640pt) — 세로가 짧은 기기·분할 화면 기준.
  /// 1024×640 에서 업무 알림 카드가 3px 넘쳤다(2026-09-07). 이 프리셋이 그 가드다.
  static const shortTabletLandscape = ScreenshotDevice(
    'short_tablet_landscape',
    Size(1024, 640),
    2.0,
  );
  static const tabletPortrait = ScreenshotDevice(
    'tablet_portrait',
    Size(820, 1180),
    2.0,
  );

  /// iPhone 급 세로 (390×844pt @3x)
  static const phonePortrait = ScreenshotDevice(
    'phone_portrait',
    Size(390, 844),
    3.0,
  );
}

final _captureKey = GlobalKey();
final _widgetCaptureKey = GlobalKey();
Uint8List? _placeholderPngBytes;

/// [child]를 실제 앱과 동일한 테마/로케일 환경에서 렌더해 PNG 로 저장한다.
///
/// - [name]: 출력 파일명 (확장자 제외)
/// - [overrides]: Riverpod provider override (fixture 데이터 주입)
/// - [device]: 캡처 디바이스 프리셋
/// - [darkMode]: 다크모드 캡처
/// - [size]: 지정 시 화면 중앙에 해당 크기 박스로 감싸 위젯 단위 캡처
/// - [settle]: 진입 애니메이션 소화 시간. pumpAndSettle 은 무한 애니메이션
///   (펄스/shimmer/캐러셀 타이머) 때문에 사용하지 않는다.
/// - [interact]: 캡처 직전 상호작용 훅(탭으로 패널 펼침 등). 호출 후 짧은
///   settle pump 을 한 번 더 태운다.
/// - [outputDir]: 저장 폴더. 기본 $SCREENSHOT_DIR → ~/Downloads
Future<File> captureScreenshot(
  WidgetTester tester, {
  required Widget child,
  required String name,
  List<Override> overrides = const [],
  ScreenshotDevice device = ScreenshotDevice.tabletLandscape,
  bool darkMode = false,
  Size? size,
  Duration settle = const Duration(milliseconds: 1200),
  Future<void> Function(WidgetTester tester)? interact,
  List<File> precacheFiles = const [],
  String? outputDir,
}) async {
  // 실제 그림자 렌더링 — flutter_test 기본값은 그림자 off(단색 근사)라
  // 카드 depth 표현이 실기기와 달라진다.
  debugDisableShadows = false;
  tester.view.physicalSize = Size(
    device.size.width * device.dpr,
    device.size.height * device.dpr,
  );
  tester.view.devicePixelRatio = device.dpr;
  addTearDown(tester.view.reset);

  // 네트워크 이미지 placeholder(웜 그레이) 생성 — 실제 async 가 필요해 runAsync.
  await tester.runAsync(() async {
    _placeholderPngBytes ??= await _makePlaceholderPng();
  });

  final colors = darkMode ? AppTheme.dark() : AppTheme.light();
  // 캡처 전용: `FilledButton.styleFrom(textStyle:)` 로 넘어간 button 스타일은
  // fontFamily 가 null 이라 flutter_test 에서 한글이 □ 로 찍힌다(앱 실기기는 정상).
  // 테마 확장의 button 에만 패밀리를 박아 tofu 를 막는다.
  final baseStyles = colors.extension<GnTextStyles>();
  final theme = baseStyles == null
      ? colors
      : colors.copyWith(
          extensions: [
            ...colors.extensions.values.where((e) => e is! GnTextStyles),
            baseStyles.copyWith(
              button: baseStyles.button.copyWith(fontFamily: 'Pretendard'),
            ),
          ],
        );

  Widget home = child;
  if (size != null) {
    // 위젯 단위 캡처 — 내부 RepaintBoundary 로 위젯 영역만 저장한다.
    home = Scaffold(
      body: Center(
        child: RepaintBoundary(
          key: _widgetCaptureKey,
          child: SizedBox(width: size.width, height: size.height, child: child),
        ),
      ),
    );
  }

  final app = RepaintBoundary(
    key: _captureKey,
    child: ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: theme,
        locale: const Locale('ko', 'KR'),
        supportedLocales: const [Locale('ko', 'KR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: home,
      ),
    ),
  );

  late final File file;
  // 모든 네트워크 요청을 placeholder PNG 로 응답 (Image.network 등).
  await HttpOverrides.runZoned(() async {
    await tester.pumpWidget(app);
    // 로컬 File 이미지(실사진 주입) 디코드 — Image.file 도 codec 디코드가
    // 실제 async 라 fake-async 프레임만으로는 완성되지 않는다.
    for (final file in precacheFiles) {
      await tester.runAsync(() => precacheImage(
            FileImage(file),
            tester.element(find.byType(MaterialApp)),
          ));
    }
    // 진입 애니메이션(300ms fade/slide, 800ms scale, 1100ms 차트)을 소화.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 120));
    await tester.pump(const Duration(milliseconds: 480));
    await tester.pump(settle);

    if (interact != null) {
      await interact(tester);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
    }

    // 에셋 PNG(클레이 아이콘 등)는 비동기 디코드라 pump 만으로는 빈 채로
    // 찍힌다 — 트리의 모든 Image provider 를 runAsync 로 precache 한 뒤
    // 한 프레임 더 그린다.
    await tester.runAsync(() async {
      for (final element in find.byType(Image).evaluate()) {
        final image = element.widget as Image;
        try {
          await precacheImage(image.image, element);
        } catch (_) {
          // 실패(fake network 등)는 폴백 UI 로 — 캡처를 막지 않는다.
        }
      }
    });
    await tester.pump();

    file = await _writePng(
      tester,
      name,
      captureKey: size != null ? _widgetCaptureKey : _captureKey,
      outputDir: outputDir,
    );

    // 화면 unmount → dispose 로 주기 타이머(캐러셀 자동슬라이드 등) 정리.
    await tester.pumpWidget(const SizedBox());
  }, createHttpClient: (_) => _FakeImageHttpClient());
  // 테스트 종료 시 프레임워크 invariant 검사(teardown 이전)에 걸리지 않도록
  // 함수 안에서 직접 복원한다.
  debugDisableShadows = true;
  return file;
}

Future<File> _writePng(
  WidgetTester tester,
  String name, {
  required GlobalKey captureKey,
  String? outputDir,
}) async {
  final boundary =
      captureKey.currentContext!.findRenderObject()! as RenderRepaintBoundary;
  final dpr = tester.view.devicePixelRatio;

  _fillMissingFontFamily(tester.renderObject(find.byKey(_captureKey)));
  await tester.pump();
  late final Uint8List bytes;
  await tester.runAsync(() async {
    final image = await boundary.toImage(pixelRatio: dpr);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    bytes = data!.buffer.asUint8List();
  });

  final dir =
      outputDir ??
      Platform.environment['SCREENSHOT_DIR'] ??
      '${Platform.environment['HOME']}/Downloads';
  final file = File('$dir/$name.png');
  file.parent.createSync(recursive: true);
  file.writeAsBytesSync(bytes);
  // ignore: avoid_print
  print('SCREENSHOT_SAVED: ${file.path}');
  return file;
}

Future<Uint8List> _makePlaceholderPng() async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(
    const Rect.fromLTWH(0, 0, 40, 40),
    Paint()..color = const Color(0xFFD8D4CE),
  );
  final image = await recorder.endRecording().toImage(40, 40);
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

// ---------------------------------------------------------------------------
// 네트워크 이미지 mock — 모든 HTTP 요청에 200 + placeholder PNG 응답.
// flutter_test 기본 HttpClient 는 모든 요청에 400 을 반환해 이미지가 깨진다.
// (cached_network_image 는 sqflite 네이티브 의존으로 테스트에서 실패할 수 있으니
//  fixture 의 imageUrl 은 null 로 두고 앱의 폴백 UI(이니셜 아바타)를 태우는 것을 권장.)
// ---------------------------------------------------------------------------

// **실사진 주입**: 환경변수 `SCREENSHOT_PHOTO_DIR` 이 있으면, URL 마지막 경로
// 조각과 이름이 같은 파일을 그 폴더에서 찾아 그대로 응답한다.
// 예) `https://photos.test/diet.png` → `$SCREENSHOT_PHOTO_DIR/diet.png`.
// 환경변수를 주지 않으면 기존과 완전히 같다.
final Map<String, Uint8List?> _photoCache = {};

Uint8List? _photoBytesFor(Uri url) {
  final dir = Platform.environment['SCREENSHOT_PHOTO_DIR'];
  if (dir == null || dir.isEmpty) return null;
  final name = url.pathSegments.isEmpty ? '' : url.pathSegments.last;
  if (name.isEmpty) return null;
  return _photoCache.putIfAbsent(name, () {
    final file = File('$dir/$name');
    return file.existsSync() ? file.readAsBytesSync() : null;
  });
}

class _FakeImageHttpClient implements HttpClient {
  @override
  bool autoUncompress = true;
  @override
  Duration? connectionTimeout;
  @override
  Duration idleTimeout = const Duration(seconds: 15);
  @override
  int? maxConnectionsPerHost;
  @override
  String? userAgent;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _FakeRequest(url);

  @override
  Future<HttpClientRequest> openUrl(String method, Uri url) async =>
      _FakeRequest(url);

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeRequest implements HttpClientRequest {
  _FakeRequest(this._url);

  final Uri _url;

  @override
  bool followRedirects = true;
  @override
  int maxRedirects = 5;
  @override
  bool persistentConnection = true;
  @override
  int contentLength = -1;
  @override
  bool bufferOutput = true;

  final _headers = _FakeHeaders();

  @override
  HttpHeaders get headers => _headers;

  @override
  void add(List<int> data) {}

  @override
  Future<void> addStream(Stream<List<int>> stream) => stream.drain<void>();

  @override
  Future<HttpClientResponse> close() async =>
      _FakeResponse(_photoBytesFor(_url));

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeResponse extends Stream<List<int>> implements HttpClientResponse {
  _FakeResponse([Uint8List? photo])
      : _bytes = photo ?? _placeholderPngBytes ?? Uint8List(0);

  final Uint8List _bytes;
  late final Stream<List<int>> _body = Stream<List<int>>.value(_bytes);

  @override
  int get statusCode => 200;

  @override
  int get contentLength => _bytes.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  String get reasonPhrase => 'OK';

  @override
  bool get isRedirect => false;

  @override
  bool get persistentConnection => false;

  @override
  HttpHeaders get headers => _FakeHeaders();

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return _body.listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

class _FakeHeaders implements HttpHeaders {
  final Map<String, List<String>> _map = {};

  @override
  List<String>? operator [](String name) => _map[name.toLowerCase()];

  @override
  void add(String name, Object value, {bool preserveHeaderCase = false}) {
    _map.putIfAbsent(name.toLowerCase(), () => []).add('$value');
  }

  @override
  void set(String name, Object value, {bool preserveHeaderCase = false}) {
    _map[name.toLowerCase()] = ['$value'];
  }

  @override
  String? value(String name) => _map[name.toLowerCase()]?.join(', ');

  @override
  void forEach(void Function(String name, List<String> values) action) {
    _map.forEach(action);
  }

  @override
  void remove(String name, Object value) {
    _map[name.toLowerCase()]?.remove('$value');
  }

  @override
  void removeAll(String name) => _map.remove(name.toLowerCase());

  @override
  int contentLength = -1;

  @override
  bool chunkedTransferEncoding = false;

  @override
  ContentType? contentType;

  @override
  dynamic noSuchMethod(Invocation invocation) =>
      throw UnimplementedError('${invocation.memberName}');
}

/// 캡처 전용 보정 — family 를 지정하지 않은 텍스트(`FilledButton.styleFrom(
/// textStyle: const TextStyle(...))` 로 넘어간 버튼 라벨 등)는 flutter_test 엔진의
/// 테스트 폰트로 떨어져 한글이 □ 로 찍힌다. 폰트 별칭으로는 잡히지 않아(엔진 기본
/// family 고정) 캡처 직전에 **family 가 비어 있는 문단만** Pretendard 를 물려준다.
/// 실기기에서는 시스템 폰트로 정상 렌더되는 텍스트라 화면 구성은 바뀌지 않는다.
void _fillMissingFontFamily(RenderObject root) {
  void visit(RenderObject node) {
    if (node is RenderParagraph) {
      final span = node.text;
      var hasWidgetSpan = false;
      span.visitChildren((s) {
        if (s is WidgetSpan) hasWidgetSpan = true;
        return !hasWidgetSpan;
      });
      if (!hasWidgetSpan && span.style?.fontFamily == null) {
        node.text = TextSpan(
          style: const TextStyle(fontFamily: 'Pretendard'),
          children: [span],
        );
      }
    }
    node.visitChildren(visit);
  }

  visit(root);
}
