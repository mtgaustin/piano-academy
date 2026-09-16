-- ================================================
-- income/expenses 테이블 컬럼 추가 보정 (2차)
-- BudgetManagement의 save() 함수가 수입/지출 구분 없이 form 전체를
-- 그대로 저장하는 구조라(data={...form,...}), isFixed 필드가 지출 전용임에도
-- 수입(income) 레코드에도 항상 같이 저장 시도됨 → income 테이블에도 필요.
-- 기존 컬럼/데이터/RLS에는 영향 없음 (컬럼 추가만 수행, IF NOT EXISTS라 반복 실행 안전).
-- ================================================

ALTER TABLE income ADD COLUMN IF NOT EXISTS is_fixed BOOLEAN DEFAULT false;
