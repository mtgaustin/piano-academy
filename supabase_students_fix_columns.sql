-- ================================================
-- students 테이블 컬럼 보정
-- App.jsx의 실제 학생 데이터 필드(SAMPLE + 등록/수정 폼)와
-- 기존 supabase_create_tables.sql의 students 컬럼이 어긋나서
-- (parent_name/email/note/lesson_schedules/class/level 누락)
-- 그대로 저장 시 PostgREST가 요청 전체를 거부하는 문제를 막기 위한 보정.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE students ADD COLUMN IF NOT EXISTS parent_name TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS email TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE students ADD COLUMN IF NOT EXISTS lesson_schedules JSONB DEFAULT '[]';
ALTER TABLE students ADD COLUMN IF NOT EXISTS class TEXT;   -- 구버전 SAMPLE 데이터에 남아있는 레거시 필드
ALTER TABLE students ADD COLUMN IF NOT EXISTS level TEXT;   -- 구버전 SAMPLE 데이터에 남아있는 레거시 필드
