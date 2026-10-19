-- =============================================
-- inquiries 테이블 스팸 차단 입력 규칙 (2026-10-19)
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 실행하세요
-- consulting.html 의 화면 검사와 같은 기준입니다.
-- `not valid` 를 붙여 이미 들어온 행은 건드리지 않고 새로 들어오는 행부터 검사합니다.
-- =============================================

-- 연락처: 숫자·하이픈·공백만 허용(폼이 010-1234-5678 꼴로 정리해서 보냄),
--         숫자는 0으로 시작하는 9~12자리(휴대폰·지역번호·안심번호) 또는 1로 시작하는 8자리(대표번호)
--         → 지금까지 들어온 스팸은 전부 이 규칙 하나로 걸림
alter table inquiries
  add constraint inquiries_phone_format
  check (
    phone ~ '^[0-9 -]+$'
    and regexp_replace(phone, '[^0-9]', '', 'g') ~ '^(0[0-9]{8,11}|1[0-9]{7})$'
  ) not valid;

-- 성함: 1~30자 (영문 이름도 허용 — 한글 강제는 2026-10-19 v2에서 제거)
alter table inquiries
  add constraint inquiries_name_format
  check (length(btrim(name)) between 1 and 30) not valid;

-- 센터명: 1~50자 (FITZONE 같은 영문 상호 허용)
alter table inquiries
  add constraint inquiries_center_name_format
  check (length(btrim(center_name)) between 1 and 50) not valid;

-- 센터 규모: 1명~20명(1명 단위) + '20명 이상'(2026-10-19 v3) + 구 선택지 4개(기존 문의 상태 변경 시 걸리지 않도록)
alter table inquiries
  add constraint inquiries_center_size_check
  check (
    center_size is null
    or center_size ~ '^([1-9]|1[0-9]|20)명$'
    or center_size = '20명 이상'
    or center_size in ('1인 (개인 또는 혼자 운영)', '2~5인', '6~10인', '11인 이상 · 다지점')
  ) not valid;

-- 이메일: 비어 있거나 이메일 형식, 100자 이하
alter table inquiries
  add constraint inquiries_email_format
  check (
    email is null or email = ''
    or (length(email) <= 100 and email ~ '^[^[:space:]@]+@[^[:space:]@]+\.[^[:space:]@]+$')
  ) not valid;

-- 길이 상한: 직함 30자, 문의내용 2000자
alter table inquiries
  add constraint inquiries_length_limits
  check (
    (role is null or length(role) <= 30)
    and (message is null or length(message) <= 2000)
  ) not valid;

-- 되돌리기 (필요 시)
-- alter table inquiries drop constraint inquiries_phone_format;
-- alter table inquiries drop constraint inquiries_name_format;
-- alter table inquiries drop constraint inquiries_center_name_format;
-- alter table inquiries drop constraint inquiries_center_size_check;
-- alter table inquiries drop constraint inquiries_email_format;
-- alter table inquiries drop constraint inquiries_length_limits;
