// 사용 가이드(www.ssentif.kr/guide-admin.html) — 관리자 모드 "공통" 절 태블릿 캡처.
//
// guide.html(강사 모드)의 공통 8개 항목은 세로 폰 스크린샷을 쓰지만, 관리자 모드는
// 태블릿/PC 에서 주로 쓰는 화면이라 guide-admin.html 은 전부 태블릿 가로 캡처로
// 통일한다(2026-08-06 전면 재작업). 이 파일은 그 중 새로 캡처가 필요한 4개
// (모드전환/프로필/계정관리/채팅)를 담는다 — 로그인·회원가입·워크스페이스생성은
// 기존 login_screen_capture_test.dart / signup_screen_capture_test.dart /
// workspace_create_screen_capture_test.dart 의 landscape 캡처를 그대로 재사용한다.
//
// 실행:
//   SCREENSHOT_DIR=... flutter test test_screenshots/guide_admin_common_tablet_capture_test.dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssentif_coach/core/theme/gn_colors_extension.dart';

import 'package:ssentif_coach/core/router/routes.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/activity_type.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/engagement_level.dart';
import 'package:ssentif_coach/domain/enums/gender.dart';
import 'package:ssentif_coach/domain/enums/meal_type.dart';
import 'package:ssentif_coach/domain/enums/member_status.dart';
import 'package:ssentif_coach/domain/enums/notice_category.dart';
import 'package:ssentif_coach/domain/enums/schedule_type.dart';
import 'package:ssentif_coach/domain/enums/session_status.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/action_item.dart';
import 'package:ssentif_coach/domain/models/chat_room.dart';
import 'package:ssentif_coach/domain/models/coach_dashboard.dart';
import 'package:ssentif_coach/domain/models/member.dart';
import 'package:ssentif_coach/domain/models/member_activity_detail.dart';
import 'package:ssentif_coach/domain/models/member_activity_group.dart';
import 'package:ssentif_coach/domain/models/notice.dart';
import 'package:ssentif_coach/domain/models/pending_invitation.dart';
import 'package:ssentif_coach/domain/models/schedule.dart';
import 'package:ssentif_coach/domain/models/user_profile.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/domain/enums/memo_access.dart';
import 'package:ssentif_coach/domain/models/memo.dart';
import 'package:ssentif_coach/features/chat/chat_screen.dart';
import 'package:ssentif_coach/features/home/home_screen.dart';
import 'package:ssentif_coach/features/memo/memo_screen.dart';
import 'package:ssentif_coach/features/settings/account_settings_screen.dart';
import 'package:ssentif_coach/features/settings/settings_screen.dart';
import 'package:ssentif_coach/gen/assets.gen.dart';
import 'package:ssentif_coach/providers/auth/auth_providers.dart';
import 'package:ssentif_coach/providers/chat/chat_providers.dart';
import 'package:ssentif_coach/providers/home/home_providers.dart';
import 'package:ssentif_coach/providers/members/engagement_providers.dart';
import 'package:ssentif_coach/providers/members/member_providers.dart';
import 'package:ssentif_coach/providers/memo/memo_providers.dart';
import 'package:ssentif_coach/providers/notice/notice_providers.dart';
import 'package:ssentif_coach/providers/onboarding/coach_onboarding_provider.dart';
import 'package:ssentif_coach/providers/workspace/invitation_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';
import 'package:ssentif_coach/shared/layouts/adaptive_scaffold.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// 공용 fixture — guide.html(강사 모드)과 같은 센터·같은 대표를 쓴다.
// ---------------------------------------------------------------------------

const _workspace = WorkspaceContext(
  workspaceId: 'ws-1',
  staffId: 'staff-1',
  role: StaffRole.owner,
  defaultMode: CoachMode.coach,
);

class _FakeWorkspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => _workspace;
}

const _user = UserProfile(
  id: 'user-1',
  email: 'coach@ssentif.kr',
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

final _baseOverrides = <Override>[
  currentWorkspaceNotifierProvider.overrideWith(_FakeWorkspace.new),
  currentUserProvider.overrideWith(_FakeUser.new),
  currentWorkspaceInfoProvider.overrideWith((ref) async => _workspaceInfo),
];

// ---------------------------------------------------------------------------
// 채팅 — 목록만 채우고 우측은 빈 상태("대화를 선택해주세요")로 둔다.
// ---------------------------------------------------------------------------

ChatRoom _room(
  String id,
  String name,
  String preview, {
  int unread = 0,
  int minutesAgo = 12,
}) {
  final now = DateTime(2026, 8, 6, 18, 40);
  return ChatRoom(
    id: id,
    workspaceId: 'ws-1',
    type: 'direct',
    name: name,
    createdAt: now.subtract(const Duration(days: 30)),
    lastMessageAt: now.subtract(Duration(minutes: minutesAgo)),
    lastMessagePreview: preview,
    unreadCount: unread,
    participants: [
      ChatParticipant(
        id: 'p-$id',
        chatRoomId: id,
        participantType: 'client',
        participantId: 'c-$id',
        joinedAt: now,
        displayName: name,
      ),
    ],
  );
}

final _rooms = <ChatRoom>[
  _room('r1', '김지훈', '코치님 내일 7시로 옮길 수 있을까요?', unread: 2, minutesAgo: 8),
  _room('r2', '이서연', '오늘 알려주신 스트레칭 하고 잤어요!', minutesAgo: 95),
  _room('r3', '박민수', '식단 사진 올렸습니다 확인 부탁드려요', unread: 1, minutesAgo: 180),
  _room('r4', '정하윤', '감사합니다 다음 주에 뵐게요', minutesAgo: 1500),
];

class _FakeChatRooms extends ChatRooms {
  @override
  Future<List<ChatRoom>> build() async => _rooms;
}

// ---------------------------------------------------------------------------
// 메모 — 목록(좌) + 에디터(우) 태블릿 분할 뷰.
// ---------------------------------------------------------------------------

final _memos = <Memo>[
  Memo(
    id: 'memo-1',
    workspaceId: 'ws-1',
    ownerStaffId: 'staff-1',
    ownerName: '박성훈',
    title: '8월 상담 준비 메모',
    content: '신규 회원 상담 시 확인할 항목들을 정리해 둡니다.\n'
        '- 기존 운동 경험\n- 통증·재활 이력\n- 선호 운동 시간대',
    pinned: true,
    shared: true,
    shareCount: 3,
    myAccess: MemoAccess.owner,
    attachmentUrls: const [],
    createdAt: DateTime(2026, 8, 1, 9),
    updatedAt: DateTime(2026, 8, 6, 10, 20),
  ),
  Memo(
    id: 'memo-2',
    workspaceId: 'ws-1',
    ownerStaffId: 'staff-1',
    ownerName: '박성훈',
    title: '락커 점검 인수인계',
    content: '3번 락커 열쇠 분실 — 여분 열쇠로 임시 교체함.',
    pinned: false,
    shared: false,
    shareCount: 0,
    myAccess: MemoAccess.owner,
    attachmentUrls: const [],
    createdAt: DateTime(2026, 7, 28, 14),
    updatedAt: DateTime(2026, 7, 28, 14),
  ),
];

// ---------------------------------------------------------------------------
// 모드전환 — 사이드레일 + 실제 홈 콘텐츠(coach_home_screen_capture_test.dart 축약본).
// ---------------------------------------------------------------------------

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
];

