/**
 * Gera scripts/seed_stress_complete.sql
 * Uso: node scripts/generate_seed_stress_sql.js
 */
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');

const OUT = path.join(__dirname, 'seed_stress_complete.sql');
const PREFIX = 'stress';
const PASSWORD_PLAIN = '123456';

function cpfFromBase(base9) {
  const base = String(base9).padStart(9, '0').slice(-9).split('').map(Number);
  let s = 0;
  for (let i = 0; i < 9; i++) s += base[i] * (10 - i);
  let d1 = (s * 10) % 11;
  if (d1 === 10) d1 = 0;
  s = 0;
  for (let i = 0; i < 9; i++) s += base[i] * (11 - i);
  s += d1 * 2;
  let d2 = (s * 10) % 11;
  if (d2 === 10) d2 = 0;
  return base.join('') + String(d1) + String(d2);
}

function cnpjFromBase(base12) {
  const w1 = [5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const w2 = [6, 5, 4, 3, 2, 9, 8, 7, 6, 5, 4, 3, 2];
  const base = String(base12).padStart(12, '0').slice(-12).split('').map(Number);
  let s = 0;
  for (let i = 0; i < 12; i++) s += base[i] * w1[i];
  let d1 = s % 11;
  d1 = d1 < 2 ? 0 : 11 - d1;
  const withD1 = [...base, d1];
  s = 0;
  for (let i = 0; i < 13; i++) s += withD1[i] * w2[i];
  let d2 = s % 11;
  d2 = d2 < 2 ? 0 : 11 - d2;
  return base.join('') + String(d1) + String(d2);
}

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "''")}'`;
}

/** Bloco SQL que alinha estoque e totais com a lógica da aplicação (RF_F2 / RF_F3 / RF_F5). */
function addCoherenceBlock(lines) {
  lines.push('');
  lines.push('-- Coerência de dados (estoque, compras e integridade)');
  lines.push(`UPDATE purchase_orders po
SET po.total_amount = (
  SELECT COALESCE(SUM(poi.total_cost), 0)
  FROM purchase_order_items poi
  WHERE poi.purchase_order_id = po.id
)
WHERE po.notes LIKE ${esc(`${PREFIX}%`)};`);

  lines.push(`UPDATE inventory_batches ib
INNER JOIN (
  SELECT oi.batch_id, SUM(oi.quantity) AS sold_qty
  FROM order_items oi
  INNER JOIN orders o ON o.id = oi.order_id
  INNER JOIN customers c ON c.id = o.customer_id
  INNER JOIN users u ON u.id = c.user_id
  WHERE u.email LIKE ${esc(`${PREFIX}.seed%`)} AND o.payment_status = 'PAID'
  GROUP BY oi.batch_id
) s ON s.batch_id = ib.id
SET ib.quantity = ib.quantity - s.sold_qty;`);

  lines.push(`UPDATE inventory_batches ib
INNER JOIN (
  SELECT d.batch_id, SUM(d.quantity) AS disposed_qty
  FROM inventory_disposals d
  INNER JOIN products p ON p.id = d.product_id
  WHERE p.slug LIKE ${esc(`${PREFIX}-%`)}
  GROUP BY d.batch_id
) x ON x.batch_id = ib.id
SET ib.quantity = ib.quantity - x.disposed_qty;`);

  lines.push('');
  lines.push('-- Validação pós-seed (esperado: 0 em todas as linhas)');
  lines.push(`SELECT 'lotes_quantidade_negativa' AS check_name, COUNT(*) AS problemas
FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id
WHERE p.slug LIKE ${esc(`${PREFIX}-%`)} AND ib.quantity < 0`);
  lines.push(`UNION ALL SELECT 'descarte_maior_que_saldo_atual', COUNT(*)
FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id
INNER JOIN (
  SELECT batch_id, SUM(quantity) AS disposed_qty
  FROM inventory_disposals
  GROUP BY batch_id
) d ON d.batch_id = ib.id
WHERE p.slug LIKE ${esc(`${PREFIX}-%`)}
  AND d.disposed_qty > ib.quantity + (
    SELECT COALESCE(SUM(oi.quantity), 0)
    FROM order_items oi
    INNER JOIN orders o ON o.id = oi.order_id
    WHERE oi.batch_id = ib.id AND o.payment_status = 'PAID'
  )`);
  lines.push(`UNION ALL SELECT 'pedido_pago_sem_itens', COUNT(*)
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE ${esc(`${PREFIX}.seed%`)}
  AND o.payment_status = 'PAID'
  AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)`);
  lines.push(`UNION ALL SELECT 'pedido_pendente_com_itens', COUNT(*)
FROM orders o
INNER JOIN customers c ON c.id = o.customer_id
INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE ${esc(`${PREFIX}.seed%`)}
  AND o.payment_status <> 'PAID'
  AND EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)`);
  lines.push(`UNION ALL SELECT 'compra_recebida_sem_lote', COUNT(*)
FROM purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
WHERE po.notes LIKE ${esc(`${PREFIX}%`)}
  AND po.status = 'RECEIVED'
  AND poi.quantity_received > 0
  AND poi.batch_id IS NULL`);
  lines.push(`UNION ALL SELECT 'total_compra_divergente', COUNT(*)
FROM purchase_orders po
WHERE po.notes LIKE ${esc(`${PREFIX}%`)}
  AND po.total_amount <> (
    SELECT COALESCE(SUM(poi.total_cost), 0)
    FROM purchase_order_items poi
    WHERE poi.purchase_order_id = po.id
  );`);
}

