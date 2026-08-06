// 사용 가이드(www.ssentif.kr/guide-admin.html) — **관리자 모드** 화면 캡처.
//
// 강사 모드용은 `guide_docs_capture_test.dart`. 공용 fixture 규칙(실사용에 가까운
// 데이터·실사진 주입)은 그 파일 주석 참조.
//
// 실행:
//   SCREENSHOT_DIR=... SCREENSHOT_PHOTO_DIR=... \
//   flutter test test_screenshots/guide_admin_capture_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/core/utils/extensions.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/gender.dart';
import 'package:ssentif_coach/domain/enums/manager_alert_type.dart';
import 'package:ssentif_coach/domain/enums/member_status.dart';
import 'package:ssentif_coach/domain/enums/membership_category.dart';
import 'package:ssentif_coach/domain/enums/schedule_type.dart';
import 'package:ssentif_coach/domain/enums/session_status.dart';
import 'package:ssentif_coach/domain/enums/stability_level.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/ai_chat_message.dart';
import 'package:ssentif_coach/domain/models/manager_action_alert.dart';
import 'package:ssentif_coach/domain/models/manager_revenue.dart';
import 'package:ssentif_coach/domain/models/manager_risk.dart';
import 'package:ssentif_coach/domain/models/member.dart';
import 'package:ssentif_coach/domain/models/membership_template.dart';
import 'package:ssentif_coach/domain/models/payroll/payroll_detail.dart';
import 'package:ssentif_coach/domain/models/payroll/payroll_line_item.dart';
import 'package:ssentif_coach/domain/models/payroll/payroll_period_summary.dart';
import 'package:ssentif_coach/domain/models/payroll/payroll_record.dart';
import 'package:ssentif_coach/domain/models/schedule.dart';
import 'package:ssentif_coach/domain/models/user_profile.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/domain/enums/payroll/payroll_line_source.dart';
import 'package:ssentif_coach/domain/enums/payroll/payroll_line_status.dart';
import 'package:ssentif_coach/domain/enums/payroll/payroll_status.dart';
import 'package:ssentif_coach/features/ai_agent/ai_agent_chat_screen.dart';
import 'package:ssentif_coach/features/manager_dashboard/manager_dashboard_screen.dart';
import 'package:ssentif_coach/features/manager_dashboard/widgets/manager_action_alerts_card.dart';
import 'package:ssentif_coach/features/manager_dashboard/widgets/manager_revenue_card.dart';
import 'package:ssentif_coach/features/manager_dashboard/widgets/manager_risk_card.dart';
import 'package:ssentif_coach/features/operations/all_members_screen.dart';
import 'package:ssentif_coach/features/operations/staff_management_screen.dart';
import 'package:ssentif_coach/features/operations/tabs/operations_settings_tab.dart';
import 'package:ssentif_coach/features/operations/widgets/assign_coach_sheet.dart';
import 'package:ssentif_coach/features/payroll/payslip/payslip_preview_screen.dart';
import 'package:ssentif_coach/features/payroll/widgets/payroll_period_panel.dart';
import 'package:ssentif_coach/features/products/products_screen.dart';
import 'package:ssentif_coach/features/schedule/widgets/schedule_team_view.dart';
import 'package:ssentif_coach/providers/ai_agent/ai_agent_providers.dart';
import 'package:ssentif_coach/providers/auth/auth_providers.dart';
import 'package:ssentif_coach/providers/coach_mode_provider.dart';
import 'package:ssentif_coach/providers/manager_dashboard/manager_dashboard_providers.dart';
import 'package:ssentif_coach/providers/membership/membership_template_providers.dart';
import 'package:ssentif_coach/providers/members/engagement_providers.dart';
import 'package:ssentif_coach/providers/operations/staff_management_providers.dart';
import 'package:ssentif_coach/providers/schedule/schedule_providers.dart';
import 'package:ssentif_coach/providers/workspace/staff_admin_providers.dart';
import 'package:ssentif_coach/data/dto/workspace/workspace_dtos.dart';
import 'package:ssentif_coach/providers/members/member_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// 공용 fixture — 강사 모드 가이드와 같은 센터·같은 사람들을 쓴다.
// ---------------------------------------------------------------------------