List<Notice> _notices() {
  final now = DateTime.now();
  return [
    Notice(
      id: 'n1',
      workspaceId: 'ws-1',
      category: NoticeCategory.notice,
      title: '8월 회원 운동 챌린지 안내',
      content: '이번 달 출석 12회 달성 시 프로틴 쉐이크를 드립니다.',
      createdAt: now.subtract(const Duration(days: 1)),
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
  ];
}

const _levels = {'c1': EngagementLevel.level3, 'c2': EngagementLevel.level2};

class _FakeOnboarding extends CoachOnboardingNotifier {
  @override
  OnboardingState build() =>
      const OnboardingState(activated: false, dismissed: false, completed: <String>{});
}

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
        textTheme:
            theme.textTheme.apply(fontFamilyFallback: const [_emojiFamily]),
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
          provider.resolve(const ImageConfiguration(devicePixelRatio: 2.0));
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
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GnLocalStorage.init();
  });

  testWidgets('가이드(관리자) — 프로필·설정 화면(태블릿)', (tester) async {
    await captureScreenshot(
      tester,
      child: const SettingsScreen(),
      name: 'guide_admin_settings_tablet',
      overrides: _baseOverrides,
    );
  });

  testWidgets('가이드(관리자) — 계정 관리 화면(태블릿)', (tester) async {
    await captureScreenshot(
      tester,
      child: const AccountSettingsScreen(),
      name: 'guide_admin_account_settings_tablet',
      overrides: _baseOverrides,
    );
  });

  testWidgets('가이드(관리자) — 채팅(태블릿 분할)', (tester) async {
    // ChatSplitView 는 자체 Scaffold 가 없다(실제 앱에서는 AdaptiveScaffold
    // 본문으로 들어가 그 배경을 물려받는다) — 단독 캡처하면 Padding 여백이
    // 배경색 없이 비어 캔버스 검정이 그대로 비친다. Scaffold 로 감싸 배경을
    // 채운다(2026-08-06).
    await captureScreenshot(
      tester,
      child: Builder(
        builder: (context) {
          final colors = Theme.of(context).extension<GnColors>()!;
          return Scaffold(
            backgroundColor: colors.surfaceMain,
            body: const ChatSplitView(),
          );
        },
      ),
      name: 'guide_admin_chat_tablet',
      overrides: [
        ..._baseOverrides,
        chatRoomsProvider.overrideWith(_FakeChatRooms.new),
      ],
    );
  });

  testWidgets('가이드(관리자) — 메모(태블릿 분할)', (tester) async {
    await captureScreenshot(
      tester,
      child: const MemoScreen(),
      name: 'guide_admin_memo_tablet',
      overrides: [
        ..._baseOverrides,
        memoListProvider.overrideWith((ref) async => _memos),
        memoDetailProvider('memo-1').overrideWith((ref) async => _memos[0]),
        selectedMemoIdProvider.overrideWith((ref) => 'memo-1'),
      ],
    );
  });

  testWidgets('가이드(관리자) — 강사 모드 홈 + 사이드레일(태블릿)', (tester) async {
    await _loadEmojiFont(tester);
    await _precacheAssets(tester, [
      Assets.images.icMembershipPass.path,
      Assets.images.icCheckDocs.path,
    ]);

    final session = _nextSession();

    await captureScreenshot(
      tester,
      child: const _WithEmojiFallback(
        child: AdaptiveScaffold(
          navigationIndex: 0,
          location: Routes.home,
          child: HomeScreen(),
        ),
      ),
      name: 'guide_admin_modes_tablet',
      overrides: [
        ..._baseOverrides,
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
        for (final id in const ['c1', 'c2'])
          memberActivityDetailsProvider(id).overrideWith(
            (ref) => Completer<List<MemberActivityDetail>>().future,
          ),
      ],
    );
  });
}
