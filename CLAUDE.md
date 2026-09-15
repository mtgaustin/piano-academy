# 피아노 학원 관리 시스템 - Claude Code 컨텍스트

이 파일은 Claude Code가 프로젝트 전체 배경과 개발 규칙을 파악하기 위한 문서입니다.
Cowork(Claude 데스크탑 앱)에서 수개월간 진행한 개발 이력이 담겨 있습니다.

---

## 프로젝트 기본 정보

- **프로젝트명**: 피아노 학원 관리 시스템
- **GitHub**: mtgaustin/piano-academy
- **배포**: Vercel (GitHub push 시 자동 배포)
- **DB**: Supabase (`src/supabase.js` — URL: `https://uzpduwajpybexzkcyzag.supabase.co`)
- **주요 파일**: `src/App.jsx` (약 15,000+ 줄, 단일 파일 SPA)
- **로컬 개발**: `npm run dev` → localhost:5173 / `localhost:5173/?blank=true` → 데모 모드
- **배포 스크립트**: `git_push.bat` (프로젝트 루트)

---

## 개발자 정보

Austin은 스타트업 창업자이며 코딩 비전공자입니다.
- 코드 수정 결과가 실제로 작동하는지 검증 필수
- 완성도와 데이터 풍부함을 중요시함
- 직설적인 피드백 스타일

---

## 기술 스택

- **Frontend**: React 18 + Vite (JSX)
- **Styling**: Tailwind CSS
- **DB**: Supabase (PostgreSQL)
- **Storage**: localStorage (`useLS` 훅, 키 suffix `6`: `hm_teachers6`, `hm_students6` 등)
- **Auth**: Supabase Auth
- **배포**: Vercel
- **SMS/알림톡**: Solapi REST API (`api/send-sms.js` 서버리스 함수)

---

## 학원명 기준

**기본값/샘플 데이터/fallback 전부: `하모니 피아노 학원`**

- `useLS('hm_academy_name', ...)` 기본값 → `'하모니 피아노 학원'`
- 다른 학원명(예: '프로비 음악학원' 등)을 코드에 하드코딩하면 안 됨
- 사용자가 설정에서 바꿀 수 있으며, 코드는 그 값을 읽어서 표시함

---

## 구현된 섹션 (14개)

1. **대시보드** — 6개 통계 카드, 할 일 카드, 최근 거래 상세 모달
2. **강사 관리** — 등록/수정/삭제, 학력·경력, 급여(`WonInput`), 첨부파일(base64), 담당 과정 복수 선택(`subjects` 배열)
3. **수업 관리** — 등록/수정/삭제, 요일 배열(`days[]`), 강의실, 정원(`CountInput`), 월 수강료, 일정 충돌 검증(`findConflict`)
4. **학생 관리** — 150명, 재원/퇴원 탭 분리, 퇴원/재등록 플로우, 진도 코멘트(`progressNotes`), `enrollmentHistory` 배열
5. **출결 관리** — 학생(type:'student', classId 필수)/강사(type:'teacher') 분리, 수업별 독립 출결, 7,893건
6. **학원비 관리** — 월별 납부/미납/연체, 735건
7. **예산 관리** — 수입/지출 등록, 월별 요약(최근 7개월), PDF 출력
8. **상담 관리** — 신규/체험/등록/종료 상태
9. **보충 수업** — 일정 및 사유
10. **공지 관리** — 공지사항 작성 + SMS/알림톡 일괄 발송
11. **레슨 영상** — 학생별 영상 링크
12. **급여 명세서** — 4대보험 자동 계산 (국민연금 4.5%, 건강보험 3.545%, 고용보험 0.9%, 소득세)
13. **성취도 관리** — 피아노 레벨/콩쿠르 수상
14. **학부모 포털** — 앱 연동 설정

---

## 샘플 데이터 현황 (2026-09까지 확장 완료)

- 강사: 5명 (t1~t5), 수업: 12개 반 (c1~c12), 학생: 150명
- 출결: 7,893건 (2025-10 ~ 2026-09), 수강료: 735건, 수입: 106건, 지출: 126건
- 매월 1일 09:00 KST에 자동으로 새달 데이터 생성하는 스케줄 작업 설정됨 (`piano-academy-monthly-sample-data`)
  - 2026-10-01부터 실제 생성 시작 (07~09월은 이미 채워져 있어 자동 건너뜀)

---

## Phase 3 진행 현황

### 완료된 항목
- **Phase 3-①** ✅ Supabase 로그인/회원가입 UI 구현
- **Phase 3-②** ✅ SMS/알림톡 연동 — Solapi API 키 설정 + 실제 발송 구현

