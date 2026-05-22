const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const { getValidStockMapByProductIds } = require('./inventoryService');

/**
 * Garante que a sessão tenha a estrutura do carrinho.
 * "Conversa" com a sessão do usuário logado/visitante.
 */
function ensureCart(session) {
  if (!session.cart || !Array.isArray(session.cart.items)) {
    session.cart = { items: [], shipping: null };
  }
  return session.cart;
}

/**
 * Ajusta quantidade para um número válido (mínimo 1).
 */
function normalizeQty(value) {
  const qty = parseInt(value, 10);
  return Number.isNaN(qty) || qty < 1 ? 1 : qty;
}

/**
 * Recalcula o carrinho com dados atuais do banco:
 * produtos, imagens e estoque disponível.
 */
async function hydrateCart(cart) {
  const productIds = cart.items.map((i) => Number(i.productId));
  if (productIds.length === 0) {
    return { items: [], subtotal: 0, shipping: cart.shipping || null, total: 0 };
  }

  const [products, images, stockMap] = await Promise.all([
    Product.findByIds(productIds, { status: 'ACTIVE' }),
    ProductImage.findByProductIds(productIds),
    getValidStockMapByProductIds(productIds),
  ]);

  const productById = new Map(products.map((p) => [Number(p.id), p]));
  const firstImageByProduct = new Map();
  images.forEach((img) => {
    if (!firstImageByProduct.has(Number(img.product_id))) firstImageByProduct.set(Number(img.product_id), img.image_url);
  });

  const validItems = [];
  for (const item of cart.items) {
    const p = productById.get(Number(item.productId));
    if (!p) continue;
    const unit = Number(p.promotional_price && p.promotional_price > 0 ? p.promotional_price : p.unit_price || 0);
    const stock = stockMap.get(Number(p.id)) || 0;
    const qty = Math.min(normalizeQty(item.quantity), stock);
    if (qty < 1) continue;
    validItems.push({
      product_id: p.id,
      name: p.name,
      lab_name: p.lab_name || 'NeoFarma',
      unit_price: unit,
      quantity: qty,
      line_total: Number((unit * qty).toFixed(2)),
      stock_available: stock,
      image_url: firstImageByProduct.get(Number(p.id)) || '/assets/img/product/product-1.webp',
    });
  }

  cart.items = validItems.map((i) => ({ productId: i.product_id, quantity: i.quantity }));
  const subtotal = Number(validItems.reduce((acc, i) => acc + i.line_total, 0).toFixed(2));
  const shipping = cart.shipping ? Number(cart.shipping.price || 0) : 0;
  const total = Number((subtotal + shipping).toFixed(2));

  return {
    items: validItems,
    subtotal,
    shipping: cart.shipping || null,
    total,
  };
}

/**
 * Retorna o carrinho pronto para exibir na tela.
 */
async function getCart(session) {
  const cart = ensureCart(session);
  return hydrateCart(cart);
}

/**
 * Adiciona item ao carrinho na sessão e recalcula totais.
 */
async function addItem(session, productId, quantity) {
  const cart = ensureCart(session);
  const id = Number(productId);
  const qty = normalizeQty(quantity);
  const existing = cart.items.find((i) => Number(i.productId) === id);
  if (existing) existing.quantity = normalizeQty(existing.quantity + qty);
  else cart.items.push({ productId: id, quantity: qty });
  return getCart(session);
}

/**
 * Atualiza quantidade de um item do carrinho.
 * Se quantidade for 0, remove o item.
 */
async function updateItem(session, productId, quantity) {
  const cart = ensureCart(session);
  const id = Number(productId);
  const qty = parseInt(quantity, 10);
  const existing = cart.items.find((i) => Number(i.productId) === id);
  if (!existing) return getCart(session);
  if (Number.isNaN(qty) || qty <= 0) {
    cart.items = cart.items.filter((i) => Number(i.productId) !== id);
  } else {
    existing.quantity = qty;
  }
  return getCart(session);
}

/**
 * Remove um item do carrinho pela identificação do produto.
 */
async function removeItem(session, productId) {
  const cart = ensureCart(session);
  const id = Number(productId);
  cart.items = cart.items.filter((i) => Number(i.productId) !== id);
  return getCart(session);
}

/**
 * Limpa todo o carrinho do usuário na sessão.
 */
async function clearCart(session) {
  session.cart = { items: [], shipping: null };
  return getCart(session);
}

/**
 * Salva a opção de frete escolhida dentro do carrinho.
 */
function setShipping(session, shipping) {
  const cart = ensureCart(session);
  cart.shipping = shipping || null;
}

module.exports = {
  getCart,
  addItem,
  updateItem,
  removeItem,
  clearCart,
  setShipping,
};
