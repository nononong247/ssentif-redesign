// 강사 홈 화면 — 세로 폰(portrait) 캡처.
//
// 실행: flutter test test_screenshots/coach_home_portrait_capture_test.dart
// 출력: ~/Downloads/coach_home_portrait_{fold,full}_{light,dark}.png
//
// - fold: 실제 폰 뷰포트(390×844) — 첫 화면에 무엇이 보이는지
// - full: 세로로 긴 뷰포트(390×2400) — 스크롤 전체 구성 한 장
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/domain/enums/activity_type.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/engagement_level.dart';
import 'package:ssentif_coach/domain/enums/meal_type.dart';
import 'package:ssentif_coach/domain/enums/member_status.dart';
import 'package:ssentif_coach/domain/enums/notice_category.dart';
import 'package:ssentif_coach/domain/enums/schedule_type.dart';
import 'package:ssentif_coach/domain/enums/session_status.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/action_item.dart';
import 'package:ssentif_coach/domain/models/coach_dashboard.dart';
import 'package:ssentif_coach/domain/models/coaching_style_example.dart';
import 'package:ssentif_coach/domain/models/coaching_style_profile.dart';
import 'package:ssentif_coach/domain/models/member.dart';
import 'package:ssentif_coach/domain/models/member_activity_detail.dart';
import 'package:ssentif_coach/domain/models/member_activity_group.dart';
import 'package:ssentif_coach/domain/models/notice.dart';
import 'package:ssentif_coach/domain/models/pending_invitation.dart';
import 'package:ssentif_coach/domain/models/schedule.dart';
import 'package:ssentif_coach/domain/models/user_profile.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/core/router/routes.dart';
import 'package:ssentif_coach/features/home/home_screen.dart';
import 'package:ssentif_coach/gen/assets.gen.dart';
import 'package:ssentif_coach/shared/layouts/adaptive_scaffold.dart';
import 'package:ssentif_coach/providers/auth/auth_providers.dart';
import 'package:ssentif_coach/providers/home/home_providers.dart';
import 'package:ssentif_coach/providers/members/engagement_providers.dart';
import 'package:ssentif_coach/providers/members/member_providers.dart';
import 'package:ssentif_coach/providers/notice/notice_providers.dart';
import 'package:ssentif_coach/providers/onboarding/coach_onboarding_provider.dart';
import 'package:ssentif_coach/providers/settings/coaching_style_provider.dart';
import 'package:ssentif_coach/providers/workspace/invitation_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

const _workspace = WorkspaceContext(
  workspaceId: 'ws-1',
  staffId: 'staff-1',
  role: StaffRole.staff,
  defaultMode: CoachMode.coach,
);

class _FakeWorkspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => _workspace;
}

class _FakeCurrentUser extends CurrentUser {
  @override
  Future<UserProfile?> build() async => const UserProfile(
        id: 'user-1',
        email: 'coach@dais.kr',
        fullName: '박성훈',
        createdAt: '2026-01-01T00:00:00',
      );
}

class _FakeOnboarding extends CoachOnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState(
        activated: false,
        dismissed: false,
        completed: <String>{},
      );
}

final _members = [
  const MemberWithMembership(
    member: Member(
      id: 'c1',
      workspaceId: 'ws-1',
      name: '김지훈',
      phone: '010-1234-5678',
      status: MemberStatus.active,
      createdAt: '2026-03-02T10:00:00',
    ),
    facility: FacilityInfo(
      name: '6개월 이용권',
      startDate: '2026-05-01',
      endDate: '2026-10-31',
    ),
    personalLesson:
        SessionRemaining(completed: 5, scheduled: 1, remaining: 5, total: 10),
  ),
  const MemberWithMembership(
    member: Member(
      id: 'c2',
      workspaceId: 'ws-1',
      name: '이서연',
      phone: '010-2345-6789',
      status: MemberStatus.active,
      createdAt: '2026-04-11T10:00:00',
    ),
    personalLesson:
        SessionRemaining(completed: 18, scheduled: 0, remaining: 2, total: 20),
  ),
  const MemberWithMembership(
    member: Member(
      id: 'c3',
      workspaceId: 'ws-1',
      name: '박민수',
      phone: '010-3456-7890',
      status: MemberStatus.consultation,
      createdAt: '2026-07-01T10:00:00',
    ),
  ),
];

ScheduleSession _nextSession() {
  final now = DateTime.now();
  final start = DateTime(now.year, now.month, now.day, now.hour)
      .add(const Duration(hours: 2));
  final end = start.add(const Duration(minutes: 50));
  return ScheduleSession(
    id: 's1',
    sessionName: '개인 레슨',
    scheduleType: ScheduleType.pt,
    participant: '김지훈',
    startTime: start.toIso8601String(),
    endTime: end.toIso8601String(),
    status: SessionStatus.scheduled,
    sessionNumber: 6,
    participantClientIds: const ['c1'],
  );
}

const _metrics = CoachMonthlyMetrics(
  newRegistrations: 4,
  reRegistrations: 3,
  completedLessons: 30,
  expiredMemberships: 1,
  newConsultations: 2,
  ptScheduled: 18,
  ptCompleted: 24,
  groupScheduled: 4,
  groupCompleted: 6,
  absentLessons: 1,
  totalRevenue: 4850000,
);

