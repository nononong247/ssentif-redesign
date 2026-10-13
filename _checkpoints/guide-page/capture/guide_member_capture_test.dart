// 사용 가이드(www.ssentif.kr/guide-member.html, 회원 모드)용 화면 캡처.
//
// 실행:
//   SCREENSHOT_DIR=... SCREENSHOT_PHOTO_DIR=... \
//   flutter test test_screenshots/guide_member_capture_test.dart
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_members/domain/enums/gender.dart';
import 'package:ssentif_members/domain/models/diet_entry.dart';
import 'package:ssentif_members/domain/models/exercise_record.dart';
import 'package:ssentif_members/domain/models/body_composition.dart';
import 'package:ssentif_members/domain/models/body_photo.dart';
import 'package:ssentif_members/domain/models/user_profile.dart';
import 'package:ssentif_members/features/home/home_screen.dart';
import 'package:ssentif_members/features/home/widgets/home_checkin_card.dart';
import 'package:ssentif_members/features/notices/notice_list_screen.dart';
import 'package:ssentif_members/features/activity_upload/diet/diet_upload_screen.dart';
import 'package:ssentif_members/features/activity_upload/body_composition/body_composition_upload_screen.dart';
import 'package:ssentif_members/features/activity_upload/body_photo/body_photo_upload_screen.dart';
import 'package:ssentif_members/providers/upload/diet_entry_upload_notifier.dart';
import 'package:ssentif_members/providers/upload/body_photo_upload_notifier.dart';
import 'package:ssentif_members/domain/enums/meal_type.dart';
import 'package:ssentif_members/features/profile/my_products_screen.dart';
import 'package:ssentif_members/features/profile/settings_screen.dart';
import 'package:ssentif_members/features/profile/withdrawal_screen.dart';
import 'package:ssentif_members/providers/activity/body_composition_providers.dart';
import 'package:ssentif_members/providers/activity/body_photo_providers.dart';
import 'package:ssentif_members/providers/activity/exercise_record_providers.dart';
import 'package:ssentif_members/providers/auth/auth_providers.dart';
import 'package:ssentif_members/data/repositories/checkin_repository.dart';
import 'package:ssentif_members/domain/models/checkin_eligibility.dart';
import 'package:ssentif_members/domain/models/my_schedule_item.dart';
import 'package:ssentif_members/domain/models/session_log.dart';
import 'package:ssentif_members/features/session_log/session_log_detail_screen.dart';
import 'package:ssentif_members/features/schedule/new_reservation_screen.dart';
import 'package:ssentif_members/features/schedule/widgets/schedule_change_dialog.dart';
import 'package:ssentif_members/providers/checkin/checkin_providers.dart';
import 'package:ssentif_members/providers/pt_request/pt_requests_provider.dart';
import 'package:ssentif_members/providers/schedule/group_schedule_providers.dart';
import 'package:ssentif_members/shared/widgets/workspace_share_dialog.dart';
import 'package:ssentif_members/providers/centers/linked_centers_provider.dart';
import 'package:ssentif_members/providers/diet/diet_entry_providers.dart';
import 'package:ssentif_members/providers/notices/member_notices_provider.dart';
import 'package:ssentif_members/providers/schedule/my_memberships_provider.dart';
import 'package:ssentif_members/providers/session_log/session_logs_provider.dart';
import 'package:ssentif_members/data/repositories/mock_member_notice_repository.dart';
import 'package:ssentif_members/data/repositories/mock_my_membership_repository.dart';
import 'package:ssentif_members/data/repositories/mock_session_log_repository.dart';

import 'package:ssentif_members/domain/enums/activity_category.dart';
import 'package:ssentif_members/domain/enums/created_by_type.dart';
import 'package:ssentif_members/domain/models/activity_feed_item.dart';
import 'package:ssentif_members/providers/activity/activity_feed_provider.dart';
import 'package:ssentif_members/providers/home/activity_markers_provider.dart';
import 'package:ssentif_members/providers/home/day_schedules_provider.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// 공용 fixture — 가이드 전체가 같은 회원·같은 센터를 쓴다.
// ---------------------------------------------------------------------------

const _user = UserProfile(
  id: 'user-1',
  email: 'member@ssentif.kr',
  fullName: '김지훈',
  phone: '010-1234-5678',
  birthDate: '1994-03-12',
  gender: Gender.male,
  linkCode: 'a4kd91xz',
  createdAt: '2026-01-04T09:00:00',
);

class _FakeHistoryCenters extends HistoryCentersNotifier {
  @override
  Future<List<LinkedCenter>> build() async => [_center];
}

