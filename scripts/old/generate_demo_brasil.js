/**
 * Gera scripts/demo_neofarma.sql — base de demonstração realista NeoFarma.
 * Pré-requisito: schema DB_Neofarma_clean.sql já aplicado.
 *
 * Uso: node scripts/generate_demo_brasil.js
 */
const fs = require('fs');
const path = require('path');
const bcrypt = require('bcrypt');
const { isValidEan13 } = require('../util/ean13');

const OUT = path.join(__dirname, 'demo_neofarma.sql');
const EMAIL_DOMAIN = '@loja.neofarma.com.br';
const PASSWORD_PLAIN = 'NeoFarma@2026';

const COUNTS = {
  products: 110,
  clientsPf: 28,
  clientsPj: 4,
  orders: 75,
  purchaseOrders: 12,
  disposals: 10,
  appointments: 45,
  prescriptions: 10,
  addresses: 32,
};

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

function makeEan13(i) {
  const base = '789' + String(100000000 + i).padStart(9, '0');
  let sum = 0;
  for (let j = 0; j < 12; j++) {
    const n = parseInt(base[j], 10);
    sum += j % 2 === 0 ? n : n * 3;
  }
  const check = (10 - (sum % 10)) % 10;
  const ean = base + String(check);
  if (!isValidEan13(ean)) throw new Error(`EAN inválido gerado: ${ean}`);
  return ean;
}

function slugify(name) {
  return name
    .toLowerCase()
    .normalize('NFD')
    .replace(/[\u0300-\u036f]/g, '')
    .replace(/[^a-z0-9]+/g, '-')
    .replace(/^-|-$/g, '')
    .slice(0, 90);
}

function esc(v) {
  if (v === null || v === undefined) return 'NULL';
  return `'${String(v).replace(/\\/g, '\\\\').replace(/'/g, "''")}'`;
}

