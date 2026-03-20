const { pool } = require('../config/database');
const User = require('./User');
const Address = require('./Address');
const Role = require('./Role');

/**
 * Lista todos os clientes com dados de user e endereço principal.
 */
async function findAll(search = null) {
  let sql = `
    SELECT c.id AS customer_id, c.loyalty_points, c.created_at AS customer_created_at,
           u.id AS user_id, u.full_name, u.email, u.phone, u.document,
           a.id AS address_id, a.street, a.number, a.complement, a.district, a.city, a.state, a.zip_code
    FROM customers c
    INNER JOIN users u ON c.user_id = u.id
    LEFT JOIN customer_addresses ca ON ca.customer_id = c.id AND ca.is_default = 1
    LEFT JOIN addresses a ON ca.address_id = a.id
    WHERE u.role_id = (SELECT id FROM roles WHERE name = 'CLIENTE')
  `;
  const params = [];
  if (search && search.trim()) {
    sql += ` AND (u.full_name LIKE ? OR u.email LIKE ? OR u.phone LIKE ? OR u.document LIKE ?)`;
    const term = `%${search.trim()}%`;
    params.push(term, term, term, term);
  }
  sql += ' ORDER BY u.full_name';
  const [rows] = await pool.execute(sql, params);
  return rows;
}

/**
 * Busca cliente por id (customer.id), com endereço principal.
 */
async function findById(customerId) {
  const [rows] = await pool.execute(
    `SELECT c.id AS customer_id, c.user_id, c.default_address_id,
            u.full_name, u.email, u.phone, u.document, u.birth_date,
            a.id AS address_id, a.street, a.number, a.complement, a.district AS bairro, a.city AS cidade, a.state AS estado, a.country AS pais, a.zip_code AS cep
     FROM customers c
     INNER JOIN users u ON c.user_id = u.id
     LEFT JOIN customer_addresses ca ON ca.customer_id = c.id AND ca.is_default = 1
     LEFT JOIN addresses a ON ca.address_id = a.id
     WHERE c.id = ?`,
    [customerId]
  );
  const row = rows[0];
  if (!row) return null;
  return {
    customer_id: row.customer_id,
    user_id: row.user_id,
    full_name: row.full_name,
    email: row.email,
    phone: row.phone,
    document: row.document,
    birth_date: row.birth_date,
    address_id: row.address_id,
    street: row.street,
    number: row.number,
    complement: row.complement,
    rua: row.street,
    bairro: row.bairro,
    cidade: row.cidade,
    estado: row.estado,
    pais: row.pais,
    cep: row.cep ? (String(row.cep).length === 8 ? String(row.cep).slice(0, 5) + '-' + String(row.cep).slice(5) : row.cep) : null,
  };
}

/**
 * Busca cliente por user_id.
 */
async function findByUserId(userId) {
  const [rows] = await pool.execute(
    'SELECT * FROM customers WHERE user_id = ?',
    [userId]
  );
  return rows[0] || null;
}

/**
 * Perfil completo do cliente (user + endereço principal) para página Minha Conta.
 */
async function getProfileByUserId(userId) {
  const [rows] = await pool.execute(
    `SELECT u.id AS user_id, u.full_name, u.email, u.phone, u.document, u.birth_date,
            c.id AS customer_id, a.id AS address_id,
            a.street, a.number, a.complement, a.district, a.city, a.state, a.country, a.zip_code
     FROM users u
     INNER JOIN customers c ON c.user_id = u.id
     LEFT JOIN customer_addresses ca ON ca.customer_id = c.id AND ca.is_default = 1
     LEFT JOIN addresses a ON ca.address_id = a.id
     WHERE u.id = ?`,
    [userId]
  );
  return rows[0] || null;
}

/**
 * Cadastra novo cliente: cria user (CLIENTE), customer, address e customer_addresses.
 * @param {Object} data - dados do formulário (nome, email, telefone, cep, rua, numero, bairro, cidade, estado, pais)
 * @param {string} passwordHash - senha já hasheada (ex: bcrypt)
 */
