-- =============================================
-- SSENTIF Supabase 테이블 생성 SQL
-- Supabase 대시보드 → SQL Editor 에 붙여넣고 실행하세요
-- =============================================

-- 1. 상담 문의 테이블
create table if not exists inquiries (
  id            bigint generated always as identity primary key,
  name          text not null,
  role          text,
  phone         text not null,
  email         text,
  center_name   text not null,
  center_size   text,
  plan          text,
  message       text,
  memo          text,                          -- 관리자 메모(백오피스 상세 팝업)
  status        text not null default '신규',  -- 신규 | 검토중 | 완료 | 보류
  submitted_at  timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- 상태값 제약
alter table inquiries
  add constraint inquiries_status_check
  check (status in ('신규', '검토중', '완료', '보류'));

-- updated_at 자동 갱신 트리거
create or replace function set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger inquiries_updated_at
  before update on inquiries
  for each row execute function set_updated_at();

-- RLS: 익명은 INSERT만, 인증된 사용자는 모두
alter table inquiries enable row level security;

create policy "누구나 문의 등록 가능"
  on inquiries for insert
  with check (true);

create policy "관리자만 조회/수정 가능"
  on inquiries for select
  using (auth.role() = 'authenticated');

create policy "관리자만 상태 변경 가능"
  on inquiries for update
  using (auth.role() = 'authenticated');

create policy "관리자만 삭제 가능"
  on inquiries for delete
  using (auth.role() = 'authenticated');


-- =============================================
-- 2. 운영지원실 아티클 테이블
-- =============================================

create table if not exists articles (
  id          bigint generated always as identity primary key,
  title       text not null,
  category    text,
  summary     text,
  content     text,
  thumb_url   text,
  read_time   int,
  published_at date,
  featured    boolean not null default false,
  status      text not null default 'draft',  -- draft | published
  created_at  timestamptz not null default now(),
  updated_at  timestamptz not null default now()
);

alter table articles
  add constraint articles_status_check
  check (status in ('draft', 'published'));

create trigger articles_updated_at
  before update on articles
  for each row execute function set_updated_at();

-- 대표 아티클은 1개만 유지하는 함수
create or replace function enforce_single_featured()
returns trigger language plpgsql as $$
begin
  if new.featured = true then
    update articles set featured = false
    where id <> new.id;
  end if;
  return new;
end;
$$;

create trigger articles_single_featured
  before insert or update on articles
  for each row when (new.featured = true)
  execute function enforce_single_featured();

-- RLS: 발행된 글은 누구나 읽기, 나머지는 인증된 사용자만
alter table articles enable row level security;

create policy "발행된 글은 누구나 읽기"
  on articles for select
  using (status = 'published' or auth.role() = 'authenticated');

create policy "관리자만 작성/수정/삭제"
  on articles for all
  using (auth.role() = 'authenticated');
