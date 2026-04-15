import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { pool } from './db';

const JWT_SECRET = process.env.jwt_secret || 'caduemaria2';

export interface AuthRequest extends Request {
  user?: {
    id: number;
    email: string;
    perfil: string;
  };
}

export const verifyJWT = async (req: AuthRequest, res: Response, next: NextFunction) => {
  const authHeader = req.headers.authorization;
  if (!authHeader || !authHeader.startsWith('Bearer ')) {
    return res.status(401).json({ error: 'Token não fornecido ou inválido' });
  }

  const token = authHeader.split(' ')[1];

  try {
    const decoded = jwt.verify(token, JWT_SECRET) as any;
    req.user = decoded;

    // Seta o usuário na sessão do Postgres para o Audit Log
    if (req.user?.id) {
      try {
        const client = await pool.connect();
        try {
          console.log('Setting app.current_user_id for user:', req.user.id);
          await client.query('SELECT set_config($1, $2, false)', ['app.current_user_id', String(req.user.id)]);
        } finally {
          client.release();
        }
      } catch (dbErr) {
        console.error('DATABASE SESSION ERROR:', dbErr);
      }
    }

    next();
  } catch (err) {
    console.error('JWT VERIFICATION ERROR:', err);
    return res.status(403).json({ error: 'Token inválido ou expirado' });
  }
};
