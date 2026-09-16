-- ================================================
-- attendance 테이블 컬럼 보정
-- 출결 기록에서 쓰는 arrivalTime(등원 시각)/departureTime(하원 시각) 필드가
-- 기존 supabase_create_tables.sql의 attendance 컬럼에는 없어서 보정.
-- <input type="time">의 빈 값은 빈 문자열이라 TEXT로 안전하게 추가.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE attendance ADD COLUMN IF NOT EXISTS arrival_time TEXT;
ALTER TABLE attendance ADD COLUMN IF NOT EXISTS departure_time TEXT;