const _workspace = WorkspaceContext(
  workspaceId: 'ws-1',
  staffId: 'staff-1',
  role: StaffRole.owner,
);

class _FakeWorkspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => _workspace;
}

const _user = UserProfile(
  id: 'user-1',
  email: 'owner@ssentif.kr',
  fullName: '박성훈',
  phone: '010-2345-6789',
  birthDate: '1992-04-18',
  gender: Gender.male,
  linkCode: 'a4kd91xz',
  createdAt: '2026-01-04T09:00:00',
);

class _FakeUser extends CurrentUser {
  @override
  Future<UserProfile?> build() async => _user;
}

const _workspaceInfo = Workspace(
  id: 'ws-1',
  name: '센티프 피트니스 강남점',
  address: '서울 강남구 테헤란로 152',
  phone: '02-555-0189',
  ownerUserId: 'user-1',
  status: 'active',
  inviteCodeClient: 'GN7K2M',
  createdAt: '2026-01-04T09:00:00',
);

class _FixedMode extends CoachModeNotifier {
  @override
  CoachMode build() => CoachMode.admin;
}

// ── 대시보드 ───────────────────────────────────────────────────────────────

DateTime _at(int day, int hour) => DateTime(2026, 8, day, hour);

final _alerts = ManagerActionAlerts(
  counts: const ManagerAlertCounts(
    total: 6,
    churn: 2,
    expiring: 3,
    newIssuance: 1,
  ),
  items: [
    ManagerActionAlert(
      type: ManagerAlertType.expiringSoon,
      coachName: '박성훈',
      memberId: 'm1',
      memberName: '김지훈',
      category: MembershipCategory.facility,
      description: '시설이용권이 3일 후 만료됩니다',
      occurredAt: _at(5, 9),
    ),
    ManagerActionAlert(
      type: ManagerAlertType.expiringSoon,
      coachName: '이수민',
      memberId: 'm2',
      memberName: '이서연',
      category: MembershipCategory.pt,
      description: '개인수업 잔여 2회 남았습니다',
      occurredAt: _at(5, 8),
    ),
    ManagerActionAlert(
      type: ManagerAlertType.newIssuance,
      coachName: '박성훈',
      memberId: 'm3',
      memberName: '박민수',
      category: MembershipCategory.pt,
      description: '개인수업 30회 정산 조건이 입력되지 않았습니다',
      occurredAt: _at(4, 19),
      membershipId: 'ms-1',
      productName: '개인수업 30회',
      productCount: 1,
    ),
    ManagerActionAlert(
      type: ManagerAlertType.churnRisk,
      coachName: '이수민',
      memberId: 'm4',
      memberName: '정하윤',
      description: '3주째 방문이 없습니다',
      occurredAt: _at(3, 11),
    ),
    ManagerActionAlert(
      type: ManagerAlertType.churnRisk,
      coachName: '박성훈',
      memberId: 'm5',
      memberName: '최지우',
      description: '2주째 방문이 없습니다',
      occurredAt: _at(2, 15),
    ),
  ],
);

const _risk = ManagerRisk(
  potentialLiability: 18450000,
  stability: StabilityLevel.normal,
);

// ── 전체 회원 ──────────────────────────────────────────────────────────────

MemberWithMembership _member({
  required String id,
  required String name,
  required String phone,
  MemberStatus status = MemberStatus.active,
  String? facilityEnd = '2026-10-27',
  int? ptRemaining = 6,
  int? ptTotal = 10,
}) => MemberWithMembership(
  member: Member(
    id: id,
    workspaceId: 'ws-1',
    name: name,
    phone: phone,
    status: status,
    createdAt: '2026-05-01T00:00:00',
  ),
  facility: facilityEnd == null
      ? null
      : FacilityInfo(
          name: '시설이용권',
          startDate: '2026-05-01',
          endDate: facilityEnd,
        ),
  personalLesson: ptRemaining == null
      ? null
      : SessionRemaining(
          completed: (ptTotal ?? 0) - ptRemaining,
          scheduled: 0,
          remaining: ptRemaining,
          total: ptTotal ?? 0,
        ),
);

