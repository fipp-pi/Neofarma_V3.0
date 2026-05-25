// Seed massivo para testes do Admin Financeiro
// Gera: produtos + lotes (FEFO), clientes/endereços, pedidos (orders), pagamentos (payments) e order_items.
//
// Uso:
//   node scripts/seed_massivo_financeiro.js
//
// Dica:
// - Este script faz CLEAN por prefixos para permitir rodar novamente.
// - Ajuste os parâmetros no topo se quiser aumentar/diminuir a massa.

const { pool } = require('../config/database');
const { buildPaymentPayload } = require('../services/paymentService');

const PREFIX_PRODUCTS = 'produto-finance-seed-';
const PREFIX_USERS = 'cliente-finance-seed-';
const PREFIX_BATCH = 'FINSEED-';

const PASSWORD_HASH =
  '$2b$10$N9qo8uLOickgx2ZMRZo5i.ejv6Lx0x6Wn2fNQbB8p4TQ9I6M4wG9K'; // mesmo do seed_minimal_for_checkout (senha: Cliente@123)

const PIX_QR_PLACEHOLDER = `data:image/svg+xml;utf8,${encodeURIComponent(
  `<svg xmlns='http://www.w3.org/2000/svg' width='220' height='220'>
    <rect width='220' height='220' fill='white'/>
    <text x='20' y='110' font-size='32' fill='black'>PIX SIM</text>
  </svg>`
)}`;

async function cleanSeed(connection) {
  // clientes/users
  await connection.execute(
    `DELETE p
     FROM payments p
     WHERE p.order_id IN (
       SELECT o.id
       FROM orders o
       WHERE o.customer_id IN (
         SELECT c.id
         FROM customers c
         INNER JOIN users u ON u.id = c.user_id
         WHERE u.email LIKE ?
       )
     )`,
    [`${PREFIX_USERS}%`]
  );

  await connection.execute(
    `DELETE oi
     FROM order_items oi
     WHERE oi.order_id IN (
       SELECT o.id
       FROM orders o
       WHERE o.customer_id IN (
         SELECT c.id
         FROM customers c
         INNER JOIN users u ON u.id = c.user_id
         WHERE u.email LIKE ?
       )
     )`,
    [`${PREFIX_USERS}%`]
  );

  await connection.execute(
    `DELETE FROM orders
     WHERE customer_id IN (
       SELECT c.id
       FROM customers c
       INNER JOIN users u ON u.id = c.user_id
       WHERE u.email LIKE ?
     )`,
    [`${PREFIX_USERS}%`]
  );

  await connection.execute(
    `DELETE ca
     FROM customer_addresses ca
     WHERE ca.customer_id IN (
       SELECT c.id
       FROM customers c
       INNER JOIN users u ON u.id = c.user_id
       WHERE u.email LIKE ?
     )`,
    [`${PREFIX_USERS}%`]
  );

  await connection.execute(
    `DELETE FROM customers
     WHERE user_id IN (
       SELECT u.id
       FROM users u
       WHERE u.email LIKE ?
     )`,
    [`${PREFIX_USERS}%`]
  );

  await connection.execute(
    `DELETE FROM users
     WHERE email LIKE ?`,
    [`${PREFIX_USERS}%`]
  );

  // produtos/lotes
  await connection.execute(
    `DELETE FROM product_images
     WHERE product_id IN (
       SELECT id FROM products WHERE slug LIKE ?
     )`,
    [`${PREFIX_PRODUCTS}%`]
  );
  await connection.execute(
    `DELETE FROM product_categories
     WHERE product_id IN (
       SELECT id FROM products WHERE slug LIKE ?
     )`,
    [`${PREFIX_PRODUCTS}%`]
  );

  await connection.execute(
    `DELETE FROM inventory_batches
     WHERE product_id IN (
       SELECT id FROM products WHERE slug LIKE ?
     )`,
    [`${PREFIX_PRODUCTS}%`]
  );

  await connection.execute(`DELETE FROM products WHERE slug LIKE ?`, [`${PREFIX_PRODUCTS}%`]);
}

function fmtZip(zip) {
  const digits = String(zip || '').replace(/\D/g, '');
  if (!digits) return '00000000';
  return digits.length === 8 ? digits : digits.slice(0, 8).padEnd(8, '0');
}

function addDaysISO(days) {
  const d = new Date();
  d.setDate(d.getDate() + days);
  return d.toISOString().slice(0, 10);
}

function toBrl(n) {
  return Number(n || 0);
}

