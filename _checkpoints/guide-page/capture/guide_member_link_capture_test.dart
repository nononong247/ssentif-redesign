/// 홈페이지 `guide-migration.html` §회원 연동 — 코치앱 연동 시트를 **세로 폰**으로 캡처.
///
/// 기존 `assets/guide/12-member-link.png` 은 태블릿 캡처라 가이드 카드 안에서 작게 보인다.
/// 원본 보관: ~/ssentif-redesign/_checkpoints/guide-page/capture/
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ssentif_coach/core/theme/gn_text_styles.dart';
import 'package:ssentif_coach/domain/enums/gender.dart';
import 'package:ssentif_coach/features/members/widgets/member_link_input_sheet.dart';

import 'screenshot_harness.dart';

/// `FilledButton.styleFrom(textStyle:)` 로 넘어간 스타일은 fontFamily 가 null 이라
/// 테스트 렌더에서 한글이 □ 로 찍힌다. 캡처에서만 family 를 박아 넣는다.
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

void main() {
  testWidgets('회원 연동 시트 — 세로 폰', (tester) async {
    await captureScreenshot(
      tester,
      name: 'guide_member_link_phone',
      device: ScreenshotDevice.phonePortrait,
      child: _PretendardButtonText(
        child: Scaffold(
        // 시트만 화면 하단에 붙여 그린다 — barrier 를 따로 트림하지 않아도 된다.
        body: Align(
          alignment: Alignment.bottomCenter,
          child: Material(
            color: Colors.transparent,
            child: MemberLinkInputSheet(
              workspaceId: 'ws-1',
              memberId: 'm-1',
              memberName: '박서연',
              memberPhone: '010-2847-1193',
              memberGender: Gender.female,
              memberAge: 32,
              ),
            ),
          ),
        ),
      ),
    );
  });
}
