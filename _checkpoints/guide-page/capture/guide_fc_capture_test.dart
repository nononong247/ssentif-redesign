/// 홈페이지 `guide-fc.html`(데스크 모드 가이드) 전용 캡처 —
/// 출입관리·데스크 모드 설정 탭의 **사용 중** 상태(데스크 계정 있음 · 기기 1대 로그인).
///
/// 앱 기본 테스트 `workspace_settings_checkin_capture_test.dart` 는 미사용 상태만 찍는다.
/// 원본 보관: ~/ssentif-redesign/_checkpoints/guide-page/capture/
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/data/dto/checkin/checkin_settings_dtos.dart';
import 'package:ssentif_coach/data/repositories/backend_checkin_repository.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/kiosk/kiosk_device_store.dart';
import 'package:ssentif_coach/features/workspace_select/widgets/workspace_settings_dialog.dart';
import 'package:ssentif_coach/providers/repository_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

class _OwnerWorkspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => const WorkspaceContext(
    workspaceId: 'ws1',
    staffId: 'me',
    role: StaffRole.owner,
    defaultMode: CoachMode.admin,
  );
}

/// 사용 중인 센터 — 토글 on · 데스크 계정 있음 · 태블릿 1대 로그인.
class _EnabledCheckinRepository implements BackendCheckinRepository {
  @override
  Future<CheckinSettings> getCheckinSettings(String workspaceId) async =>
      CheckinSettings(
        checkinEnabled: true,
        fcAccount: FcAccountSummary(
          loginId: 'gangnam-desk',
          passwordUpdatedAt: DateTime.now().subtract(const Duration(days: 12)),
        ),
      );

  @override
  Future<List<CheckinDevice>> listCheckinDevices(String workspaceId) async => [
    CheckinDevice(
      deviceId: 'dev-1',
      name: '데스크 태블릿',
      loggedInAt: DateTime.now().subtract(const Duration(hours: 3)),
      lastSeenAt: DateTime.now().subtract(const Duration(minutes: 2)),
    ),
  ];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeDeviceStore implements KioskDeviceStore {
  @override
  Future<String?> readDeviceId() async => null;

  @override
  Future<void> save(String deviceId) async {}
}

void main() {
  testWidgets('데스크 모드 설정 — 사용 중 (태블릿)', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_fc_settings_enabled',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_OwnerWorkspace.new),
        currentWorkspaceInfoProvider.overrideWith((ref) async => null),
        checkinRepositoryProvider.overrideWithValue(_EnabledCheckinRepository()),
        kioskDeviceStoreProvider.overrideWithValue(_FakeDeviceStore()),
      ],
      child: Builder(
        builder: (context) => Center(
          child: ElevatedButton(
            onPressed: () => showWorkspaceSettingsDialog(
              context,
              initialMenuLabel: kWorkspaceSettingsCheckinMenuLabel,
            ),
            child: const Text('open'),
          ),
        ),
      ),
      interact: (tester) async {
        debugResetWorkspaceSettingsGuard();
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));
        if (find.byIcon(Icons.close).evaluate().isNotEmpty) {
          await tester.tap(find.byIcon(Icons.close));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));
        }
      },
    );
  });
}
