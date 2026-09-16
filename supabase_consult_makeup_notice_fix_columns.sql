-- ================================================
-- consultations / makeups / notices 테이블 컬럼 보정
-- 각 관리 화면의 실제 폼이 쓰는 필드들이 기존 supabase_create_tables.sql
-- 컬럼에는 없어서 보정. 기존 컬럼/데이터/RLS에는 영향 없음
-- (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- 빈 문자열이 들어갈 수 있는 날짜성 필드는 DATE 대신 TEXT로 안전하게 추가.
-- ================================================

-- consultations: 상담 관리
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS grade TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS interested_class TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS source TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS source_note TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS trial_date TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS register_date TEXT;
ALTER TABLE consultations ADD COLUMN IF NOT EXISTS assigned_teacher_id TEXT;

-- makeups: 보강 관리
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS student_name TEXT;
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS class_name TEXT;
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS absence_date TEXT;
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS makeup_start_time TEXT;
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS makeup_end_time TEXT;
ALTER TABLE makeups ADD COLUMN IF NOT EXISTS room TEXT;

-- notices: 공지 관리
ALTER TABLE notices ADD COLUMN IF NOT EXISTS date TEXT;
ALTER TABLE notices ADD COLUMN IF NOT EXISTS category TEXT;
ALTER TABLE notices ADD COLUMN IF NOT EXISTS target TEXT;
ALTER TABLE notices ADD COLUMN IF NOT EXISTS important BOOLEAN DEFAULT false;
ALTER TABLE notices ADD COLUMN IF NOT EXISTS poster_img TEXT;
ALTER TABLE notices ADD COLUMN IF NOT EXISTS attachments JSONB DEFAULT '[]';
