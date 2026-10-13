import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ssentif_coach/data/local/local_storage.dart';

import 'package:ssentif_coach/domain/enums/notice_audience.dart';
import 'package:ssentif_coach/domain/enums/notice_category.dart';
import 'package:ssentif_coach/domain/models/notice.dart';
import 'package:ssentif_coach/features/notices/member_notices_screen.dart';
import 'package:ssentif_coach/providers/notice/notice_providers.dart';

import 'screenshot_harness.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await GnLocalStorage.init();
  });
  testWidgets('회원 공지 목록 화면 캡처 (provider override)', (tester) async {
    // 고정 핀 1건 포함, 카테고리 다양(공지/이벤트/휴무).
    // Repository 정렬(is_pinned DESC → created_at DESC)과 동일 순서로 배치.
    final notices = [
      Notice(
        id: 'n1',
        workspaceId: 'ws1',
        category: NoticeCategory.notice,
        targetAudience: NoticeAudience.members,
        createdById: 'staff1',
        title: '7월 셋째 주 수업 일정 안내',
        content: '다음 주 화요일(7/21) 오전 수업은 센터 내부 점검으로 30분 늦게 시작합니다. '
            '예약하신 회원님들은 변경된 시간을 꼭 확인해주세요.',
        isPinned: true,
        createdAt: DateTime(2026, 7, 13, 9, 30),
      ),
      Notice(
        id: 'n2',
        workspaceId: 'ws1',
        category: NoticeCategory.event,
        targetAudience: NoticeAudience.members,
        createdById: 'staff1',
        title: '여름 바디 챌린지 참가자 모집',
        content: '8주간 진행되는 여름 바디 챌린지! 체성분 측정과 식단 인증을 함께합니다. '
            '참여를 원하시는 분은 수업 시간에 말씀해주세요.',
        createdAt: DateTime(2026, 7, 10, 18, 0),
      ),
      Notice(
        id: 'n3',
        workspaceId: 'ws1',
        category: NoticeCategory.holiday,
        targetAudience: NoticeAudience.members,
        createdById: 'staff1',
        title: '7월 27일(월) 개인 일정으로 휴무',
        content: '해당 날짜 수업은 전 주에 미리 조율해서 진행하겠습니다.',
        createdAt: DateTime(2026, 7, 8, 12, 0),
      ),
    ];

    await captureScreenshot(
      tester,
      child: const MemberNoticesScreen(),
      name: 'member_notices_screen',
      overrides: [
        myMemberNoticesProvider.overrideWith((ref) => Future.value(notices)),
      ],
    );
  });
}