const _insights = CoachInsights(
  ptConsumed: 62,
  ptTotal: 90,
  groupConsumed: 14,
  groupTotal: 24,
  remainingValue: 2860000,
);

const _actions = [
  ActionItem(
    type: ActionType.facilityExpiring,
    clientId: 'c1',
    memberName: '김지훈',
    message: '시설이용권이 3일 후 만료됩니다',
    priorityOrder: 0,
  ),
  ActionItem(
    type: ActionType.sessionLow,
    clientId: 'c2',
    memberName: '이서연',
    message: '개인수업 잔여 2회 남았습니다',
    priorityOrder: 1,
  ),
  ActionItem(
    type: ActionType.consultationPending,
    clientId: 'c3',
    memberName: '박민수',
    message: '상담 후 수강권 등록이 필요합니다',
    priorityOrder: 2,
  ),
];

List<Notice> _notices() {
  final now = DateTime.now();
  return [
    Notice(
      id: 'n1',
      workspaceId: 'ws-1',
      category: NoticeCategory.notice,
      title: '7월 회원 운동 챌린지 안내',
      content: '이번 달 출석 12회 달성 시 프로틴 쉐이크를 드립니다.',
      createdAt: now.subtract(const Duration(days: 1)),
    ),
    Notice(
      id: 'n2',
      workspaceId: 'ws-1',
      category: NoticeCategory.event,
      title: '바디프로필 촬영 그룹 클래스 모집',
      content: '8주 코스 신청은 데스크 또는 채팅으로 문의해주세요.',
      createdAt: now.subtract(const Duration(days: 3)),
    ),
    Notice(
      id: 'n3',
      workspaceId: 'ws-1',
      category: NoticeCategory.maintenance,
      title: '스미스머신 점검 안내',
      content: '금요일 오전 10시~12시 스미스머신 사용이 제한됩니다.',
      createdAt: now.subtract(const Duration(days: 5)),
    ),
  ];
}

List<MemberActivityGroup> _activityGroups() {
  final now = DateTime.now();
  return [
    MemberActivityGroup(
      clientId: 'c1',
      memberName: '김지훈',
      countLast7Days: 6,
      countToday: 2,
      activeTypesLast7Days: const {ActivityType.exercise, ActivityType.diet},
      lastActivityType: ActivityType.diet,
      lastActivityMealType: MealType.lunch,
      lastOccurredAt: now.subtract(const Duration(hours: 2)),
      exerciseCount: 3,
      unfeedbackedCount: 2,
    ),
    MemberActivityGroup(
      clientId: 'c2',
      memberName: '이서연',
      countLast7Days: 4,
      countToday: 1,
      activeTypesLast7Days: const {
        ActivityType.bodyComposition,
        ActivityType.bodyPhoto,
      },
      lastActivityType: ActivityType.bodyComposition,
      lastOccurredAt: now.subtract(const Duration(hours: 5)),
      unfeedbackedCount: 1,
    ),
    MemberActivityGroup(
      clientId: 'c3',
      memberName: '박민수',
      countLast7Days: 3,
      countToday: 0,
      activeTypesLast7Days: const {ActivityType.exercise},
      lastActivityType: ActivityType.exercise,
      lastOccurredAt: now.subtract(const Duration(days: 1)),
      exerciseCount: 3,
      unfeedbackedCount: 1,
    ),
  ];
}

const _levels = {
  'c1': EngagementLevel.level3,
  'c2': EngagementLevel.level2,
  'c3': EngagementLevel.level4,
};

const _emojiFamily = 'Apple Color Emoji';

Future<void> _loadEmojiFont(WidgetTester tester) async {
  final file = File('/System/Library/Fonts/Apple Color Emoji.ttc');
  if (!file.existsSync()) return;
  await tester.runAsync(() async {
    final bytes = await file.readAsBytes();
    final loader = FontLoader(_emojiFamily)
      ..addFont(Future.value(ByteData.sublistView(bytes)));
    await loader.load();
  });
}

class _WithEmojiFallback extends StatelessWidget {
  const _WithEmojiFallback({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.apply(
          fontFamilyFallback: const [_emojiFamily],
        ),
      ),
      child: child,
    );
  }
}

Future<void> _precacheAssets(WidgetTester tester, List<String> paths) async {
  await tester.runAsync(() async {
    for (final path in paths) {
      final provider = AssetImage(path);
      final completer = Completer<void>();
      final stream =
          provider.resolve(const ImageConfiguration(devicePixelRatio: 3.0));
      late final ImageStreamListener listener;
      listener = ImageStreamListener(
        (info, _) {
          if (!completer.isCompleted) completer.complete();
        },
        onError: (e, _) {
          if (!completer.isCompleted) completer.complete();
        },
      );
      stream.addListener(listener);
      await completer.future;
      stream.removeListener(listener);
    }
  });
}

