import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_members/core/checkin/checkin_credential_store.dart';
import 'package:ssentif_members/domain/models/checkin_eligibility.dart';
import 'package:ssentif_members/features/checkin/checkin_qr_sheet.dart';
import 'package:ssentif_members/providers/checkin/checkin_providers.dart';

import 'screenshot_harness.dart';

/// 입장 QR 시트 캡처 — 헤더·2줄 안내·통과 배지·QR·카운트다운.
///
/// ⚠️ 라이트/다크를 모두 찍는다 — 통과 배지는 **`primary` solid(민트 채움 + 흰 잉크)**
/// 라 대비가 1.79:1 이고(정본이 알고 채택한 값), QR 카드는 **양 모드 고정 흰색**이어야
/// 스캐너가 요구하는 quiet zone 이 유지된다. 둘 다 값이 아니라 그림으로 판단된다.
class _FixedCredentialNotifier extends CheckinCredentialNotifier {
  _FixedCredentialNotifier(this._state);

  final CheckinCredentialState _state;

  @override
  Future<CheckinCredentialState> build() async => _state;
}

void main() {
  final seed = Uint8List.fromList(List<int>.generate(16, (i) => i));
  // 카운트다운이 매번 달라지지 않도록 시계를 고정한다.
  final clock = DateTime.utc(2026, 9, 4, 3, 0, 12);

  final overrides = [
    checkinCredentialProvider.overrideWith(
      () => _FixedCredentialNotifier(
        CheckinCredentialReady(
          StoredCredential(ref: 'ref-1', seed: seed, clockOffset: Duration.zero),
        ),
      ),
    ),
  ];

  for (final dark in [false, true]) {
    testWidgets('guide_checkin_qr${dark ? '_dark' : '_light'}', (tester) async {
      await captureScreenshot(
        tester,
        name: 'guide_checkin_qr${dark ? '_dark' : '_light'}',
        device: ScreenshotDevice.phonePortrait,
        darkMode: dark,
        overrides: overrides,
        child: Scaffold(
          body: Align(
            alignment: Alignment.bottomCenter,
            child: CheckinQrSheet(
              initialWorkspaceId: 'ws-1',
              nowUtc: () => clock,
              eligibility: const [
                CheckinEligibility(
                  workspaceId: 'ws-1',
                  workspaceName: '센티프 피트니스 강남점',
                  buttonVisible: true,
                  todayEligible: true,
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
