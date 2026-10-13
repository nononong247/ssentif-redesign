// 사용 가이드용 — 회원 보관/삭제 다이얼로그 · 삭제된 회원 목록.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/member_deletion.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/members/deleted_members_screen.dart';
import 'package:ssentif_coach/features/members/widgets/member_delete_dialog.dart';
import 'package:ssentif_coach/providers/members/member_removal_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

class _Ws extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => const WorkspaceContext(
        workspaceId: 'ws-1',
        staffId: 'staff-1',
        role: StaffRole.owner,
      );
}

final _preview = MemberDeletePreview(
  closingMemberships: [
    ClosingMembership(
      membershipId: 'ms-1',
      name: '개인수업 30회',
      remainingCount: 17,
      totalCount: 30,
      endDate: DateTime(2026, 11, 21),
      pooled: false,
    ),
  ],
  upcomingScheduleCount: 3,
  pendingRequestCount: 0,
  hasOpenPause: false,
  poolParticipant: false,
  canPurge: true,
  alreadyDeleted: false,
);

final _deleted = [
  DeletedMember(
    id: 'd1',
    name: '정하윤',
    phoneLast4: '8890',
    deletedAt: DateTime(2026, 9, 28),
    deletedByName: '박성훈',
    closedMembershipCount: 1,
    assignedCoachName: '이수민',
  ),
  DeletedMember(
    id: 'd2',
    name: '최지우',
    phoneLast4: '2271',
    deletedAt: DateTime(2026, 9, 20),
    deletedByName: '이수민',
    closedMembershipCount: 0,
    assignedCoachName: '이수민',
  ),
];

void main() {
  setUpAll(() => initializeDateFormatting('ko'));

  testWidgets('가이드 — 회원 보관/삭제 다이얼로그', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_member_delete',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_Ws.new),
        memberDeletePreviewProvider('client-1').overrideWith((ref) async => _preview),
      ],
      child: Scaffold(
        body: Center(
          child: Builder(
            builder: (ctx) => FilledButton(
              onPressed: () => showDialog<void>(
                context: ctx,
                builder: (_) => const MemberDeleteDialog(
                  memberId: 'client-1',
                  memberName: '김지훈',
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
      interact: (tester) async {
        await tester.tap(find.text('open'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
      },
    );
  });

  testWidgets('가이드 — 삭제된 회원 목록', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_deleted_members',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_Ws.new),
        deletedMembersProvider.overrideWith((ref) async => _deleted),
      ],
      child: const DeletedMembersScreen(),
    );
  });
}
