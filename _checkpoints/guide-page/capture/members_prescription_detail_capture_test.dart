// 회원앱 처방 상세(보기) 캡처 — 인스타 캐러셀용.
//
// 실행: flutter test test_screenshots/prescription_detail_capture_test.dart
//
// ① 완료 전(예정) — 처방운동·예정 배지, 처방 메모, 목표 세트 표, [운동 시작하기]
// ② 완료 후 — 처방·수행 비교 표, 「안 함」, 「직접 추가」
//
// ⚠️ 미디어 URL 은 넣지 않는다(CachedNetworkImage 가 하네스를 멈춘다).
import 'dart:io';

import 'package:flutter/material.dart' show Size;
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_members/domain/enums/exercise_record_mode.dart';
import 'package:ssentif_members/domain/models/activity_feed_item.dart';
import 'package:ssentif_members/domain/models/activity_social.dart';
import 'package:ssentif_members/domain/models/exercise_prescription.dart';
import 'package:ssentif_members/domain/models/exercise_record.dart';
import 'package:ssentif_members/domain/models/exercise_set_input.dart';
import 'package:ssentif_members/features/activity_upload/shared/pending_upload_file_store.dart';
import 'package:ssentif_members/features/activity_upload/shared/prescription_draft_store.dart';
import 'package:ssentif_members/features/record_detail/record_detail_screen.dart';
import 'package:ssentif_members/providers/activity/exercise_record_providers.dart';
import 'package:ssentif_members/providers/activity/prescription_providers.dart';
import 'package:ssentif_members/providers/auth/auth_providers.dart';
import 'package:ssentif_members/providers/social/activity_social_providers.dart';

import 'screenshot_harness.dart';

late ExerciseRecord _current;

class _FakeRecordsNotifier extends ExerciseRecordsNotifier {
  @override
  Future<List<ExerciseRecord>> build() async => [_current];
}

class _FakeSocialNotifier extends ActivitySocialNotifier {
  @override
  Future<ActivitySocial> build(ActivitySocialKey arg) async =>
      const ActivitySocial(threads: []);
}

ExerciseSetEntry _w(double w, int r) => ExerciseSetEntry(weight: w, reps: r);

final _prescribedExercises = [
  PrescribedExercise(
    id: 'pe-1',
    name: '바벨 백스쿼트',
    bodyPart: 'lower_body',
    coachMemo: '무릎이 안쪽으로 모이지 않게',
    sets: [_w(40, 12), _w(50, 10), _w(60, 8), _w(60, 8)],
  ),
  PrescribedExercise(
    id: 'pe-2',
    name: '루마니안 데드리프트',
    bodyPart: 'lower_body',
    sortOrder: 1,
    sets: [_w(30, 12), _w(35, 10), _w(35, 10)],
  ),
  const PrescribedExercise(
    id: 'pe-3',
    name: '플랭크',
    bodyPart: 'core',
    measurementType: 'duration',
    sortOrder: 2,
    sets: [
      ExerciseSetEntry(durationMinutes: 1),
      ExerciseSetEntry(durationMinutes: 1),
      ExerciseSetEntry(durationSeconds: 45),
    ],
  ),
];

ExercisePrescription _prescription(PrescriptionStoredStatus status) =>
    ExercisePrescription(
      status: status,
      prescribedDate: DateTime(2026, 10, 2),
      prescribedByName: '박준호',
      memo: '하체 위주, 무리하지 마세요',
      version: 1,
      prescribedAt: DateTime(2026, 10, 1, 21),
      completedAt: status == PrescriptionStoredStatus.completed
          ? DateTime(2026, 10, 2, 19, 40)
          : null,
      exercises: _prescribedExercises,
    );

