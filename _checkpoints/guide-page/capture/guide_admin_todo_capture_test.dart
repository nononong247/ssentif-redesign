// 할 일 목록 화면(TodoListScreen) 스크린샷 캡처.
//
// 실행: flutter test test_screenshots/todo_list_screen_capture_test.dart
// 출력: ~/Downloads/todo_list_screen_{tablet,phone}_{filled,empty,admin,admin_by_item}.png
//
// 본문은 앱바 아래를 채우는 흰 카드 하나 — 좌측 상단 날짜 전환 + 목록, 비면 카드 중앙 빈 상태.
// `admin` 은 맨 아래 '팀원에게 배정한 업무' 섹션(강사 이름 배지)이 선다(앱바 배정 버튼은 2026-09-12 폐기).
// 가로 태블릿은 카드 안이 좌 목록 / 우 상세 2단이다(2026-09-12) — `admin` 은 배정 업무를 골라
// 팀원별 현황, `admin_by_item` 은 항목별 현황 세그먼트까지 누른 장면이다.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:ssentif_coach/data/dto/workspace/workspace_dtos.dart';
import 'package:ssentif_coach/domain/enums/staff_role.dart';
import 'package:ssentif_coach/domain/enums/todo_check_status.dart';
import 'package:ssentif_coach/domain/models/assigned_todo_summary.dart';
import 'package:ssentif_coach/domain/models/staff_todo.dart';
import 'package:ssentif_coach/domain/models/workspace_context.dart';
import 'package:ssentif_coach/features/manager_dashboard/widgets/manager_todo_card.dart';
import 'package:ssentif_coach/providers/todo/todo_providers.dart';
import 'package:ssentif_coach/providers/workspace/workspace_providers.dart';

import 'screenshot_harness.dart';

final _day = DateTime(2026, 9, 11);

class _Ws extends CurrentWorkspaceNotifier {
  _Ws(this.role);

  final StaffRole role;

  @override
  WorkspaceContext? build() =>
      WorkspaceContext(workspaceId: 'ws-1', staffId: 's-me', role: role);
}

class _FixedDate extends SelectedTodoDate {
  @override
  DateTime build() => _day;
}

StaffTodoOccurrence _o(
  String title, {
  DateTime? date,
  int? due,
  TodoCheckStatus status = TodoCheckStatus.todo,
  String? assignerName,
  bool assignedByMe = false,
  List<StaffTodoItem> items = const [],
}) => StaffTodoOccurrence(
  todoId: title,
  occurrenceDate: date ?? _day,
  title: title,
  status: status,
  assignedByMe: assignedByMe,
  assignerName: assignerName,
  assigneeStaffId: 's-me',
  repeatLabel: '',
  editable: assignerName == null,
  dueMinutes: due,
  items: items,
  itemCount: items.length,
  checkedCount: items.where((i) => i.checked).length,
);

final _filled = StaffTodoList(
  date: _day,
  overdue: [_o('주간 회의 자료 확인', date: DateTime(2026, 9, 10))],
  today: [
    _o('김지훈 회원 식단 피드백', due: 10 * 60),
    _o('신규 상담 리포트 정리', due: 14 * 60, assignerName: '김관리'),
    _o('수업 후 기구 정리'),
    _o('락커 키 반납 확인', status: TodoCheckStatus.done),
  ],
);

final _empty = StaffTodoList(date: _day, today: const [], overdue: const []);

List<StaffTodoItem> _items(List<(String, bool)> specs) => [
  for (var i = 0; i < specs.length; i++)
    StaffTodoItem(itemId: 'i-$i-${specs[i].$1}', content: specs[i].$1, checked: specs[i].$2),
];

final _adminMine = StaffTodoList(
  date: _day,
  overdue: const [],
  today: [
    _o(
      '월간 매출 마감 확인',
      due: 11 * 60,
      items: _items([('엑셀 취합', true), ('결재 상신', false)]),
    ),
    _o('신규 강사 면접 준비'),
  ],
);

