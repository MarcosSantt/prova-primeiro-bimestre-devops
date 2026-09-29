const express = require('express');
const { pool } = require('./db');
const reservasRouter = require('./routes/reservas');

const app = express();

// Permite receber JSON no corpo das requisições (POST/PUT)
app.use(express.json());

// Healthcheck: verifica se a API está no ar e se o banco responde
app.get('/health', async (req, res) => {
  try {
    await pool.query('SELECT 1');
    res.status(200).json({ status: 'ok', banco: 'conectado' });
  } catch (err) {
    res.status(503).json({ status: 'erro', banco: 'indisponivel' });
  }
});

// CRUD de reservas
app.use('/reservas', reservasRouter);

// Qualquer rota não encontrada
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

// Tratador de erros genérico (Express 5 captura erros de rotas async)
app.use((err, req, res, next) => {
  // JSON malformado no corpo da requisição é erro do cliente, não do servidor
  if (err.type === 'entity.parse.failed') {
    return res.status(400).json({ erro: 'JSON inválido no corpo da requisição' });
  }
  console.error(err);
  res.status(500).json({ erro: 'Erro interno do servidor' });
});

module.exports = app;
