-- =============================================
-- inquiries 스팸 차단 규칙 v3 (2026-10-19) — v2까지 실행한 DB에서 실행
-- 바뀐 점: 센터 규모 선택지를 1명~20명(1명 단위) + '20명 이상'으로 교체. 구 값 4개는 기존 문의용으로 계속 허용
-- =============================================

alter table inquiries drop constraint if exists inquiries_center_size_check;

alter table inquiries
  add constraint inquiries_center_size_check
  check (
    center_size is null
    or center_size ~ '^([1-9]|1[0-9]|20)명$'
    or center_size = '20명 이상'
    or center_size in ('1인 (개인 또는 혼자 운영)', '2~5인', '6~10인', '11인 이상 · 다지점')
  ) not valid;
