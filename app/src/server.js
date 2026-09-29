const app = require('./app');
const { initDb } = require('./db');

const PORT = process.env.PORT || 3000;

async function iniciar() {
  try {
    await initDb();
    console.log('Banco de dados pronto (tabela reservas verificada)');
  } catch (err) {
    console.error('Falha ao conectar no banco de dados:', err.message);
    process.exit(1);
  }

  app.listen(PORT, () => {
    console.log(`API de Reservas rodando na porta ${PORT}`);
  });
}

iniciar();
