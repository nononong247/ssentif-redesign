// 사용 가이드(www.ssentif.kr/guide.html)용 화면 캡처.
//
// 가이드는 "따라 하는 문서"라 두 가지를 지킨다:
//  1) fixture 를 실사용에 가깝게 채운다 — 빈 상태(`사용자`, `-`)로 찍으면 독자가
//     자기 화면과 대조할 수 없다.
//  2) 사진이 들어가는 화면은 **실사진**을 넣는다. 하네스가 `SCREENSHOT_PHOTO_DIR`
//     의 파일을 URL 마지막 조각으로 매칭해 응답하므로, fixture 의 imageUrl 을
//     `https://photos.test/diet.png` 처럼 두면 그 사진이 그대로 렌더된다.
//
// 실행:
//   SCREENSHOT_DIR=... SCREENSHOT_PHOTO_DIR=... \
//   flutter test test_screenshots/guide_docs_capture_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/exercise_category.dart';
import 'package:ssentif_coach/domain/enums/exercise_media_type.dart';
import 'package:ssentif_coach/domain/enums/exercise_taxonomy.dart';
import 'package:ssentif_coach/domain/enums/exercise_video_source_type.dart';
import 'package:ssentif_coach/domain/enums/gender.dart';
import 'package:ssentif_coach/domain/enums/meal_type.dart';
import 'package:ssentif_coach/domain/enums/measurement_type.dart';
import 'package:ssentif_coach/domain/enums/membership_category.dart';
import 'package:ssentif_coach/domain/enums/photo_angle.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/care_record.dart';
import 'package:ssentif_coach/domain/models/chat_room.dart';
import 'package:ssentif_coach/domain/models/exercise.dart';
import 'package:ssentif_coach/domain/models/member_activity_detail.dart';
import 'package:ssentif_coach/domain/models/membership_template.dart';
import 'package:ssentif_coach/domain/models/session_log.dart';
import 'package:ssentif_coach/domain/models/user_profile.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/auth/signup_screen.dart';
import 'package:ssentif_coach/features/chat/chat_screen.dart';
import 'package:ssentif_coach/features/class_recording/class_recording_screen.dart';
import 'package:ssentif_coach/features/exercise_library/exercise_library_screen.dart';
import 'package:ssentif_coach/features/members/tabs/activity_feed_tab.dart';
import 'package:ssentif_coach/features/members/widgets/body_photo_capture_dialog.dart';
import 'package:ssentif_coach/features/members/widgets/member_add_dialog.dart';
import 'package:ssentif_coach/features/members/widgets/member_link_input_sheet.dart';
import 'package:ssentif_coach/features/members/widgets/membership_issue_dialog.dart';
import 'package:ssentif_coach/features/products/products_screen.dart';
import 'package:ssentif_coach/features/settings/account_settings_screen.dart';
import 'package:ssentif_coach/features/settings/settings_screen.dart';
import 'package:ssentif_coach/providers/auth/auth_providers.dart';
import 'package:ssentif_coach/providers/chat/chat_providers.dart';
import 'package:ssentif_coach/providers/class_recording/class_recording_providers.dart';
import 'package:ssentif_coach/providers/home/home_providers.dart';
import 'package:ssentif_coach/providers/membership/membership_template_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// 공용 fixture — 가이드 전체가 같은 센터·같은 코치·같은 회원을 쓴다.
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

// 하네스가 SCREENSHOT_PHOTO_DIR 에서 같은 이름의 파일을 찾아 응답한다.
const _diet = 'https://photos.test/diet.png';
const _bench = 'https://photos.test/bench.png';
const _squat = 'https://photos.test/squat.png';
const _front = 'https://photos.test/front.png';
const _side = 'https://photos.test/side.png';
const _back = 'https://photos.test/back.png';

MembershipTemplate _product(
  String id,
  String name,
  MembershipCategory category, {
  int price = 0,
  int? totalCount,
  int? sessionDurationMin,
  int? durationMonths,
  int? unitPrice,
}) => MembershipTemplate(
  id: id,
  workspaceId: 'ws-1',
  name: name,
  category: category,
  price: price,
  totalCount: totalCount,
  sessionDurationMin: sessionDurationMin,
  durationMonths: durationMonths,
  unitPrice: unitPrice,
);

