// 메모 에디터 첨부 스트립 캡처 — 맨 앞 1:1 사진 추가 타일(원형 배지) 확인.
//
// 실행: flutter test test_screenshots/memo_editor_attachment_capture_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/domain/enums/memo_access.dart';
import 'package:ssentif_coach/domain/models/memo.dart';
import 'package:ssentif_coach/features/memo/widgets/memo_editor_panel.dart';
import 'package:ssentif_coach/providers/memo/memo_providers.dart';

import 'package:ssentif_coach/core/env/app_env.dart';
import 'package:ssentif_coach/core/auth/token_storage.dart';
import 'package:ssentif_coach/core/core_providers.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';

import 'screenshot_harness.dart';

Memo _memo({required List<String> attachments}) => Memo(
  id: 'memo-1',
  workspaceId: 'ws-1',
  ownerStaffId: 'staff-1',
  ownerName: '김코치',
  title: '8월 상담 준비 메모',
  content: '신규 회원 상담 시 확인할 항목들을 정리해 둡니다.',
  pinned: false,
  shared: false,
  shareCount: 0,
  myAccess: MemoAccess.owner,
  attachmentUrls: attachments,
  createdAt: DateTime(2026, 7, 30, 9),
  updatedAt: DateTime(2026, 7, 30, 10, 20),
);

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GnLocalStorage.init();
  });
  for (final dark in [false, true]) {
    final suffix = dark ? 'dark' : 'light';

    testWidgets('메모 에디터 · 첨부 있음 ($suffix)', (tester) async {
      await captureScreenshot(
        tester,
        name: 'memo_editor_attachments_$suffix',
        darkMode: dark,
        size: const Size(720, 620),
        overrides: [
        appEnvProvider.overrideWithValue(AppEnv.fromEnvironment()),
        tokenStorageProvider.overrideWithValue(TokenStorage()),
          memoDetailProvider('memo-1').overrideWith(
            (ref) async => _memo(
              attachments: const [
                'https://example.com/a.jpg',
                'https://example.com/b.jpg',
              ],
            ),
          ),
        ],
        child: const MemoEditorPanel(memoId: 'memo-1'),
      );
    });

    testWidgets('메모 에디터 · 첨부 없음 ($suffix)', (tester) async {
      await captureScreenshot(
        tester,
        name: 'memo_editor_no_attachments_$suffix',
        darkMode: dark,
        size: const Size(720, 620),
        overrides: [
        appEnvProvider.overrideWithValue(AppEnv.fromEnvironment()),
        tokenStorageProvider.overrideWithValue(TokenStorage()),
          memoDetailProvider(
            'memo-1',
          ).overrideWith((ref) async => _memo(attachments: const [])),
        ],
        child: const MemoEditorPanel(memoId: 'memo-1'),
      );
    });
  }
}
