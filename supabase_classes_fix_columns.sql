-- ================================================
-- classes 테이블 컬럼 보정
-- App.jsx의 수업 등록/수정 폼이 쓰는 closeDate(폐강/휴강일) 필드가
-- 기존 supabase_create_tables.sql의 classes 컬럼에는 없어서 보정.
-- 빈 문자열('')이 들어갈 수 있어 DATE 대신 TEXT로 추가 (Postgres 오류 방지).
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE classes ADD COLUMN IF NOT EXISTS close_date TEXT;