/// 수업일지 상세 — 원격 사진(CachedNetworkImage → sqflite)은 테스트에서 멈추므로
/// 미디어 없이 세트·코치 메모만 채운다.
MemberSessionLog _sessionLog() {
  final now = DateTime.now();
  final at = DateTime(now.year, now.month, now.day - 1, 19);
  return MemberSessionLog(
    id: 'log-1',
    scheduleId: 'sch-1',
    workspaceId: 'ws-1',
    workspaceName: '센티프 피트니스 강남점',
    coachName: '박성훈',
    overallMemo: '오늘은 하체 위주로 진행했습니다. 스쿼트 폼이 많이 좋아졌어요. '
        '다음 시간에는 데드리프트 중량을 조금 더 올려볼게요.',
    completedAt: at.add(const Duration(hours: 1)),
    scheduledAt: at,
    durationMinutes: 50,
    scheduleType: 'pt',
    scheduleStatus: 'completed',
    exercises: const [
      SessionLogExercise(
        id: 'ex-1',
        customName: '바벨 스쿼트',
        measurementType: 'weightReps',
        memo: '깊이 좋음. 무게 안정적.',
        sets: [
          SessionLogSet(setNumber: 1, weight: 40, reps: 12, warmup: true),
          SessionLogSet(setNumber: 2, weight: 60, reps: 10),
          SessionLogSet(setNumber: 3, weight: 70, reps: 8, failure: true),
        ],
      ),
      SessionLogExercise(
        id: 'ex-2',
        customName: '레그 프레스',
        measurementType: 'weightReps',
        sets: [
          SessionLogSet(setNumber: 1, weight: 120, reps: 12),
          SessionLogSet(setNumber: 2, weight: 140, reps: 10),
        ],
      ),
      SessionLogExercise(
        id: 'ex-3',
        customName: '런지',
        measurementType: 'weightReps',
        sets: [
          SessionLogSet(setNumber: 1, weight: 20, reps: 12),
          SessionLogSet(setNumber: 2, weight: 20, reps: 12),
        ],
      ),
    ],
  );
}

class _FakeLinkedCenters extends LinkedCentersNotifier {
  @override
  Future<List<LinkedCenter>> build() async => [
        LinkedCenter(
          id: 'lc-1',
          workspaceId: 'ws-1',
          workspaceName: '센티프 피트니스 강남점',
          status: 'active',
          coachName: '박성훈',
          linkedAt: DateTime(2026, 1, 10),
        ),
      ];
}

const _center = LinkedCenter(
  id: 'lc-1',
  workspaceId: 'ws-1',
  workspaceName: '센티프 피트니스 강남점',
  status: 'active',
  coachName: '박성훈',
);

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

class _EmptyExerciseRecords extends ExerciseRecordsNotifier {
  @override
  Future<List<ExerciseRecord>> build() async => const [];
}

class _EmptyDietEntries extends DietEntriesNotifier {
  @override
  Future<List<DietEntry>> build() async => const [];
}

class _EmptyBodyCompositions extends BodyCompositionsNotifier {
  @override
  Future<List<BodyComposition>> build() async => const [];
}

class _EmptyBodyPhotos extends BodyPhotosNotifier {
  @override
  Future<List<BodyPhoto>> build() async => const [];
}

final _commonOverrides = <Override>[
  currentUserProvider.overrideWith((ref) async => _user),
  linkedCentersProvider.overrideWith(_FakeLinkedCenters.new),
  historyCentersProvider.overrideWith(_FakeHistoryCenters.new),
  exerciseRecordsProvider.overrideWith(_EmptyExerciseRecords.new),
  dietEntriesProvider.overrideWith(_EmptyDietEntries.new),
  bodyCompositionsProvider.overrideWith(_EmptyBodyCompositions.new),
  bodyPhotosProvider.overrideWith(_EmptyBodyPhotos.new),
  sessionLogRepositoryProvider.overrideWithValue(
    const MockSessionLogRepository(),
  ),
  memberNoticeRepositoryProvider.overrideWithValue(
    const MockMemberNoticeRepository(),
  ),
  myMembershipRepositoryProvider.overrideWithValue(
    const MockMyMembershipRepository(),
  ),
  // 홈 '센터 입장하기' 카드 — 이번 주 월·수 입장 + 오늘 입장 가능.
  checkinRepositoryProvider.overrideWithValue(_StubCheckinRepository()),
  checkinEligibilityProvider.overrideWith((ref) async {
    final week = checkinWeekDays(DateTime.now());
    return [
      CheckinEligibility(
        workspaceId: 'ws-1',
        workspaceName: '센티프 피트니스 강남점',
        buttonVisible: true,
        todayEligible: true,
        weekCheckinDates: [week[0], week[2]],
      ),
    ];
  }),
];

