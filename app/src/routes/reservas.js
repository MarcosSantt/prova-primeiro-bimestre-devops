const { Router } = require('express');
const { pool } = require('../db');

const router = Router();

const STATUS_VALIDOS = ['pendente', 'confirmada', 'cancelada'];

// Confere se a data existe no calendário (ex.: rejeita 2026-02-31)
function dataValida(data) {
  if (typeof data !== 'string' || !/^\d{4}-\d{2}-\d{2}$/.test(data)) return false;
  const convertida = new Date(`${data}T00:00:00Z`);
  return !isNaN(convertida) && convertida.toISOString().slice(0, 10) === data;
}

// Valida os campos enviados no corpo; devolve uma mensagem de erro ou null
function validarReserva({ cliente, data, status }, statusObrigatorio) {
  if (typeof cliente !== 'string' || cliente.trim() === '') {
    return 'Campo "cliente" é obrigatório';
  }
  if (!dataValida(data)) {
    return 'Campo "data" deve ser uma data válida no formato AAAA-MM-DD';
  }
  if (status === undefined && statusObrigatorio) {
    return 'Campo "status" é obrigatório';
  }
  if (status !== undefined && !STATUS_VALIDOS.includes(status)) {
    return `Campo "status" deve ser um de: ${STATUS_VALIDOS.join(', ')}`;
  }
  return null;
}

// Converte o :id da URL em número; devolve null se for inválido
function lerId(req) {
  const id = Number(req.params.id);
  return Number.isInteger(id) && id > 0 ? id : null;
}

// POST /reservas — cria uma reserva
router.post('/', async (req, res) => {
  const erro = validarReserva(req.body ?? {}, false);
  if (erro) return res.status(400).json({ erro });

  const { cliente, data, status = 'pendente' } = req.body;
  const { rows } = await pool.query(
    'INSERT INTO reservas (cliente, data, status) VALUES ($1, $2, $3) RETURNING *',
    [cliente.trim(), data, status]
  );
  res.status(201).json(rows[0]);
});

// GET /reservas — lista todas
router.get('/', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM reservas ORDER BY id');
  res.json(rows);
});

// GET /reservas/:id — busca uma
router.get('/:id', async (req, res) => {
  const id = lerId(req);
  if (!id) return res.status(400).json({ erro: 'ID inválido' });

  const { rows } = await pool.query('SELECT * FROM reservas WHERE id = $1', [id]);
  if (rows.length === 0) return res.status(404).json({ erro: 'Reserva não encontrada' });
  res.json(rows[0]);
});

// PUT /reservas/:id — atualiza todos os campos
router.put('/:id', async (req, res) => {
  const id = lerId(req);
  if (!id) return res.status(400).json({ erro: 'ID inválido' });

  const erro = validarReserva(req.body ?? {}, true);
  if (erro) return res.status(400).json({ erro });

  const { cliente, data, status } = req.body;
  const { rows } = await pool.query(
    'UPDATE reservas SET cliente = $1, data = $2, status = $3 WHERE id = $4 RETURNING *',
    [cliente.trim(), data, status, id]
  );
  if (rows.length === 0) return res.status(404).json({ erro: 'Reserva não encontrada' });
  res.json(rows[0]);
});

// DELETE /reservas/:id — remove
router.delete('/:id', async (req, res) => {
  const id = lerId(req);
  if (!id) return res.status(400).json({ erro: 'ID inválido' });

  const { rowCount } = await pool.query('DELETE FROM reservas WHERE id = $1', [id]);
  if (rowCount === 0) return res.status(404).json({ erro: 'Reserva não encontrada' });
  res.status(204).send();
});

module.exports = router;