final _members = <MemberWithMembership>[
  _member(id: 'm1', name: '김지훈', phone: '01012345678', ptRemaining: 8),
  _member(id: 'm2', name: '이서연', phone: '01084762442', ptRemaining: 2),
  _member(id: 'm3', name: '박민수', phone: '01077235510', ptRemaining: 28, ptTotal: 30),
  _member(id: 'm4', name: '정하윤', phone: '01044712093', ptRemaining: 5),
  _member(
    id: 'm5',
    name: '최지우',
    phone: '01033218890',
    status: MemberStatus.paused,
    ptRemaining: 4,
  ),
  _member(
    id: 'm6',
    name: '한서윤',
    phone: '01022119087',
    status: MemberStatus.expired,
    facilityEnd: '2026-07-01',
    ptRemaining: 0,
  ),
  _member(
    id: 'm7',
    name: '오세림',
    phone: '01055630011',
    status: MemberStatus.consultation,
    facilityEnd: null,
    ptRemaining: null,
  ),
];

const _staffNames = <String, String>{
  'staff-1': '박성훈',
  'staff-2': '이수민',
};

// 회원 → 담당 강사 매핑(미배정은 null 로 둬 '미배정' 필터도 화면에 나타나게 한다).
const _coachMap = <String, String?>{
  'm1': '박성훈',
  'm2': '이수민',
  'm3': '박성훈',
  'm4': '이수민',
  'm5': '박성훈',
  'm6': null,
  'm7': null,
};

// ── 팀원 목록(팀원 상세용) ───────────────────────────────────────────────

final _staffList = <StaffResponseDto>[
  StaffResponseDto(
    id: 'staff-1',
    workspaceId: 'ws-1',
    userId: 'user-1',
    role: 'OWNER',
    displayName: '박성훈',
    phone: '01023456789',
    email: 'owner@ssentif.kr',
    startDate: '2026-01-04',
    employmentType: 'FULL_TIME',
    baseSalary: 3200000,
    status: 'ACTIVE',
    joinedAt: '2026-01-04T09:00:00',
  ),
  StaffResponseDto(
    id: 'staff-2',
    workspaceId: 'ws-1',
    userId: 'user-2',
    role: 'STAFF',
    displayName: '이수민',
    phone: '01098765432',
    email: 'coach@ssentif.kr',
    startDate: '2026-03-02',
    employmentType: 'FULL_TIME',
    baseSalary: 2600000,
    status: 'ACTIVE',
    joinedAt: '2026-03-02T00:00:00',
  ),
];

// ── 매출 현황 카드 ───────────────────────────────────────────────────────
//
// _revenue 의 series 는 7/10~7/16 일별 라벨이라, 토글 기본값(월별)로 두면
// 헤더는 '월별 매출 추이'인데 x축은 일별 날짜가 찍히는 불일치가 생긴다
// (managerRevenueWindowProvider 는 ManagerRevenue.period 와 무관한 별도
// state). 카드가 fixture 와 같은 '일별' 창에서 열리도록 창도 함께 고정한다
// (2026-08-06).

class _FixedDailyRevenueWindow extends ManagerRevenueWindow {
  @override
  RevenueWindow build() =>
      // 일별 뷰는 fixture 라벨을 파싱하지 않고 anchor 로부터 역산한 실제 요일에
      // series 를 재색인한다(`_dayView`) — anchor 는 반드시 **토요일**이어야
      // series 마지막 항목(74만원, 일~토 마지막 칸)이 선택 총액과 일치한다.
      // 2026-07-18 은 토요일이라 series[0..6](7/12 일~7/18 토, fixture 라벨은
      // 7/10~7/16 이지만 라벨 문자열은 표시에 쓰이지 않는다)이 일~토 그대로 채워진다.
      RevenueWindow(period: 'day', anchor: DateTime(2026, 7, 18));
}

