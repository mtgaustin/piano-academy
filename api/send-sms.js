// Vercel Serverless Function — 솔라피 SMS / 카카오 알림톡 발송
// POST /api/send-sms
// body: { apiKey, apiSecret, from, to, text, type?, kakaoOptions? }
// type: 'SMS'(기본) | 'ATA'(카카오 알림톡)
// kakaoOptions: { pfId, templateId, variables }

export default async function handler(req, res) {
  // CORS 허용
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');
  if (req.method === 'OPTIONS') return res.status(200).end();
  if (req.method !== 'POST') return res.status(405).json({ error: 'Method not allowed' });

  const { apiKey, apiSecret, from, to, text, type = 'SMS', kakaoOptions } = req.body || {};
  if (!apiKey || !apiSecret || !from || !to) {
    return res.status(400).json({ error: '필수 파라미터 누락 (apiKey, apiSecret, from, to)' });
  }

  try {
    const { SolapiMessageService } = await import('solapi');
    const messageService = new SolapiMessageService(apiKey, apiSecret);

    let result;

    if (type === 'ATA' && kakaoOptions?.pfId && kakaoOptions?.templateId) {
      // 카카오 알림톡 발송
      result = await messageService.send({
        to,
        from,
        kakaoOptions: {
          pfId: kakaoOptions.pfId,
          templateId: kakaoOptions.templateId,
          variables: kakaoOptions.variables || {},
        },
      });
    } else {
      // SMS 발송 (기본)
      if (!text) return res.status(400).json({ error: 'SMS 발송 시 text 필수' });
      result = await messageService.send({ to, from, text });
    }

    return res.status(200).json({ success: true, type, result });
  } catch (e) {
    return res.status(500).json({ success: false, error: e.message || '발송 실패' });
  }
}