async function createClient(data, passwordHash) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const roleCliente = await Role.findByName('CLIENTE');
    if (!roleCliente) throw new Error('Role CLIENTE não encontrada no banco.');

    const userId = await User.create({
      role_id: roleCliente.id,
      full_name: data.nome || data.full_name,
      email: data.email,
      password_hash: passwordHash,
      phone: data.telefone || data.phone,
      document: data.document || data.cpf || null,
      birth_date: data.birth_date || null,
    });
    if (!userId) throw new Error('Falha ao criar usuário.');

    const addressId = await Address.create({
      street: data.rua || data.street,
      number: data.numero || data.number,
      complement: data.complement,
      district: data.bairro || data.district,
      city: data.cidade || data.city,
      state: data.estado || data.state,
      country: data.pais || data.country || 'Brasil',
      zip_code: data.cep || data.zip_code,
    });

    const [custResult] = await connection.execute(
      'INSERT INTO customers (user_id, default_address_id) VALUES (?, ?)',
      [userId, addressId]
    );
    const customerId = custResult.insertId;

    await connection.execute(
      'INSERT INTO customer_addresses (customer_id, address_id, label, is_default) VALUES (?, ?, ?, 1)',
      [customerId, addressId, 'Principal']
    );

    await connection.commit();
    return { userId, customerId, addressId };
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * Atualiza cliente (user + endereço padrão). Endereço é identificado por customer_addresses.
 */