### 미완료 항목 (순서대로 진행)
- **Phase 3-③** 자동 청구 시스템 (월 수강료 자동 청구)
- **Phase 3-④** 결제 연동
- **Phase 3-⑤** 학부모 앱 등원 확인 → 자동 출결

### ⚠️ 중요: 리팩토링 예정
**Phase 3 전체 완료 후** App.jsx (15,000+ 줄)를 파일 분리 리팩토링 예정.
Phase 3 진행 중에는 리팩토링하지 말 것 — 단일 파일 유지.

---

## SMS/알림톡 연동 (Solapi)

### 구조
- **API 서버**: `api/send-sms.js` (Vercel 서버리스 함수)
- **핵심 함수**: `sendSMSAuto(phone, text, msgType)` — App.jsx 최상단에 정의
- **발송 우선순위**: 카카오 알림톡(ATA) → 실패 시 SMS 자동 폴백

### solapiConfig 구조 (localStorage에 저장)
```js
{
  enabled: true/false,
  apiKey: 'SOLAPI_API_KEY',
  apiSecret: 'SOLAPI_SECRET',
  fromPhone: '발신번호',
  kakaoEnabled: true/false,       // 카카오 알림톡 사용 여부
  kakaoChannelId: 'pfId',         // 카카오 채널 ID
  kakaoTplTuition: 'templateId',  // 수강료 납부 확인 템플릿
  kakaoTplNotice: 'templateId',   // 공지/보강/출결 알림 템플릿
}
```

### SMS 발송 트리거 5곳 (모두 구현 완료)
1. **공지사항** (NoticeManagement) — 선택된 학부모에게 일괄 발송
2. **보강 확정** (MakeupManagement) — 보강 일정 확정 시 학부모 알림
3. **출결** (AttendanceManagement) — 결석/지각/조퇴 시 `window.confirm()` 후 발송
4. **일괄 휴강** (confirmBatchMakeup) — 휴강 처리 후 학부모 알림
5. **수강료 납부 확인** (TuitionManagement) — 납부 처리 시 자동 발송

### 컴포넌트 props 패턴
SMS 기능이 있는 컴포넌트는 모두 `solapiConfig`와 `sendSMSAuto`를 props로 받음:
```jsx
<NoticeManagement solapiConfig={solapiConfig} sendSMSAuto={sendSMSAuto} ... />
<MakeupManagement solapiConfig={solapiConfig} sendSMSAuto={sendSMSAuto} ... />
<AttendanceManagement solapiConfig={solapiConfig} sendSMSAuto={sendSMSAuto} ... />
```

### 카카오 알림톡 설정 (미완료)
카카오 알림톡을 실제로 사용하려면:
1. 카카오 비즈니스 채널에서 `검색용 아이디` + `관리자 번호` 확보
2. Solapi에서 카카오 채널 연동
3. 템플릿 생성 및 카카오 승인 (1~2주 소요)
4. 앱 설정 → SMS 알림 → 카카오 알림톡 탭에서 채널ID + 템플릿ID 입력

---

## Claude Code 사용법

### VS Code에서 Remote Control 설정
1. VS Code 터미널에서 `claude` 입력 → Claude Code 실행
2. Claude Code 입력창에 `/remote-control` 입력 → "Enable Remote Control" 선택
3. 모바일 claude.ai 앱 → Code 탭 → 해당 세션 연결

### 모바일에서 연결하는 법
- claude.ai 모바일 앱 → 왼쪽 메뉴 → `piano-academy` 프로젝트 → 활성 세션 선택
- 또는 새로 생성 → 아래 "로컬" 버튼 → "원격 제어" 선택

### ⚠️ 주의사항
- Cowork(Claude 데스크탑)과 Claude Code가 동시에 같은 파일을 수정하면 충돌 발생
- 한 번에 하나의 도구만 사용할 것

---

## 중요 개발 규칙 (반드시 준수)

### 1. 금액 데이터 컨벤션 (1원 단위 랜덤값 절대 금지)

- `수강료` income: `fee × 해당월 재학 학생 수` (fee의 정배수 — 자동으로 깨끗한 값)
- `강사급여` expense: `teachers[].salary`와 정확히 일치 (랜덤 변동 금지, 강사 5명 모두 매달 있어야 함)
- 기타 고정비: 최소 1,000원 단위 반올림

### 2. "오늘 날짜" vs "데이터 최근월" 구분

