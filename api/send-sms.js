// Vercel Serverless Function — 솔라피 SMS 발송
// POST /api/send-sms
// body: { apiKey, apiSecret, from, to, text }

export default async function handler(req, res) {
  // CORS 허용
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { apiKey, apiSecret, from, to, text } = req.body || {};
  if (!apiKey || !apiSecret || !from || !to || !text) {
    return res.status(400).json({ error: '필수 파라미터 누락 (apiKey, apiSecret, from, to, text)' });
  }

  try {
    const { SolapiMessageService } = await import('solapi');
    const messageService = new SolapiMessageService(apiKey, apiSecret);
    const result = await messageService.send({ to, from, text });
    return res.status(200).json({ success: true, result });
  } catch (e) {
    return res.status(500).json({ success: false, error: e.message || '발송 실패' });
  }
}
