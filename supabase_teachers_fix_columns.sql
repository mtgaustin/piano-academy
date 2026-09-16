-- ================================================
-- teachers 테이블 컬럼 보정
-- App.jsx의 실제 강사 등록/수정 폼 + 퇴직/휴직 처리 + 강사 로그인 계정
-- 기능이 쓰는 필드들이 기존 supabase_create_tables.sql의 teachers 컬럼에는 없어서
-- (dependents/note/contract_end/employment_type/withholding_rate/children_age8to20/edu/
--  resigned_*/inactive_*/login_id/login_pw 누락) 그대로 저장 시
-- PostgREST가 요청 전체를 거부하는 문제를 막기 위한 보정.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
--
-- 날짜 필드 중 앱에서 빈 문자열('')로 남을 수 있는 것들은 DATE가 아니라 TEXT로 추가함
-- (DATE 컬럼에 빈 문자열을 넣으면 Postgres가 오류를 내기 때문 — contract_start처럼
-- 항상 값이 채워지는 필드만 DATE 유지, 나머지는 TEXT로 안전하게).
-- ================================================

ALTER TABLE teachers ADD COLUMN IF NOT EXISTS dependents INTEGER DEFAULT 1;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS contract_end TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS employment_type TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS withholding_rate INTEGER;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS children_age8to20 INTEGER DEFAULT 0;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS edu JSONB DEFAULT '{}';
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS resigned_at TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS resigned_reason TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS resigned_note TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS inactive_reason TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS inactive_start_date TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS inactive_end_date TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS inactive_note TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS login_id TEXT;
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS login_pw TEXT;
