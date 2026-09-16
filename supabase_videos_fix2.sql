-- ================================================
-- videos 테이블 컬럼 추가 보정 (2차)
-- 선생님 코멘트/학부모 발송 기능이 쓰는 필드들이 누락되어 있었음.
-- ================================================

ALTER TABLE videos ADD COLUMN IF NOT EXISTS teacher_comment TEXT;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS comment_date TEXT;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS comment_teacher TEXT;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS sent_to_parent BOOLEAN DEFAULT false;
ALTER TABLE videos ADD COLUMN IF NOT EXISTS sent_date TEXT;
