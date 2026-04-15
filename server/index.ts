import express, { Request, Response } from 'express';
import cors from 'cors';
import { pool } from './db';
import dotenv from 'dotenv';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { verifyJWT } from './auth';

dotenv.config();
const JWT_SECRET = process.env.JWT_SECRET || 'jadiel_saas_secret_2026';

const app = express();
const port = 3001;

app.use(cors({ origin: '*', methods: '*', allowedHeaders: '*' }));
app.use(express.json());

app.post('/api/login', async (req: Request, res: Response) => {
  const { email, senha } = req.body;
  try {
    const result = await pool.query(
      'SELECT id, nome, email, senha, perfil FROM usuarios WHERE (email ILIKE $1 OR nome ILIKE $1)',
      [email]
    );

    if (result.rows.length > 0) {
      const user = result.rows[0];
      if (bcrypt.compareSync(senha, user.senha)) {
         delete user.senha;
         const token = jwt.sign({ id: user.id, email: user.email }, JWT_SECRET, { expiresIn: '8h' });
         res.json({ token, user });
      } else {
         res.status(401).json({ error: 'Invalido' });
      }
    } else {
      res.status(401).json({ error: 'Invalido' });
    }
  } catch (err) {
    res.status(500).json({ error: 'Erro' });
  }
});

app.use(verifyJWT as any);
app.get('/api/health', (req, res) => res.json({ status: 'ok' }));

app.listen(port, '0.0.0.0', () => {
  console.log(`Running on port ${port}`);
});