const PO_STATUSES = [
  ['DRAFT', 'PENDING', null],
  ['DRAFT', 'PENDING', 'PIX'],
  ['AWAITING_DELIVERY', 'PAID', 'PIX'],
  ['AWAITING_DELIVERY', 'PAID', 'TRANSFER'],
  ['RECEIVED', 'PAID', 'BOLETO'],
  ['RECEIVED', 'PAID', 'CASH'],
  ['CANCELLED', 'FAILED', 'PIX'],
];

const PAY_STATUSES = ['PAID', 'PAID', 'PAID', 'PENDING', 'FAILED'];
const PAY_METHODS = ['PIX', 'BOLETO', 'CREDIT_CARD'];

/** Simula baixas FEFO + descartes para detectar lotes negativos antes de gravar o SQL. */
function validateCoherenceInMemory() {
  /** @type {Map<number, Array<{ key: string, qty: number, expiryDays: number }>>} */
  const byProduct = new Map();
  for (let i = 0; i < 50; i++) {
    const prodNum = i + 1;
    const bDays = 20 + (i % 25);
    byProduct.set(prodNum, [
      { key: `A-${prodNum}`, qty: 5 + (i % 10), expiryDays: -15 },
      { key: `B-${prodNum}`, qty: 80 + (i * 3) % 200, expiryDays: bDays },
      { key: `C-${prodNum}`, qty: 150 + (i * 5) % 300, expiryDays: 180 + (i % 120) },
    ]);
  }
  for (let p = 0; p < 20; p++) {
    const [st] = PO_STATUSES[p % PO_STATUSES.length];
    if (st === 'RECEIVED') {
      const prodNum = (p % 50) + 1;
      const list = byProduct.get(prodNum);
      list.push({ key: `RCV-${p + 1}`, qty: 20 + p * 2, expiryDays: 365 });
    }
  }

  function allocateFEFO(prodNum, requested) {
    const list = byProduct.get(prodNum);
    const sellable = list
      .filter((b) => b.expiryDays >= 0)
      .sort((a, b) => a.expiryDays - b.expiryDays || a.key.localeCompare(b.key));
    let remaining = requested;
    for (const batch of sellable) {
      if (remaining <= 0) break;
      const take = Math.min(batch.qty, remaining);
      batch.qty -= take;
      remaining -= take;
    }
    if (remaining > 0) {
      throw new Error(`Estoque insuficiente produto ${prodNum} (faltam ${remaining} un.)`);
    }
  }

  for (let o = 0; o < 420; o++) {
    const payM = PAY_METHODS[o % 3];
    let payS = payM === 'CREDIT_CARD' ? 'PAID' : PAY_STATUSES[o % 5];
    if (payS !== 'PAID') continue;
    const prodNum = (o % 50) + 1;
    const qty = 1 + (o % 4);
    allocateFEFO(prodNum, qty);
  }

  for (let d = 0; d < 18; d++) {
    const prodNum = d + 1;
    const disposeQty = Math.min(1 + (d % 3), 5 + ((prodNum - 1) % 10));
    const batch = byProduct.get(prodNum).find((b) => b.key === `A-${prodNum}`);
    if (!batch || batch.qty < disposeQty) {
      throw new Error(`Descarte inválido lote A-${prodNum}: saldo ${batch?.qty ?? 0}, descarte ${disposeQty}`);
    }
    batch.qty -= disposeQty;
  }

  for (const [prodNum, batches] of byProduct) {
    for (const b of batches) {
      if (b.qty < 0) {
        throw new Error(`Lote ${b.key} produto ${prodNum} ficaria negativo (${b.qty})`);
      }
    }
  }
  return true;
}

const PF_NAMES = [
  'Ana Beatriz Ferreira', 'Carlos Eduardo Souza', 'Mariana Oliveira Lima', 'João Pedro Almeida',
  'Fernanda Rocha Martins', 'Ricardo Henrique Dias', 'Juliana Costa Pereira', 'Lucas Gabriel Santos',
  'Patrícia Mendes Barbosa', 'Roberto Carlos Nunes', 'Camila Duarte Freitas', 'Bruno Henrique Castro',
  'Larissa Aparecida Melo', 'Diego Augusto Ribeiro', 'Amanda Cristina Gomes', 'Felipe Andrade Teixeira',
  'Bianca Luiza Carvalho', 'Thiago Rafael Pinto', 'Gabriela Moura Azevedo', 'Vinícius Luís Correia',
  'Helena Vitória Cardoso', 'Matheus Antônio Lopes', 'Isabela Fernanda Vieira', 'Guilherme Augusto Ramos',
  'Beatriz Helena Monteiro', 'Rafaela Cristiane Farias', 'Daniel Augusto Borges', 'Natália Souza Rezende',
  'Eduardo Luiz Cavalcanti', 'Aline Rodrigues Nascimento', 'Paulo Sérgio Machado', 'Renata Aparecida Brito',
  'Gustavo Henrique Peixoto', 'Tatiane Silva Guimarães', 'Rodrigo Martins Coelho', 'Vanessa Lima Prado',
  'André Luiz Tavares', 'Priscila Oliveira Cunha', 'Marcelo Henrique Barros', 'Simone Aparecida Paiva',
  'Leandro Costa Miranda', 'Eliane Rodrigues Pires', 'Fábio José Santana', 'Cristiane Alves Moreira',
  'Henrique Moraes Batista', 'Luciana Pereira Fonseca', 'Sérgio Ricardo Campos', 'Adriana Luiza Matos',
  'Otávio César Aguiar', 'Michele Cristina Duarte', 'Cláudio Henrique Assis', 'Rosana Ferreira Bueno',
  'Igor Samuel Valente', 'Denise Aparecida Neves', 'Caio Eduardo Xavier', 'Sandra Regina Toledo',
];

