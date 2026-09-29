const express = require('express');

const app = express();

// Permite receber JSON no corpo das requisições (POST/PUT)
app.use(express.json());

// Healthcheck: usado para verificar se a API está no ar
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok' });
});

// Qualquer rota não encontrada
app.use((req, res) => {
  res.status(404).json({ erro: 'Rota não encontrada' });
});

// Tratador de erros genérico (Express 5 captura erros de rotas async)
app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ erro: 'Erro interno do servidor' });
});

module.exports = app;
