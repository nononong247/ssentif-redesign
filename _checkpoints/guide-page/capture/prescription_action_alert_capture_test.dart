// 강사 홈 업무 알림 — 「처방 운동 완료」 행 캡처(세로 폰 폭). 인스타 캐러셀용.
//
// 실행: flutter test test_screenshots/prescription_action_alert_capture_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/member_status.dart';
import 'package:ssentif_coach/domain/models/action_item.dart';
import 'package:ssentif_coach/features/home/widgets/coach_action_needed_section.dart';
import 'package:ssentif_coach/providers/home/home_providers.dart';

import 'screenshot_harness.dart';

final _fixture = [
  ActionItem(
    type: ActionType.prescriptionCompleted,
    clientId: 'c1',
    memberName: '김지혜',
    message: '처방 운동 완료',
    subtitle: '김지혜 회원 · 10월 2일 처방 · 3/3종목 수행',
    priorityOrder: -2,
    alertKey: 'alert-rx-1',
    eventResourceId: 'rec-1',
    occurredAt: DateTime(2026, 10, 2, 19, 40),
    activityDate: DateTime(2026, 10, 2),
  ),
  const ActionItem(
    type: ActionType.sessionLow,
    clientId: 'c3',
    memberName: '박지훈',
    message: '개인수업 잔여 2회 남았습니다',
    priorityOrder: 1,
    memberStatus: MemberStatus.active,
  ),
  const ActionItem(
    type: ActionType.facilityExpiring,
    clientId: 'c2',
    memberName: '이서연',
    message: '시설이용권이 3일 후 만료돼요',
    priorityOrder: 2,
    memberStatus: MemberStatus.active,
  ),
];

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await GnLocalStorage.init();
  });

  testWidgets('업무 알림 — 처방 운동 완료 행', (tester) async {
    await captureScreenshot(
      tester,
      name: 'rx_04_coach_home_alert',
      device: ScreenshotDevice.phonePortrait,
      size: const Size(358, 300),
      overrides: [
        coachActionNeededProvider.overrideWith((ref) async => _fixture),
      ],
      child: const CoachActionNeededSection(),
    );
  });
}
