// test_screenshots/ 하위 모든 테스트의 공통 부트스트랩.
// flutter_test 는 기본 Ahem(□) 폰트만 쓰므로, 실제 UI 캡처를 위해
// 앱 번들 폰트(Pretendard 9 weights)를 실물 로드한다.
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  TestWidgetsFlutterBinding.ensureInitialized();

  await _loadAllFonts();
  // DateFormat('...', 'ko') 사용 화면 대비
  await initializeDateFormatting('ko');
  // GnLocalStorage(SharedPreferences) 의존 provider 대비
  // (테스트 전용 config 파일 — lint 가 test 파일로 인식하지 못해 ignore)
  // ignore: invalid_use_of_visible_for_testing_member
  SharedPreferences.setMockInitialValues(<String, Object>{});
  _mockPlugins();

  await testMain();
}

/// FontManifest.json 의 모든 폰트(MaterialIcons 포함)를 실물 로드하고,
/// 번들에 없는 family('Inter', 미지정→'Roboto')는 Pretendard 로 별칭 등록해
/// 실기기의 시스템 폰트 폴백을 근사한다.
Future<void> _loadAllFonts() async {
  final manifest = await rootBundle.loadString('FontManifest.json');
  final entries =
      (json.decode(manifest) as List).cast<Map<String, dynamic>>();

  final pretendardAssets = <String>[];
  for (final entry in entries) {
    var family = entry['family'] as String;
    // 'packages/pkg/Family' → 'Family'
    if (family.startsWith('packages/')) {
      family = family.split('/').last;
    }
    final assets = (entry['fonts'] as List)
        .cast<Map<String, dynamic>>()
        .map((f) => f['asset'] as String)
        .toList();
    if (family == 'Pretendard') pretendardAssets.addAll(assets);

    final loader = FontLoader(family);
    for (final asset in assets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }

  // 미번들 family 폴백 별칭 (앱 코드가 'Inter'/family 미지정을 쓰는 곳 대응).
  // 'Ahem' 은 flutter tester 의 기본 폰트 — 덮어써서 family 미지정 텍스트도
  // 실기기(시스템 폰트 폴백)처럼 실제 글리프로 렌더되게 한다.
  // 'monospace' 계열은 코드 칩(초대코드·연동코드)이, 'FlutterTest' 는 최신
  // flutter_test 의 기본 family 다 — 빠뜨리면 그 텍스트만 □ 로 찍힌다.
  for (final alias in [
    'Inter',
    'Roboto',
    'Ahem',
    'Arial',
    'sans-serif',
    'monospace',
    'Menlo',
    'Courier',
    'FlutterTest',
  ]) {
    final loader = FontLoader(alias);
    for (final asset in pretendardAssets) {
      loader.addFont(rootBundle.load(asset));
    }
    await loader.load();
  }
}

/// 네이티브 플러그인 채널 mock — 캡처 중 MissingPluginException 방지.
void _mockPlugins() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  // path_provider (cached_network_image 캐시 디렉토리 등)
  final tmp = Directory.systemTemp.createTempSync('screenshot_cache');
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.flutter.io/path_provider'),
    (call) async => tmp.path,
  );

  // flutter_secure_storage (토큰 조회 — 항상 빈 값)
  messenger.setMockMethodCallHandler(
    const MethodChannel('plugins.it_nomads.com/flutter_secure_storage'),
    (call) async {
      if (call.method == 'readAll') return <String, String>{};
      return null;
    },
  );
}
