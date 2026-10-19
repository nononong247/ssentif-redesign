-- =============================================
-- inquiries 테이블 스팸 차단 입력 규칙 (2026-10-19)
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 실행하세요
-- consulting.html 의 화면 검사와 같은 기준입니다.
-- `not valid` 를 붙여 이미 들어온 행은 건드리지 않고 새로 들어오는 행부터 검사합니다.
-- =============================================

-- 연락처: 숫자·하이픈·공백만 허용, 숫자는 0으로 시작하는 9~11자리(휴대폰·지역번호)
--         또는 1로 시작하는 8자리(1588 같은 대표번호)
alter table inquiries
  add constraint inquiries_phone_format
  check (
    phone ~ '^[0-9 -]+$'
    and regexp_replace(phone, '[^0-9]', '', 'g') ~ '^(0[0-9]{8,10}|1[0-9]{7})$'
  ) not valid;

-- 성함: 1~30자, 한글(가~힣)이 한 글자 이상 있거나 "John Smith" 처럼 띄어쓰기가 있어야 함
--       → "SwQIDEmJcSOePqzxalKn" 같은 무작위 영문, "ㄱ" 같은 자음 한 글자는 거름
alter table inquiries
  add constraint inquiries_name_format
  check (
    length(btrim(name)) between 1 and 30
    and (name ~ '[가-힣]' or btrim(name) ~ ' ')
  ) not valid;

-- 센터명: 1~50자, 한글이 한 글자 이상 있거나 띄어쓰기가 있어야 함
alter table inquiries
  add constraint inquiries_center_name_format
  check (
    length(btrim(center_name)) between 1 and 50
    and (center_name ~ '[가-힣]' or btrim(center_name) ~ ' ')
  ) not valid;

-- 센터 규모: 폼의 선택지 4개만 허용
alter table inquiries
  add constraint inquiries_center_size_check
  check (
    center_size is null
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
