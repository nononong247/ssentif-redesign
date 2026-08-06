// 사용 가이드(www.ssentif.kr/guide-member.html, 회원 모드)용 화면 캡처.
//
// 실행:
//   SCREENSHOT_DIR=... SCREENSHOT_PHOTO_DIR=... \
//   flutter test test_screenshots/guide_member_capture_test.dart
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
import 'package:ssentif_members/providers/centers/linked_centers_provider.dart';
import 'package:ssentif_members/providers/diet/diet_entry_providers.dart';
import 'package:ssentif_members/providers/notices/member_notices_provider.dart';
import 'package:ssentif_members/providers/schedule/my_memberships_provider.dart';
import 'package:ssentif_members/providers/session_log/session_logs_provider.dart';
import 'package:ssentif_members/data/repositories/mock_member_notice_repository.dart';
import 'package:ssentif_members/data/repositories/mock_my_membership_repository.dart';
import 'package:ssentif_members/data/repositories/mock_session_log_repository.dart';

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
];

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

void main() {
  testWidgets('홈 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const HomeScreen(),
      name: 'guide_member_home',
      overrides: _commonOverrides,
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
      device: ScreenshotDevice.phonePortrait,
    );
  });

  testWidgets('회원 탈퇴 화면', (tester) async {
    await captureScreenshot(
      tester,
      child: const WithdrawalScreen(),
      name: 'guide_member_withdrawal',
      overrides: _commonOverrides,
      device: ScreenshotDevice.phonePortrait,
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