const PJ_NAMES = [
  'Clínica Bem Viver Ltda', 'Distribuidora Fitonatural ME', 'Laboratório Verde Vida SA',
  'Rede Saúde Integrada Ltda', 'Comercial Ervas do Campo EPP',
];

const STREETS = [
  ['Rua Siqueira Campos', 'Centro', 'Presidente Prudente', 'SP', '19010010'],
  ['Avenida Manoel Goulart', 'Vila Nova', 'Presidente Prudente', 'SP', '19020000'],
  ['Rua Tenente Nicolau Mascarenhas', 'Jardim Paulista', 'Presidente Prudente', 'SP', '19023450'],
  ['Avenida Coronel José Soares Marcondes', 'Centro', 'Presidente Prudente', 'SP', '19010001'],
  ['Rua José Bonifácio', 'Centro', 'Presidente Prudente', 'SP', '19010020'],
  ['Rua Duque de Caxias', 'Centro', 'São Paulo', 'SP', '01025000'],
  ['Avenida Paulista', 'Bela Vista', 'São Paulo', 'SP', '01311000'],
  ['Rua Augusta', 'Consolação', 'São Paulo', 'SP', '01305000'],
  ['Rua XV de Novembro', 'Centro', 'Campinas', 'SP', '13010000'],
  ['Avenida Francisco Glicério', 'Centro', 'Campinas', 'SP', '13012000'],
  ['Rua das Palmeiras', 'Jardim América', 'Ribeirão Preto', 'SP', '14020000'],
  ['Avenida Nove de Julho', 'Centro', 'Ribeirão Preto', 'SP', '14015000'],
  ['Rua Sete de Setembro', 'Centro', 'Bauru', 'SP', '17010000'],
  ['Avenida Nações Unidas', 'Pinheiros', 'São Paulo', 'SP', '04578910'],
  ['Rua Oscar Freire', 'Jardins', 'São Paulo', 'SP', '01426001'],
];

const PRODUCT_TYPES = [
  ['Fitoterápico', 'fitoterapico', 'Produtos de origem vegetal medicinal'],
  ['Suplemento Alimentar', 'suplemento-alimentar', 'Vitaminas, minerais e complementos'],
  ['Higiene Pessoal', 'higiene-pessoal', 'Sabonetes, shampoos naturais'],
  ['Cosmético Natural', 'cosmetico-natural', 'Dermocosméticos à base de ingredientes naturais'],
  ['Chá Medicinal', 'cha-medicinal', 'Chás funcionais e infusões'],
  ['Óleo Essencial', 'oleo-essencial', 'Aromaterapia e uso tópico diluído'],
  ['Homeopatia', 'homeopatia', 'Medicamentos homeopáticos'],
  ['Produto Manipulado', 'produto-manipulado', 'Fórmulas magistrais padronizadas'],
];

const CATEGORIES = [
  [null, 'Fitoterápicos', 'fitoterapicos', 'Linha fitoterápica'],
  [null, 'Suplementos', 'suplementos', 'Suplementação alimentar'],
  [null, 'Chás e Infusões', 'chas-infusiones', 'Chás funcionais'],
  [null, 'Dermocosméticos', 'dermocosmeticos', 'Cuidados com pele e cabelo'],
  [null, 'Higiene Natural', 'higiene-natural', 'Higiene com ingredientes naturais'],
  [null, 'Aromaterapia', 'aromaterapia', 'Óleos essenciais e difusores'],
  [null, 'Manipulados', 'manipulados', 'Fórmulas magistrais'],
  [null, 'Infantil Natural', 'infantil-natural', 'Linha pediátrica natural'],
];

const LABS = [
  ['Herbarium Laboratório Botânico', 'herbarium@lab.com.br'],
  ['Apsen Farmacêutica', 'contato@apsen.com.br'],
  ['Aché Laboratórios Farmacêuticos', 'sac@ache.com.br'],
  ['Legrand Pharma', 'atendimento@legrand.com.br'],
  ['Natulab Laboratório Natural', 'lab@natulab.com.br'],
];

const SUPPLIERS = [
  ['Distribuidora Fitonatural Ltda', 'Fitonatural', 'compras@fitonatural.com.br'],
  ['Ervas do Campo Comercial ME', 'Ervas do Campo', 'vendas@ervasdocampo.com.br'],
  ['Verde Vida Distribuição SA', 'Verde Vida', 'logistica@verdevida.com.br'],
  ['Botica Popular Atacado Ltda', 'Botica Popular', 'atacado@boticapopular.com.br'],
  ['Pharma Nativa Supply Ltda', 'Pharma Nativa', 'supply@pharmanativa.com.br'],
  ['Central de Insumos Naturais EPP', 'Central Naturais', 'pedidos@centralnaturais.com.br'],
  ['MaxFito Distribuidora Ltda', 'MaxFito', 'comercial@maxfito.com.br'],
  ['Organica Trade Importadora SA', 'Organica Trade', 'trade@organica.com.br'],
];