const _revenue = ManagerRevenue(
  period: 'day',
  total: 740000,
  categories: [
    RevenueCategorySlice(category: MembershipCategory.pt, amount: 470000, ratio: 0.635),
    RevenueCategorySlice(category: MembershipCategory.group, amount: 130000, ratio: 0.176),
    RevenueCategorySlice(category: MembershipCategory.facility, amount: 90000, ratio: 0.122),
    RevenueCategorySlice(category: MembershipCategory.locker, amount: 50000, ratio: 0.067),
  ],
  series: [
    RevenueSeriesPoint(label: '7/10', total: 320000, byCategory: {MembershipCategory.pt: 320000}),
    RevenueSeriesPoint(label: '7/11', total: 0, byCategory: {}),
    RevenueSeriesPoint(label: '7/12', total: 510000, byCategory: {
      MembershipCategory.pt: 310000,
      MembershipCategory.group: 200000,
    }),
    RevenueSeriesPoint(label: '7/13', total: 180000, byCategory: {MembershipCategory.facility: 180000}),
    RevenueSeriesPoint(label: '7/14', total: 0, byCategory: {}),
    RevenueSeriesPoint(label: '7/15', total: 620000, byCategory: {
      MembershipCategory.pt: 420000,
      MembershipCategory.locker: 200000,
    }),
    RevenueSeriesPoint(label: '7/16', total: 740000, byCategory: {
      MembershipCategory.pt: 470000,
      MembershipCategory.group: 130000,
      MembershipCategory.facility: 90000,
      MembershipCategory.locker: 50000,
    }),
  ],
);

// ── 상품 목록 ───────────────────────────────────────────────────────────

const _templates = <MembershipTemplate>[
  MembershipTemplate(
    id: 'tpl-1',
    workspaceId: 'ws-1',
    name: '개인수업 30회',
    category: MembershipCategory.pt,
    totalCount: 30,
    sessionDurationMin: 50,
    price: 1500000,
    priceExcludingVat: 1363636,
    unitPrice: 50000,
    isActive: true,
  ),
  MembershipTemplate(
    id: 'tpl-2',
    workspaceId: 'ws-1',
    name: '필라테스 그룹 20회',
    category: MembershipCategory.group,
    totalCount: 20,
    sessionDurationMin: 50,
    price: 600000,
    priceExcludingVat: 545454,
    unitPrice: 30000,
    isActive: true,
  ),
  MembershipTemplate(
    id: 'tpl-3',
    workspaceId: 'ws-1',
    name: '3개월 시설이용권',
    category: MembershipCategory.facility,
    durationMonths: 3,
    price: 300000,
    priceExcludingVat: 272727,
    isActive: true,
  ),
  MembershipTemplate(
    id: 'tpl-4',
    workspaceId: 'ws-1',
    name: '락커 3개월',
    category: MembershipCategory.locker,
    durationMonths: 3,
    price: 60000,
    priceExcludingVat: 54545,
    isActive: false,
  ),
];

// ── 급여 정산(팀원 관리 → 급여 정산 패널) ──────────────────────────────

PayrollRecord _payrollRecord({
  required String name,
  bool hasUnconfirmed = false,
}) =>
    PayrollRecord(
      payrollId: 'pr-$name',
      staffId: 'st-$name',
      staffName: name,
      period: '2026-08',
      status: PayrollStatus.open,
      netPay: 3120000,
      hasUnconfirmed: hasUnconfirmed,
    );

final _payrollSummary = PayrollPeriodSummary(
  period: '2026-08',
  totalNetPay: 12340000,
  records: [
    _payrollRecord(name: '박성훈', hasUnconfirmed: true),
    _payrollRecord(name: '이수민'),
  ],
);