void main() {
  // fold = 실제 폰 뷰포트(첫 화면) / full = 세로로 늘려 스크롤 전체를 한 장에.
  const devices = {
    'fold': ScreenshotDevice('phone_portrait', Size(390, 844), 3.0),
    'full': ScreenshotDevice('phone_portrait_tall', Size(390, 2400), 3.0),
  };

  for (final entry in devices.entries) {
    for (final mode in ['light', 'dark']) {
      testWidgets('강사 홈 세로 캡처 — ${entry.key} $mode', (tester) async {
        await _loadEmojiFont(tester);
        await _precacheAssets(tester, [
          Assets.images.icMembershipPass.path,
          Assets.images.icCheckDocs.path,
        ]);

        final session = _nextSession();

        await captureScreenshot(
          tester,
          child: const _WithEmojiFallback(child: HomeScreen()),
          name: 'coach_home_portrait_${entry.key}_$mode',
          device: entry.value,
          darkMode: mode == 'dark',
          overrides: [
            currentWorkspaceNotifierProvider.overrideWith(_FakeWorkspace.new),
            currentUserProvider.overrideWith(_FakeCurrentUser.new),
            coachOnboardingNotifierProvider.overrideWith(_FakeOnboarding.new),
            invitationDialogShownProvider.overrideWith((ref) => true),
            pendingInvitationsProvider
                .overrideWith((ref) async => const <PendingInvitation>[]),
            assignedMembersProvider.overrideWith((ref) async => _members),
            todaySessionsProvider.overrideWith((ref) async => [session]),
            nextActionableSessionProvider.overrideWithValue(session),
            monthlyCoachMetricsProvider.overrideWith((ref) async => _metrics),
            coachInsightsProvider.overrideWith((ref) async => _insights),
            coachActionNeededProvider.overrideWith((ref) async => _actions),
            homeNoticesProvider.overrideWith((ref) async => _notices()),
            recentActiveMemberGroupsProvider
                .overrideWith((ref) async => _activityGroups()),
            memberEngagementLevelsProvider.overrideWith((ref) async => _levels),
            coachingStyleNotifierProvider
                .overrideWith(_FakeCoachingStyle.new),
            for (final id in const ['c1', 'c2', 'c3'])
              memberActivityDetailsProvider(id).overrideWith(
                (ref) => Completer<List<MemberActivityDetail>>().future,
              ),
          ],
        );
      });
    }
  }

  // 가이드(guide.html "강사 모드와 관리자 모드" 절)용 — 하단 5탭 + 실제 홈 콘텐츠를
  // 한 장에 담는다. 위 루프의 캡처는 AdaptiveScaffold 없이 HomeScreen 만 렌더해
  // 하단 네비가 없고, `portrait_nav_capture_test.dart` 는 반대로 네비만 있고
  // 본문이 빈 placeholder 카드다(설계 의도 — 그 파일의 주석 참조). 가이드 스샷은
  // 둘 다 필요해 이 파일의 실데이터 오버라이드에 AdaptiveScaffold 셸을 더한다.
  testWidgets('강사 홈 세로 캡처 — 가이드용(네비 포함, light)', (tester) async {
    await _loadEmojiFont(tester);
    await _precacheAssets(tester, [
      Assets.images.icMembershipPass.path,
      Assets.images.icCheckDocs.path,
    ]);

    final session = _nextSession();

    await captureScreenshot(
      tester,
      child: const AdaptiveScaffold(
        navigationIndex: 0,
        location: Routes.home,
        child: _WithEmojiFallback(child: HomeScreen()),
      ),
      name: 'guide_modes_nav',
      device: const ScreenshotDevice(
        'phone_portrait',
        Size(390, 844),
        3.0,
      ),
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_FakeWorkspace.new),
        currentUserProvider.overrideWith(_FakeCurrentUser.new),
        coachOnboardingNotifierProvider.overrideWith(_FakeOnboarding.new),
        invitationDialogShownProvider.overrideWith((ref) => true),
        pendingInvitationsProvider
            .overrideWith((ref) async => const <PendingInvitation>[]),
        assignedMembersProvider.overrideWith((ref) async => _members),
        todaySessionsProvider.overrideWith((ref) async => [session]),
        nextActionableSessionProvider.overrideWithValue(session),
        monthlyCoachMetricsProvider.overrideWith((ref) async => _metrics),
        coachInsightsProvider.overrideWith((ref) async => _insights),
        coachActionNeededProvider.overrideWith((ref) async => _actions),
        homeNoticesProvider.overrideWith((ref) async => _notices()),
        recentActiveMemberGroupsProvider
            .overrideWith((ref) async => _activityGroups()),
        memberEngagementLevelsProvider.overrideWith((ref) async => _levels),
        coachingStyleNotifierProvider.overrideWith(_FakeCoachingStyle.new),
        for (final id in const ['c1', 'c2', 'c3'])
          memberActivityDetailsProvider(id).overrideWith(
            (ref) => Completer<List<MemberActivityDetail>>().future,
          ),
      ],
    );
  });
}

class _FakeCoachingStyle extends CoachingStyleNotifier {
  @override
  Future<CoachingStyleState> build() async => const CoachingStyleState(
        profile: CoachingStyleProfile(),
        configured: true,
      );
}