async function updateClient(customerId, data) {
  const customer = await findById(customerId);
  if (!customer) return null;

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    await connection.execute(
      `UPDATE users SET full_name = ?, email = ?, phone = ?, document = ?, birth_date = ? WHERE id = ?`,
      [data.nome || data.full_name, data.email, data.telefone || data.phone, data.document || null, data.birth_date || null, customer.user_id]
    );

    const [addrRows] = await connection.execute(
      `SELECT address_id FROM customer_addresses WHERE customer_id = ? AND is_default = 1 LIMIT 1`,
      [customerId]
    );
    const addressId = addrRows[0]?.address_id;
    if (addressId) {
      await connection.execute(
        `UPDATE addresses SET street = ?, number = ?, complement = ?, district = ?, city = ?, state = ?, country = ?, zip_code = ? WHERE id = ?`,
        [
          data.rua || data.street,
          data.numero || data.number,
          data.complement || null,
          data.bairro || data.district || null,
          data.cidade || data.city,
          data.estado || data.state,
          data.pais || data.country || 'Brasil',
          data.cep || data.zip_code,
          addressId,
        ]
      );
    }

    await connection.commit();
    return true;
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * Remove um cliente: customer_addresses, customer e user associado.
 */
async function deleteById(customerId) {
  const connection = await pool.getConnection();
  try {
    const [rows] = await connection.execute('SELECT user_id FROM customers WHERE id = ?', [customerId]);
    const userId = rows[0] ? rows[0].user_id : null;
    await connection.execute('DELETE FROM customer_addresses WHERE customer_id = ?', [customerId]);
    const [custResult] = await connection.execute('DELETE FROM customers WHERE id = ?', [customerId]);
    const deleted = custResult.affectedRows;
    if (deleted && userId) {
      await connection.execute('DELETE FROM users WHERE id = ?', [userId]);
    }
    return deleted;
  } finally {
    connection.release();
  }
}

/**
 * Remove vários clientes por id.
 * Remove customer_addresses, depois customers, depois os users associados (evita FK).
 */
async function deleteManyByIds(ids) {
  if (!Array.isArray(ids) || ids.length === 0) return 0;
  const placeholders = ids.map(() => '?').join(',');
  const connection = await pool.getConnection();
  try {
    const [userRows] = await connection.execute(
      `SELECT user_id FROM customers WHERE id IN (${placeholders})`,
      ids
    );
    const userIds = userRows.map((r) => r.user_id).filter(Boolean);
    await connection.execute(`DELETE FROM customer_addresses WHERE customer_id IN (${placeholders})`, ids);
    const [custResult] = await connection.execute(`DELETE FROM customers WHERE id IN (${placeholders})`, ids);
    const deleted = custResult.affectedRows;
    if (userIds.length > 0) {
      const ph = userIds.map(() => '?').join(',');
      await connection.execute(`DELETE FROM users WHERE id IN (${ph})`, userIds);
    }
    return deleted;
  } finally {
    connection.release();
  }
}

/**
 * Lista todos os endereços do cliente (para aba Endereço).
 */
async function getAddressesByCustomerId(customerId) {
  const [rows] = await pool.execute(
    `SELECT ca.address_id, ca.label, ca.is_default,
            a.street, a.number, a.complement, a.district, a.city, a.state, a.country, a.zip_code
     FROM customer_addresses ca
     INNER JOIN addresses a ON a.id = ca.address_id
     WHERE ca.customer_id = ?
     ORDER BY ca.is_default DESC, ca.address_id`,
    [customerId]
  );
  return rows;
}

/**
 * Atualiza apenas dados do usuário (sem endereço).
 */
async function updateUserOnly(customerId, data) {
  const customer = await findById(customerId);
  if (!customer) return null;
  await pool.execute(
    `UPDATE users SET full_name = ?, email = ?, phone = ?, document = ?, birth_date = ? WHERE id = ?`,
    [data.full_name || data.nome, data.email, data.telefone || data.phone, data.document || null, data.birth_date || null, customer.user_id]
  );
  return true;
}

/**
 * Verifica se o endereço pertence ao cliente (via customer_addresses).
 */
async function customerOwnsAddress(customerId, addressId) {
  const [rows] = await pool.execute(
    'SELECT 1 FROM customer_addresses WHERE customer_id = ? AND address_id = ?',
    [customerId, addressId]
  );
  return rows.length > 0;
}

/**
 * Adiciona novo endereço ao cliente.
 */
async function addAddressToCustomer(customerId, data, label = 'Novo') {
  const addressId = await Address.create({
    street: (data.street || data.rua || '').trim(),
    number: (data.number || data.numero || '').trim(),
    complement: (data.complement || '').trim() || null,
    district: (data.district || data.bairro || '').trim(),
    city: (data.city || data.cidade || '').trim(),
    state: (data.state || data.estado || '').trim().toUpperCase().slice(0, 2),
    country: (data.country || data.pais || 'Brasil').trim(),
    zip_code: (data.cep || data.zip_code || '').replace(/\D/g, ''),
  });
  const [rows] = await pool.execute(
    'SELECT COUNT(*) AS n FROM customer_addresses WHERE customer_id = ?',
    [customerId]
  );
  const isFirst = rows[0].n === 0;
  await pool.execute(
    'INSERT INTO customer_addresses (customer_id, address_id, label, is_default) VALUES (?, ?, ?, ?)',
    [customerId, addressId, label, isFirst ? 1 : 0]
  );
  if (isFirst) {
    await pool.execute('UPDATE customers SET default_address_id = ? WHERE id = ?', [addressId, customerId]);
  }
  return addressId;
}

/**
 * Atualiza um endereço existente.
 */
async function updateAddressForCustomer(addressId, data) {
  await Address.updateById(addressId, {
    street: (data.street || data.rua || '').trim(),
    number: (data.number || data.numero || '').trim(),
    complement: (data.complement || '').trim() || null,
    district: (data.district || data.bairro || '').trim(),
    city: (data.city || data.cidade || '').trim(),
    state: (data.state || data.estado || '').trim().toUpperCase().slice(0, 2),
    country: (data.country || data.pais || 'Brasil').trim(),
    zip_code: (data.cep || data.zip_code || '').replace(/\D/g, ''),
  });
  return true;
}

/**
 * Remove endereço do cliente. Se era o padrão, define outro como padrão.
 */
async function removeAddressFromCustomer(customerId, addressId) {
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    const [link] = await connection.execute(
      'SELECT is_default FROM customer_addresses WHERE customer_id = ? AND address_id = ?',
      [customerId, addressId]
    );
    if (link.length === 0) {
      await connection.rollback();
      return false;
    }
    await connection.execute('DELETE FROM customer_addresses WHERE customer_id = ? AND address_id = ?', [customerId, addressId]);
    if (link[0].is_default) {
      const [next] = await connection.execute(
        'SELECT address_id FROM customer_addresses WHERE customer_id = ? LIMIT 1',
        [customerId]
      );
      if (next.length > 0) {
        await connection.execute('UPDATE customer_addresses SET is_default = 1 WHERE customer_id = ? AND address_id = ?', [customerId, next[0].address_id]);
        await connection.execute('UPDATE customers SET default_address_id = ? WHERE id = ?', [next[0].address_id, customerId]);
      } else {
        await connection.execute('UPDATE customers SET default_address_id = NULL WHERE id = ?', [customerId]);
      }
    }
    await connection.execute('DELETE FROM addresses WHERE id = ?', [addressId]);
    await connection.commit();
    return true;
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

/**
 * Define endereço como padrão do cliente.
 */
async function setDefaultAddress(customerId, addressId) {
  const ok = await customerOwnsAddress(customerId, addressId);
  if (!ok) return false;
  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();
    await connection.execute('UPDATE customer_addresses SET is_default = 0 WHERE customer_id = ?', [customerId]);
    await connection.execute('UPDATE customer_addresses SET is_default = 1 WHERE customer_id = ? AND address_id = ?', [customerId, addressId]);
    await connection.execute('UPDATE customers SET default_address_id = ? WHERE id = ?', [addressId, customerId]);
    await connection.commit();
    return true;
  } catch (err) {
    await connection.rollback();
    throw err;
  } finally {
    connection.release();
  }
}

module.exports = {
  findAll,
  findById,
  findByUserId,
  getProfileByUserId,
  getAddressesByCustomerId,
  createClient,
  updateClient,
  updateUserOnly,
  deleteById,
  deleteManyByIds,
  customerOwnsAddress,
  addAddressToCustomer,
  updateAddressForCustomer,
  removeAddressFromCustomer,
  setDefaultAddress,
};