const PRODUCT_NAMES = [
  'Chá de Camomila NeoHerbs 20g', 'Extrato Seco de Valeriana 60 cápsulas', 'Óleo de Melaleuca 30ml',
  'Própolis Verde Spray 30ml', 'Mel de Manuka UMF 10+ 250g', 'Shampoo de Alecrim 300ml',
  'Sabonete de Calêndula 90g', 'Complexo B Natural 60 comprimidos', 'Vitamina D3 2000UI 60 cápsulas',
  'Magnésio Quelato 120 cápsulas', 'Gel de Arnica Montana 100g', 'Pomada de Propolis 30g',
  'Óleo Essencial de Lavanda 10ml', 'Óleo Essencial de Eucalipto 10ml', 'Chá de Erva-Doce 50g',
  'Chá de Hibisco com Gengibre 40g', 'Colágeno Hidrolisado 300g', 'Ômega 3 EPA/DHA 120 cápsulas',
  'Probiótico 10 cepas 30 cápsulas', 'Cúrcuma com Piperina 60 cápsulas', 'Ginkgo Biloba 80mg 60 cápsulas',
  'Passiflora Incarnata 500mg 60 cápsulas', 'Crataegus Oxyacantha 60 cápsulas', 'Gel Hidratante de Aloe Vera 200g',
  'Repelente Natural Citronela 100ml', 'Desodorante Crystal Natural 80g', 'Creme Dental Sem Flúor 90g',
  'Enxaguante Bucal de Própolis 250ml', 'Loção Capilar de Jaborandi 200ml', 'Óleo de Rosa Mosqueta 30ml',
  'Sérum Facial Vitamina C 30ml', 'Máscara de Argila Verde 100g', 'Echinacea Purpurea 60 cápsulas',
  'Guaraná em Pó 100g', 'Maca Peruana 500mg 60 cápsulas', 'Spirulina 500mg 120 comprimidos',
  'Clorella 500mg 120 comprimidos', 'Psyllium 500mg 120 cápsulas', 'Melatonina 3mg 60 cápsulas',
  'Ashwagandha 300mg 60 cápsulas', 'Rhodiola Rosea 300mg 60 cápsulas', 'Calendula Officinalis Tintura 50ml',
  'Hamamelis Virginiana Tônico 200ml', 'Calêndula Pomada Infantil 50g', 'Óleo de Copaíba 30ml',
  'Spray Nasal Sal Marinho 50ml', 'Xarope de Própolis Infantil 100ml', 'Fórmula Magistral Base Creme 100g',
  'Homeopatia Ignatia 30CH', 'Homeopatia Arnica 6CH', 'Fitoterápico Boldo do Chile 60 cápsulas',
];