ExerciseRecord _pending() => ExerciseRecord(
  id: 'r1',
  userId: 'u1',
  recordMode: ExerciseRecordMode.detailed,
  performedAt: DateTime(2026, 10, 2),
  exercises: const [
    ExerciseInDetailedRecord(
      name: '바벨 백스쿼트',
      bodyPart: 'lower_body',
      prescriptionExerciseId: 'pe-1',
      sets: [],
    ),
    ExerciseInDetailedRecord(
      name: '루마니안 데드리프트',
      bodyPart: 'lower_body',
      prescriptionExerciseId: 'pe-2',
      sortOrder: 1,
      sets: [],
    ),
    ExerciseInDetailedRecord(
      name: '플랭크',
      bodyPart: 'core',
      measurementType: 'duration',
      prescriptionExerciseId: 'pe-3',
      sortOrder: 2,
      sets: [],
    ),
  ],
  prescription: _prescription(PrescriptionStoredStatus.prescribed),
);

ExerciseRecord _completed() => _pending().copyWith(
  performedAt: DateTime(2026, 10, 2, 19, 30),
  memo: '스쿼트 마지막 세트가 힘들었어요',
  exercises: [
    ExerciseInDetailedRecord(
      name: '바벨 백스쿼트',
      bodyPart: 'lower_body',
      prescriptionExerciseId: 'pe-1',
      sets: [_w(40, 12), _w(50, 10), _w(65, 8), _w(65, 6)],
    ),
    const ExerciseInDetailedRecord(
      name: '루마니안 데드리프트',
      bodyPart: 'lower_body',
      prescriptionExerciseId: 'pe-2',
      sortOrder: 1,
      skipped: true,
      sets: [],
    ),
    const ExerciseInDetailedRecord(
      name: '플랭크',
      bodyPart: 'core',
      measurementType: 'duration',
      prescriptionExerciseId: 'pe-3',
      sortOrder: 2,
      sets: [
        ExerciseSetEntry(durationMinutes: 1),
        ExerciseSetEntry(durationMinutes: 1),
      ],
    ),
    ExerciseInDetailedRecord(
      name: '레그 프레스',
      bodyPart: 'lower_body',
      sortOrder: 3,
      sets: [_w(80, 12), _w(90, 10)],
    ),
  ],
  prescription: _prescription(PrescriptionStoredStatus.completed),
);

void main() {
  late Directory temp;

  setUpAll(() async {
    await initializeDateFormatting('ko');
    SharedPreferences.setMockInitialValues(<String, Object>{});
    temp = await Directory.systemTemp.createTemp('rx-capture-');
  });

  for (final (name, build) in [
    ('rx_02_member_detail_pending', _pending),
    ('rx_03b_member_detail_completed', _completed),
  ]) {
    testWidgets('회원앱 처방 상세 캡처 — $name', (tester) async {
      final record = build();
      _current = record;
      await captureScreenshot(
        tester,
        child: RecordDetailScreen(
          type: 'exercise',
          id: record.id,
          initialItem: ExerciseFeedItem(record),
        ),
        name: name,
        device: name.contains('completed')
            ? const ScreenshotDevice('phone_tall', Size(390, 1620), 3.0)
            : ScreenshotDevice.phonePortrait,
        overrides: [
          exerciseRecordsProvider.overrideWith(_FakeRecordsNotifier.new),
          exerciseRecordDetailProvider.overrideWith(
            (ref, id) => Future.value(record),
          ),
          activitySocialProvider.overrideWith(_FakeSocialNotifier.new),
          currentUserProvider.overrideWith((ref) async => null),
          prescriptionClockProvider.overrideWithValue(
            () => DateTime.utc(2026, 10, 2, 3),
          ),
          prescriptionDraftExistsProvider.overrideWith(
            (ref, id) => Future.value(false),
          ),
          exerciseRecordsInRangeProvider.overrideWith(
            (ref, range) => Future.value(const <ExerciseRecord>[]),
          ),
          pendingUploadFileStoreProvider.overrideWithValue(
            PendingUploadFileStore(supportDirectory: () async => temp),
          ),
        ],
      );
    });
  }
}
