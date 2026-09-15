-- ================================================
-- 피아노 학원 관리 시스템 - Row Level Security 설정
-- 기존 정책 삭제 후 재생성 (중복 실행 안전)
-- ================================================

-- ================================================
-- RLS 활성화
-- ================================================
ALTER TABLE IF EXISTS academies ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS teachers ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS classes ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS students ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS attendance ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS tuitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS income ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS expenses ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS consultations ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS makeups ENABLE ROW LEVEL SECURITY;
ALTER TABLE IF EXISTS notices ENABLE ROW LEVEL SECURITY;

-- ================================================
-- 기존 정책 전부 삭제 (재실행 시 충돌 방지)
-- ================================================
DO $$ DECLARE
  r RECORD;
BEGIN
  FOR r IN SELECT policyname, tablename FROM pg_policies WHERE schemaname = 'public' LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I', r.policyname, r.tablename);
  END LOOP;
END $$;

-- ================================================
-- 헬퍼 함수
-- ================================================
CREATE OR REPLACE FUNCTION get_my_academy_id()
RETURNS UUID AS $$
  SELECT auth.uid();
$$ LANGUAGE sql SECURITY DEFINER STABLE;

-- ================================================
-- academies 정책
-- ================================================
CREATE POLICY "own_academy_select" ON academies FOR SELECT USING (owner_id = auth.uid());
CREATE POLICY "own_academy_insert" ON academies FOR INSERT WITH CHECK (owner_id = auth.uid());
CREATE POLICY "own_academy_update" ON academies FOR UPDATE USING (owner_id = auth.uid());

-- ================================================
-- teachers 정책
-- ================================================
CREATE POLICY "academy_teachers_select" ON teachers FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_teachers_insert" ON teachers FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_teachers_update" ON teachers FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_teachers_delete" ON teachers FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- classes 정책
-- ================================================
CREATE POLICY "academy_classes_select" ON classes FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_classes_insert" ON classes FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_classes_update" ON classes FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_classes_delete" ON classes FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- students 정책
-- ================================================
CREATE POLICY "academy_students_select" ON students FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_students_insert" ON students FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_students_update" ON students FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_students_delete" ON students FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- attendance 정책
-- ================================================
CREATE POLICY "academy_attendance_select" ON attendance FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_attendance_insert" ON attendance FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_attendance_update" ON attendance FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_attendance_delete" ON attendance FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- tuitions 정책
-- ================================================
CREATE POLICY "academy_tuitions_select" ON tuitions FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_tuitions_insert" ON tuitions FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_tuitions_update" ON tuitions FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_tuitions_delete" ON tuitions FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- income 정책
-- ================================================
CREATE POLICY "academy_income_select" ON income FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_income_insert" ON income FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_income_update" ON income FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_income_delete" ON income FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- expenses 정책
-- ================================================
CREATE POLICY "academy_expenses_select" ON expenses FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_expenses_insert" ON expenses FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_expenses_update" ON expenses FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_expenses_delete" ON expenses FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- consultations 정책
-- ================================================
CREATE POLICY "academy_consultations_select" ON consultations FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_consultations_insert" ON consultations FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_consultations_update" ON consultations FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_consultations_delete" ON consultations FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- makeups 정책
-- ================================================
CREATE POLICY "academy_makeups_select" ON makeups FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_makeups_insert" ON makeups FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_makeups_update" ON makeups FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_makeups_delete" ON makeups FOR DELETE USING (academy_id::text = auth.uid()::text);

-- ================================================
-- notices 정책
-- ================================================
CREATE POLICY "academy_notices_select" ON notices FOR SELECT USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_notices_insert" ON notices FOR INSERT WITH CHECK (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_notices_update" ON notices FOR UPDATE USING (academy_id::text = auth.uid()::text);
CREATE POLICY "academy_notices_delete" ON notices FOR DELETE USING (academy_id::text = auth.uid()::text);
