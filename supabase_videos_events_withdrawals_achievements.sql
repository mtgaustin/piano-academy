-- ================================================
-- videos / events / withdrawals / achievements 보정
-- 4개 테이블이 이미 예전 구조(academy_id TEXT)로 존재하고 있어서
-- CREATE TABLE IF NOT EXISTS가 스킵됨. 누락된 컬럼만 추가하고,
-- RLS 정책은 academy_id가 TEXT이므로 auth.uid()를 text로 캐스팅해서 비교.
-- ================================================

-- 누락 컬럼 보정
ALTER TABLE events ADD COLUMN IF NOT EXISTS note TEXT;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS "_file_name" TEXT;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS "_file_type" TEXT;

-- RLS 활성화
ALTER TABLE videos ENABLE ROW LEVEL SECURITY;
ALTER TABLE events ENABLE ROW LEVEL SECURITY;
ALTER TABLE withdrawals ENABLE ROW LEVEL SECURITY;
ALTER TABLE achievements ENABLE ROW LEVEL SECURITY;

-- 기존 정책 있으면 삭제 (재실행 안전)
DROP POLICY IF EXISTS "academy_videos_select" ON videos;
DROP POLICY IF EXISTS "academy_videos_insert" ON videos;
DROP POLICY IF EXISTS "academy_videos_update" ON videos;
DROP POLICY IF EXISTS "academy_videos_delete" ON videos;
DROP POLICY IF EXISTS "academy_events_select" ON events;
DROP POLICY IF EXISTS "academy_events_insert" ON events;
DROP POLICY IF EXISTS "academy_events_update" ON events;
DROP POLICY IF EXISTS "academy_events_delete" ON events;
DROP POLICY IF EXISTS "academy_withdrawals_select" ON withdrawals;
DROP POLICY IF EXISTS "academy_withdrawals_insert" ON withdrawals;
DROP POLICY IF EXISTS "academy_withdrawals_update" ON withdrawals;
DROP POLICY IF EXISTS "academy_withdrawals_delete" ON withdrawals;
DROP POLICY IF EXISTS "academy_achievements_select" ON achievements;
DROP POLICY IF EXISTS "academy_achievements_insert" ON achievements;
DROP POLICY IF EXISTS "academy_achievements_update" ON achievements;
DROP POLICY IF EXISTS "academy_achievements_delete" ON achievements;

-- 정책 재생성 (academy_id TEXT = auth.uid()::text)
CREATE POLICY "academy_videos_select" ON videos FOR SELECT USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_videos_insert" ON videos FOR INSERT WITH CHECK (academy_id = auth.uid()::text);
CREATE POLICY "academy_videos_update" ON videos FOR UPDATE USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_videos_delete" ON videos FOR DELETE USING (academy_id = auth.uid()::text);

CREATE POLICY "academy_events_select" ON events FOR SELECT USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_events_insert" ON events FOR INSERT WITH CHECK (academy_id = auth.uid()::text);
CREATE POLICY "academy_events_update" ON events FOR UPDATE USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_events_delete" ON events FOR DELETE USING (academy_id = auth.uid()::text);

CREATE POLICY "academy_withdrawals_select" ON withdrawals FOR SELECT USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_withdrawals_insert" ON withdrawals FOR INSERT WITH CHECK (academy_id = auth.uid()::text);
CREATE POLICY "academy_withdrawals_update" ON withdrawals FOR UPDATE USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_withdrawals_delete" ON withdrawals FOR DELETE USING (academy_id = auth.uid()::text);

CREATE POLICY "academy_achievements_select" ON achievements FOR SELECT USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_achievements_insert" ON achievements FOR INSERT WITH CHECK (academy_id = auth.uid()::text);
CREATE POLICY "academy_achievements_update" ON achievements FOR UPDATE USING (academy_id = auth.uid()::text);
CREATE POLICY "academy_achievements_delete" ON achievements FOR DELETE USING (academy_id = auth.uid()::text);

-- 기존 행 중 academy_id가 NULL인 게 있으면 현재 계정으로 채움 (다른 테이블과 동일 패턴)
UPDATE videos SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE events SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE withdrawals SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE achievements SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
