-- ================================================
-- 기존에 SQL로 직접 넣어진 샘플 데이터의 academy_id가 NULL로 남아있어
-- RLS 정책(academy_id = 내 계정)에 안 걸려서 수정이 막히는 문제 해결.
-- 학원이 현재 1곳(계정 1개)뿐이므로, NULL인 행을 전부 그 계정 소유로 채운다.
-- updated_at 자동갱신 트리거가 원인 모를 오류를 일으켜서, 업데이트 하는 동안만
-- 잠깐 꺼뒀다가 다시 켠다 (트리거 자체는 그대로 유지됨, 이 스크립트 실행 중에만 비활성화).
-- ================================================

ALTER TABLE teachers DISABLE TRIGGER teachers_updated_at;
ALTER TABLE classes DISABLE TRIGGER classes_updated_at;
ALTER TABLE students DISABLE TRIGGER students_updated_at;
ALTER TABLE tuitions DISABLE TRIGGER tuitions_updated_at;
ALTER TABLE consultations DISABLE TRIGGER consultations_updated_at;

UPDATE students  SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE teachers  SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE classes   SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE attendance SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE tuitions  SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE income    SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE expenses  SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE consultations SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE makeups   SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;
UPDATE notices   SET academy_id = '5ba14738-8a02-42dd-b508-12952e263f5c' WHERE academy_id IS NULL;

ALTER TABLE teachers ENABLE TRIGGER teachers_updated_at;
ALTER TABLE classes ENABLE TRIGGER classes_updated_at;
ALTER TABLE students ENABLE TRIGGER students_updated_at;
ALTER TABLE tuitions ENABLE TRIGGER tuitions_updated_at;
ALTER TABLE consultations ENABLE TRIGGER consultations_updated_at;

-- 확인용: 전부 채워졌는지 체크 (0행이 나와야 정상)
SELECT 'students' AS tbl, count(*) FROM students WHERE academy_id IS NULL
UNION ALL SELECT 'teachers', count(*) FROM teachers WHERE academy_id IS NULL
UNION ALL SELECT 'classes', count(*) FROM classes WHERE academy_id IS NULL
UNION ALL SELECT 'attendance', count(*) FROM attendance WHERE academy_id IS NULL
UNION ALL SELECT 'tuitions', count(*) FROM tuitions WHERE academy_id IS NULL
UNION ALL SELECT 'income', count(*) FROM income WHERE academy_id IS NULL
UNION ALL SELECT 'expenses', count(*) FROM expenses WHERE academy_id IS NULL
UNION ALL SELECT 'consultations', count(*) FROM consultations WHERE academy_id IS NULL
UNION ALL SELECT 'makeups', count(*) FROM makeups WHERE academy_id IS NULL
UNION ALL SELECT 'notices', count(*) FROM notices WHERE academy_id IS NULL;
