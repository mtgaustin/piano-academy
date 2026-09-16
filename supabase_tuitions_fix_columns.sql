-- ================================================
-- tuitions 테이블 컬럼 보정
-- 학원비 등록/수정 폼과 자동 생성 로직이 쓰는 studentName/isProrated/baseFee/
-- textbookFee 필드가 기존 supabase_create_tables.sql의 tuitions 컬럼에는 없어서
-- (특히 is_prorated 누락으로 브라우저 콘솔에 400 에러 발생 중) 보정.
-- textbook_fee는 폼 기본값이 빈 문자열('')이라 숫자형 컬럼에 넣으면 Postgres 오류가
-- 나므로 TEXT로 안전하게 추가.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS student_name TEXT;
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS is_prorated BOOLEAN DEFAULT false;
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS base_fee INTEGER;
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS textbook_fee TEXT;