/// 다이얼로그를 띄우기 위한 최소 런처 — 캡처 대상은 다이얼로그 자체다.
class _DialogLauncher extends ConsumerWidget {
  const _DialogLauncher(this.open);

  final void Function(BuildContext context, WidgetRef ref) open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: Builder(
          builder: (ctx) => FilledButton(
            onPressed: () => open(ctx, ref),
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

MyScheduleItem _ptItem() {
  final now = DateTime.now();
  return MyScheduleItem(
    scheduleId: 'sch-1',
    workspaceId: 'ws-1',
    workspaceName: '센티프 피트니스 강남점',
    scheduleType: 'pt',
    coachName: '박성훈',
    scheduledAt: DateTime(now.year, now.month, now.day + 2, 19),
    durationMinutes: 50,
    attendanceStatus: 'scheduled',
    membershipId: 'mock-ms-1',
    remainingCount: 8,
    ptSessionNumber: 13,
  );
}

// 실사진(로컬 File) 주입 — 강사 모드 가이드와 같은 픽스처 폴더를 공유한다.
// Image.file 은 플러그인 의존이 없어 flutter_test 안에서도 그대로 렌더된다
// (CachedNetworkImage/원격 URL 은 sqflite 네이티브 의존이라 여기서는 쓰지 않는다).
String? get _photoDir => Platform.environment['SCREENSHOT_PHOTO_DIR'];

File? _photo(String name) {
  final dir = _photoDir;
  if (dir == null) return null;
  final f = File('$dir/$name.png');
  return f.existsSync() ? f : null;
}

class _DietWithPhoto extends DietEntryUploadNotifier {
  @override
  Future<DietEntryFormState> build() async {
    final photo = _photo('diet');
    return DietEntryFormState(
      mealType: MealType.lunch,
      eatenAt: DateTime.now(),
      imageFiles: photo != null ? [photo] : const [],
    );
  }
}

class _BodyPhotoWithPhotos extends BodyPhotoUploadNotifier {
  @override
  Future<BodyPhotoFormState> build() async {
    return BodyPhotoFormState(
      takenAt: DateTime.now(),
      frontFile: _photo('front'),
      sideFile: _photo('side'),
      backFile: _photo('back'),
    );
  }
}

/// 본문이 짧은 화면용 — 폭은 같고 높이만 낮은 폰. 하단 고정 CTA 가 본문 가까이
/// 붙어 빈 공간 없이 한 장에 담긴다.
ScreenshotDevice _shortPhone(double height) =>
    ScreenshotDevice('phone_portrait_short', Size(390, height), 3.0);

// 홈 하단 기록 영역 — 오늘 남긴 식단·체성분 2건과 캘린더 마커.
final _homeToday = () {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}();
DateTime _hAt(int h, int m) =>
    DateTime(_homeToday.year, _homeToday.month, _homeToday.day, h, m);

final _homeFeed = <HomeActivityFeedItem>[
  DietFeedItem(
    DietEntry(
      id: 'd-1',
      userId: 'user-1',
      mealType: MealType.lunch,
      eatenAt: _hAt(12, 30),
      createdByType: CreatedByType.self,
      foodNames: const ['닭가슴살 샐러드', '현미밥'],
      calories: 480,
    ),
  ),
  BodyCompositionFeedItem(
    BodyComposition(
      id: 'bc-1',
      userId: 'user-1',
      measuredAt: _hAt(9, 0),
      createdByType: CreatedByType.self,
      createdAt: _hAt(9, 0),
      weight: 72.4,
      skeletalMuscleMass: 32.1,
      bodyFatPercentage: 18.2,
    ),
  ),
];

final _homeMarkers = {
  _homeToday: {ActivityCategory.diet, ActivityCategory.change},
  _homeToday.subtract(const Duration(days: 2)): {ActivityCategory.exercise},
  _homeToday.subtract(const Duration(days: 3)): {
    ActivityCategory.personalLesson,
    ActivityCategory.diet,
  },
};

final _homeOverrides = <Override>[
  homeActivityMarkersProvider.overrideWith((ref) async => _homeMarkers),
  monthActivityMarkersProvider.overrideWith((ref, month) async => _homeMarkers),
  dayActivityFeedProvider.overrideWith((ref, day) async => _homeFeed),
  daySchedulesProvider.overrideWith((ref, day) async => const []),
];

void main() {
  testWidgets('홈 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const HomeScreen(),
      name: 'guide_member_home',
      overrides: [..._commonOverrides, ..._homeOverrides],
      device: ScreenshotDevice.phonePortrait,
      settle: const Duration(milliseconds: 1800),
      precacheAssets: const [
        'assets/images/ic_memo_clay.png',
        'assets/images/ic_diet.png',
        'assets/images/ic_dumbbell.png',
        'assets/images/ic_bodyweight_clay.png',
        'assets/images/ic_bodyshape_clay.png',
      ],
    );
  });

  // 일정 탭 [수업 예약하기] — 개인수업 예약 요청 폼(수강권 선택 + 날짜 + 시간).
  testWidgets('수업 예약하기 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const NewReservationScreen(),
      name: 'guide_member_reserve',
      overrides: [
        ..._commonOverrides,
        selectedReservationCenterProvider.overrideWithValue(_center),
        pendingPtRequestsProvider.overrideWith((ref) async => const []),
        ptAvailableSlotsProvider.overrideWith(
          (ref, q) async => const ['10:00', '11:00', '14:00', '15:00', '17:00', '19:00'],
        ),
      ],
      device: _shortPhone(600),
      settle: const Duration(milliseconds: 1800),
    );
  });

  // 일정 → 전체보기에서 예정 수업을 눌렀을 때 — 수업 취소 및 변경 창.
  testWidgets('수업 변경·취소 다이얼로그', (tester) async {
    await captureScreenshot(
      tester,
      child: _DialogLauncher(
        (ctx, ref) => showDialog<void>(
          context: ctx,
          builder: (_) => ScheduleChangeDialog(item: _ptItem()),
        ),
      ),
      name: 'guide_member_change',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
      interact: _tapOpen,
    );
  });

  // 기록 저장 시 '어떤 센터에 공유하시겠어요?' 창.
  testWidgets('센터 공유 다이얼로그', (tester) async {
    await captureScreenshot(
      tester,
      child: _DialogLauncher(
        (ctx, ref) => showWorkspaceShareDialog(ctx, ref),
      ),
      name: 'guide_member_share',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
      interact: _tapOpen,
    );
  });

  testWidgets('수업일지 상세 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: SessionLogDetailScreen(id: 'log-1', log: _sessionLog()),
      name: 'guide_member_log',
      overrides: _commonOverrides,
      device: const ScreenshotDevice('phone_portrait_tall', Size(390, 1100), 3.0),
      precacheAssets: const ['assets/images/ic_memo_clay.png'],
    );
  });

  testWidgets('공지 목록 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const NoticeListScreen(workspaceId: 'ws-1'),
      name: 'guide_member_notice',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
    );
  });

  testWidgets('내 상품 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const MyProductsScreen(),
      name: 'guide_member_products',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
      precacheAssets: const [
        'assets/images/ic_personal_lesson.png',
        'assets/images/ic_group_training.png',
        'assets/images/ic_facility.png',
        'assets/images/ic_uniform.png',
        'assets/images/ic_locker.png',
        'assets/images/ic_etc_product.png',
      ],
    );
  });

  testWidgets('설정 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const SettingsScreen(),
      name: 'guide_member_settings',
      overrides: _commonOverrides,
      device: _shortPhone(730),
    );
  });

  testWidgets('회원 탈퇴 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const WithdrawalScreen(),
      name: 'guide_member_withdrawal',
      overrides: _commonOverrides,
      device: _shortPhone(560),
    );
  });

  testWidgets('식단 기록 화면 (사진 첨부)', (tester) async {
    final photo = _photo('diet');
    await captureScreenshot(
      tester,
      child: const DietUploadScreen(),
      name: 'guide_member_diet',
      overrides: [
        ..._commonOverrides,
        dietEntryUploadProvider.overrideWith(_DietWithPhoto.new),
      ],
      device: ScreenshotDevice.phonePortrait,
      precacheFiles: photo != null ? [photo] : const [],
    );
  });

  testWidgets('체성분 기록 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const BodyCompositionUploadScreen(),
      name: 'guide_member_body_composition',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
    );
  });

  testWidgets('체형사진 기록 화면', (tester) async {
    final files = [_photo('front'), _photo('side'), _photo('back')]
        .whereType<File>()
        .toList();
    await captureScreenshot(
      tester,
      child: const BodyPhotoUploadScreen(),
      name: 'guide_member_body_photo',
      overrides: [
        ..._commonOverrides,
        bodyPhotoUploadProvider.overrideWith(_BodyPhotoWithPhotos.new),
      ],
      device: ScreenshotDevice.phonePortrait,
      precacheFiles: files,
    );
  });
}
