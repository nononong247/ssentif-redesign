// Supabase 클라이언트 초기화
// 프로젝트 생성 후 아래 두 값을 교체하세요
const SUPABASE_URL  = 'https://eyjzurevdslukzfkimfg.supabase.co';
const SUPABASE_ANON = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImV5anp1cmV2ZHNsdWt6ZmtpbWZnIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODI2OTIxOTUsImV4cCI6MjA5ODI2ODE5NX0.rdj8s_9g5Mg7KQh4xIogZVfFYKTf2KIUWFXdz-_7jxI';

const { createClient } = supabase;
const db = createClient(SUPABASE_URL, SUPABASE_ANON);
