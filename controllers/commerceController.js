const { pool } = require('../config/database');
const Customer = require('../models/Customer');
const Product = require('../models/Product');
const ProductImage = require('../models/ProductImage');
const InventoryBatch = require('../models/InventoryBatch');
const Order = require('../models/Order');
const Payment = require('../models/Payment');
const cartService = require('../services/cartService');
const { calculateShipping, normalizeCep } = require('../services/shippingService');
const { buildInstallments, buildPaymentPayload } = require('../services/paymentService');
const { getValidStockByProductId } = require('../services/inventoryService');

/**
 * Detecta se o cliente espera resposta JSON (API/AJAX).
 */
function wantsJson(req) {
  return req.xhr || /application\/json/i.test(req.get('accept') || '');
}

function formatZip(zip) {
  const digits = String(zip || '').replace(/\D/g, '');
  if (digits.length !== 8) return '';
  return `${digits.slice(0, 5)}-${digits.slice(5)}`;
}

async function getUserDefaultZip(req) {
  if (!req.session || !req.session.userId) return '';
  const profile = await Customer.getProfileByUserId(req.session.userId);
  const zip = profile && (profile.zip_code || profile.cep);
  return formatZip(zip);
}

async function resolveShippingCep(req, inputCep) {
  const manual = String(inputCep || '').trim();
  if (manual) return manual;
  const userZip = await getUserDefaultZip(req);
  return userZip;
}

async function apiGetCart(req, res, next) {
  try {
    const cart = await cartService.getCart(req.session);
    res.json({ ok: true, cart });
  } catch (err) {
    next(err);
  }
}

async function apiAddToCart(req, res, next) {
  try {
    const { product_id, quantity } = req.body || {};
    const cart = await cartService.addItem(req.session, product_id, quantity || 1);
    res.json({ ok: true, cart });
  } catch (err) {
    next(err);
  }
}

async function apiUpdateCartItem(req, res, next) {
  try {
    const { quantity } = req.body || {};
    const cart = await cartService.updateItem(req.session, req.params.productId, quantity);
    res.json({ ok: true, cart });
  } catch (err) {
    next(err);
  }
}

async function apiRemoveCartItem(req, res, next) {
  try {
    const cart = await cartService.removeItem(req.session, req.params.productId);
    res.json({ ok: true, cart });
  } catch (err) {
    next(err);
  }
}

async function apiClearCart(req, res, next) {
  try {
    const cart = await cartService.clearCart(req.session);
    res.json({ ok: true, cart });
  } catch (err) {
    next(err);
  }
}

async function apiShippingQuote(req, res, next) {
  try {
    const { cep } = req.body || {};
    const cart = await cartService.getCart(req.session);
    const resolvedCep = await resolveShippingCep(req, cep);
    if (!resolvedCep) return res.status(400).json({ ok: false, message: 'Informe um CEP para calcular o frete.' });
    // Recalcula o frete com base no subtotal vigente do carrinho.
    const quote = await calculateShipping({ cep: resolvedCep, subtotal: cart.subtotal });
    res.json({ ok: true, quote });
  } catch (err) {
    if (err.code === 'INVALID_ZIP') return res.status(400).json({ ok: false, message: err.message });
    next(err);
  }
}

async function apiSetShipping(req, res, next) {
  try {
    const { cep, service_code } = req.body || {};
    const cart = await cartService.getCart(req.session);
    const resolvedCep = await resolveShippingCep(req, cep);
    if (!resolvedCep) return res.status(400).json({ ok: false, message: 'Informe um CEP para selecionar o frete.' });
    // Sempre revalida serviços antes de persistir no carrinho.
    const quote = await calculateShipping({ cep: resolvedCep, subtotal: cart.subtotal });
    const selected = quote.services.find((s) => s.code === service_code);
    if (!selected) return res.status(400).json({ ok: false, message: 'Serviço de frete inválido.' });
    cartService.setShipping(req.session, {
      code: selected.code,
      label: selected.label,
      price: selected.price,
      deadlineDays: selected.deadlineDays,
      cep: quote.destinationZip,
    });
    const updated = await cartService.getCart(req.session);
    res.json({ ok: true, cart: updated });
  } catch (err) {
    next(err);
  }
}