// ── 급여명세서 미리보기 ─────────────────────────────────────────────────

final _payrollDetail = PayrollDetail(
  summary: PayrollRecord(
    payrollId: 'pr-이수민',
    staffId: 'staff-2',
    staffName: '이수민',
    role: 'STAFF',
    employmentType: 'FULL_TIME',
    period: '2026-08',
    status: PayrollStatus.open,
    baseSalarySnapshot: 2600000,
    baseSalaryProrated: 2600000,
    tenureDays: 31,
    periodDays: 31,
    ptSubtotal: 720000,
    groupSubtotal: 180000,
    etcSubtotal: 0,
    taxableAmount: 3500000,
    withholdingApplied: true,
    withholdingRateBp: 330,
    withholdingAmount: 115500,
    netPay: 3384500,
  ),
  baseLines: const [
    PayrollLineItem(
      id: 'line-base',
      sourceType: PayrollLineSource.base,
      status: PayrollLineStatus.auto,
      computedAmount: 2600000,
      amount: 2600000,
      label: '기본급',
    ),
  ],
  ptLines: [
    PayrollLineItem(
      id: 'line-pt-1',
      sourceType: PayrollLineSource.ptCommission,
      status: PayrollLineStatus.auto,
      memberName: '김지훈',
      productName: '개인수업 30회',
      sessionDate: '2026-08-04',
      unitPrice: 30000,
      count: 24,
      computedAmount: 720000,
      amount: 720000,
      commissionType: 'flat',
    ),
  ],
  groupLines: [
    PayrollLineItem(
      id: 'line-group-1',
      sourceType: PayrollLineSource.groupCommission,
      status: PayrollLineStatus.auto,
      lessonTitle: '필라테스 그룹',
      sessionDate: '2026-08-05',
      computedAmount: 180000,
      amount: 180000,
    ),
  ],
);

// ── 팀 전체 일정 ────────────────────────────────────────────────────────

ScheduleSession _teamSession({
  required String id,
  required DateTime start,
  required ScheduleType type,
  required String coachId,
  SessionStatus status = SessionStatus.scheduled,
}) {
  final end = start.add(const Duration(minutes: 50));
  return ScheduleSession(
    id: id,
    sessionName: type == ScheduleType.group ? '필라테스 그룹' : '개인수업',
    participant: '김민수',
    startTime: start.toIso8601String(),
    endTime: end.toIso8601String(),
    scheduleType: type,
    status: status,
    trainerId: coachId,
  );
}

Map<DateTime, List<ScheduleSession>> _teamMonthFixture() {
  final byDay = <DateTime, List<ScheduleSession>>{};
  void add(int day, List<ScheduleSession> list) {
    byDay[DateTime(2026, 8, day)] = list;
  }

  add(3, [
    _teamSession(id: 'a1', start: DateTime(2026, 8, 3, 10), type: ScheduleType.pt, coachId: 'staff-1'),
    _teamSession(id: 'a2', start: DateTime(2026, 8, 3, 14), type: ScheduleType.pt, coachId: 'staff-2'),
    _teamSession(id: 'a3', start: DateTime(2026, 8, 3, 19), type: ScheduleType.group, coachId: 'staff-1'),
  ]);
  add(12, [
    for (var i = 0; i < 4; i++)
      _teamSession(
        id: 'c$i',
        start: DateTime(2026, 8, 12, 8 + i),
        type: ScheduleType.pt,
        coachId: i.isEven ? 'staff-1' : 'staff-2',
      ),
    _teamSession(id: 'cg', start: DateTime(2026, 8, 12, 18), type: ScheduleType.group, coachId: 'staff-2'),
  ]);
  add(20, [
    _teamSession(
      id: 'd1',
      start: DateTime(2026, 8, 20, 11),
      type: ScheduleType.pt,
      coachId: 'staff-1',
      status: SessionStatus.completed,
    ),
  ]);
  return byDay;
}