final _products = <MembershipTemplate>[
  _product('p1', '개인수업 10회', MembershipCategory.pt,
      price: 700000, totalCount: 10, sessionDurationMin: 50, unitPrice: 70000),
  _product('p2', '개인수업 30회', MembershipCategory.pt,
      price: 1830000, totalCount: 30, sessionDurationMin: 50, unitPrice: 61000),
  _product('p3', '그룹수업 8회', MembershipCategory.group,
      price: 320000, totalCount: 8, sessionDurationMin: 50, unitPrice: 40000),
  _product('p4', '시설이용권 3개월', MembershipCategory.facility,
      price: 270000, durationMonths: 3),
  _product('p5', '락커 6개월', MembershipCategory.locker,
      price: 90000, durationMonths: 6),
  _product('p6', '운동복 세트', MembershipCategory.uniform, price: 45000),
];

ChatRoom _room(
  String id,
  String name,
  String preview, {
  int unread = 0,
  int minutesAgo = 12,
}) {
  final now = DateTime(2026, 8, 5, 18, 40);
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

/// 회원 활동 — 실사진이 들어가는 유일한 화면이라 타입을 골고루 섞는다.
DateTime _d(int day, int hour, [int minute = 0]) =>
    DateTime(2026, 8, day, hour, minute);

// 오늘(8/5)에 여러 타입을 몰아둔다 — 탭은 오늘을 기본 선택하므로, 오늘이 비면
// 우측 일별 피드가 한 줄짜리로 찍혀 무엇을 보여주는 화면인지 전달되지 않는다.
final _activities = <MemberActivityDetail>[
  MemberActivityDetail.diet(
    id: 'a1',
    occurredAt: _d(5, 12, 30),
    mealType: MealType.lunch,
    imageUrl: _diet,
    imageUrls: const [_diet],
    memo: '닭가슴살 샐러드랑 현미밥 먹었어요',
    calories: 480,
    carbsG: 52,
    proteinG: 38,
    fatG: 11,
  ),
  MemberActivityDetail.exercise(
    id: 'a2',
    occurredAt: _d(5, 19, 20),
    title: '가슴 · 삼두 개인운동',
    setCount: 12,
    totalVolume: 4820,
    imageUrls: const [_bench],
    memo: '벤치프레스 70kg 성공',
  ),
  MemberActivityDetail.bodyPhoto(
    id: 'a3',
    occurredAt: _d(5, 9),
    imageUrls: const [_front, _side, _back],
    memo: '8월 첫 주 체형 기록',
  ),
  MemberActivityDetail.bodyComposition(
    id: 'a4',
    occurredAt: _d(5, 8, 20),
    weight: 72.4,
    muscleMass: 33.1,
    bodyFatMass: 13.2,
    bodyFatPercent: 18.2,
    weightDelta: -0.8,
  ),
  MemberActivityDetail.diet(
    id: 'a5',
    occurredAt: _d(5, 8, 10),
    mealType: MealType.breakfast,
    imageUrl: _diet,
    imageUrls: const [_diet],
    calories: 320,
  ),
  // 월별 그리드가 한 달치로 보이도록 앞선 날짜에도 흩뿌린다.
  MemberActivityDetail.exercise(
    id: 'a6',
    occurredAt: _d(4, 7, 40),
    title: '하체 개인운동',
    setCount: 10,
    totalVolume: 6300,
    imageUrls: const [_squat],
  ),
  MemberActivityDetail.diet(
    id: 'a7',
    occurredAt: _d(3, 19, 10),
    mealType: MealType.dinner,
    imageUrl: _diet,
    imageUrls: const [_diet],
    calories: 610,
  ),
  MemberActivityDetail.bodyPhoto(
    id: 'a8',
    occurredAt: _d(2, 9),
    imageUrls: const [_front, _side, _back],
  ),
  MemberActivityDetail.exercise(
    id: 'a9',
    occurredAt: _d(1, 20),
    title: '가슴 개인운동',
    setCount: 9,
    totalVolume: 3900,
    imageUrls: const [_bench],
  ),
];

// 운동 라이브러리 — 시스템 운동 + 코치가 직접 등록한 운동을 섞는다.
Exercise _ex(
  String id,
  String name,
  ExerciseCategory category,
  ExerciseType type,
  ExerciseSection? section, {
  bool system = false,
  MeasurementType measurement = MeasurementType.weightReps,
}) => Exercise(
  id: id,
  name: name,
  category: category,
  type: type,
  section: section,
  measurementType: measurement,
  isSystemExercise: system,
  createdByStaffId: system ? null : 'staff-1',
  videoSourceType:
      system ? null : ExerciseVideoSourceType.uploadedFile,
  videoUrl: system ? null : 'https://photos.test/bench.png',
);

final _exercises = <Exercise>[
  _ex('e1', '바벨 벤치프레스', ExerciseCategory.barbell, ExerciseType.strength,
      ExerciseSection.chest, system: true),
  _ex('e2', '랫풀다운', ExerciseCategory.machine, ExerciseType.strength,
      ExerciseSection.back, system: true),
  _ex('e3', '바벨 백스쿼트', ExerciseCategory.barbell, ExerciseType.strength,
      ExerciseSection.lowerBody, system: true),
  _ex('e4', '루마니안 데드리프트', ExerciseCategory.barbell, ExerciseType.strength,
      ExerciseSection.lowerBody, system: true),
  _ex('e5', '오버헤드 프레스', ExerciseCategory.barbell, ExerciseType.strength,
      ExerciseSection.shoulder, system: true),
  _ex('e6', '케틀벨 하이풀', ExerciseCategory.dumbbell, ExerciseType.strength,
      ExerciseSection.shoulder),
  _ex('e7', '밴드 워킹 런지', ExerciseCategory.bodyweight, ExerciseType.strength,
      ExerciseSection.lowerBody),
  _ex('e8', '리포머 풋워크', ExerciseCategory.pilates, ExerciseType.pilates,
      ExerciseSection.pilatesReformer,
      measurement: MeasurementType.repsOnly),
];

// 수업 기록 — 세트가 채워진 상태 + 수업 중 찍은 사진.
ExerciseMedia _media(String id, String photo) => ExerciseMedia(
      id: id,
      type: ExerciseMediaType.photo,
      localPath: '',
      url: photo,
      createdAt: '2026-08-05T19:20:00',
    );

final _sessionLog = SessionLog(
  id: 'log-1',
  sessionId: 'session-1',
  workspaceId: 'ws-1',
  clientId: 'client-1',
  coachStaffId: 'staff-1',
  date: '2026-08-05',
  exercises: [
    SessionLogExercise(
      id: 'sle-1',
      exerciseId: 'e1',
      exerciseName: '바벨 벤치프레스',
      orderIndex: 0,
      exerciseType: '근력',
      bodyPart: '가슴',
      memo: '어깨 내려서 견갑 고정. 3세트째 보조 1회.',
      sets: const [
        ExerciseSet(setNumber: 1, weight: 60, reps: 12),
        ExerciseSet(setNumber: 2, weight: 65, reps: 10),
        ExerciseSet(setNumber: 3, weight: 70, reps: 8),
      ],
      media: [_media('m1', _bench), _media('m2', _squat)],
    ),
    const SessionLogExercise(
      id: 'sle-2',
      exerciseId: 'e3',
      exerciseName: '바벨 백스쿼트',
      orderIndex: 1,
      exerciseType: '근력',
      bodyPart: '하체',
      sets: [
        ExerciseSet(setNumber: 1, weight: 80, reps: 10),
        ExerciseSet(setNumber: 2, weight: 90, reps: 8),
      ],
    ),
  ],
);

class _FakeSessionLog extends SessionLogNotifier {
  @override
  SessionLog build(String sessionId) => _sessionLog;
}

/// 체형 사진 세트 — 정면·측면·후면 실사진.
const _bodyPhotoSet = BodyPhotoSet(
  id: 'bps-1',
  date: '2026-08-05',
  editable: true,
  memo: '8월 첫 주 체형 기록',
  photos: [
    BodyPhoto(angle: PhotoAngle.front, url: _front),
    BodyPhoto(angle: PhotoAngle.side, url: _side),
    BodyPhoto(angle: PhotoAngle.back, url: _back),
  ],
);

/// 다이얼로그를 띄우기 위한 최소 런처 — 캡처 대상은 다이얼로그 자체다.
class _DialogLauncher extends StatelessWidget {
  const _DialogLauncher(this.open);

  final void Function(BuildContext context) open;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (ctx) => FilledButton(
            onPressed: () => open(ctx),
            child: const Text('open'),
          ),
        ),
      ),
    );
  }
}

