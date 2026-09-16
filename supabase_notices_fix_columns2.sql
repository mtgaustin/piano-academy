-- ================================================
-- notices 테이블 컬럼 추가 보정 (2차)
-- 공지 발송 기능이 쓰는 sentContacts(발송된 학부모 연락처 목록)/
-- sentDate(발송일) 필드가 기존 컬럼에 없어서 보정.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE notices ADD COLUMN IF NOT EXISTS sent_contacts JSONB DEFAULT '[]';
ALTER TABLE notices ADD COLUMN IF NOT EXISTS sent_date TEXT;
