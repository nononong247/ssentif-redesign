/// 홈페이지 `guide-migration.html` STEP 03 — 태블릿 사이드바 상단(워크스페이스 로고)을
/// 눌렀을 때 뜨는 워크스페이스 스위처 팝업. 여러 워크스페이스 + 내 계정 섹션이 있는
/// 실제 화면을 캡처한다.
///
/// 원본 보관: ~/ssentif-redesign/_checkpoints/guide-page/capture/
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/domain/enums/coach_mode.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/models/user_profile.dart';
import 'package:ssentif_coach/domain/models/workspace.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/domain/models/workspace_list_item.dart';
import 'package:ssentif_coach/features/workspace_select/widgets/workspace_switcher_popup.dart';
import 'package:ssentif_coach/providers/auth/auth_providers.dart';
import 'package:ssentif_coach/providers/workspace/invitation_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_join_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

class _FakeCurrentUser extends CurrentUser {
  @override
  Future<UserProfile?> build() async => const UserProfile(
    id: 'u1',
    email: 'coach@example.com',
    fullName: '김도현',
    linkCode: 'qmd185tp',
    createdAt: '2026-01-01T00:00:00',
  );
}

class _CurrentWorkspace extends CurrentWorkspaceNotifier {
  @override
  WorkspaceContext? build() => const WorkspaceContext(
    workspaceId: 'ws-1',
    staffId: 'me',
    role: StaffRole.owner,
    defaultMode: CoachMode.admin,
  );
}

WorkspaceListItem _ws(String id, String name, int teamSize) => WorkspaceListItem(
  memberCount: teamSize,
  member: WorkspaceMember(
    id: 'me-$id',
    userId: 'u1',
    workspaceId: id,
    role: StaffRole.owner,
    status: 'active',
    joinedAt: '',
    specialties: const [],
  ),
  workspaceName: name,
  ownerName: '김도현',
);

final _list = [
  _ws('ws-1', '센티프 피트니스 광화문점', 7),
  _ws('ws-2', '센티프 피트니스 한남점', 1),
  _ws('ws-3', '센티프 피트니스 천호점', 1),
  _ws('ws-4', '센티프 피트니스 강남점', 1),
];

void main() {
  testWidgets('워크스페이스 스위처 팝업 (태블릿)', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_switcher_tablet',
      device: ScreenshotDevice.tabletLandscape,
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(_CurrentWorkspace.new),
        workspaceListProvider.overrideWith((ref) async => _list),
        currentUserProvider.overrideWith(_FakeCurrentUser.new),
        pendingInvitationsProvider.overrideWith((ref) async => const []),
        myWorkspaceJoinsProvider.overrideWith((ref) async => const []),
      ],
      child: Builder(
        builder: (context) => Scaffold(
          body: Row(
            children: [
              Container(width: 72, color: Colors.black12),
              Expanded(
                child: Center(
                  child: ElevatedButton(
                    onPressed: () => showWorkspaceSwitcherPopup(context),
                    child: const Text('open'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      interact: (tester) async {
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      },
    );
  });
}
