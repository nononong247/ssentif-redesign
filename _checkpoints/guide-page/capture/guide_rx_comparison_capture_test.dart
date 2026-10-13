// 코치앱 완료 처방 — 처방·수행 비교 본문(`PrescriptionRecordSection`) 캡처. 인스타 캐러셀용.
//
// 실행: flutter test test_screenshots/prescription_comparison_capture_test.dart
//
// 활동 상세 다이얼로그 전체는 소통 패널(서버 조회)이 붙어 있어, 그 안의 처방 본문 위젯만
// 실제 그대로 그린다. ⚠️ 미디어 URL 은 넣지 않는다(CachedNetworkImage 가 하네스를 멈춘다).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/core/utils/extensions.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/models/exercise_record_detail.dart';
import 'package:ssentif_coach/shared/widgets/prescription_record_section.dart';

import 'screenshot_harness.dart';

Map<String, dynamic> _w(num w, int r) => <String, dynamic>{
  'weight': w,
  'reps': r,
};

Map<String, dynamic> _json() => <String, dynamic>{
  'id': 'rec-1',
  'recordMode': 'DETAILED',
  'title': null,
  'memo': '스쿼트 마지막 세트가 힘들었어요',
  'performedAt': '2026-10-02T19:30:00',
  'source': 'PRESCRIPTION',
  'imageUrls': <dynamic>[],
  'exercises': <dynamic>[
    <String, dynamic>{
      'id': 'ere-1',
      'customName': '바벨 백스쿼트',
      'exerciseType': 'strength',
      'bodyPart': 'lower_body',
      'measurementType': 'weightReps',
      'prescriptionExerciseId': 'pe-1',
      'skipped': false,
      'sortOrder': 0,
      'sets': <dynamic>[_w(40, 12), _w(50, 10), _w(65, 8), _w(65, 6)],
      'media': <dynamic>[],
    },
    <String, dynamic>{
      'id': 'ere-2',
      'customName': '루마니안 데드리프트',
      'exerciseType': 'strength',
      'bodyPart': 'lower_body',
      'measurementType': 'weightReps',
      'prescriptionExerciseId': 'pe-2',
      'skipped': true,
      'sortOrder': 1,
      'sets': <dynamic>[],
      'media': <dynamic>[],
    },
    <String, dynamic>{
      'id': 'ere-3',
      'customName': '플랭크',
      'exerciseType': 'strength',
      'bodyPart': 'core',
      'measurementType': 'duration',
      'prescriptionExerciseId': 'pe-3',
      'skipped': false,
      'sortOrder': 2,
      'sets': <dynamic>[
        <String, dynamic>{'durationMinutes': 1},
        <String, dynamic>{'durationMinutes': 1},
      ],
      'media': <dynamic>[],
    },
    <String, dynamic>{
      'id': 'ere-4',
      'customName': '레그 프레스',
      'exerciseType': 'strength',
      'bodyPart': 'lower_body',
      'measurementType': 'weightReps',
      'prescriptionExerciseId': null,
      'skipped': false,
      'sortOrder': 3,
      'sets': <dynamic>[_w(80, 12), _w(90, 10)],
      'media': <dynamic>[],
    },
  ],
  'prescription': <String, dynamic>{
    'status': 'COMPLETED',
    'prescribedDate': '2026-10-02',
    'prescribedByStaffId': 'staff-1',
    'prescribedByName': '박성훈',
    'memo': '하체 위주, 무리하지 마세요',
    'version': 1,
    'prescribedAt': '2026-10-01T21:00:00',
    'completedAt': '2026-10-02T19:40:00',
    'exercises': <dynamic>[
      <String, dynamic>{
        'id': 'pe-1',
        'customName': '바벨 백스쿼트',
        'exerciseType': 'strength',
        'bodyPart': 'lower_body',
        'measurementType': 'weightReps',
        'coachMemo': '무릎이 안쪽으로 모이지 않게',
        'sortOrder': 0,
        'sets': <dynamic>[_w(40, 12), _w(50, 10), _w(60, 8), _w(60, 8)],
        'media': <dynamic>[],
      },
      <String, dynamic>{
        'id': 'pe-2',
        'customName': '루마니안 데드리프트',
        'exerciseType': 'strength',
        'bodyPart': 'lower_body',
        'measurementType': 'weightReps',
        'sortOrder': 1,
        'sets': <dynamic>[_w(30, 12), _w(35, 10), _w(35, 10)],
        'media': <dynamic>[],
      },
      <String, dynamic>{
        'id': 'pe-3',
        'customName': '플랭크',
        'exerciseType': 'strength',
        'bodyPart': 'core',
        'measurementType': 'duration',
        'sortOrder': 2,
        'sets': <dynamic>[
          <String, dynamic>{'durationMinutes': 1},
          <String, dynamic>{'durationMinutes': 1},
          <String, dynamic>{'durationSeconds': 45},
        ],
        'media': <dynamic>[],
      },
    ],
  },
};

class _Scene extends StatelessWidget {
  const _Scene({required this.record});

  final ExerciseRecordDetail record;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gnColors.surfaceMain,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: PrescriptionRecordSection(
            record: record,
            today: DateTime(2026, 10, 2),
            memberMemo: record.memo,
          ),
        ),
      ),
    );
  }
}

void main() {
  setUpAll(() async {
    await initializeDateFormatting('ko');
    SharedPreferences.setMockInitialValues(<String, Object>{});
    await GnLocalStorage.init();
  });

  testWidgets('코치앱 완료 처방 비교 캡처', (tester) async {
    final record = ExerciseRecordDetail.fromJson(_json());
    await captureScreenshot(
      tester,
      child: _Scene(record: record),
      name: 'grx_03_coach_comparison',
      device: const ScreenshotDevice('phone_tall', Size(390, 1300), 3.0),
    );
  });
}
