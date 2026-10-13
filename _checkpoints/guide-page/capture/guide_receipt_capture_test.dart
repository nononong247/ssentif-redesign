import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/membership_category.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/client_payment.dart';
import 'package:ssentif_coach/domain/models/member.dart';
import 'package:ssentif_coach/domain/models/membership_bundle.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/members/tabs/membership_tab.dart';
import 'package:ssentif_coach/providers/members/member_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

/// 결제건 영수증 · 상품 상세 다이얼로그 캡처.
///
/// 둘 다 **다이얼로그**라 위젯 단위 캡처(`size`)로는 잡히지 않는다(루트 오버레이에
/// 뜬다) — 화면 전체를 찍는다.
const _memberId = 'm1';

String _iso(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-'
    '${d.month.toString().padLeft(2, '0')}-'
    '${d.day.toString().padLeft(2, '0')}';

final _today = DateTime.now();

/// 결합 결제건 1건 — 분할 결제 + 정산 설정된 PT + 정산 미설정 PT + 락커.
/// 영수증이 보여줄 것(수단별 내역 · 분류별 금액 · 할인 · 미설정 안내)이 한 건에
/// 모두 들어 있어야 캡처가 실제 화면을 대표한다.
List<MembershipBundle> _fixtures() => [
  MembershipBundle(
    payment: ClientPayment(
      id: 'PAY-20260711-0124',
      workspaceId: 'ws1',
      clientId: _memberId,
      price: 1300000,
      paidAt: '${_iso(_today.subtract(const Duration(days: 40)))}T14:31:00',
      paymentMethod: 'card',
      registrationType: 'new',
      paymentSplits: const [
        ClientPaymentSplit(
          method: 'card',
          amount: 900000,
          cardIssuer: 'SHINHAN',
        ),
        ClientPaymentSplit(method: 'cash', amount: 400000),
      ],
    ),
    memberships: [
      MembershipWithStatus(
        status: 'active',
        membership: Membership(
          id: 'pt30',
          workspaceId: 'ws1',
          clientId: _memberId,
          category: MembershipCategory.pt,
          name: '개인수업 30회',
          startDate: _iso(_today.subtract(const Duration(days: 40))),
          endDate: _iso(_today.add(const Duration(days: 50))),
          totalCount: 30,
          remainingCount: 17,
          sessionDurationMin: 50,
          unitPrice: 40000,
          price: 1200000,
          paymentId: 'PAY-20260711-0124',
        ),
      ),
      MembershipWithStatus(
        status: 'active',
        membership: Membership(
          id: 'fac3',
          workspaceId: 'ws1',
          clientId: _memberId,
          category: MembershipCategory.facility,
          name: '시설이용권 3개월',
          startDate: _iso(_today.subtract(const Duration(days: 40))),
          endDate: _iso(_today.add(const Duration(days: 50))),
          price: 300000,
          paymentId: 'PAY-20260711-0124',
        ),
      ),
    ],
  ),
];

Future<void> _capture(
  WidgetTester tester, {
  required String name,
  required bool dark,
  required Future<void> Function(WidgetTester tester) interact,
}) async {
  await captureScreenshot(
    tester,
    name: name,
    darkMode: dark,
    overrides: [
      memberAllMembershipsProvider(
        _memberId,
      ).overrideWith((ref) async => _fixtures()),
      // 영수증의 `발급한 센터` 행은 워크스페이스를 못 읽으면 그려지지 않는다 —
      // fixture 를 주지 않으면 그 행이 캡처에 한 번도 나타나지 않는다.
      currentWorkspaceInfoProvider.overrideWith(
        (ref) async => const Workspace(
          id: 'ws1',
          name: '센티프 피트니스 강남점',
          ownerUserId: 'u1',
          status: 'active',
          createdAt: '2026-01-01',
        ),
      ),
    ],
    interact: interact,
    child: const Scaffold(body: MembershipTab(memberId: _memberId)),
  );
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
    TestWidgetsFlutterBinding.ensureInitialized();
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await GnLocalStorage.init();
  });

  setUp(() async {
    await GnLocalStorage.saveWorkspace(
      const WorkspaceContext(
        workspaceId: 'ws1',
        staffId: 'st1',
        role: StaffRole.admin,
      ),
    );
  });

  Future<void> openReceipt(WidgetTester tester) async {
    await tester.tap(find.byKey(kPaymentReceiptButtonKey));
    await tester.pumpAndSettle();
  }

  Future<void> openItemDetail(WidgetTester tester) async {
    await tester.tap(find.text('개인수업 30회'));
    await tester.pumpAndSettle();
  }

  testWidgets('결제건 영수증 — 라이트', (tester) async {
    await _capture(
      tester,
      name: 'guide_receipt_light',
      dark: false,
      interact: openReceipt,
    );
  });

  testWidgets('결제건 영수증 — 다크', (tester) async {
    await _capture(
      tester,
      name: 'guide_receipt_dark',
      dark: true,
      interact: openReceipt,
    );
  });

  testWidgets('상품 상세 — 라이트', (tester) async {
    await _capture(
      tester,
      name: 'membership_item_detail_light',
      dark: false,
      interact: openItemDetail,
    );
  });

  testWidgets('상품 상세 — 다크', (tester) async {
    await _capture(
      tester,
      name: 'membership_item_detail_dark',
      dark: true,
      interact: openItemDetail,
    );
  });
}
