// Vercel Cron Job — 수강료 납부 자동 알림 (매일 1회 실행)
// - 납부기한 7일 전 / 당일 / 연체 시작 시점(1회만) 학부모에게 SMS·알림톡 발송
// - 서비스 롤 키로 RLS를 우회해 전체 학원 데이터를 순회함
// GET /api/cron-sms?dryRun=true  ← 실제 발송 없이 대상만 확인 (테스트용)
// 인증: Vercel Cron이 자동으로 붙이는 Authorization: Bearer <CRON_SECRET> 헤더
//       또는 수동 테스트 시 ?secret=<CRON_SECRET> 쿼리 파라미터

import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = 'https://uzpduwajpybexzkcyzag.supabase.co';

function isAuthorized(req) {
  const secret = process.env.CRON_SECRET;
  if (!secret) return true; // CRON_SECRET 미설정 시 통과 (설정 강력 권장)
  const authHeader = req.headers['authorization'];
  if (authHeader === `Bearer ${secret}`) return true;
  if (req.query?.secret === secret) return true;
  return false;
}

async function sendViaSolapi(cfg, toPhone, text, msgType) {
  const { SolapiMessageService } = await import('solapi');
  const messageService = new SolapiMessageService(cfg.apiKey, cfg.apiSecret);
  const cleanTo = (toPhone || '').replace(/[^0-9]/g, '');
  const cleanFrom = (cfg.fromPhone || '').replace(/[^0-9]/g, '');
  if (!cleanTo) return { ok: false, reason: '연락처 없음' };

  if (cfg.kakaoEnabled && cfg.kakaoChannelId) {
    const tplId = msgType === 'tuition' ? cfg.kakaoTplTuition : cfg.kakaoTplNotice;
    if (tplId) {
      try {
        await messageService.send({
          to: cleanTo, from: cleanFrom,
          kakaoOptions: { pfId: cfg.kakaoChannelId, templateId: tplId, variables: { '#{내용}': text } },
        });
        return { ok: true, via: 'alimtalk' };
      } catch (e) { /* 알림톡 실패 시 SMS로 폴백 */ }
    }
  }
  try {
    await messageService.send({ to: cleanTo, from: cleanFrom, text });
    return { ok: true, via: 'sms' };
  } catch (e) {
    return { ok: false, reason: e.message || '발송 실패' };
  }
}

const fWon = n => `${Number(n || 0).toLocaleString('ko-KR')}원`;

function buildMessage(kind, academyName, student, tuition) {
  const name = academyName || '학원';
  const who = `${student.name} 학생`;
  const amt = fWon(tuition.amount);
  const month = tuition.month;
  if (kind === 'd7') {
    return `[${name}] ${who} ${month} 수강료 ${amt} 납부기한이 7일 남았습니다 (${tuition.due_date}까지). 확인 부탁드립니다.`;
  }
  if (kind === 'dday') {
    return `[${name}] ${who} ${month} 수강료 ${amt} 납부기한이 오늘(${tuition.due_date})까지입니다. 납부 부탁드립니다.`;
  }
  return `[${name}] ${who} ${month} 수강료 ${amt}가 미납 상태입니다 (납부기한 ${tuition.due_date}). 빠른 시일 내 납부 부탁드립니다.`;
}

export default async function handler(req, res) {
  if (!isAuthorized(req)) return res.status(401).json({ error: 'Unauthorized' });

  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!serviceKey) return res.status(500).json({ error: 'SUPABASE_SERVICE_ROLE_KEY 환경변수가 설정되지 않았습니다' });

  const dryRun = req.query?.dryRun === 'true';
  const admin = createClient(SUPABASE_URL, serviceKey);

  const now = new Date();
  const toYMD = d => d.toISOString().split('T')[0];
  const todayStr = toYMD(now);
  const d7Date = new Date(now); d7Date.setDate(d7Date.getDate() + 7);
  const d7Str = toYMD(d7Date);

  const { data: settingsRows, error: settingsErr } = await admin
    .from('settings').select('academy_id, value').eq('key', 'solapi_config');
  if (settingsErr) return res.status(500).json({ error: settingsErr.message });

  const { data: nameRows } = await admin
    .from('settings').select('academy_id, value').eq('key', 'academy_name');
  const nameByAcademy = {};
  (nameRows || []).forEach(r => { nameByAcademy[r.academy_id] = r.value; });

  const results = [];

  for (const row of settingsRows || []) {
    const cfg = row.value;
    const academyId = row.academy_id;
    // dryRun은 꺼져있어도(enabled:false) "만약 켜져있다면" 미리보기를 보여줌 — 실제 발송(dryRun 아님)만 활성화 여부를 엄격히 확인
    if (!dryRun && (!cfg?.enabled || !cfg?.apiKey || !cfg?.apiSecret || !cfg?.fromPhone)) continue;

    const { data: tuitions, error: tErr } = await admin
      .from('tuitions').select('*').eq('academy_id', academyId).eq('status', 'unpaid');
    if (tErr) { results.push({ academyId, error: tErr.message }); continue; }

    for (const t of tuitions || []) {
      if (!t.due_date) continue;
      let kind = null;
      if (t.due_date === d7Str && !t.notified_d7) kind = 'd7';
      else if (t.due_date === todayStr && !t.notified_dday) kind = 'dday';
      else if (t.due_date < todayStr && !t.notified_overdue) kind = 'overdue';
      if (!kind) continue;

      const { data: student } = await admin
        .from('students').select('*').eq('id', t.student_id).eq('academy_id', academyId).maybeSingle();
      if (!student) continue;

      const isAdult = student.grade === '성인';
      const toPhone = isAdult ? student.phone : student.parent_phone;
      if (!toPhone) { results.push({ studentId: t.student_id, kind, skipped: '연락처 없음' }); continue; }

      const academyName = nameByAcademy[academyId] || '학원';
      const text = buildMessage(kind, academyName, student, t);

      if (dryRun) {
        results.push({ academyId, studentId: t.student_id, studentName: student.name, kind, toPhone, text, dryRun: true, currentlyEnabled: !!cfg?.enabled });
        continue;
      }

      const sendResult = await sendViaSolapi(cfg, toPhone, text, 'tuition');
      if (sendResult.ok) {
        const field = kind === 'd7' ? 'notified_d7' : kind === 'dday' ? 'notified_dday' : 'notified_overdue';
        const patch = { [field]: true };
        if (kind === 'overdue') patch.status = 'overdue';
        await admin.from('tuitions').update(patch).eq('id', t.id);
      }
      results.push({ academyId, studentId: t.student_id, studentName: student.name, kind, ...sendResult });
    }
  }

  return res.status(200).json({ ok: true, dryRun, count: results.length, results });
}
