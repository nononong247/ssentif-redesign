// 개인운동 처방 작성 화면(세로 폰) 캡처 — 인스타 캐러셀용.
//
// 실행: flutter test test_screenshots/prescription_editor_capture_test.dart
//
// 화면 위젯을 직접 pump 하지 않고 헤더 · 종목 레일 · 기록 판 · 떠 있는 CTA 를
// 실제 위젯 그대로 조립한다(class_recording_screen_capture_test 선례 — 화면
// State 가 임시저장 복원·dispose 흐름을 갖고 있다).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ssentif_coach/core/constants/shadows.dart';
import 'package:ssentif_coach/core/utils/extensions.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/exercise_category.dart';
import 'package:ssentif_coach/domain/enums/exercise_taxonomy.dart';
import 'package:ssentif_coach/domain/enums/measurement_type.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/exercise.dart';
import 'package:ssentif_coach/domain/models/prescription_draft.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/class_recording/class_recording_screen.dart'
    show kCompleteCtaBottomGap, kCompleteCtaReserve, kCompleteCtaSideGap;
import 'package:ssentif_coach/features/prescription/widgets/prescription_editor_header.dart';
import 'package:ssentif_coach/features/prescription/widgets/prescription_exercise_rail.dart';
import 'package:ssentif_coach/features/prescription/widgets/prescription_record_panel.dart';
import 'package:ssentif_coach/providers/class_recording/class_recording_providers.dart';
import 'package:ssentif_coach/providers/members/prescription_editor_provider.dart';
import 'package:ssentif_coach/providers/members/prescription_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

const PrescriptionEditorKey _key = (memberId: 'c-1', recordId: null);
final _date = DateTime(2026, 10, 2);

class _Ws extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => const WorkspaceContext(
    workspaceId: 'ws-1',
    staffId: 'staff-1',
    role: StaffRole.staff,
    defaultMode: CoachMode.coach,
  );
}

PrescriptionSetDraft _w(double w, int r) =>
    PrescriptionSetDraft(weight: w, reps: r);

final _exercises = [
  PrescriptionExerciseDraft(
    key: 'k1',
    exerciseLibraryId: 'lib-1',
    name: '바벨 백스쿼트',
    bodyPart: 'lower_body',
    coachMemo: '무릎이 안쪽으로 모이지 않게',
    sets: padPrescriptionSetRows([
      _w(40, 12),
      _w(50, 10),
      _w(60, 8),
      _w(60, 8),
    ]),
  ),
  PrescriptionExerciseDraft(
    key: 'k2',
    exerciseLibraryId: 'lib-2',
    name: '루마니안 데드리프트',
    bodyPart: 'lower_body',
    sets: padPrescriptionSetRows([_w(30, 12), _w(35, 10), _w(35, 10)]),
  ),
  PrescriptionExerciseDraft(
    key: 'k3',
    exerciseLibraryId: 'lib-3',
    name: '플랭크',
    bodyPart: 'core',
    measurementType: 'duration',
    sets: padPrescriptionSetRows(const [
      PrescriptionSetDraft(durationMinutes: 1),
      PrescriptionSetDraft(durationMinutes: 1),
      PrescriptionSetDraft(durationSeconds: 45),
    ]),
  ),
];

class _Seeded extends PrescriptionEditorNotifier {
  @override
  PrescriptionEditorState build(PrescriptionEditorKey key) {
    super.build(key);
    return PrescriptionEditorState(
      phase: PrescriptionEditorPhase.ready,
      draft: PrescriptionDraft(
        draftId: 'd-1',
        memberId: key.memberId,
        prescribedDate: _date,
        memo: '하체 위주, 무리하지 마세요',
        exercises: _exercises,
      ),
    );
  }
}

final _library = [
  const Exercise(
    id: 'lib-1',
    name: '바벨 백스쿼트',
    category: ExerciseCategory.barbell,
    type: ExerciseType.strength,
    section: ExerciseSection.lowerBody,
    measurementType: MeasurementType.weightReps,
  ),
  const Exercise(
    id: 'lib-2',
    name: '루마니안 데드리프트',
    category: ExerciseCategory.barbell,
    type: ExerciseType.strength,
    section: ExerciseSection.lowerBody,
    measurementType: MeasurementType.weightReps,
  ),
  const Exercise(
    id: 'lib-3',
    name: '플랭크',
    category: ExerciseCategory.bodyweight,
    type: ExerciseType.strength,
    section: ExerciseSection.core,
    measurementType: MeasurementType.duration,
  ),
];

class _Scene extends StatelessWidget {
  const _Scene();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.gnColors.surfaceMain,
      body: SafeArea(
        child: Column(
          children: [
            PrescriptionEditorHeader(
              memberName: '김지훈',
              prescribedDate: _date,
              draftSavedAt: null,
              submitLabel: '처방하기',
              onBack: () {},
              onPickDate: () {},
              onSubmit: () {},
              showSubmitButton: false,
              loading: false,
            ),
            PrescriptionExerciseRail(
              editorKey: _key,
              onAddExercise: () {},
              onOpenList: () {},
            ),
            Expanded(
              child: Stack(
                children: [
                  const Positioned.fill(
                    child: PrescriptionRecordPanel(
                      editorKey: _key,
                      bottomInset: kCompleteCtaReserve,
                    ),
                  ),
                  Positioned(
                    left: kCompleteCtaSideGap,
                    right: kCompleteCtaSideGap,
                    bottom: kCompleteCtaBottomGap,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(Radius.circular(999)),
                        boxShadow: GnShadows.card,
                      ),
                      child: PrescriptionSubmitButton(
                        label: '처방하기',
                        onTap: () {},
                        expanded: true,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
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

  testWidgets('처방 작성 화면 캡처 — 세로 폰', (tester) async {
    var i = 0;
    await captureScreenshot(
      tester,
      child: const _Scene(),
      name: 'grx_01_coach_editor',
      device: ScreenshotDevice.phonePortrait,
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_Ws.new),
        prescriptionClockProvider.overrideWithValue(
          () => DateTime.utc(2026, 10, 2, 3),
        ),
        prescriptionDraftDebounceProvider.overrideWithValue(Duration.zero),
        prescriptionIdGeneratorProvider.overrideWithValue(() => 'id-${i++}'),
        exerciseLibraryProvider.overrideWith((ref) async => _library),
        prescriptionEditorProvider.overrideWith(_Seeded.new),
      ],
    );
  });
}