- **분석/통계 조회 화면** (대시보드, 학원비 관리, 결석경고 집계 등): `new Date()` 사용 금지. 데이터에서 최근 월을 동적으로 계산해서 기본값으로 사용
  ```js
  const latestMonth = [...new Set(data.map(d => d.date.slice(0, 7)))].sort().at(-1)
  ```
- **실시간 기록 화면** (출결 체크, 급여명세서): `new Date()` 사용 정상

### 3. SAMPLE 데이터 필드값 일관성

- `status` 필드: 한글/영어 혼용 절대 금지. 비교 로직(`==='absent'`, `==='paid'`)과 데이터 값이 반드시 일치해야 함
- `description` vs `memo` vs `note`: 수입·지출 → `description`, 학생·이벤트 비고 → `memo`, 출결·학원비·상담 비고 → `note`

### 4. JSX 검증

- HTML/React 파일 수정 후 반드시 JSX 태그 균형 검사 (div/span/button/table 모두)
- SAMPLE 데이터 수정 시 필드명 일관성 확인 (`teacherId`, `days[]`, `refId` 등)

### 5. localStorage 캐시 주의

- `useLS` 훅이 고정 키로 localStorage에 저장 → 앱을 한 번이라도 열었던 브라우저는 코드를 고쳐도 예전 캐시 데이터를 볼 수 있음
- Austin이 "고쳤는데 그대로다"라고 하면 우측 상단 "데이터 초기화" 버튼을 먼저 안내
- SAMPLE 구조 변경(필드 추가/배열 분리 등) 시, 기존 캐시 브라우저를 위한 자동 보정 `useEffect`를 추가할 것
- **중요**: 같은 state를 보정하는 마이그레이션 여러 개는 반드시 **하나의 `useEffect`, 하나의 `setXxx` 호출**로 합쳐야 함 (각자 실행하면 나중 것이 먼저 것을 덮어씀)

### 6. CSS 스크롤 버그 방지

- `html, body { margin: 0; height: 100%; overflow: hidden }` + `#root { height: 100% }` 리셋 필수
- 공유 CSS 클래스(`.modal-box` 등)에 `overflow-y:auto`가 있는 상태에서 내부에 또 `overflow-y-auto`를 넣으면 스크롤 컨테이너 중첩 → `sticky` 헤더 버그 발생

### 7. 입력 검증 컴포넌트 구분

- **`WonInput`**: 원화 입력, blur 시 만원 단위 보정 (자유 타이핑 후 보정 방식)
- **`CountInput`**: 정수 입력, `onChange`에서 즉시 음수/소수 제거 (타이핑 중에도 바로 필터링)
- 두 패턴을 혼동해서 복사하면 버그 재발

### 8. 시간표/캘린더 배치

- 시작~종료가 있는 이벤트는 칸 단위 배치가 아니라 절대 위치(`position:absolute`)로 실제 길이에 비례하게 그릴 것
  ```js
  top = (startMin - baseMin) / 60 * ROW_H
  height = durationMin / 60 * ROW_H
  ```

### 9. 백업 정책

- 위험한 대규모/자동 변환 작업 **직전에만** 새 이름으로 백업 (`App.jsx.bak_taskXX` 등)
- 평소 작은 수정에는 백업하지 않음

---

## 데이터 모델 핵심 필드

```
teachers[]: { id, name, salary, subjects[], career[], attachments[], contractStart, status }
classes[]:  { id, name, teacherId, subject, days[], startTime, endTime, room, maxStudents, fee, openDate }
students[]: { id, name, grade, phone, parentPhone, school, enrolledClasses[], status, enrollmentHistory[], progressNotes[] }
attendance[]: { id, date, type('student'|'teacher'), refId, classId(학생만), status }
tuitions[]:  { id, studentId, classId, month, amount, status, paidDate, payMethod, note }
income[]:    { id, date, category, description, amount }
expenses[]:  { id, date, category, description, amount }
```

---

## 배포 워크플로우

1. `src/App.jsx` 수정
2. `git_push.bat` 실행 → commit message 입력 → 자동으로 GitHub push
3. Vercel이 자동 감지하여 배포 (~1-2분 소요)

---

## 파일 구조 참고

```
piano-academy/
├── src/
│   ├── App.jsx        ← 메인 코드 (15,000+ 줄, 단일 파일)
│   └── supabase.js    ← DB 연결 설정
├── api/
│   └── send-sms.js    ← Solapi SMS/알림톡 서버리스 함수
├── public/
├── CLAUDE.md          ← 이 파일
├── git_push.bat       ← 배포 스크립트
├── package.json
└── vite.config.js
```