async function apiPaymentPreview(req, res, next) {
  try {
    const { payment_method, amount } = req.body || {};
    const method = String(payment_method || '').toUpperCase();
    const amt = Number(amount);

    if (!['PIX', 'BOLETO'].includes(method)) {
      return res.status(400).json({ ok: false, message: 'Selecione Pix ou Boleto para visualizar o pagamento.' });
    }
    if (!amt || amt <= 0) return res.status(400).json({ ok: false, message: 'Informe um valor válido para o preview.' });

    const ref = String(Math.floor(Math.random() * 10000)).padStart(4, '0');
    const dueDate = new Date();
    dueDate.setDate(dueDate.getDate() + 3);
    const boleto_due_date = dueDate.toISOString().slice(0, 10);

    req.session.paymentPreview = { payment_method: method, ref, boleto_due_date };

    const paymentExtras = buildPaymentPayload(method, {
      orderId: 0,
      orderRef: ref,
      boleto_due_date,
      amount: amt,
      card_number: null,
      installments: null,
      total: amt,
    });

    return res.json({
      ok: true,
      payment: paymentExtras,
      preview_ref: ref,
      boleto_due_date,
    });
  } catch (err) {
    next(err);
  }
}

async function renderCart(req, res, next) {
  try {
    const cart = await cartService.getCart(req.session);
    const defaultShippingCep = await getUserDefaultZip(req);
    res.render('cart', {
      title: 'Carrinho - NeoFarma',
      bodyClass: 'cart-page',
      activeNav: 'category',
      cart,
      defaultShippingCep,
    });
  } catch (err) {
    next(err);
  }
}

async function renderCheckout(req, res, next) {
  try {
    const cart = await cartService.getCart(req.session);
    if (!cart.items.length) return res.redirect('/cart');
    const customer = await Customer.findByUserId(req.session.userId);
    const addresses = customer ? await Customer.getAddressesByCustomerId(customer.id) : [];
    res.render('checkout', {
      title: 'Checkout - NeoFarma',
      bodyClass: 'checkout-page',
      activeNav: 'category',
      cart,
      addresses,
      installmentPlans: buildInstallments(cart.total || 0),
    });
  } catch (err) {
    next(err);
  }
}