class _FixedDate extends SelectedDate {
  @override
  DateTime build() => DateTime(2026, 8, 12);
}

class _MonthScale extends AdminScheduleTimeScale {
  @override
  int build() => 1;
}

// ── AI 어시스턴트 대화 ──────────────────────────────────────────────────

final _aiConversation = <AiChatMessage>[
  AiChatMessage(
    role: 'user',
    content: '이번 달 이탈 위험 회원 알려줘',
    timestamp: DateTime(2026, 8, 5, 10, 0),
  ),
  AiChatMessage(
    role: 'assistant',
    content: '최근 3주 이상 방문이 없는 회원은 정하윤님, 최지우님이에요.\n'
        '채팅으로 안부를 먼저 남겨보시는 걸 추천드려요.',
    timestamp: DateTime(2026, 8, 5, 10, 0),
  ),
];

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GnLocalStorage.init();
  });

  final base = <Override>[
    currentWorkspaceNotifierProvider.overrideWith(_FakeWorkspace.new),
    currentUserProvider.overrideWith(_FakeUser.new),
    currentWorkspaceInfoProvider.overrideWith((ref) async => _workspaceInfo),
    coachModeNotifierProvider.overrideWith(_FixedMode.new),
  ];

  testWidgets('가이드(관리자) — 운영 대시보드', (tester) async {
    await captureScreenshot(
      tester,
      child: const ManagerDashboardScreen(),
      name: 'guide_admin_dashboard',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        managerActionAlertsProvider.overrideWith((ref) async => _alerts),
        managerRiskProvider.overrideWith((ref) async => _risk),
      ],
    );
  });

  testWidgets('가이드(관리자) — 전체 회원', (tester) async {
    await captureScreenshot(
      tester,
      child: const AllMembersScreen(),
      name: 'guide_admin_members',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        allWorkspaceMembersProvider.overrideWith(
          (ref) async => (members: _members, coachMap: _coachMap),
        ),
        workspaceStaffNameMapProvider.overrideWith((ref) async => _staffNames),
      ],
    );
  });

  testWidgets('가이드(관리자) — 팀원 관리', (tester) async {
    await captureScreenshot(
      tester,
      child: const StaffManagementScreen(),
      name: 'guide_admin_staff',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        workspaceStaffListProvider.overrideWith((ref) async => _staffList),
      ],
    );
  });

  testWidgets('가이드(관리자) — 팀원 상세(고용 정보)', (tester) async {
    await captureScreenshot(
      tester,
      child: const StaffManagementScreen(),
      name: 'guide_admin_staff_detail',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        workspaceStaffListProvider.overrideWith((ref) async => _staffList),
        staffAssignedMembersProvider('staff-2').overrideWith((ref) async => []),
        staffTenureStintsProvider('staff-2').overrideWith((ref) async => []),
      ],
      interact: (tester) async {
        await tester.tap(find.text('이수민').first);
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('가이드(관리자) — 업무 알림 카드', (tester) async {
    await captureScreenshot(
      tester,
      child: const ManagerActionAlertsCard(),
      name: 'guide_admin_alerts',
      size: const Size(430, 560),
      overrides: [
        ...base,
        managerActionAlertsProvider.overrideWith((ref) async => _alerts),
      ],
    );
  });

  testWidgets('가이드(관리자) — 매출 현황 카드', (tester) async {
    await captureScreenshot(
      tester,
      child: const ManagerRevenueCard(),
      name: 'guide_admin_revenue',
      size: const Size(430, 640),
      overrides: [
        ...base,
        managerRevenueProvider.overrideWith((ref) async => _revenue),
        managerRevenueWindowProvider.overrideWith(_FixedDailyRevenueWindow.new),
      ],
    );
  });

  testWidgets('가이드(관리자) — 운영 위험도 카드', (tester) async {
    await captureScreenshot(
      tester,
      child: const ManagerRiskCard(),
      name: 'guide_admin_risk',
      // 실제 콘텐츠 높이(~165)보다 220 이 커서 카드 하단에 빈 여백이
      // 남았다 — 콘텐츠에 맞춰 축소(2026-08-06).
      size: const Size(430, 175),
      overrides: [
        ...base,
        managerRiskProvider.overrideWith((ref) async => _risk),
      ],
    );
  });

  testWidgets('가이드(관리자) — 상품 목록', (tester) async {
    await captureScreenshot(
      tester,
      child: const ProductsScreen(),
      name: 'guide_admin_products',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        manageableMembershipProductsProvider.overrideWith((ref) async => _templates),
        membershipTemplatesProvider.overrideWith((ref) async => _templates),
      ],
    );
  });

  testWidgets('가이드(관리자) — 급여 정산 패널', (tester) async {
    await captureScreenshot(
      tester,
      child: Scaffold(
        body: Builder(
          builder: (context) => ColoredBox(
            color: context.gnColors.surfaceMain,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Align(
                alignment: Alignment.topCenter,
                child: PayrollPeriodPanel(
                  period: '2026-08',
                  status: PayrollStatus.open,
                  summary: _payrollSummary,
                  workspaceName: '센티프 피트니스 강남점',
                  canGoNext: true,
                  busy: false,
                  onPrev: () {},
                  onNext: () {},
                  onRefresh: () {},
                  onReport: () {},
                  onCloseMonth: () {},
                  onReopen: () {},
                ),
              ),
            ),
          ),
        ),
      ),
      name: 'guide_admin_payroll',
      size: const Size(1180, 320),
      overrides: base,
    );
  });

  testWidgets('가이드(관리자) — 급여명세서 미리보기', (tester) async {
    await captureScreenshot(
      tester,
      child: Scaffold(
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => openPayslipPreview(context, detail: _payrollDetail),
              child: const Text('명세서 열기'),
            ),
          ),
        ),
      ),
      name: 'guide_admin_payslip',
      device: ScreenshotDevice.tabletLandscape,
      overrides: base,
      interact: (tester) async {
        await tester.tap(find.text('명세서 열기'));
        await tester.pumpAndSettle();
      },
    );
  });

  testWidgets('가이드(관리자) — 팀 전체 일정(월간)', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_admin_schedule_scope',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...base,
        selectedDateProvider.overrideWith(_FixedDate.new),
        adminScheduleTimeScaleProvider.overrideWith(_MonthScale.new),
        scheduleTeamMonthSessionsProvider.overrideWith((ref) async => _teamMonthFixture()),
      ],
      child: const Scaffold(
        body: Padding(
          padding: EdgeInsets.all(17.5),
          child: ScheduleTeamView(),
        ),
      ),
    );
  });

  testWidgets('가이드(관리자) — 센터 정보·운영 설정', (tester) async {
    await captureScreenshot(
      tester,
      child: const Scaffold(body: OperationsSettingsTab()),
      name: 'guide_admin_center_hours',
      device: ScreenshotDevice.tabletLandscape,
      overrides: base,
    );
  });

  testWidgets('가이드(관리자) — AI 운영 어시스턴트', (tester) async {
    await captureScreenshot(
      tester,
      child: const AiAgentChatScreen(),
      name: 'guide_admin_ai_agent',
      // 전체 태블릿 세로(820)로 캡처하면 대화 2턴짜리 fixture 아래로 화면
      // 절반 넘게 빈 배경만 남는다 — 실제 대화 내용이 채우는 높이에 맞춰
      // 캡처 디바이스 자체를 줄인다(2026-08-06, 후처리 crop 대신 근본 수정).
      device: const ScreenshotDevice('ai_agent_short', Size(1180, 380), 2.0),
      overrides: [
        ...base,
        aiChatNotifierProvider.overrideWith(() => _FixtureChat(_aiConversation)),
      ],
    );
  });
}

class _FixtureChat extends AiChatNotifier {
  _FixtureChat(this._messages);

  final List<AiChatMessage> _messages;

  @override
  List<AiChatMessage> build() => _messages;
}