function emailLocal(part) {
  return `${part}${EMAIL_DOMAIN}`;
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

const PF_NAMES = [
  'Ana Beatriz Ferreira', 'Carlos Eduardo Souza', 'Mariana Oliveira Lima', 'João Pedro Almeida',
  'Fernanda Rocha Martins', 'Ricardo Henrique Dias', 'Juliana Costa Pereira', 'Lucas Gabriel Santos',
  'Patrícia Mendes Barbosa', 'Roberto Carlos Nunes', 'Camila Duarte Freitas', 'Bruno Henrique Castro',
  'Larissa Aparecida Melo', 'Diego Augusto Ribeiro', 'Amanda Cristina Gomes', 'Felipe Andrade Teixeira',
  'Bianca Luiza Carvalho', 'Thiago Rafael Pinto', 'Gabriela Moura Azevedo', 'Vinícius Luís Correia',
  'Helena Vitória Cardoso', 'Matheus Antônio Lopes', 'Isabela Fernanda Vieira', 'Guilherme Augusto Ramos',
  'Beatriz Helena Monteiro', 'Rafaela Cristiane Farias', 'Daniel Augusto Borges', 'Natália Souza Rezende',
];

const PJ_NAMES = [
  'Clínica Bem Viver Ltda', 'Distribuidora Fitonatural ME', 'Laboratório Verde Vida SA', 'Rede Saúde Integrada Ltda',
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
  ['Fitoterápicos', 'fitoterapicos', 'Linha fitoterápica'],
  ['Suplementos', 'suplementos', 'Suplementação alimentar'],
  ['Chás e Infusões', 'chas-infusiones', 'Chás funcionais'],
  ['Dermocosméticos', 'dermocosmeticos', 'Cuidados com pele e cabelo'],
  ['Higiene Natural', 'higiene-natural', 'Higiene com ingredientes naturais'],
  ['Aromaterapia', 'aromaterapia', 'Óleos essenciais'],
  ['Manipulados', 'manipulados', 'Fórmulas magistrais'],
  ['Infantil Natural', 'infantil-natural', 'Linha pediátrica natural'],
];

const LABS = [
  ['Herbarium Laboratório Botânico', 'contato@herbarium.com.br'],
  ['Apsen Farmacêutica', 'sac@apsen.com.br'],
  ['Aché Laboratórios Farmacêuticos', 'sac@ache.com.br'],
  ['Legrand Pharma', 'atendimento@legrand.com.br'],
  ['Natulab Laboratório Natural', 'comercial@natulab.com.br'],
  ['Medley Farmacêutica', 'atendimento@medley.com.br'],
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
  'Magnésio Quelato 120 cápsulas', 'Gel de Arnica Montana 100g', 'Pomada de Própolis 30g',
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
  'Dipirona Monoidratada 500mg 20 comprimidos', 'Paracetamol 750mg 20 comprimidos', 'Ibuprofeno 400mg 20 cápsulas',
  'Loratadina 10mg 12 comprimidos', 'Omeprazol 20mg 28 cápsulas', 'Soro Fisiológico 0,9% 500ml',
  'Fralda Descartável P 36un', 'Lenço Umedecido 96un', 'Protetor Solar FPS 50 120ml',
  'Multivitamínico Mulher 60 cápsulas', 'Multivitamínico Homem 60 cápsulas', 'Zinco Quelato 30mg 60 cápsulas',
  'Ferro Quelato 30mg 60 cápsulas', 'Vitamina C 1000mg 30 comprimidos', 'Vitamina B12 1000mcg 60 cápsulas',
  'Chá de Espinheira-Santa 50g', 'Chá de Carqueja 50g', 'Chá de Boldo 50g', 'Chá de Maracujá 50g',
  'Óleo Essencial de Tea Tree 10ml', 'Óleo Essencial de Hortelã-Pimenta 10ml', 'Difusor Ultrassônico 300ml',
  'Hidratante Corporal Urucum 200ml', 'Condicionador de Babosa 300ml', 'Sabonete Líquido Neutro 500ml',
  'Pasta de Dentes Própolis 90g', 'Fio Dental com Cera 50m', 'Escova Dental Macia',
  'Whey Protein Natural 900g', 'BCAA 2:1:1 120 cápsulas', 'Creatina Monoidratada 300g',
  'Glucosamina + Condroitina 60 cápsulas', 'Colágeno Tipo II 60 cápsulas', 'Hyaluronic Acid 50mg 60 cápsulas',
  'Berberina 500mg 60 cápsulas', 'Resveratrol 200mg 60 cápsulas', 'Coenzima Q10 100mg 60 cápsulas',
  'Óleo de Prímula 1000mg 60 cápsulas', 'Equinácea + Vitamina C 60 cápsulas', 'Própolis Verde 60 cápsulas',
  'Melatonina Líquida 30ml', 'Valeriana Gotas 20ml', 'Passiflora Gotas 20ml',
  'Pomada Hemorroidária Natural 30g', 'Creme para Assaduras 60g', 'Talco Natural 100g',
  'Álcool Gel 70% 500ml', 'Água Oxigenada 10 Volumes 100ml', 'Iodopovidona Tópico 100ml',
  'Termômetro Digital', 'Medidor de Pressão de Pulso', 'Glicosímetro + 10 tiras',
  'Máscara Descartável Tripla 50un', 'Luvas de Procedimento 100un', 'Atadura Crepe 10cm',
  'Homeopatia Pulsatilla 30CH', 'Homeopatia Nux Vomica 30CH', 'Homeopatia Rhus Toxicodendron 6CH',
  'Fitoterápico Artichoke 60 cápsulas', 'Fitoterápico Milk Thistle 60 cápsulas', 'Fitoterápico Saw Palmetto 60 cápsulas',
  'Óleo de Coco Extra Virgem 200ml', 'Açúcar de Coco 300g', 'Farinha de Amêndoas 200g',
];

function validateCoherenceInMemory(productCount, orderCount, disposalCount, poCount) {
  const byProduct = new Map();
  for (let i = 0; i < productCount; i++) {
    const prodNum = i + 1;
    const bDays = 20 + (i % 25);
    byProduct.set(prodNum, [
      { key: `L24-A-${String(prodNum).padStart(3, '0')}`, qty: 5 + (i % 10), expiryDays: -15 },
      { key: `L24-B-${String(prodNum).padStart(3, '0')}`, qty: 80 + (i * 3) % 200, expiryDays: bDays },
      { key: `L24-C-${String(prodNum).padStart(3, '0')}`, qty: 150 + (i * 5) % 300, expiryDays: 180 + (i % 120) },
    ]);
  }
  for (let p = 0; p < poCount; p++) {
    const [st] = PO_STATUSES[p % PO_STATUSES.length];
    if (st === 'RECEIVED') {
      const prodNum = (p % productCount) + 1;
      byProduct.get(prodNum).push({ key: `L24-R-${String(p + 1).padStart(3, '0')}`, qty: 20 + p * 2, expiryDays: 365 });
    }
  }

  function allocateFEFO(prodNum, requested) {
    const list = byProduct.get(prodNum);
    const sellable = list.filter((b) => b.expiryDays >= 0).sort((a, b) => a.expiryDays - b.expiryDays || a.key.localeCompare(b.key));
    let remaining = requested;
    for (const batch of sellable) {
      if (remaining <= 0) break;
      const take = Math.min(batch.qty, remaining);
      batch.qty -= take;
      remaining -= take;
    }
    if (remaining > 0) throw new Error(`Estoque insuficiente produto ${prodNum} (faltam ${remaining})`);
  }

  for (let o = 0; o < orderCount; o++) {
    const payM = PAY_METHODS[o % 3];
    const payS = payM === 'CREDIT_CARD' ? 'PAID' : PAY_STATUSES[o % 5];
    if (payS !== 'PAID') continue;
    allocateFEFO((o % productCount) + 1, 1 + (o % 4));
  }

  for (let d = 0; d < disposalCount; d++) {
    const prodNum = d + 1;
    const disposeQty = Math.min(1 + (d % 3), 5 + ((prodNum - 1) % 10));
    const batch = byProduct.get(prodNum).find((b) => b.key.startsWith('L24-A-'));
    if (!batch || batch.qty < disposeQty) {
      throw new Error(`Descarte inválido produto ${prodNum}`);
    }
    batch.qty -= disposeQty;
  }

  for (const [prodNum, batches] of byProduct) {
    for (const b of batches) {
      if (b.qty < 0) throw new Error(`Lote ${b.key} produto ${prodNum} negativo (${b.qty})`);
    }
  }
}

function addCoherenceBlock(lines) {
  lines.push('');
  lines.push('-- Coerência: totais de compra, baixa de estoque e descartes');
  lines.push(`UPDATE purchase_orders po
SET po.total_amount = (
  SELECT COALESCE(SUM(poi.total_cost), 0) FROM purchase_order_items poi WHERE poi.purchase_order_id = po.id
)
WHERE po.notes LIKE 'OC-2024-%';`);

  lines.push(`UPDATE inventory_batches ib
INNER JOIN (
  SELECT oi.batch_id, SUM(oi.quantity) AS sold_qty
  FROM order_items oi
  INNER JOIN orders o ON o.id = oi.order_id
  INNER JOIN customers c ON c.id = o.customer_id
  INNER JOIN users u ON u.id = c.user_id
  WHERE u.email LIKE ${esc(`%${EMAIL_DOMAIN}`)} AND o.payment_status = 'PAID'
  GROUP BY oi.batch_id
) s ON s.batch_id = ib.id
SET ib.quantity = ib.quantity - s.sold_qty;`);

  lines.push(`UPDATE inventory_batches ib
INNER JOIN (
  SELECT d.batch_id, SUM(d.quantity) AS disposed_qty
  FROM inventory_disposals d
  INNER JOIN products p ON p.id = d.product_id
  WHERE p.sku LIKE 'NF-%'
  GROUP BY d.batch_id
) x ON x.batch_id = ib.id
SET ib.quantity = ib.quantity - x.disposed_qty;`);

  lines.push('');
  lines.push('-- Validação (esperado: 0 problemas)');
  lines.push(`SELECT 'lotes_negativos' AS check_name, COUNT(*) AS problemas FROM inventory_batches ib
INNER JOIN products p ON p.id = ib.product_id WHERE p.sku LIKE 'NF-%' AND ib.quantity < 0`);
  lines.push(`UNION ALL SELECT 'pedido_pago_sem_itens', COUNT(*) FROM orders o
INNER JOIN customers c ON c.id = o.customer_id INNER JOIN users u ON u.id = c.user_id
WHERE u.email LIKE ${esc(`%${EMAIL_DOMAIN}`)} AND o.payment_status = 'PAID'
AND NOT EXISTS (SELECT 1 FROM order_items oi WHERE oi.order_id = o.id)`);
  lines.push(`UNION ALL SELECT 'compra_recebida_sem_lote', COUNT(*) FROM purchase_order_items poi
INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
WHERE po.notes LIKE 'OC-2024-%' AND po.status = 'RECEIVED' AND poi.quantity_received > 0 AND poi.batch_id IS NULL;`);
}

async function main() {
  const hash = await bcrypt.hash(PASSWORD_PLAIN, 10);
  const lines = [];
  const { products: P, clientsPf, clientsPj, orders: O, purchaseOrders: PO, disposals: D, appointments: A, prescriptions: R, addresses: ADDR } = COUNTS;
  const totalClients = clientsPf + clientsPj;

  lines.push('-- ============================================================');
  lines.push('-- NEOFARMA — Base de demonstração operacional');
  lines.push('-- Gerado por: node scripts/generate_demo_brasil.js');
  lines.push('-- Pré-requisito: scripts/DB_Neofarma_clean.sql');
  lines.push(`-- Senha dos usuários @loja.neofarma.com.br: ${PASSWORD_PLAIN}`);
  lines.push('-- Admin original do schema: admin@neofarma.com / Admin@123');
  lines.push('-- ============================================================');
  lines.push('');
  lines.push('USE neofarma;');
  lines.push('SET NAMES utf8mb4;');
  lines.push('SET FOREIGN_KEY_CHECKS = 0;');
  lines.push('');

  lines.push('-- Limpeza de execução anterior');
  const clean = [
    `DELETE FROM inventory_disposals WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%')`,
    `DELETE FROM order_pending_items WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM order_items WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM payments WHERE order_id IN (SELECT o.id FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM orders WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM purchase_order_items WHERE purchase_order_id IN (SELECT id FROM purchase_orders WHERE notes LIKE 'OC-2024-%')`,
    `DELETE FROM purchase_orders WHERE notes LIKE 'OC-2024-%'`,
    `DELETE FROM service_appointments WHERE customer_email LIKE '%${EMAIL_DOMAIN}'`,
    `DELETE FROM service_professional_availability WHERE professional_id IN (SELECT id FROM service_professionals WHERE email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM service_professionals WHERE email LIKE '%${EMAIL_DOMAIN}'`,
    `DELETE FROM prescription_items WHERE prescription_id IN (SELECT id FROM prescriptions WHERE notes LIKE 'Receita %')`,
    `DELETE FROM prescriptions WHERE notes LIKE 'Receita %'`,
    `DELETE FROM product_images WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%')`,
    `DELETE FROM product_categories WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%')`,
    `DELETE FROM inventory_batches WHERE product_id IN (SELECT id FROM products WHERE sku LIKE 'NF-%')`,
    `DELETE FROM products WHERE sku LIKE 'NF-%'`,
    `DELETE FROM customer_addresses WHERE customer_id IN (SELECT c.id FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM customers WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM employees WHERE user_id IN (SELECT id FROM users WHERE email LIKE '%${EMAIL_DOMAIN}')`,
    `DELETE FROM users WHERE email LIKE '%${EMAIL_DOMAIN}'`,
    `DELETE FROM suppliers WHERE cnpj LIKE '30%' AND corporate_name IN (${SUPPLIERS.map(([c]) => esc(c)).join(', ')})`,
    `DELETE FROM labs WHERE name IN (${LABS.map(([n]) => esc(n)).join(', ')})`,
    `DELETE FROM categories WHERE slug IN (${CATEGORIES.map(([, s]) => esc(s)).join(', ')})`,
    `DELETE FROM product_types WHERE slug IN (${PRODUCT_TYPES.map(([, s]) => esc(s)).join(', ')})`,
  ];
  clean.forEach((q) => lines.push(`${q};`));
  lines.push('SET FOREIGN_KEY_CHECKS = 1;');
  lines.push('');

  lines.push(`INSERT INTO roles (name, description) VALUES
('ADMIN','Administrador'),('FUNCIONARIO','Funcionário'),('ESTOQUISTA','Estoquista'),('CLIENTE','Cliente')
ON DUPLICATE KEY UPDATE description=VALUES(description);`);

  lines.push('');
  lines.push('-- Tipos e categorias');
  PRODUCT_TYPES.forEach(([name, slug, desc]) => {
    lines.push(`INSERT INTO product_types (name, slug, description, is_active) VALUES (${esc(name)}, ${esc(slug)}, ${esc(desc)}, 1) ON DUPLICATE KEY UPDATE name=VALUES(name);`);
  });
  CATEGORIES.forEach(([name, slug, desc]) => {
    lines.push(`INSERT INTO categories (parent_id, name, slug, description, is_active) VALUES (NULL, ${esc(name)}, ${esc(slug)}, ${esc(desc)}, 1) ON DUPLICATE KEY UPDATE name=VALUES(name);`);
  });

  lines.push('');
  lines.push('-- Endereços');
  for (let i = 0; i < ADDR; i++) {
    const [street, district, city, state, zip] = STREETS[i % STREETS.length];
    const num = 100 + (i * 17) % 900;
    const comp = i % 4 === 0 ? `Sala ${100 + i}` : null;
    lines.push(`INSERT INTO addresses (street, number, complement, district, city, state, country, zip_code) VALUES (${esc(street)}, ${esc(String(num))}, ${comp ? esc(comp) : 'NULL'}, ${esc(district)}, ${esc(city)}, ${esc(state)}, 'Brasil', ${esc(zip)});`);
  }

  lines.push(`SET @addr_base := (SELECT MIN(id) FROM (SELECT id FROM addresses ORDER BY id DESC LIMIT ${ADDR}) AS recent_addrs);`);

  lines.push('');
  lines.push('-- Laboratórios e fornecedores');
  LABS.forEach(([name, email], i) => {
    lines.push(`INSERT INTO labs (name, cnpj, email, phone, address_id, is_active) VALUES (${esc(name)}, ${esc(cnpjFromBase(200000000000 + i * 1111))}, ${esc(email)}, ${esc(`18${99001000 + i}`)}, @addr_base + ${i}, 1);`);
  });
  SUPPLIERS.forEach(([corp, trade, email], i) => {
    lines.push(`INSERT INTO suppliers (corporate_name, trade_name, cnpj, email, phone, address_id, is_active) VALUES (${esc(corp)}, ${esc(trade)}, ${esc(cnpjFromBase(300000000000 + i * 2222))}, ${esc(email)}, ${esc(`18${99102000 + i}`)}, @addr_base + ${(i + 5) % ADDR}, ${i === 7 ? 0 : 1});`);
  });

  lines.push('SET @lab_id := (SELECT id FROM labs WHERE name = \'Herbarium Laboratório Botânico\' LIMIT 1);');
  lines.push('SET @supplier_id := (SELECT id FROM suppliers WHERE trade_name = \'Fitonatural\' LIMIT 1);');
  lines.push('SET @type_fit := (SELECT id FROM product_types WHERE slug = \'fitoterapico\' LIMIT 1);');
  lines.push('SET @type_sup := (SELECT id FROM product_types WHERE slug = \'suplemento-alimentar\' LIMIT 1);');
  lines.push('SET @type_hig := (SELECT id FROM product_types WHERE slug = \'higiene-pessoal\' LIMIT 1);');
  lines.push('SET @cat_fito := (SELECT id FROM categories WHERE slug = \'fitoterapicos\' LIMIT 1);');
  lines.push('SET @cat_sup := (SELECT id FROM categories WHERE slug = \'suplementos\' LIMIT 1);');
  lines.push('SET @cat_cha := (SELECT id FROM categories WHERE slug = \'chas-infusiones\' LIMIT 1);');

  lines.push('');
  lines.push('-- Equipe');
  const staff = [
    ['FUNCIONARIO', 'Eliane Souza Moraes', 'eliane.moraes', 'Atendente de Balcão', 3200],
    ['ESTOQUISTA', 'Robson Pereira Lima', 'robson.lima', 'Estoquista', 2800],
    ['ADMIN', 'Marcos Antônio Ribeiro', 'marcos.ribeiro', 'Gerente Operacional', 8500],
  ];
  staff.forEach(([role, name, login, title, salary], i) => {
    const em = emailLocal(login);
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(em)}, ${esc(hash)}, ${esc(cpfFromBase(900000000 + i))}, ${esc(`189${9700100 + i}`)}, '1985-06-15', 1 FROM roles r WHERE r.name=${esc(role)} LIMIT 1;`);
    lines.push(`INSERT INTO employees (user_id, hire_date, salary, role_title)
SELECT u.id, '2022-03-01', ${salary}, ${esc(title)} FROM users u WHERE u.email=${esc(em)} LIMIT 1;`);
  });

  lines.push('');
  lines.push('-- Clientes PF');
  for (let i = 0; i < clientsPf; i++) {
    const name = PF_NAMES[i];
    const local = name.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, '.').split('.').slice(0, 2).join('.');
    const em = emailLocal(`${local}${i > 0 ? i + 1 : ''}`);
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(em)}, ${esc(hash)}, ${esc(cpfFromBase(100000001 + i))}, ${esc(`179${9600100 + i}`)}, ${esc(`19${70 + (i % 30)}-${String((i % 12) + 1).padStart(2, '0')}-15`)}, ${i === clientsPf - 1 ? 0 : 1} FROM roles r WHERE r.name='CLIENTE' LIMIT 1;`);
    lines.push(`INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + ${i % ADDR}, ${(i * 17) % 500} FROM users u WHERE u.email=${esc(em)} LIMIT 1;`);
    lines.push(`INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + ${i % ADDR}, 'Residencial', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(em)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Clientes PJ');
  for (let j = 0; j < clientsPj; j++) {
    const name = PJ_NAMES[j];
    const local = `empresa.${slugify(name).slice(0, 20)}`;
    const em = emailLocal(local);
    lines.push(`INSERT INTO users (role_id, full_name, email, password_hash, document, phone, birth_date, is_active)
SELECT r.id, ${esc(name)}, ${esc(em)}, ${esc(hash)}, ${esc(cnpjFromBase(400000000000 + j * 3333))}, ${esc(`113${5500100 + j}`)}, NULL, 1 FROM roles r WHERE r.name='CLIENTE' LIMIT 1;`);
    lines.push(`INSERT INTO customers (user_id, default_address_id, loyalty_points)
SELECT u.id, @addr_base + ${(clientsPf + j) % ADDR}, ${100 + j * 50} FROM users u WHERE u.email=${esc(em)} LIMIT 1;`);
    lines.push(`INSERT INTO customer_addresses (customer_id, address_id, label, is_default)
SELECT c.id, @addr_base + ${(clientsPf + j) % ADDR}, 'Matriz', 1 FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(em)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Produtos');
  const slugUsed = new Set();
  for (let i = 0; i < P; i++) {
    const name = PRODUCT_NAMES[i % PRODUCT_NAMES.length] + (i >= PRODUCT_NAMES.length ? ` — ref. ${i + 1}` : '');
    let slug = slugify(name);
    if (slugUsed.has(slug)) slug = `${slug}-${i + 1}`;
    slugUsed.add(slug);
    const sku = `NF-${String(i + 1).padStart(4, '0')}`;
    const ean = makeEan13(i + 1);
    const price = (12.9 + (i % 25) * 3.2).toFixed(2);
    const promo = i % 5 === 0 ? (Number(price) * 0.88).toFixed(2) : null;
    const status = i % 19 === 0 ? 'DISCONTINUED' : i % 13 === 0 ? 'INACTIVE' : 'ACTIVE';
    const typeVar = i % 3 === 0 ? '@type_fit' : i % 3 === 1 ? '@type_sup' : '@type_hig';
    const rx = i % 11 === 0 ? 1 : 0;
    const catVar = i % 3 === 0 ? '@cat_fito' : i % 3 === 1 ? '@cat_sup' : '@cat_cha';
    lines.push(`INSERT INTO products (lab_id, main_supplier_id, product_type_id, name, slug, sku, ean13, description, composition, usage_info, prescription_required, unit_price, promotional_price, status)
VALUES (@lab_id, @supplier_id, ${typeVar}, ${esc(name)}, ${esc(slug)}, ${esc(sku)}, ${esc(ean)}, ${esc(`${name}. Produto comercializado pela NeoFarma.`)}, ${esc('Composição conforme rótulo e bula.')}, ${esc('Uso conforme orientação farmacêutica ou bula.')}, ${rx}, ${price}, ${promo || 'NULL'}, ${esc(status)});`);
    lines.push(`INSERT INTO product_categories (product_id, category_id) SELECT p.id, ${catVar} FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
    lines.push(`INSERT INTO product_images (product_id, image_url, sort_order) SELECT p.id, '/assets/img/product/product-${(i % 5) + 1}.webp', 0 FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Lotes (FEFO: vencido, próximo, válido)');
  for (let i = 0; i < P; i++) {
    const sku = `NF-${String(i + 1).padStart(4, '0')}`;
    const codeA = `L24-A-${String(i + 1).padStart(3, '0')}`;
    const codeB = `L24-B-${String(i + 1).padStart(3, '0')}`;
    const codeC = `L24-C-${String(i + 1).padStart(3, '0')}`;
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(codeA)}, DATE_SUB(CURDATE(), INTERVAL 400 DAY), DATE_SUB(CURDATE(), INTERVAL 15 DAY), ${5 + (i % 10)} FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(codeB)}, DATE_SUB(CURDATE(), INTERVAL 90 DAY), DATE_ADD(CURDATE(), INTERVAL ${20 + (i % 25)} DAY), ${80 + (i * 3) % 200} FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
    lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT p.id, ${esc(codeC)}, DATE_SUB(CURDATE(), INTERVAL 30 DAY), DATE_ADD(CURDATE(), INTERVAL ${180 + (i % 120)} DAY), ${150 + (i * 5) % 300} FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Compras a fornecedores');
  for (let p = 0; p < PO; p++) {
    const [st, paySt, payM] = PO_STATUSES[p % PO_STATUSES.length];
    const prodIdx = (p % P) + 1;
    const sku = `NF-${String(prodIdx).padStart(4, '0')}`;
    const qty = 20 + p * 3;
    const cost = (8.5 + (p % 12)).toFixed(2);
    const itemTotal = (qty * Number(cost)).toFixed(2);
    const poNotes = `OC-2024-${String(p + 1).padStart(4, '0')}`;
    const rcvBatch = `L24-R-${String(p + 1).padStart(3, '0')}`;
    lines.push(`INSERT INTO purchase_orders (supplier_id, employee_id, order_date, expected_date, status, payment_status, payment_method, total_amount, notes)
SELECT @supplier_id, (SELECT e.id FROM employees e LIMIT 1), DATE_SUB(NOW(), INTERVAL ${p * 4} DAY), DATE_ADD(NOW(), INTERVAL ${7 + p} DAY), ${esc(st)}, ${esc(paySt)}, ${payM ? esc(payM) : 'NULL'}, ${itemTotal}, ${esc(poNotes)};`);
    lines.push(`INSERT INTO purchase_order_items (purchase_order_id, product_id, quantity, quantity_received, batch_code, expiry_date, unit_cost, total_cost)
SELECT po.id, pr.id, ${qty}, ${st === 'RECEIVED' ? qty : 0}, ${st === 'RECEIVED' ? esc(rcvBatch) : 'NULL'}, ${st === 'RECEIVED' ? 'DATE_ADD(CURDATE(), INTERVAL 365 DAY)' : 'NULL'}, ${cost}, ${itemTotal}
FROM purchase_orders po, products pr WHERE po.notes=${esc(poNotes)} AND pr.sku=${esc(sku)} LIMIT 1;`);
    if (st === 'RECEIVED') {
      lines.push(`INSERT INTO inventory_batches (product_id, batch_code, mfg_date, expiry_date, quantity)
SELECT pr.id, ${esc(rcvBatch)}, CURDATE(), DATE_ADD(CURDATE(), INTERVAL 365 DAY), ${qty} FROM products pr WHERE pr.sku=${esc(sku)} LIMIT 1;`);
      lines.push(`UPDATE purchase_order_items poi INNER JOIN purchase_orders po ON po.id = poi.purchase_order_id
INNER JOIN products pr ON pr.id = poi.product_id INNER JOIN inventory_batches ib ON ib.product_id = pr.id AND ib.batch_code = ${esc(rcvBatch)}
SET poi.batch_id = ib.id WHERE po.notes = ${esc(poNotes)};`);
    }
  }

  lines.push('');
  lines.push('-- Pedidos de clientes');
  const orderStatuses = ['DELIVERED', 'SHIPPED', 'PROCESSING', 'CONFIRMED', 'CANCELLED'];

  function clientEmail(idx) {
    if (idx < clientsPf) {
      const name = PF_NAMES[idx];
      const local = name.toLowerCase().normalize('NFD').replace(/[\u0300-\u036f]/g, '').replace(/\s+/g, '.').split('.').slice(0, 2).join('.');
      return emailLocal(`${local}${idx > 0 ? idx + 1 : ''}`);
    }
    const j = idx - clientsPf;
    const name = PJ_NAMES[j];
    return emailLocal(`empresa.${slugify(name).slice(0, 20)}`);
  }

  for (let o = 0; o < O; o++) {
    const custIdx = o % totalClients;
    const em = clientEmail(custIdx);
    const payM = PAY_METHODS[o % 3];
    const payS = payM === 'CREDIT_CARD' ? 'PAID' : PAY_STATUSES[o % 5];
    const ordS = payS === 'FAILED' ? 'CANCELLED' : orderStatuses[o % 5];
    const daysAgo = o % 90;
    const prodIdx = (o % P) + 1;
    const sku = `NF-${String(prodIdx).padStart(4, '0')}`;
    const qty = 1 + (o % 3);
    const unit = (15 + (prodIdx % 12) * 2.8).toFixed(2);
    const lineTotal = (qty * Number(unit)).toFixed(2);
    const ship = (o % 4 === 0 ? 0 : 14.9).toFixed(2);
    const total = (Number(lineTotal) + Number(ship)).toFixed(2);

    lines.push(`INSERT INTO orders (customer_id, address_id, status, subtotal, shipping_cost, total, payment_method, payment_status, shipping_zip, shipping_service, shipping_deadline_days, created_at)
SELECT c.id, c.default_address_id, ${esc(ordS)}, ${lineTotal}, ${ship}, ${total}, ${esc(payM)}, ${esc(payS)}, '19010010', 'PAC', 7, DATE_SUB(NOW(), INTERVAL ${daysAgo} DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(em)} LIMIT 1;`);
    lines.push('SET @last_order := LAST_INSERT_ID();');

    if (payS === 'PAID') {
      lines.push(`INSERT INTO order_items (order_id, product_id, batch_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, (SELECT ib.id FROM inventory_batches ib WHERE ib.product_id=p.id AND ib.expiry_date >= CURDATE() ORDER BY ib.expiry_date ASC LIMIT 1), ${qty}, ${unit}, ${lineTotal}
FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
    } else {
      lines.push(`INSERT INTO order_pending_items (order_id, product_id, quantity, unit_price, line_total)
SELECT @last_order, p.id, ${qty}, ${unit}, ${lineTotal} FROM products p WHERE p.sku=${esc(sku)} LIMIT 1;`);
    }

    const pixVal = payM === 'PIX' ? esc(`00020126580014BR.GOV.BCB.PIX0136123e4567-e89b-12d3-a456-426614174000${o}`) : 'NULL';
    const boletoVal = payM === 'BOLETO' ? esc(`23793.${String(1000000000 + o).slice(-10)}`) : 'NULL';
    const cardLast4 = payM === 'CREDIT_CARD' ? esc(String(1000 + (o % 9000)).slice(-4)) : 'NULL';
    lines.push(`INSERT INTO payments (order_id, method, status, amount, pix_copy_paste, boleto_barcode, card_last4, installments)
VALUES (@last_order, ${esc(payM)}, ${esc(payS)}, ${total}, ${pixVal}, ${boletoVal}, ${cardLast4}, ${payM === 'CREDIT_CARD' ? 1 + (o % 4) : 'NULL'});`);
  }

  lines.push('');
  lines.push('-- Descartes de lotes vencidos');
  const reasons = ['Produto vencido em conferência de estoque', 'Embalagem danificada na movimentação', 'Quebra operacional no balcão', 'Contaminação visual identificada na inspeção'];
  for (let d = 0; d < D; d++) {
    const prodNum = d + 1;
    const sku = `NF-${String(prodNum).padStart(4, '0')}`;
    const batchCode = `L24-A-${String(prodNum).padStart(3, '0')}`;
    const disposeQty = Math.min(1 + (d % 3), 5 + ((prodNum - 1) % 10));
    lines.push(`INSERT INTO inventory_disposals (product_id, batch_id, quantity, reason, disposed_by, created_at)
SELECT p.id, ib.id, ${disposeQty}, ${esc(reasons[d % 4])}, (SELECT u.id FROM users u WHERE u.email=${esc(emailLocal('robson.lima'))} LIMIT 1), DATE_SUB(NOW(), INTERVAL ${d * 6} DAY)
FROM products p INNER JOIN inventory_batches ib ON ib.product_id=p.id AND ib.batch_code=${esc(batchCode)} WHERE p.sku=${esc(sku)} LIMIT 1;`);
  }

  addCoherenceBlock(lines);

  lines.push('');
  lines.push('-- Profissionais de saúde e agenda');
  const pros = [
    ['Dra. Helena Martins', 'FARMACEUTICO', 'CRF', 'SP', '45678', 'helena.martins'],
    ['Enf. Paulo Ricardo Dias', 'ENFERMEIRO', 'COREN', 'SP', '123456', 'paulo.dias'],
    ['Dra. Camila Rocha', 'FARMACEUTICO', 'CRF', 'SP', '78901', 'camila.rocha'],
    ['Enf. Juliana Freitas', 'ENFERMEIRO', 'COREN', 'SP', '654321', 'juliana.freitas'],
    ['Dr. Roberto Alves', 'FARMACEUTICO', 'CRF', 'SP', '23456', 'roberto.alves'],
    ['Enf. Marcos Vinícius', 'ENFERMEIRO', 'COREN', 'SP', '987654', 'marcos.vinicius'],
  ];
  pros.forEach(([name, role, council, uf, num, login], i) => {
    const em = emailLocal(login);
    lines.push(`INSERT INTO service_professionals (full_name, role_name, email, phone, council_type, council_uf, council_number, is_active)
VALUES (${esc(name)}, ${esc(role)}, ${esc(em)}, ${esc(`189${9800100 + i}`)}, ${esc(council)}, ${esc(uf)}, ${esc(num)}, ${i === 5 ? 0 : 1});`);
    for (let dow = 1; dow <= 5; dow++) {
      lines.push(`INSERT INTO service_professional_availability (professional_id, day_of_week, start_time, end_time, is_active)
SELECT id, ${dow}, '08:00:00', '18:00:00', 1 FROM service_professionals WHERE email=${esc(em)} LIMIT 1;`);
    }
  });

  lines.push(`INSERT INTO service_holidays (holiday_date, name, is_active) VALUES
(DATE_ADD(CURDATE(), INTERVAL 45 DAY), 'Corpus Christi', 1),
(DATE_ADD(CURDATE(), INTERVAL 120 DAY), 'Emenda Feriado Municipal', 1)
ON DUPLICATE KEY UPDATE name=VALUES(name);`);

  lines.push('');
  lines.push('-- Agendamentos de serviços');
  const apptStatuses = ['COMPLETED', 'CONFIRMED', 'IN_PROGRESS', 'RESERVED', 'NO_SHOW', 'INCOMPLETE', 'CANCELLED', 'PAYMENT_FAILED'];
  for (let a = 0; a < A; a++) {
    const custIdx = a % clientsPf;
    const em = clientEmail(custIdx);
    const st = apptStatuses[a % apptStatuses.length];
    const paySt = ['COMPLETED', 'IN_PROGRESS', 'CONFIRMED'].includes(st) ? 'PAID'
      : ['NO_SHOW', 'INCOMPLETE'].includes(st) ? 'REFUNDED_PARTIAL'
        : st === 'PAYMENT_FAILED' ? 'FAILED' : 'PENDING';
    const svcId = 1 + (a % 10);
    const proLogin = pros[a % 5][5];
    const offsetDays = -45 + (a % 75);
    lines.push(`INSERT INTO service_appointments (service_id, professional_id, customer_id, customer_name, customer_email, customer_phone, modality, total_amount, scheduled_start, scheduled_end, status, payment_status, payment_method, booking_channel, clinical_record, refund_amount, completed_at, created_at)
SELECT ${svcId}, (SELECT id FROM service_professionals WHERE email=${esc(emailLocal(proLogin))} LIMIT 1),
  c.id, u.full_name, u.email, u.phone, IF(${a} % 4 = 0, 'HOME', 'IN_STORE'), (SELECT price FROM health_services WHERE id=${svcId} LIMIT 1),
  DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 9 HOUR, DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 10 HOUR,
  ${esc(st)}, ${esc(paySt)}, IF(${a} % 3 = 0, 'PIX', IF(${a} % 3 = 1, 'CREDIT_CARD', 'CASH')), IF(${a} % 2 = 0, 'CUSTOMER_ONLINE', 'ADMIN'),
  ${st === 'COMPLETED' ? esc('Atendimento realizado conforme protocolo. Paciente orientado sobre cuidados.') : 'NULL'},
  ${st === 'NO_SHOW' ? '19.95' : st === 'INCOMPLETE' ? '24.95' : 'NULL'},
  ${st === 'COMPLETED' ? `DATE_ADD(NOW(), INTERVAL ${offsetDays} DAY) + INTERVAL 10 HOUR` : 'NULL'},
  DATE_SUB(NOW(), INTERVAL ${Math.max(1, Math.abs(offsetDays))} DAY)
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(em)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Receitas médicas');
  const doctors = ['Dr. André Silva', 'Dra. Patricia Mendes', 'Dr. Fernando Costa', 'Dra. Luiza Barros'];
  for (let r = 0; r < R; r++) {
    const em = clientEmail(r % clientsPf);
    const sku = `NF-${String((r % P) + 1).padStart(4, '0')}`;
    const rxNotes = `Receita ${r + 1} — ${doctors[r % doctors.length]}`;
    lines.push(`INSERT INTO prescriptions (customer_id, doctor_name, doctor_crm, issued_at, valid_until, notes)
SELECT c.id, ${esc(doctors[r % doctors.length])}, ${esc(`CRM-SP ${100000 + r}`)}, DATE_SUB(CURDATE(), INTERVAL ${r * 12} DAY), DATE_ADD(CURDATE(), INTERVAL ${90 - r} DAY), ${esc(rxNotes)}
FROM customers c INNER JOIN users u ON u.id=c.user_id WHERE u.email=${esc(em)} LIMIT 1;`);
    lines.push(`INSERT INTO prescription_items (prescription_id, product_id, dosage, quantity_allowed, quantity_used)
SELECT pr.id, p.id, 'Conforme prescrição médica', 2, ${r % 2} FROM prescriptions pr, products p WHERE pr.notes=${esc(rxNotes)} AND p.sku=${esc(sku)} LIMIT 1;`);
  }

  lines.push('');
  lines.push('-- Resumo');
  lines.push(`SELECT 'Usuários demo' AS item, COUNT(*) AS qtd FROM users WHERE email LIKE '%${EMAIL_DOMAIN}'`);
  lines.push(`UNION ALL SELECT 'Produtos', COUNT(*) FROM products WHERE sku LIKE 'NF-%'`);
  lines.push(`UNION ALL SELECT 'Lotes', COUNT(*) FROM inventory_batches ib INNER JOIN products p ON p.id=ib.product_id WHERE p.sku LIKE 'NF-%'`);
  lines.push(`UNION ALL SELECT 'Pedidos', COUNT(*) FROM orders o INNER JOIN customers c ON c.id=o.customer_id INNER JOIN users u ON u.id=c.user_id WHERE u.email LIKE '%${EMAIL_DOMAIN}'`);
  lines.push(`UNION ALL SELECT 'Agendamentos', COUNT(*) FROM service_appointments WHERE customer_email LIKE '%${EMAIL_DOMAIN}'`);
  lines.push(';');
  lines.push('');
  lines.push('-- ============================================================');
  lines.push('-- Acessos principais');
  lines.push('-- Admin (schema): admin@neofarma.com / Admin@123');
  lines.push(`-- Gerente:      ${emailLocal('marcos.ribeiro')} / ${PASSWORD_PLAIN}`);
  lines.push(`-- Atendente:    ${emailLocal('eliane.moraes')} / ${PASSWORD_PLAIN}`);
  lines.push(`-- Estoquista:   ${emailLocal('robson.lima')} / ${PASSWORD_PLAIN}`);
  lines.push(`-- Cliente:      ${clientEmail(0)} / ${PASSWORD_PLAIN}`);
  lines.push('-- ============================================================');

  validateCoherenceInMemory(P, O, D, PO);

  fs.writeFileSync(OUT, lines.join('\n'), 'utf8');
  console.log(`Gerado: ${OUT} (${lines.length} linhas)`);
}

main().catch((err) => {
  console.error(err);
  process.exit(1);
});
