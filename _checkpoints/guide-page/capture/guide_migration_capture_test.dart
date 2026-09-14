/// 홈페이지 `guide-migration.html`(센티프 1.0 → 2.0 이전 안내) 전용 캡처.
///
/// 마법사 4단계 중 **본인 확인**과 **회원 선택** 두 화면을 실제 위젯으로 뽑는다.
/// 나머지(설정 진입·메뉴·완료)는 앱에 이미 캡처 테스트가 있어 그것을 쓴다.
///
/// 원본 보관: ~/ssentif-redesign/_checkpoints/guide-page/capture/
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/core/theme/gn_text_styles.dart';
import 'package:ssentif_coach/domain/business_logic/v1_import_wizard.dart';
import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/v1_migration.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/v1_import/v1_import_screen.dart';
import 'package:ssentif_coach/providers/v1_migration/v1_import_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

// ---------------------------------------------------------------------------
// 고정 데이터
// ---------------------------------------------------------------------------

final _workspace = Workspace(
  id: 'ws-1',
  name: '스트롱짐 강남점',
  ownerUserId: 'u-1',
  status: 'active',
  createdAt: DateTime(2026, 1, 1).toIso8601String(),
);

class _Workspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => const WorkspaceContext(
    workspaceId: 'ws-1',
    staffId: 'me',
    role: StaffRole.owner,
    defaultMode: CoachMode.coach,
  );
}

const _identity = V1TrainerIdentity(
  legacyTrainerId: 4821,
  name: '김도현',
  maskedEmail: 'do****@naver.com',
  workplaceName: '스트롱짐 강남점',
);

/// 회원 선택 화면용 후보. 숫자는 화면이 실제로 읽는 필드만 채운다 —
/// 0 으로 두면 카드에 요약 줄이 서지 않아 빈 카드처럼 보인다.
V1ClientCandidate _c(
  int id,
  String name, {
  String? phone,
  bool centerCreated = false,
  int vouchers = 0,
  int amount = 0,
  int schedules = 0,
  int logs = 0,
  int diets = 0,
  int exercises = 0,
  int bodyComps = 0,
  int bodyPhotos = 0,
}) => V1ClientCandidate(
  legacyClientId: id,
  name: name,
  phone: phone,
  centerCreated: centerCreated,
  dependentVoucherCount: vouchers,
  dependentVoucherAmount: amount,
  dependentScheduleCount: schedules,
  dependentSessionLogCount: logs,
  dependentDietCount: diets,
  dependentExerciseCount: exercises,
  dependentBodyCompositionCount: bodyComps,
  dependentBodyPhotoCount: bodyPhotos,
);

final _preview = V1MigrationPreview(
  snapshotCutoffAt: DateTime(2026, 9, 14, 13, 44),
  clients: [
    _c(
      101,
      '박서연',
      phone: '010-2847-1193',
      vouchers: 2,
      amount: 1840000,
      schedules: 34,
      logs: 31,
      diets: 96,
      exercises: 48,
      bodyComps: 6,
      bodyPhotos: 9,
    ),
    _c(
      102,
      '이준호',
      phone: '010-5512-8840',
      vouchers: 1,
      amount: 960000,
      schedules: 18,
      logs: 16,
      diets: 24,
      exercises: 22,
      bodyComps: 3,
    ),
    _c(
      103,
      '최민아',
      phone: '010-3390-7725',
      vouchers: 1,
      amount: 1200000,
      schedules: 22,
      logs: 20,
      diets: 51,
      exercises: 30,
      bodyComps: 4,
      bodyPhotos: 3,
    ),
    _c(104, '정하늘', centerCreated: true, schedules: 4, logs: 3, exercises: 5),
  ],
);

// ---------------------------------------------------------------------------
// 서버를 부르지 않는 notifier — 상태만 들고 있는다
// ---------------------------------------------------------------------------

class _FixedNotifier extends V1ImportNotifier {
  _FixedNotifier(super.ref, V1ImportState initial) {
    state = initial;
  }

  // 화면 initState 가 부른다. 실제 구현은 서버를 왕복하므로 여기서 끊는다.
  @override
  Future<void> restoreForWorkspace(String workspaceId) async {}
}

/// `TextButton.styleFrom(textStyle:)` 로 넘어간 스타일은 fontFamily 가 null 이라
/// 테스트 렌더에서 한글이 □ 로 찍힌다(별칭으로 안 잡힌다 — 하네스 알려진 제약).
/// 캡처에서만 family 를 박아 넣는다. 앱 코드는 건드리지 않는다.
class _PretendardButtonText extends StatelessWidget {
  const _PretendardButtonText({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final styles = theme.extension<GnTextStyles>()!;
    final exts = theme.extensions.values.toList()
      ..removeWhere((e) => e is GnTextStyles)
      ..add(
        styles.copyWith(
          button: styles.button.copyWith(fontFamily: 'Pretendard'),
        ),
      );
    return Theme(data: theme.copyWith(extensions: exts), child: child);
  }
}

List<Override> _overrides(V1ImportState initial) => [
  currentWorkspaceNotifierProvider.overrideWith(_Workspace.new),
  currentWorkspaceInfoProvider.overrideWith((ref) async => _workspace),
  v1LinkCandidatesProvider.overrideWith((ref) async => const []),
  v1ImportNotifierProvider.overrideWith((ref) => _FixedNotifier(ref, initial)),
];

void main() {
  // STEP 5 — 본인 확인(1.0 이메일 입력 후 계정을 찾은 상태)
  testWidgets('v1 import — 본인 확인', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_migration_05_identity',
      device: ScreenshotDevice.phonePortrait,
      overrides: _overrides(
        const V1ImportState(
          step: V1ImportStep.identity,
          email: 'dohyun.k@naver.com',
          identity: _identity,
        ),
      ),
      child: const _PretendardButtonText(child: V1ImportScreen()),
    );
  });

  // STEP 6 — 가져올 회원 선택
  testWidgets('v1 import — 회원 선택', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_migration_06_members',
      device: ScreenshotDevice.phonePortrait,
      overrides: _overrides(
        V1ImportState(
          step: V1ImportStep.members,
          email: 'dohyun.k@naver.com',
          identity: _identity,
          targetWorkspaceId: 'ws-1',
          jobId: 'job-1',
          preview: _preview,
          decisions: const {
            101: V1ClientDecision.createNew,
            102: V1ClientDecision.createNew,
            103: V1ClientDecision.createNew,
            104: V1ClientDecision.exclude,
          },
        ),
      ),
      child: const _PretendardButtonText(child: V1ImportScreen()),
    );
  });
}
