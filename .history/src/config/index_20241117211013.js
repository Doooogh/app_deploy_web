export default {
  baseURL: process.env.NODE_ENV === 'production' ? '/api' : '/api',
  wsURL: process.env.NODE_ENV === 'production' ? 'ws://your-domain/ws' : 'ws://localhost:3000/ws'
} 