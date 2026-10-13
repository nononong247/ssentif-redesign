import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_members/data/repositories/checkin_repository.dart';
import 'package:ssentif_members/domain/models/checkin_eligibility.dart';
import 'package:ssentif_members/domain/models/member_notice.dart';
import 'package:ssentif_members/features/home/widgets/home_checkin_card.dart';
import 'package:ssentif_members/features/home/widgets/home_workspace_section.dart';
import 'package:ssentif_members/providers/centers/linked_centers_provider.dart';
import 'package:ssentif_members/providers/checkin/checkin_providers.dart';
import 'package:ssentif_members/providers/notices/member_notices_provider.dart';

import 'screenshot_harness.dart';

/// 홈 **센터 덩어리** 캡처 — `[로고 센터명]` 헤더 + 센터 칩 + 입장 카드 + 공지 리스트.
///
/// ⚠️ 라이트/다크를 모두 찍는다 —
/// · 로고 폴백은 `GnGradients.brandSymbol` 고정 그라디언트 + 흰 잉크라 모드 불변이어야 하고,
/// · 주간 출석 박스의 "민트 채움(입장) ↔ 테두리만(미입장) ↔ 오늘 링" 3상태 대비와
///   공지 카드 peek 캐러셀은 **값이 아니라 그림으로만** 판단된다.
class _FakeLinkedCenters extends LinkedCentersNotifier {
  @override
  Future<List<LinkedCenter>> build() async => const [
        LinkedCenter(
          id: 'lc-1',
          workspaceId: 'ws-1',
          workspaceName: '데이즈 피트니스',
          status: 'active',
        ),
        LinkedCenter(
          id: 'lc-2',
          workspaceId: 'ws-2',
          workspaceName: '그립노트 잠실점',
          status: 'active',
        ),
      ];
}

/// 캡처가 실제 네트워크(Dio)로 나가지 않게 하는 최소 stub.
class _StubCheckinRepository implements CheckinRepository {
  @override
  Future<CheckinCredentialResponse> getCredential({bool rotate = false}) async =>
      CheckinCredentialResponse(
        checkinRef: 'ref-1',
        seedBase64: base64Encode(List<int>.filled(32, 7)),
        stepSeconds: 30,
        serverTime: DateTime.utc(2026, 9, 4),
      );

  @override
  Future<void> revokeCredential() async {}

  @override
  Future<List<CheckinEligibility>> getEligibility() async => const [];

  @override
  Future<CheckinHistoryPage> getHistory(
    String workspaceId, {
    DateTime? month,
    String? cursor,
    int limit = 20,
  }) async => const CheckinHistoryPage(items: [], nextCursor: null);
}

MemberNotice _notice(String id, String title, NoticeCategory category,
        {bool important = false}) =>
    MemberNotice(
      id: id,
      workspaceId: 'ws-1',
      workspaceName: '데이즈 피트니스',
      title: title,
      // 카드가 2줄 미리보기를 싣는 구성이라 픽스처에도 본문을 둔다 — 없으면 제목과
      // 게시일 사이가 통째로 비어 실제와 다른 그림이 찍힌다.
      contentPreview: '추석 연휴 기간 센터를 휴관합니다. 예약된 수업은 자동으로 다음 주로 '
          '이월되니 참고해 주세요.',
      category: category,
      important: important,
      publishedAt: DateTime(2026, 9, 1),
    );

void main() {
  // 이번 주 월~수 입장 — 민트 채움과 오늘 링이 한 그림에 함께 나오게 한다.
  final week = checkinWeekDays(DateTime.now());

  final overrides = [
    linkedCentersProvider.overrideWith(_FakeLinkedCenters.new),
    checkinRepositoryProvider.overrideWithValue(_StubCheckinRepository()),
    checkinEligibilityProvider.overrideWith((ref) async => [
          CheckinEligibility(
            workspaceId: 'ws-1',
            workspaceName: '데이즈 피트니스',
            buttonVisible: true,
            todayEligible: true,
            weekCheckinDates: [week[0], week[2]],
          ),
          // 두 번째 센터 — 칩·페이지뷰가 그림에 나오게 한다.
          const CheckinEligibility(
            workspaceId: 'ws-2',
            workspaceName: '그립노트 잠실점',
            buttonVisible: true,
            todayEligible: false,
            hint: '오늘은 예약된 수업이 없어요',
          ),
        ]),
    homeNoticeGroupsProvider.overrideWith((ref) async => [
          WorkspaceNoticeGroup(
            workspaceId: 'ws-1',
            workspaceName: '데이즈 피트니스',
            notices: [
              _notice('n-1', '추석 연휴 휴관 안내', NoticeCategory.holiday,
                  important: true),
              _notice('n-2', '샤워실 정비 일정', NoticeCategory.maintenance),
              _notice('n-3', '가을 등록 프로모션', NoticeCategory.event),
              _notice('n-4', '주차장 이용 안내', NoticeCategory.notice),
            ],
          ),
        ]),
  ];

  for (final dark in [false, true]) {
    testWidgets('home_workspace${dark ? '_dark' : '_light'}', (tester) async {
      await captureScreenshot(
        tester,
        name: 'home_workspace${dark ? '_dark' : '_light'}',
        device: ScreenshotDevice.phonePortrait,
        darkMode: dark,
        overrides: overrides,
        child: const Scaffold(
          body: SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 17.5),
              child: HomeWorkspaceSection(),
            ),
          ),
        ),
      );
    });
  }
}
