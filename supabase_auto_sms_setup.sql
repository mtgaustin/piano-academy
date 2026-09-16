-- ================================================
-- 자동 청구/알림 시스템(Phase 3-③) 준비용 SQL
-- 1) settings 테이블에 academy_id + RLS 추가 (지금은 UNRESTRICTED라 보안 구멍)
-- 2) tuitions 테이블에 알림 중복 발송 방지용 컬럼 추가
-- ================================================

-- settings: academy_id 추가 (다른 신규 테이블들과 동일하게 UUID)
ALTER TABLE settings ADD COLUMN IF NOT EXISTS academy_id UUID;
-- 학원별로 같은 key를 하나씩만 가지도록 유니크 제약 (upsert onConflict용)
CREATE UNIQUE INDEX IF NOT EXISTS settings_academy_key_uidx ON settings(academy_id, key);

ALTER TABLE settings ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "academy_settings_select" ON settings;
DROP POLICY IF EXISTS "academy_settings_insert" ON settings;
DROP POLICY IF EXISTS "academy_settings_update" ON settings;
DROP POLICY IF EXISTS "academy_settings_delete" ON settings;
CREATE POLICY "academy_settings_select" ON settings FOR SELECT USING (academy_id = auth.uid());
CREATE POLICY "academy_settings_insert" ON settings FOR INSERT WITH CHECK (academy_id = auth.uid());
CREATE POLICY "academy_settings_update" ON settings FOR UPDATE USING (academy_id = auth.uid());
CREATE POLICY "academy_settings_delete" ON settings FOR DELETE USING (academy_id = auth.uid());

-- tuitions: 알림 발송 여부 추적 (중복 발송 방지)
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS notified_d7 BOOLEAN DEFAULT false;
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS notified_dday BOOLEAN DEFAULT false;
ALTER TABLE tuitions ADD COLUMN IF NOT EXISTS notified_overdue BOOLEAN DEFAULT false;