async function main() {
  const hash = await bcrypt.hash(PASSWORD_PLAIN, 10);
  const lines = [];

  lines.push('-- ============================================================');
  lines.push('-- NEOFARMA — SEED COMPLETO PARA TESTES DE ESTRESSE');
  lines.push('-- Gerado por: node scripts/generate_seed_stress_sql.js');
  lines.push('-- Pré-requisito: schema criado (DB_Neofarma_clean.sql + migration se necessário)');
  lines.push('-- Senha padrão de TODOS os usuários seed: 123456');
  lines.push('-- ============================================================');
  lines.push('');
  lines.push('USE neofarma;');
  lines.push('');
  lines.push('SET NAMES utf8mb4;');
  lines.push('SET FOREIGN_KEY_CHECKS = 0;');
  lines.push('');

  // Cleanup
  lines.push('-- Limpeza de execuções anteriores (prefixo stress)');
  const cleanTables = [
    `DELETE FROM inventory_disposals WHERE product_id IN (SELECT id FROM products WHERE slug LIKE '${PREFIX}-%')`,
    `DELETE FROM order_pending_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '${PREFIX}.seed%'))`,
    `DELETE FROM order_items WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '${PREFIX}.seed%'))`,
    `DELETE FROM payments WHERE order_id IN (SELECT id FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '${PREFIX}.seed%'))`,
    `DELETE FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '${PREFIX}.seed%')`,
    `DELETE FROM purchase_order_items WHERE purchase_order_id IN (SELECT id FROM purchase_orders WHERE notes LIKE '${PREFIX}%')`,
    `DELETE FROM purchase_orders WHERE notes LIKE '${PREFIX}%'`,
    `DELETE FROM service_appointments WHERE customer_email LIKE '${PREFIX}.seed%' OR customer_name LIKE 'Cliente Stress%'`,
    `DELETE FROM service_professional_availability WHERE professional_id IN (SELECT id FROM service_professionals WHERE email LIKE '${PREFIX}.seed%')`,
    `DELETE FROM service_professionals WHERE email LIKE '${PREFIX}.seed%'`,
    `DELETE FROM prescription_items WHERE prescription_id IN (SELECT id FROM prescriptions WHERE notes LIKE '${PREFIX}%')`,
    `DELETE FROM prescriptions WHERE notes LIKE '${PREFIX}%'`,
    `DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE slug LIKE '${PREFIX}-%')`,
    `DELETE FROM product_categories WHERE product_id IN (SELECT id FROM products WHERE slug LIKE '${PREFIX}-%')`,
    `DELETE FROM inventory_batches WHERE product_id IN (SELECT id FROM products WHERE slug LIKE '${PREFIX}-%')`,
    `DELETE FROM products WHERE slug LIKE '${PREFIX}-%'`,
    `DELETE FROM customer_addresses WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '${PREFIX}.seed%')`,
    `DELETE FROM customers WHERE user_id IN (SELECT id FROM users WHERE email LIKE '${PREFIX}.seed%')`,
    `DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE email LIKE '${PREFIX}.seed%')`,
    `DELETE FROM users WHERE email LIKE '${PREFIX}.seed%'`,
    `DELETE FROM suppliers WHERE email LIKE '%stress%' OR trade_name LIKE 'Stress %'`,
    `DELETE FROM labs WHERE email LIKE '%stress%' OR name LIKE 'Stress Lab %'`,
    `DELETE FROM addresses WHERE street LIKE 'Stress Seed %'`,
    `DELETE FROM categories WHERE slug LIKE '${PREFIX}-%'`,
    `DELETE FROM product_types WHERE slug LIKE '${PREFIX}-%'`,
  ];
  cleanTables.forEach((q) => lines.push(q + ';'));
  lines.push('');
  lines.push('SET FOREIGN_KEY_CHECKS = 1;');
  lines.push('');

  // Roles (ensure)
  lines.push(`INSERT INTO roles (name, description) VALUES
  ('ADMIN','Administrador'),('FUNCIONARIO','Funcionário'),('ESTOQUISTA','Estoquista'),('CLIENTE','Cliente')
ON DUPLICATE KEY UPDATE description=VALUES(description);`);

  // Product types
  lines.push('');
  lines.push('-- Tipos de produto (RF_B3)');
  PRODUCT_TYPES.forEach(([name, slug, desc], i) => {
    lines.push(`INSERT INTO product_types (name, slug, description, is_active) VALUES (${esc(name)}, ${esc(`${PREFIX}-${slug}`)}, ${esc(desc)}, 1);`);
  });

  // Categories
  lines.push('');
  lines.push('-- Categorias (RF_B4)');
  CATEGORIES.forEach(([parent, name, slug, desc]) => {
    lines.push(`INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (${parent === null ? 'NULL' : parent}, ${esc(name)}, ${esc(`${PREFIX}-${slug}`)}, ${esc(desc)}, 1);`);
  });

  // Addresses - 30
  lines.push('');
  lines.push('-- Endereços reais (Brasil)');
  for (let i = 0; i < 30; i++) {
    const [street, district, city, state, zip] = STREETS[i % STREETS.length];
    const num = 100 + (i * 17) % 900;
    const comp = i % 4 === 0 ? `Sala ${100 + i}` : null;
    lines.push(`INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES (${esc(`Stress Seed ${street}`)}, ${esc(String(num))}, ${comp ? esc(comp) : 'NULL'}, ${esc(district)}, ${esc(city)}, ${esc(state)}, 'Brasil', ${esc(zip)});`);
  }

  // Labs & suppliers - use address ids via variables in comments; we'll use subqueries in inserts
  lines.push('');
  lines.push('SET @addr_base := (SELECT MIN(id) FROM addresses WHERE street LIKE \'Stress Seed %\');');

  lines.push('');
  lines.push('-- Laboratórios');
  LABS.forEach(([name, email], i) => {
    const cnpj = cnpjFromBase(200000000000 + i * 1111);
    lines.push(`INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES (${esc(`Stress Lab ${name}`)}, ${esc(cnpj)}, ${esc(email.replace('@', `+${i}@`))}, ${esc(`18${99001000 + i}`)}, @addr_base + ${i}, 1);`);
  });

  lines.push('');
  lines.push('-- Fornecedores');
  SUPPLIERS.forEach(([corp, trade, email], i) => {
    const cnpj = cnpjFromBase(300000000000 + i * 2222);
    lines.push(`INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES (${esc(corp)}, ${esc(`Stress ${trade}`)}, ${esc(cnpj)}, ${esc(email.replace('@', `+${i}@`))}, ${esc(`18${99102000 + i}`)}, @addr_base + ${(i + 5) % 30}, ${i === 7 ? 0 : 1});`);
  });

  lines.push('SET @lab_id := (SELECT id FROM labs WHERE name LIKE \'Stress Lab %\' ORDER BY id LIMIT 1);');
  lines.push('SET @supplier_id := (SELECT id FROM suppliers WHERE trade_name LIKE \'Stress %\' ORDER BY id LIMIT 1);');
  lines.push('SET @type_fit := (SELECT id FROM product_types WHERE slug = \'stress-fitoterapico\' LIMIT 1);');
  lines.push('SET @type_sup := (SELECT id FROM product_types WHERE slug = \'stress-suplemento-alimentar\' LIMIT 1);');
  lines.push('SET @cat_fito := (SELECT id FROM categories WHERE slug = \'stress-fitoterapicos\' LIMIT 1);');
  lines.push('SET @cat_sup := (SELECT id FROM categories WHERE slug = \'stress-suplementos\' LIMIT 1);');

  // Staff users
  lines.push('');
  lines.push('-- Funcionários / perfis de acesso (RF_B1)');
  const staff = [
    ['ADMIN', 'Marcos Antônio Ribeiro', 'admin', 'Gerente Geral', 8500],
    ['FUNCIONARIO', 'Eliane Souza Moraes', 'funcionario', 'Atendente Farmácia', 3200],
    ['ESTOQUISTA', 'Robson Pereira Lima', 'estoquista', 'Estoquista', 2800],
  ];
  staff.forEach(([role, name, login, title, salary], i) => {
    const cpf = cpfFromBase(900000000 + i);
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(`${PREFIX}.seed.${login}@neofarma.com`)}, ${esc(hash)}, ${esc(cpf)}, ${esc(`189${9700100 + i}`)}, '1985-06-15', 1 FROM roles r WHERE r.name=${esc(role)} LIMIT 1;`);
    lines.push(`INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', ${salary}, ${esc(title)} FROM users u WHERE u.email=${esc(`${PREFIX}.seed.${login}@neofarma.com`)} LIMIT 1;`);
  });

  // Clients - 55 PF + 5 PJ style (longer doc)
  lines.push('');
  lines.push('-- Clientes (PF e PJ para relatórios RF_S3)');
  for (let i = 0; i < 55; i++) {
    const name = PF_NAMES[i % PF_NAMES.length] + (i >= PF_NAMES.length ? ` ${Math.floor(i / PF_NAMES.length) + 1}` : '');
    const cpf = cpfFromBase(100000001 + i);
    const email = `${PREFIX}.seed.cliente${String(i + 1).padStart(2, '0')}@neofarma.com`;
    const active = i === 54 ? 0 : 1;
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(email)}, ${esc(hash)}, ${esc(cpf)}, ${esc(`179${9600100 + i}`)}, ${esc(`19${70 + (i % 30)}-${String((i % 12) + 1).padStart(2, '0')}-15`)}, ${active} FROM roles r WHERE r.name='CLIENTE' LIMIT 1;`);
    lines.push(`INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + ${i % 30}, ${(i * 17) % 500} FROM users u WHERE u.email=${esc(email)} LIMIT 1;`);
    lines.push(`INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + ${i % 30}, 'Principal', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(email)} LIMIT 1;`);
  }
  for (let j = 0; j < 5; j++) {
    const name = PJ_NAMES[j];
    const cnpj = cnpjFromBase(400000000000 + j * 3333);
    const email = `${PREFIX}.seed.pj${String(j + 1).padStart(2, '0')}@neofarma.com`;
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(email)}, ${esc(hash)}, ${esc(cnpj)}, ${esc(`113${5500100 + j}`)}, NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;`);
    lines.push(`INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + ${(55 + j) % 30}, ${100 + j * 50} FROM users u WHERE u.email=${esc(email)} LIMIT 1;`);
    lines.push(`INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + ${(55 + j) % 30}, 'Sede', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(email)} LIMIT 1;`);
  }

  // Products - 50
  lines.push('');
  lines.push('-- Produtos (RF_B2) — mix de status e promoções');
  for (let i = 0; i < 50; i++) {
    const name = PRODUCT_NAMES[i % PRODUCT_NAMES.length];
    const slug = `${PREFIX}-prod-${String(i + 1).padStart(3, '0')}`;
    const sku = `SKU-${PREFIX.toUpperCase()}-${String(i + 1).padStart(4, '0')}`;
    const ean = `789${String(1000000000 + i).slice(-10)}`;
    const price = (12.9 + (i % 20) * 3.5).toFixed(2);
    const promo = i % 4 === 0 ? (Number(price) * 0.85).toFixed(2) : null;
    const status = i % 17 === 0 ? 'DISCONTINUED' : i % 11 === 0 ? 'INACTIVE' : 'ACTIVE';
    const typeVar = i % 2 === 0 ? '@type_fit' : '@type_sup';
    const rx = i % 9 === 0 ? 1 : 0;
    lines.push(`INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, ${typeVar}, ${esc(name)}, ${esc(slug)}, ${esc(sku)}, ${esc(ean)}, ${esc(`Produto seed ${name} para testes NeoFarma.`)}, ${esc('Composição conforme rótulo.')}, ${esc('Seguir orientação farmacêutica.')}, ${rx}, ${price}, ${promo ? promo : 'NULL'}, ${esc(status)});`);
    lines.push(`INSERT INTO product_categories (product_id, category_id) SELECT p.id, IF(${i} % 2 = 0, @cat_fito, @cat_sup) FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
    lines.push(`INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-${(i % 5) + 1}.webp', 0 FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
  }

  // Inventory batches - 3 per product = 150
  lines.push('');
  lines.push('-- Lotes FEFO: vencidos, próximos e válidos');
  for (let i = 0; i < 50; i++) {
    const slug = `${PREFIX}-prod-${String(i + 1).padStart(3, '0')}`;
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(`${PREFIX.toUpperCase()}-A-${i + 1}`)}, DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), ${5 + (i % 10)} FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(`${PREFIX.toUpperCase()}-B-${i + 1}`)}, DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL ${20 + (i % 25)} DAY), ${80 + (i * 3) % 200} FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(`${PREFIX.toUpperCase()}-C-${i + 1}`)}, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL ${180 + (i % 120)} DAY), ${150 + (i * 5) % 300} FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
  }

  // Purchase orders
  lines.push('');
  lines.push('-- Compras (RF_F3) — todos os status');
  for (let p = 0; p < 20; p++) {
    const [st, paySt, payM] = PO_STATUSES[p % PO_STATUSES.length];
    const prodIdx = (p % 50) + 1;
    const slug = `${PREFIX}-prod-${String(prodIdx).padStart(3, '0')}`;
    const qty = 20 + p * 2;
    const cost = (8 + (p % 10)).toFixed(2);
    const itemTotal = (qty * Number(cost)).toFixed(2);
    const poNotes = `${PREFIX} pedido compra #${p + 1}`;
    const rcvBatch = `${PREFIX.toUpperCase()}-RCV-${p + 1}`;
    lines.push(`INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL ${p * 3} DAY), DATE_ADD(NOW(), INTERVAL ${7 + p} DAY), ${esc(st)}, ${esc(paySt)}, ${payM ? esc(payM) : 'NULL'}, ${itemTotal}, ${esc(poNotes)};`);
    lines.push(`INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, ${qty}, ${st === 'RECEIVED' ? qty : 0}, ${st === 'RECEIVED' ? esc(rcvBatch) : 'NULL'}, ${st === 'RECEIVED' ? 'DATE_ADD(CURDATE(), INTERVAL 365 DAY)' : 'NULL'}, ${cost}, ${itemTotal}
FROM purchase_orders po, products pr WHERE po.notes=${esc(poNotes)} AND pr.slug=${esc(slug)} LIMIT 1;`);
    if (st === 'RECEIVED') {
      lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, ${esc(rcvBatch)}, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), ${qty}
FROM products pr WHERE pr.slug=${esc(slug)} LIMIT 1;`);
      lines.push(`UPDATE purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id
INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = ${esc(rcvBatch)}
SET poi.batch_id = ib.id
WHERE po.notes = ${esc(poNotes)};`);
    }
  }

  // Orders - 420
  lines.push('');
  lines.push('-- Pedidos e pagamentos (RF_F2 / RF_F8) — paginação e inadimplência');
  const orderStatuses = ['DELIVERED', 'SHIPPED', 'PROCESSING', 'CONFIRMED', 'CANCELLED'];

  for (let o = 0; o < 420; o++) {
    const custIdx = (o % 60) + 1;
    const email = custIdx <= 55
      ? `${PREFIX}.seed.cliente${String(custIdx).padStart(2, '0')}@neofarma.com`
      : `${PREFIX}.seed.pj${String(custIdx - 55).padStart(2, '0')}@neofarma.com`;
    const payM = PAY_METHODS[o % 3];
    let payS = PAY_METHODS[o % 3] === 'CREDIT_CARD' ? 'PAID' : PAY_STATUSES[o % 5];
    const ordS = payS === 'FAILED' || payS === 'PENDING' && o % 7 === 0 ? 'CONFIRMED' : orderStatuses[o % 5];
    const finalOrdS = payS === 'FAILED' ? 'CANCELLED' : ordS;
    const daysAgo = o % 120;
    const prodIdx = (o % 50) + 1;
    const slug = `${PREFIX}-prod-${String(prodIdx).padStart(3, '0')}`;
    const qty = 1 + (o % 4);
    const unit = (15 + (prodIdx % 10) * 2.5).toFixed(2);
    const lineTotal = (qty * Number(unit)).toFixed(2);
    const subtotal = lineTotal;
    const ship = (o % 3 === 0 ? 0 : 12.9).toFixed(2);
    const total = (Number(subtotal) + Number(ship)).toFixed(2);

    lines.push(`INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, ${esc(finalOrdS)}, ${subtotal}, ${ship}, ${total}, ${esc(payM)}, ${esc(payS)}, '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL ${daysAgo} DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(email)} LIMIT 1;`);

    lines.push(`SET @last_order := LAST_INSERT_ID();`);

    if (payS === 'PAID') {
      lines.push(`INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), ${qty}, ${unit}, ${lineTotal}
FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
    } else {
      lines.push(`INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, ${qty}, ${unit}, ${lineTotal} FROM products p WHERE p.slug=${esc(slug)} LIMIT 1;`);
    }

    const pixVal = payM === 'PIX' ? esc(`00020126580014BR.GOV.BCB.PIX0136${PREFIX}-pix-${o}`) : 'NULL';
    const boletoVal = payM === 'BOLETO' ? esc(`23793.${String(o).padStart(10, '0')}`) : 'NULL';
    const cardLast4 = payM === 'CREDIT_CARD' ? esc(String(1000 + (o % 9000)).slice(-4)) : 'NULL';
    const installments = payM === 'CREDIT_CARD' ? 1 + (o % 6) : 'NULL';
    lines.push(`INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, ${esc(payM)}, ${esc(payS)}, ${total}, ${pixVal}, ${boletoVal}, ${cardLast4}, ${installments});`);
  }

  // Disposals — lote A vencido; quantidade sempre <= saldo inicial do lote
  lines.push('');
  lines.push('-- Descartes (RF_F5) — lotes A vencidos, parcial ou total');
  for (let d = 0; d < 18; d++) {
    const prodNum = d + 1;
    const slug = `${PREFIX}-prod-${String(prodNum).padStart(3, '0')}`;
    const batchCode = `${PREFIX.toUpperCase()}-A-${prodNum}`;
    const batchInitialQty = 5 + ((prodNum - 1) % 10);
    const disposeQty = Math.min(1 + (d % 3), batchInitialQty);
    const reasons = ['Produto vencido em conferência', 'Embalagem avariada', 'Quebra operacional', 'Contaminação visual'];
    lines.push(`INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, ${disposeQty}, ${esc(reasons[d % 4])}, (SELECT u.id FROM users u WHERE u.email=${esc(`${PREFIX}.seed.estoquista@neofarma.com`)} LIMIT 1), DATE_SUB(NOW(), INTERVAL ${d * 5} DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code=${esc(batchCode)} WHERE p.slug=${esc(slug)} LIMIT 1;`);
  }

  addCoherenceBlock(lines);

  // Service professionals
  lines.push('');
  lines.push('-- Profissionais e agenda (RF_F6/F7)');
  const pros = [
    ['Dra. Helena Martins', 'FARMACEUTICO', 'CRF', 'SP', '45678'],
    ['Enf. Paulo Ricardo Dias', 'ENFERMEIRO', 'COREN', 'SP', '123456'],
    ['Dra. Camila Rocha', 'FARMACEUTICO', 'CRF', 'SP', '78901'],
    ['Enf. Juliana Freitas', 'ENFERMEIRO', 'COREN', 'SP', '654321'],
    ['Dr. Roberto Alves', 'FARMACEUTICO', 'CRF', 'SP', '23456'],
    ['Enf. Marcos Vinícius', 'ENFERMEIRO', 'COREN', 'SP', '987654'],
  ];
  pros.forEach(([name, role, council, uf, num], i) => {
    lines.push(`INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES (${esc(name)}, ${esc(role)}, ${esc(`${PREFIX}.seed.pro${i + 1}@neofarma.com`)}, ${esc(`189${9800100 + i}`)}, ${esc(council)}, ${esc(uf)}, ${esc(num)}, ${i === 5 ? 0 : 1});`);
    for (let dow = 1; dow <= 5; dow++) {
      lines.push(`INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, ${dow}, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email=${esc(`${PREFIX}.seed.pro${i + 1}@neofarma.com`)} LIMIT 1;`);
    }
  });

  lines.push(`INSERT INTO service_holidays (holiday_date, name, is_active) VALUES (DATE_ADD(CURDATE(), INTERVAL 30 DAY), 'Feriado seed teste', 1) ON DUPLICATE KEY UPDATE name=VALUES(name);`);

  const apptStatuses = ['COMPLETED', 'CONFIRMED', 'IN_PROGRESS', 'RESERVED', 'NO_SHOW', 'INCOMPLETE', 'CANCELLED', 'PAYMENT_FAILED'];
  for (let a = 0; a < 130; a++) {
    const custIdx = (a % 55) + 1;
    const email = `${PREFIX}.seed.cliente${String(custIdx).padStart(2, '0')}@neofarma.com`;
    const st = apptStatuses[a % apptStatuses.length];
    const paySt = st === 'COMPLETED' || st === 'IN_PROGRESS' || st === 'CONFIRMED' ? 'PAID' : st === 'NO_SHOW' || st === 'INCOMPLETE' ? 'REFUNDED_PARTIAL' : st === 'PAYMENT_FAILED' ? 'FAILED' : 'PENDING';
    const svcId = 1 + (a % 10);
    const proId = 1 + (a % 5);
    const offsetDays = -60 + (a % 90);
    lines.push(`INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT ${svcId}, (SELECT id FROM service_professionals WHERE email=${esc(`${PREFIX}.seed.pro${((a % 5) + 1)}@neofarma.com`)} LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(${a} % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=${svcId} LIMIT 1),
  DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 10 HOUR,
  ${esc(st)}, ${esc(paySt)}, IF(${a} % 3 = 0, 'PIX', 'CASH'), IF(${a} % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  ${st === 'COMPLETED' ? esc('Atendimento realizado conforme protocolo farmacêutico.') : 'NULL'},
  ${st === 'NO_SHOW' ? '19.95' : st === 'INCOMPLETE' ? '24.95' : 'NULL'},
  ${st === 'COMPLETED' ? `DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 10 HOUR` : 'NULL'},
  DATE_SUB(NOW(), INTERVAL ${Math.abs(offsetDays)} DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(email)} LIMIT 1;`);
  }

  // Prescriptions
  lines.push('');
  lines.push('-- Receitas');
  for (let r = 0; r < 12; r++) {
    const email = `${PREFIX}.seed.cliente${String((r % 55) + 1).padStart(2, '0')}@neofarma.com`;
    const slug = `${PREFIX}-prod-${String((r % 50) + 1).padStart(3, '0')}`;
    const rxNotes = `${PREFIX} receita teste #${r + 1}`;
    lines.push(`INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, ${esc(`Dr. Médico Seed ${r + 1}`)}, ${esc(`CRM-SP ${100000 + r}`)}, DATE_SUB(CURDATE(), INTERVAL ${r * 10} DAY), DATE_ADD(CURDATE(), INTERVAL ${90 - r} DAY), ${esc(rxNotes)}
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(email)} LIMIT 1;`);
    lines.push(`INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, '1 cápsula ao dia', 2, ${r % 2} FROM prescriptions pr, products p WHERE pr.notes=${esc(rxNotes)} AND p.slug=${esc(slug)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Resumo');
  lines.push(`SELECT 'Usuários stress' AS item, COUNT(*) AS qtd FROM users WHERE email LIKE '${PREFIX}.seed%'`);
  lines.push('UNION ALL SELECT \'Produtos stress\', COUNT(*) FROM products WHERE slug LIKE \'stress-%\'');
  lines.push('UNION ALL SELECT \'Pedidos stress\', COUNT(*) FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE \'stress.seed%\')');
  lines.push('UNION ALL SELECT \'Agendamentos stress\', COUNT(*) FROM service_appointments WHERE customer_email LIKE \'stress.seed%\'');
  lines.push(';');
  lines.push('');
  lines.push('-- Logins de teste (senha: 123456)');
  lines.push(`-- Admin:     ${PREFIX}.seed.admin@neofarma.com`);
  lines.push(`-- Func.:     ${PREFIX}.seed.funcionario@neofarma.com`);
  lines.push(`-- Estoq.:    ${PREFIX}.seed.estoquista@neofarma.com`);
  lines.push(`-- Cliente:   ${PREFIX}.seed.cliente01@neofarma.com`);
  lines.push(`-- Cliente PJ: ${PREFIX}.seed.pj01@neofarma.com`);

  validateCoherenceInMemory();

  fs.writeFileSync(OUT, lines.join('\n'), 'utf8');
  console.log(`Gerado: ${OUT} (${lines.length} linhas)`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
