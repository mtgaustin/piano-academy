-- ================================================
-- teachers/classes/students/tuitions/consultations 테이블에
-- updated_at 컬럼이 없어서 (기존 테이블이 CREATE TABLE IF NOT EXISTS로 인해
-- 예전 구조 그대로 남아있었음) 자동갱신 트리거가 실패하던 문제 해결.
-- 컬럼 추가만 수행 (IF NOT EXISTS라 반복 실행 안전, 기존 데이터 영향 없음).
-- ================================================

ALTER TABLE teachers ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE classes ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE students ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT NOW();

-- created_at도 혹시 없을 수 있으니 같이 보정 (트리거와는 무관하지만 안전차 추가)
ALTER TABLE teachers ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE classes ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE students ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS created_at TIMESTAMPTZ DEFAULT NOW();
