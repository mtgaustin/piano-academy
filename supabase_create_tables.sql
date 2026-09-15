-- ================================================
-- 피아노 학원 관리 시스템 - Supabase 테이블 생성
-- 다중 학원 SaaS 구조 (academy_id 기반 RLS)
-- ================================================

-- UUID 확장 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ================================================
-- 1. 학원 (academies)
-- ================================================
CREATE TABLE IF NOT EXISTS academies (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  owner_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL DEFAULT '하모니 피아노 학원',
  phone TEXT,
  address TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 2. 강사 (teachers)
-- ================================================
CREATE TABLE IF NOT EXISTS teachers (
  id TEXT PRIMARY KEY,  -- 기존 t1, t2, t3... 형식 유지
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,  -- auth.uid() 직접 사용
  name TEXT NOT NULL,
  phone TEXT,
  email TEXT,
  salary INTEGER DEFAULT 0,
  subjects JSONB DEFAULT '[]',        -- 담당 과목 배열
  career JSONB DEFAULT '[]',          -- 경력 배열
  attachments JSONB DEFAULT '[]',     -- 첨부파일 (base64) 배열
  contract_start DATE,
  status TEXT DEFAULT 'active',       -- 'active' | 'inactive'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 3. 수업 (classes)
-- ================================================
CREATE TABLE IF NOT EXISTS classes (
  id TEXT PRIMARY KEY,  -- 기존 c1, c2... 형식 유지
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  teacher_id TEXT REFERENCES teachers(id),
  subject TEXT,
  days JSONB DEFAULT '[]',           -- 요일 배열 ['mon','wed','fri']
  start_time TEXT,                   -- 'HH:MM' 형식
  end_time TEXT,
  room TEXT,
  max_students INTEGER DEFAULT 10,
  fee INTEGER DEFAULT 0,             -- 월 수강료
  open_date DATE,
  status TEXT DEFAULT 'active',
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 4. 학생 (students)
-- ================================================
CREATE TABLE IF NOT EXISTS students (
  id TEXT PRIMARY KEY,  -- 기존 s1, s2... 형식 유지
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  grade TEXT,
  phone TEXT,
  parent_phone TEXT,
  school TEXT,
  enrolled_classes JSONB DEFAULT '[]',    -- 수강 중인 수업 ID 배열
  status TEXT DEFAULT 'active',           -- 'active' | 'inactive'
  enrollment_history JSONB DEFAULT '[]',  -- 등록/퇴원 이력
  progress_notes JSONB DEFAULT '[]',      -- 진도 노트
  join_date DATE,
  leave_date DATE,
  memo TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 5. 출결 (attendance)
-- ================================================
CREATE TABLE IF NOT EXISTS attendance (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  type TEXT NOT NULL,           -- 'student' | 'teacher'
  ref_id TEXT NOT NULL,         -- student.id 또는 teacher.id
  class_id TEXT,                -- 학생 출결일 경우 필수 (REFERENCES classes(id))
  status TEXT NOT NULL,         -- 'present' | 'absent' | 'late' | 'early_leave'
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_attendance_academy_date ON attendance(academy_id, date);
CREATE INDEX IF NOT EXISTS idx_attendance_ref_id ON attendance(ref_id);
CREATE INDEX IF NOT EXISTS idx_attendance_class_id ON attendance(class_id);

-- ================================================
-- 6. 수강료 (tuitions)
-- ================================================
CREATE TABLE IF NOT EXISTS tuitions (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  student_id TEXT REFERENCES students(id),
  class_id TEXT REFERENCES classes(id),
  month TEXT NOT NULL,          -- 'YYYY-MM' 형식
  amount INTEGER NOT NULL DEFAULT 0,
  status TEXT DEFAULT 'unpaid', -- 'paid' | 'unpaid' | 'overdue'
  paid_date DATE,
  pay_method TEXT,              -- '현금' | '계좌이체' | '카드'
  due_date DATE,                -- 납부 예정일 (자동 SMS 발송 기준)
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tuitions_academy_month ON tuitions(academy_id, month);
CREATE INDEX IF NOT EXISTS idx_tuitions_student_id ON tuitions(student_id);
CREATE INDEX IF NOT EXISTS idx_tuitions_status ON tuitions(status);
CREATE INDEX IF NOT EXISTS idx_tuitions_due_date ON tuitions(due_date);

-- ================================================
-- 7. 수입 (income)
-- ================================================
CREATE TABLE IF NOT EXISTS income (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  category TEXT,
  description TEXT,
  amount INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_income_academy_date ON income(academy_id, date);

-- ================================================
-- 8. 지출 (expenses)
-- ================================================
CREATE TABLE IF NOT EXISTS expenses (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  date DATE NOT NULL,
  category TEXT,
  description TEXT,
  amount INTEGER NOT NULL DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_expenses_academy_date ON expenses(academy_id, date);

-- ================================================
-- 9. 상담 (consultations)
-- ================================================
CREATE TABLE IF NOT EXISTS consultations (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  name TEXT NOT NULL,
  phone TEXT,
  subject TEXT,
  status TEXT DEFAULT 'new',    -- 'new' | 'trial' | 'enrolled' | 'closed'
  date DATE,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 10. 보강 (makeups)
-- ================================================
CREATE TABLE IF NOT EXISTS makeups (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  student_id TEXT REFERENCES students(id),
  class_id TEXT REFERENCES classes(id),
  original_date DATE,
  makeup_date DATE,
  status TEXT DEFAULT 'pending', -- 'pending' | 'confirmed' | 'completed'
  reason TEXT,
  note TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- 11. 공지 (notices)
-- ================================================
CREATE TABLE IF NOT EXISTS notices (
  id TEXT PRIMARY KEY,
  academy_id UUID REFERENCES auth.users(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  content TEXT,
  target_classes JSONB DEFAULT '[]',  -- 대상 수업 ID 배열
  sms_sent BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- ================================================
-- updated_at 자동 갱신 트리거
-- ================================================
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER teachers_updated_at BEFORE UPDATE ON teachers
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER classes_updated_at BEFORE UPDATE ON classes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER students_updated_at BEFORE UPDATE ON students
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER tuitions_updated_at BEFORE UPDATE ON tuitions
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

CREATE TRIGGER consultations_updated_at BEFORE UPDATE ON consultations
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
