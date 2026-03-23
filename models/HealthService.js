const { pool } = require('../config/database');

async function findAll(activeOnly = false) {
  let sql = 'SELECT * FROM health_services WHERE 1=1';
  if (activeOnly) sql += ' AND is_active = 1';
  sql += ' ORDER BY name ASC';
  const [rows] = await pool.execute(sql);
  return rows;
}

async function findById(id) {
  const [rows] = await pool.execute('SELECT * FROM health_services WHERE id = ? LIMIT 1', [id]);
  return rows[0] || null;
}

async function upsert(data) {
  if (data.id) {
    const [result] = await pool.execute(
      `UPDATE health_services
       SET name = ?, price = ?, duration_minutes = ?, requires_prescription = ?, service_group = ?, in_store_available = ?, home_available = ?, min_age_years = ?, max_age_years = ?, post_observation_minutes = ?, prep_instructions = ?, contraindications = ?, required_supplies = ?, is_active = ?, notes = ?
       WHERE id = ?`,
      [
        data.name,
        data.price,
        data.duration_minutes,
        data.requires_prescription ? 1 : 0,
        data.service_group || 'OUTRO',
        data.in_store_available ? 1 : 0,
        data.home_available ? 1 : 0,
        data.min_age_years !== undefined ? data.min_age_years : null,
        data.max_age_years !== undefined ? data.max_age_years : null,
        data.post_observation_minutes || 0,
        data.prep_instructions || null,
        data.contraindications || null,
        data.required_supplies || null,
        data.is_active ? 1 : 0,
        data.notes || null,
        data.id,
      ]
    );
    return { id: data.id, affectedRows: result.affectedRows };
  }

  const [result] = await pool.execute(
    `INSERT INTO health_services (name, price, duration_minutes, requires_prescription, service_group, in_store_available, home_available, min_age_years, max_age_years, post_observation_minutes, prep_instructions, contraindications, required_supplies, is_active, notes)
     VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
    [
      data.name,
      data.price,
      data.duration_minutes,
      data.requires_prescription ? 1 : 0,
      data.service_group || 'OUTRO',
      data.in_store_available ? 1 : 0,
      data.home_available ? 1 : 0,
      data.min_age_years !== undefined ? data.min_age_years : null,
      data.max_age_years !== undefined ? data.max_age_years : null,
      data.post_observation_minutes || 0,
      data.prep_instructions || null,
      data.contraindications || null,
      data.required_supplies || null,
      data.is_active ? 1 : 0,
      data.notes || null,
    ]
  );
  return { id: result.insertId, affectedRows: result.affectedRows };
}

async function deleteById(id) {
  const [result] = await pool.execute('DELETE FROM health_services WHERE id = ?', [id]);
  return result.affectedRows;
}

module.exports = {
  findAll,
  findById,
  upsert,
  deleteById,
};