async function finalizeCheckout(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const { address_id, payment_method, cep, shipping_service, card_number, installments } = req.body || {};
    const cart = await cartService.getCart(req.session);
    if (!cart.items.length) return res.status(400).json({ ok: false, message: 'Carrinho vazio.' });

    const customer = await Customer.findByUserId(req.session.userId);
    if (!customer) return res.status(403).json({ ok: false, message: 'Cliente não encontrado para este usuário.' });
    const ownsAddress = await Customer.customerOwnsAddress(customer.id, Number(address_id));
    if (!ownsAddress) return res.status(400).json({ ok: false, message: 'Endereço inválido para este cliente.' });
    if (!payment_method) return res.status(400).json({ ok: false, message: 'Selecione um método de pagamento.' });

    const quote = await calculateShipping({ cep: cep || (cart.shipping && cart.shipping.cep), subtotal: cart.subtotal });
    const selectedService = quote.services.find((s) => s.code === shipping_service);
    if (!selectedService) return res.status(400).json({ ok: false, message: 'Frete inválido.' });
    cartService.setShipping(req.session, {
      code: selectedService.code,
      label: selectedService.label,
      price: selectedService.price,
      deadlineDays: selectedService.deadlineDays,
      cep: quote.destinationZip,
    });
    const freshCart = await cartService.getCart(req.session);

    // Bloco transacional crítico:
    // 1) valida disponibilidade real
    // 2) cria pedido/itens/pagamento
    // 3) baixa estoque por FEFO de forma atômica
    await connection.beginTransaction();
    const products = await Product.findByIds(freshCart.items.map((i) => i.product_id), { status: 'ACTIVE' });
    const productMap = new Map(products.map((p) => [Number(p.id), p]));
    for (const item of freshCart.items) {
      if (!productMap.has(Number(item.product_id))) {
        throw new Error(`Produto ${item.product_id} indisponível.`);
      }
      // Defesa extra: valida estoque em tempo de checkout (não confiar no front).
      const stock = await getValidStockByProductId(item.product_id);
      if (Number(item.quantity) > Number(stock)) {
        const stockErr = new Error(`Estoque insuficiente para ${item.name}.`);
        stockErr.code = 'INSUFFICIENT_STOCK';
        throw stockErr;
      }
    }

    const subtotal = freshCart.subtotal;
    const shippingCost = selectedService.price;
    const total = Number((subtotal + shippingCost).toFixed(2));

    const orderId = await Order.createOrder(
      {
        customer_id: customer.id,
        address_id: Number(address_id),
        status: 'CONFIRMED',
        subtotal,
        shipping_cost: shippingCost,
        total,
        payment_method,
        payment_status: payment_method === 'CREDIT_CARD' ? 'PAID' : 'PENDING',
        shipping_zip: normalizeCep(quote.destinationZip),
        shipping_service: selectedService.code,
        shipping_deadline_days: selectedService.deadlineDays,
      },
      connection
    );

    for (const item of freshCart.items) {
      // FEFO: consome primeiro os lotes com validade mais próxima.
      const allocations = await InventoryBatch.allocateFEFO(connection, item.product_id, item.quantity);
      for (const alloc of allocations) {
        await Order.createOrderItem(
          {
            order_id: orderId,
            product_id: item.product_id,
            batch_id: alloc.batch_id,
            quantity: alloc.quantity,
            unit_price: item.unit_price,
            line_total: Number((item.unit_price * alloc.quantity).toFixed(2)),
          },
          connection
        );
      }
    }

    // Reaproveita preview para manter cópia Pix/Boleto consistente entre telas.
    const sessionPreview = req.session && req.session.paymentPreview && req.session.paymentPreview.payment_method === payment_method
      ? req.session.paymentPreview
      : null;
    const paymentRef = sessionPreview ? sessionPreview.ref : orderId;
    const boleto_due_date = sessionPreview ? sessionPreview.boleto_due_date : undefined;

    const paymentExtras = buildPaymentPayload(payment_method, {
      orderId,
      orderRef: paymentRef,
      boleto_due_date,
      amount: total,
      card_number,
      installments,
      total,
    });
    await Payment.create(
      {
        order_id: orderId,
        method: payment_method,
        status: paymentExtras.status || 'PENDING',
        amount: total,
        ...paymentExtras,
      },
      connection
    );

    await connection.commit();
    await cartService.clearCart(req.session);
    if (req.session && req.session.paymentPreview) delete req.session.paymentPreview;
    return res.json({ ok: true, redirect: `/order-confirmation?order=${orderId}` });
  } catch (err) {
    await connection.rollback();
    if (err.code === 'INSUFFICIENT_STOCK') return res.status(409).json({ ok: false, message: err.message });
    next(err);
  } finally {
    connection.release();
  }
}

async function renderOrderConfirmation(req, res, next) {
  try {
    const orderId = Number(req.query.order);
    if (!orderId) return res.redirect('/cart');
    const [order, items, payment] = await Promise.all([
      Order.findById(orderId),
      Order.findItemsByOrderId(orderId),
      Payment.findByOrderId(orderId),
    ]);
    if (!order) return res.redirect('/cart');

    const productIds = items.map((i) => i.product_id);
    const images = await ProductImage.findByProductIds(productIds);
    const imageMap = new Map();
    images.forEach((img) => {
      if (!imageMap.has(Number(img.product_id))) imageMap.set(Number(img.product_id), img.image_url);
    });
    const decoratedItems = items.map((i) => ({
      ...i,
      image_url: imageMap.get(Number(i.product_id)) || '/assets/img/product/product-1.webp',
    }));

    res.render('order-confirmation', {
      title: 'Pedido Confirmado - NeoFarma',
      bodyClass: 'order-confirmation-page',
      activeNav: 'category',
      order,
      items: decoratedItems,
      payment,
    });
  } catch (err) {
    next(err);
  }
}

module.exports = {
  apiGetCart,
  apiAddToCart,
  apiUpdateCartItem,
  apiRemoveCartItem,
  apiClearCart,
  apiShippingQuote,
  apiSetShipping,
  apiPaymentPreview,
  renderCart,
  renderCheckout,
  finalizeCheckout,
  renderOrderConfirmation,
};