/// 배정 업무 '마감 청소' 의 강사 기준 회차 — 우측 상세의 담당자 × 항목 표가 이걸 읽는다.
StaffTodoOccurrence _cleanup(String staffId, List<bool> checked) => StaffTodoOccurrence(
  todoId: 'assigned-1',
  occurrenceDate: _day,
  title: '마감 청소',
  status: checked.every((c) => c) ? TodoCheckStatus.done : TodoCheckStatus.todo,
  assignedByMe: false,
  assigneeStaffId: staffId,
  repeatLabel: '',
  editable: false,
  items: _items([('탈의실 정리', checked[0]), ('바닥 청소', checked[1])]),
  itemCount: 2,
  checkedCount: checked.where((c) => c).length,
);

AssignedTodoStaff _staff(String name, List<StaffTodoOccurrence> items, {String role = 'STAFF'}) =>
    AssignedTodoStaff(
      staffId: 's-$name',
      name: name,
      role: role,
      total: items.length,
      done: items.where((i) => i.status.isDone).length,
      items: items,
    );

final _assigned = AssignedTodoSummary(
  total: 4,
  done: 1,
  staff: [
    _staff('박지성', [
      _o('신규 회원 상담 리포트 정리', due: 14 * 60, assignedByMe: true),
      _o('PT 룸 기구 점검', status: TodoCheckStatus.done, assignedByMe: true),
      _cleanup('s-박지성', [true, true]),
    ]),
    _staff('이서연', [
      _o('그룹 수업 출석 확인', due: 10 * 60, assignedByMe: true),
      _cleanup('s-이서연', [true, false]),
    ]),
    _staff('front01', [
      _o('락커 키 반납 확인', assignedByMe: true),
      _cleanup('s-front01', [false, false]),
    ], role: 'FC'),
  ],
  todos: [
    AssignedTodo(
      todoId: 'assigned-1',
      occurrenceDate: _day,
      title: '마감 청소',
      memo: '퇴근 전 마감 체크. 탈의실은 분실물 함까지 확인해 주세요.',
      dueMinutes: 22 * 60,
      repeatLabel: '매일',
      items: _items([('탈의실 정리', false), ('바닥 청소', false)]),
      assignees: [
        const AssignedTodoAssignee(
          staffId: 's-박지성',
          name: '박지성',
          role: 'STAFF',
          status: TodoCheckStatus.done,
          checkedCount: 2,
          itemCount: 2,
        ),
        const AssignedTodoAssignee(
          staffId: 's-이서연',
          name: '이서연',
          role: 'STAFF',
          status: TodoCheckStatus.todo,
          checkedCount: 1,
          itemCount: 2,
        ),
        const AssignedTodoAssignee(
          staffId: 's-front01',
          name: 'front01',
          role: 'FC',
          status: TodoCheckStatus.todo,
          checkedCount: 0,
          itemCount: 2,
        ),
      ],
    ),
  ],
);

typedef _Case = ({StaffRole role, StaffTodoList mine, AssignedTodoSummary assigned});

// 가이드(guide-admin.html "오늘 해야할 업무" 절)용 — 관리자 대시보드 카드 하나만
// 찍는다. 픽스처는 todo_list_screen_capture_test.dart 의 admin 케이스와 같다.
DateTime _todayKey() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

void main() {
  setUpAll(() => initializeDateFormatting('ko'));

  testWidgets('가이드(관리자) — 오늘 해야할 업무 카드', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_admin_todo',
      // 카드가 슬롯 높이를 채우므로 콘텐츠 높이에 맞춘다(빈 흰 여백 방지).
      size: const Size(430, 200),
      overrides: [
        currentWorkspaceNotifierProvider.overrideWith(() => _Ws(StaffRole.admin)),
        selectedTodoDateProvider.overrideWith(_FixedDate.new),
        todayTodosProvider.overrideWith((ref) async => _adminMine),
        assignedTodosProvider(_todayKey()).overrideWith((ref) async => _assigned),
        assignedTodosProvider(_day).overrideWith((ref) async => _assigned),
      ],
      child: const ManagerTodoCard(),
    );
  });
}
