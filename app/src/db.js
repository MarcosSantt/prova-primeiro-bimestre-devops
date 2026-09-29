const { Pool, types } = require('pg');

// Tipo DATE (OID 1082): devolve como texto 'YYYY-MM-DD' em vez de objeto Date,
// evitando que o fuso horário altere o dia da reserva no JSON.
types.setTypeParser(1082, (valor) => valor);

// Configuração lida de variáveis de ambiente (nada de senha no código)
const pool = new Pool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 5432,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
  // No RDS a conexão exige SSL; localmente (Docker) não
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: false } : false,
});

// Se o banco derrubar uma conexão ociosa, apenas registra o erro.
// Sem este tratador, o Node.js encerraria a API inteira.
pool.on('error', (err) => {
  console.error('Conexão com o banco perdida:', err.message);
});

// Cria a tabela na inicialização, caso ainda não exista
async function initDb() {
  await pool.query(`
    CREATE TABLE IF NOT EXISTS reservas (
      id      SERIAL PRIMARY KEY,
      cliente VARCHAR(120) NOT NULL,
      data    DATE         NOT NULL,
      status  VARCHAR(20)  NOT NULL DEFAULT 'pendente'
              CHECK (status IN ('pendente', 'confirmada', 'cancelada'))
    )
  `);
}

module.exports = { pool, initDb };