Future<void> _tapOpen(WidgetTester tester) async {
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GnLocalStorage.init();
  });

  final baseOverrides = <Override>[
    currentWorkspaceNotifierProvider.overrideWith(_FakeWorkspace.new),
    currentUserProvider.overrideWith(_FakeUser.new),
    currentWorkspaceInfoProvider.overrideWith((ref) async => _workspaceInfo),
  ];

  final activityOverrides = <Override>[
    ...baseOverrides,
    memberMonthActivitiesProvider.overrideWith((ref, arg) async => _activities),
  ];

  testWidgets('가이드 — 회원가입 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const SignupScreen(),
      name: 'guide_signup',
      device: ScreenshotDevice.phonePortrait,
    );
  });

  testWidgets('가이드 — 프로필·설정 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const SettingsScreen(),
      name: 'guide_settings',
      device: ScreenshotDevice.phonePortrait,
      overrides: baseOverrides,
    );
  });

  testWidgets('가이드 — 계정 관리 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const AccountSettingsScreen(),
      name: 'guide_account_settings',
      device: ScreenshotDevice.phonePortrait,
      overrides: baseOverrides,
    );
  });

  testWidgets('가이드 — 채팅 목록', (tester) async {
    await captureScreenshot(
      tester,
      child: const ChatScreen(),
      name: 'guide_chat',
      device: ScreenshotDevice.phonePortrait,
      overrides: [
        ...baseOverrides,
        chatRoomsProvider.overrideWith(_FakeChatRooms.new),
      ],
    );
  });

  testWidgets('가이드 — 회원 추가 다이얼로그', (tester) async {
    await captureScreenshot(
      tester,
      child: _DialogLauncher((ctx) => showMemberAddDialog(ctx)),
      name: 'guide_member_add',
      device: ScreenshotDevice.tabletLandscape,
      overrides: baseOverrides,
      interact: _tapOpen,
    );
  });

  testWidgets('가이드 — 상품 관리 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const ProductsScreen(),
      name: 'guide_products',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...baseOverrides,
        manageableMembershipProductsProvider
            .overrideWith((ref) async => _products),
      ],
    );
  });

  testWidgets('가이드 — 상품 등록(발급) 다이얼로그', (tester) async {
    await captureScreenshot(
      tester,
      child: _DialogLauncher(
        (ctx) => showMembershipIssueDialog(ctx, 'client-1'),
      ),
      name: 'guide_membership_issue',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...baseOverrides,
        membershipTemplatesProvider.overrideWith((ref) async => _products),
      ],
      interact: _tapOpen,
    );
  });

  // 실제 '활동' 탭 — 구 캡처는 캘린더 위젯만 따로 조립한 합성이라 실제 화면과
  // 달랐다. 여기서는 탭 자체를 렌더하고 사진도 실사진으로 채운다.
  testWidgets('가이드 — 활동 탭(일별: 캘린더 + 피드)', (tester) async {
    await captureScreenshot(
      tester,
      // Scaffold 로 감싼다 — 실제 앱에서 이 탭은 Scaffold 안이고, 밖에서 렌더하면
      // DefaultTextStyle 이 없어 모든 텍스트에 노란 이중밑줄(Flutter 의 "Material
      // 없음" 디버그 표시)이 그려진다.
      child: const Scaffold(body: ActivityFeedTab(memberId: 'client-1')),
      name: 'guide_activity_daily',
      device: ScreenshotDevice.tabletLandscape,
      overrides: activityOverrides,
    );
  });

  testWidgets('가이드 — 회원 연동 시트', (tester) async {
    await captureScreenshot(
      tester,
      child: const Scaffold(
        body: MemberLinkInputSheet(
          workspaceId: 'ws-1',
          memberId: 'client-1',
          memberName: '김지훈',
          memberPhone: '010-1234-5678',
          memberGender: Gender.male,
          memberAge: 32,
        ),
      ),
      name: 'guide_member_link',
      device: ScreenshotDevice.tabletLandscape,
      overrides: baseOverrides,
    );
  });

  testWidgets('가이드 — 운동 라이브러리', (tester) async {
    await captureScreenshot(
      tester,
      child: const ExerciseLibraryScreen(),
      name: 'guide_exercise_library',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...baseOverrides,
        exerciseLibraryProvider.overrideWith((ref) async => _exercises),
      ],
    );
  });

  testWidgets('가이드 — 수업 기록 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const ClassRecordingScreen(sessionId: 'session-1'),
      name: 'guide_class_log',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        ...baseOverrides,
        sessionLogNotifierProvider('session-1')
            .overrideWith(_FakeSessionLog.new),
        // 실기기에서는 모델이 이미 받아져 있어 이 배너가 뜨지 않는다.
        handwritingModelReadyProvider.overrideWith((ref) async => true),
      ],
    );
  });

  // 체형 사진 등록 다이얼로그는 캡처하지 않는다 — 슬롯이 cached_network_image
  // 를 쓰는데 그 패키지는 sqflite 네이티브 의존이라 테스트에서 멈춘다
  // (screenshot_harness.dart 주석 참조). 체형 사진은 활동 탭 월별 그리드와
  // 회원 인증 다이얼로그 캡처가 대신 보여준다.

  testWidgets('가이드 — 활동 탭(월별: 사진 모아보기)', (tester) async {
    await captureScreenshot(
      tester,
      child: const Scaffold(body: ActivityFeedTab(memberId: 'client-1')),
      name: 'guide_activity_grid',
      device: ScreenshotDevice.tabletLandscape,
      overrides: activityOverrides,
      interact: (tester) async {
        final monthly = find.text('월별');
        if (monthly.evaluate().isNotEmpty) {
          await tester.tap(monthly.first);
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));
        }
      },
    );
  });
}
