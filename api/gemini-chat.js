import { GoogleGenerativeAI } from '@google/generative-ai';

// Initialize Gemini
const genAI = new GoogleGenerativeAI(process.env.GEMINI_API_KEY || '');

// Build prompt
function buildPrompt({ role, userName, message, history }) {
  const intro =
    `You are an AI assistant inside a Flutter travel planner application. ` +
    `Respond concisely and helpfully for a ${role || 'user'}. ` +
    `Focus on travel packages, bookings, destinations, admin operations. ` +
    `User name: ${userName || 'Unknown'}. ` +
    `Respond in plain text only. Do NOT use markdown, asterisks (*), or any special formatting symbols.`;

  const conversation = (history || [])
    .slice(-8)
    .map((e) => `${e.role || 'user'}: ${e.message || ''}`)
    .join('\n');

  return `${intro}\n\nConversation:\n${conversation}\n\nUser: ${message}`;
}

// Handler
export default async function handler(req, res) {
  // ✅ CORS (VERY IMPORTANT)
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'POST, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  // Handle preflight (browser requirement)
  if (req.method === 'OPTIONS') {
    return res.status(200).end();
  }

  // Reject non-POST
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Method not allowed' });
  }

  try {
    const { message, history, role, userName } = req.body || {};

    // Validation
    if (!message || typeof message !== 'string') {
      return res.status(400).json({ error: 'Message is required' });
    }

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({ error: 'API key not configured' });
    }

    // Model
    const model = genAI.getGenerativeModel({
      model: 'gemini-2.5-flash-lite',
    });

    // Prompt
    const prompt = buildPrompt({
      role,
      userName,
      message,
      history,
    });

    // Generate response
    const result = await model.generateContent(prompt);
    const response = await result.response;

    return res.status(200).json({
      reply: response.text(),
    });

  } catch (err) {
    return res.status(500).json({
      error: err.message || 'Something went wrong',
    });
  }
}