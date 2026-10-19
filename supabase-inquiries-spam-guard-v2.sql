-- =============================================
-- inquiries 스팸 차단 규칙 v2 (2026-10-19) — v1을 이미 실행한 DB에서 실행
-- 바뀐 점: 성함·센터명의 "한글 포함" 조건 제거(영문 이름·영문 상호 허용),
--          연락처 자릿수 상한 11→12 (0507 안심번호 허용)
-- 최종 규칙 전체는 supabase-inquiries-spam-guard.sql 참고
-- =============================================

alter table inquiries drop constraint if exists inquiries_phone_format;
alter table inquiries drop constraint if exists inquiries_name_format;
alter table inquiries drop constraint if exists inquiries_center_name_format;

alter table inquiries
  add constraint inquiries_phone_format
  check (
    phone ~ '^[0-9 -]+$'
    and regexp_replace(phone, '[^0-9]', '', 'g') ~ '^(0[0-9]{8,11}|1[0-9]{7})$'
  ) not valid;

alter table inquiries
  add constraint inquiries_name_format
  check (length(btrim(name)) between 1 and 30) not valid;

alter table inquiries
  add constraint inquiries_center_name_format
  check (length(btrim(center_name)) between 1 and 50) not valid;