async function seedMassivoFinancas() {
  const productCount = 30;
  const customerCount = 90;
  const orderCount = 900;
  const minItems = 1;
  const maxItems = 3;

  const connection = await pool.getConnection();
  try {
    await connection.beginTransaction();

    // CLEAN
    await cleanSeed(connection);

    // Roles
    const [roleRows] = await connection.execute(`SELECT id, name FROM roles WHERE name IN ('CLIENTE')`);
    const roleClienteId = (roleRows || []).find((r) => r.name === 'CLIENTE')?.id;
    if (!roleClienteId) throw new Error('Role CLIENTE não encontrada.');

    // Base address for lab/supplier
    await connection.execute(
      `INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code)
       SELECT 'Rua Seed Financeira', '10', NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', '19000002'
       WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE zip_code='19000002')`
    );
    // insert may not return inserted id; query it
    const [[addrLab]] = await connection.execute(`SELECT id FROM addresses WHERE zip_code='19000002' ORDER BY id DESC LIMIT 1`);

    // Lab + supplier
    await connection.execute(
      `INSERT INTO labs (name, cnpj, email, phone, address_id, is_active)
       SELECT 'Lab Seed Finance', '55555555000191', 'lab.seed@neofarma.com', '18999990011', ?, 1
       WHERE NOT EXISTS (SELECT 1 FROM labs WHERE cnpj='55555555000191')`,
      [addrLab.id]
    );
    const [[labRow]] = await connection.execute(`SELECT id FROM labs WHERE cnpj='55555555000191' ORDER BY id DESC LIMIT 1`);
    const labId = labRow.id;

    await connection.execute(
      `INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active)
       SELECT 'Fornecedor Seed Finance', 'Fornecedor Seed', '66666666000191', 'forn.seed@neofarma.com', '18999990012', ?, 1
       WHERE NOT EXISTS (SELECT 1 FROM suppliers WHERE cnpj='66666666000191')`,
      [addrLab.id]
    );
    const [[supplierRes]] = await connection.execute(`SELECT id FROM suppliers WHERE cnpj='66666666000191' ORDER BY id DESC LIMIT 1`);
    const supplierId = supplierRes.id;

    // Category
    await connection.execute(
      `INSERT INTO categories (parent_id, name, slug, description, is_active)
       SELECT NULL, 'Categoria Seed Finance', 'categoria-seed-finance', 'Seed financeiro', 1
       WHERE NOT EXISTS (SELECT 1 FROM categories WHERE slug='categoria-seed-finance')`
    );
    const [[categoryIdRow]] = await connection.execute(
      `SELECT id FROM categories WHERE slug='categoria-seed-finance' ORDER BY id DESC LIMIT 1`
    );
    const categoryId = categoryIdRow.id;

    // Products + inventory batches
    const products = [];
    for (let i = 1; i <= productCount; i += 1) {
      const slug = `${PREFIX_PRODUCTS}${i}`;
      const sku = `SKU-FIN-${i}`;
      const ean13 = `EAN-FIN-${i}`;
      const unitPrice = toBrl(10 + i);
      const promoPrice = i % 5 === 0 ? Number((unitPrice * 0.8).toFixed(2)) : null;

      const [prodCheck] = await connection.execute(`SELECT id FROM products WHERE slug = ? LIMIT 1`, [slug]);
      let productId;
      if (prodCheck.length) {
        productId = prodCheck[0].id;
      } else {
        const [res] = await connection.execute(
          `INSERT INTO products
            (lab_id, main_supplier_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
           VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, 0, ?, ?, 'ACTIVE')`,
          [
            labId,
            supplierId,
            `Produto Finance Seed ${i}`,
            slug,
            sku,
            ean13,
            `Seed financeiro - ${i}`,
            'Composição teste',
            'Uso teste',
            unitPrice,
            promoPrice,
          ]
        );
        productId = res.insertId;
      }

      await connection.execute(`INSERT IGNORE INTO product_categories (product_id, category_id) VALUES (?, ?)`, [productId, categoryId]);
      await connection.execute(
        `INSERT IGNORE INTO product_images (product_id, image_url, sort_order) VALUES (?, '/assets/img/product/product-1.webp', 0)`,
        [productId]
      );

      // Reset seed inventory batches for this product
      await connection.execute(
        `DELETE FROM inventory_batches WHERE product_id = ? AND batch_code LIKE ?`,
        [productId, `${PREFIX_BATCH}${i}-%`]
      );

      // Create 3 batches
      const batchA = `${PREFIX_BATCH}${i}-A`;
      const batchB = `${PREFIX_BATCH}${i}-B`;
      const batchC = `${PREFIX_BATCH}${i}-C`;
      const expiryA = addDaysISO(180 + i);
      const expiryB = addDaysISO(60 + (i % 15));
      const expiryC = addDaysISO(25 + (i % 10));

      await connection.execute(
        `INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
         VALUES (?, ?, DATE_SUB(CURDATE(), INTERVAL 120 DAY), ?, ?),
                (?, ?, DATE_SUB(CURDATE(), INTERVAL 80 DAY), ?, ?),
                (?, ?, DATE_SUB(CURDATE(), INTERVAL 30 DAY), ?, ?)`,
        [
          productId,
          batchA,
          expiryA,
          3000 + i * 100,
          productId,
          batchB,
          expiryB,
          2500 + i * 60,
          productId,
          batchC,
          expiryC,
          2000 + i * 40,
        ]
      );

      const [batchRows] = await connection.execute(
        `SELECT id, batch_code, quantity FROM inventory_batches WHERE product_id = ? AND batch_code IN (?, ?, ?)`,
        [productId, batchA, batchB, batchC]
      );
      const batchesByCode = {};
      batchRows.forEach((r) => { batchesByCode[r.batch_code] = r; });

      products.push({
        id: productId,
        unitPrice,
        promoPrice,
        batchesByCode,
      });
    }

    // Customers
    const customers = [];
    for (let c = 1; c <= customerCount; c += 1) {
      const email = `${PREFIX_USERS}${c}@neofarma.com`;
      const fullName = `Cliente Finance Seed ${c}`;

      const [userRows] = await connection.execute(`SELECT id FROM users WHERE email = ? LIMIT 1`, [email]);
      let userId;
      if (userRows.length) {
        userId = userRows[0].id;
      } else {
        const [res] = await connection.execute(
          `INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
           VALUES (?, ?, ?, ?, NULL, '189999900${String(100 + c).slice(-3)}', '1995-01-01', 1)`,
          [roleClienteId, fullName, email, PASSWORD_HASH]
        );
        userId = res.insertId;
      }

      const zip = fmtZip(19000000 + c);
      const [addrRows] = await connection.execute(
        `INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code)
         SELECT 'Rua Cliente Seed Finance', ?, NULL, 'Centro', 'Presidente Prudente', 'SP', 'Brasil', ?
         WHERE NOT EXISTS (SELECT 1 FROM addresses WHERE zip_code = ? AND number = ?)`,
        [100 + c, zip, zip, String(100 + c)]
      );

      const [[addr] ] = await connection.execute(
        `SELECT id FROM addresses WHERE zip_code = ? AND street='Rua Cliente Seed Finance' ORDER BY id DESC LIMIT 1`,
        [zip]
      );
      const addressId = addr.id;

      // customers row
      const [custRows] = await connection.execute(`SELECT id, default_address_id FROM customers WHERE user_id = ? LIMIT 1`, [userId]);
      let customerId;
      let defaultAddressId;
      if (custRows.length) {
        customerId = custRows[0].id;
        defaultAddressId = custRows[0].default_address_id;
      } else {
        const [resCust] = await connection.execute(
          `INSERT INTO customers (user_id, default_address_id, loyalty_points) VALUES (?, ?, 0)`,
          [userId, addressId]
        );
        customerId = resCust.insertId;
        defaultAddressId = addressId;
      }

      // customer_addresses link
      await connection.execute(
        `INSERT IGNORE INTO customer_addresses (customer_id, address_id, label, is_default) VALUES (?, ?, 'Principal', 1)`,
        [customerId, defaultAddressId]
      );

      customers.push({ customerId, defaultAddressId });
    }

    // Seed orders + payments
    const shippingA = { service: 'PADRAO', days: 7, cost: 15.00 };
    const shippingB = { service: 'EXPRESSO', days: 3, cost: 25.00 };

    for (let o = 1; o <= orderCount; o += 1) {
      const customer = customers[(o - 1) % customers.length];
      const customerId = customer.customerId;
      const addressId = customer.defaultAddressId;

      const shipping = o % 2 === 0 ? shippingA : shippingB;
      const shippingCost = shipping.cost;

      // payment status selection:
      // - ~70% PAID
      // - ~20% PENDING
      // - ~10% FAILED
      let paymentStatus;
      const mod10 = o % 10;
      if (mod10 === 0 || mod10 === 7) paymentStatus = 'FAILED';
      else if (mod10 === 3 || mod10 === 6) paymentStatus = 'PENDING';
      else paymentStatus = 'PAID';

      // payment method selection:
      // - if FAILED/PENDING, prefer PIX/BOLETO so you can later mark in admin.
      // - if PAID, allow credit card sometimes.
      let paymentMethod;
      if (paymentStatus !== 'PAID') {
        paymentMethod = o % 2 === 0 ? 'PIX' : 'BOLETO';
      } else {
        const mm = o % 3;
        paymentMethod = mm === 0 ? 'PIX' : mm === 1 ? 'BOLETO' : 'CREDIT_CARD';
      }

      // Items count
      const itemsCount = minItems + (o % (maxItems - minItems + 1));
      let subtotal = 0;

      // create order
      let orderStatus = 'CONFIRMED';
      if (paymentStatus === 'FAILED') orderStatus = 'CANCELLED';
      if (paymentStatus === 'PAID') orderStatus = 'PROCESSING';

      const [orderRes] = await connection.execute(
        `INSERT INTO orders
         (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days)
         VALUES (?, ?, ?, 0, ?, 0, ?, ?, (SELECT zip_code FROM addresses WHERE id = ?), ?, ?)`,
        [customerId, addressId, orderStatus, shippingCost, paymentMethod, paymentStatus, addressId, shipping.service, shipping.days]
      );
      const orderId = orderRes.insertId;

      // create items and deduct stock from chosen batches
      for (let j = 1; j <= itemsCount; j += 1) {
        // Weighted to make product 1 more sold
        let productIndex;
        if ((o + j) % 10 < 4) productIndex = 0;
        else productIndex = (o * j) % products.length;

        const product = products[productIndex];

        const unitPrice = product.promoPrice != null ? product.promoPrice : product.unitPrice;
        const qty = 1 + ((o + j * 2) % 3);

        const letterPick = (o + j) % 3;
        const letter = letterPick === 0 ? 'A' : letterPick === 1 ? 'B' : 'C';
        const correctBatchCode = `${PREFIX_BATCH}${productIndex + 1}-${letter}`;
        const batch = product.batchesByCode[correctBatchCode] || product.batchesByCode[`${PREFIX_BATCH}${productIndex + 1}-A`] || Object.values(product.batchesByCode)[0];
        const batchId = batch.id;

        const lineTotal = Number((unitPrice * qty).toFixed(2));
        subtotal = Number((subtotal + lineTotal).toFixed(2));

        await connection.execute(
          `INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [orderId, product.id, batchId, qty, unitPrice, lineTotal]
        );

        await connection.execute(
          `UPDATE inventory_batches SET quantity = quantity - ? WHERE id = ?`,
          [qty, batchId]
        );
      }

      const total = Number((subtotal + shippingCost).toFixed(2));

      await connection.execute(
        `UPDATE orders SET subtotal = ?, total = ?, payment_status = ? WHERE id = ?`,
        [subtotal, total, paymentStatus, orderId]
      );

      // payment record
      const amount = total;
      let paymentExtras;
      if (paymentMethod === 'PIX') {
        paymentExtras = buildPaymentPayload('PIX', { orderId, orderRef: orderId, amount });
        // buildPixPayload returns status PENDING; override to match paymentStatus for testing
        paymentExtras.status = paymentStatus;
      } else if (paymentMethod === 'BOLETO') {
        const boleto_due_date = addDaysISO(3 + (o % 5));
        paymentExtras = buildPaymentPayload('BOLETO', { orderId, orderRef: orderId, amount, boleto_due_date, total: amount });
        paymentExtras.status = paymentStatus;
        paymentExtras.boleto_due_date = boleto_due_date;
      } else {
        // CREDIT_CARD: for this seed, credit card is always considered PAID
        paymentExtras = buildPaymentPayload('CREDIT_CARD', { card_number: '4242424242424242', installments: 1, total: amount });
        paymentExtras.status = 'PAID';
      }

      await connection.execute(
        `INSERT INTO payments
         (order_id, method, status, amount, pix_qr_code, pix_copy_paste, boleto_barcode, boleto_due_date, card_brand, card_last4, installments, interest_rate)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [
          orderId,
          paymentMethod,
          paymentExtras.status,
          amount,
          paymentMethod === 'PIX' ? paymentExtras.pix_qr_code || PIX_QR_PLACEHOLDER : null,
          paymentExtras.pix_copy_paste || null,
          paymentExtras.boleto_barcode || null,
          paymentExtras.boleto_due_date || null,
          paymentExtras.card_brand || null,
          paymentExtras.card_last4 || null,
          paymentExtras.installments || null,
          paymentExtras.interest_rate || null,
        ]
      );
    }

    await connection.commit();
    // eslint-disable-next-line no-console
    console.log('Seed financeiro finalizado ✅');
    console.log(`- products: ${productCount}`);
    console.log(`- customers: ${customerCount}`);
    console.log(`- orders: ${orderCount}`);
  } catch (err) {
    await connection.rollback();
    // eslint-disable-next-line no-console
    console.error('Erro no seed massivo:', err);
    throw err;
  } finally {
    connection.release();
  }
}

seedMassivoFinancas().catch(() => process.exit(1));

