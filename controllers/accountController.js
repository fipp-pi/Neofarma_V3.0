/**
 * Área logada do cliente: perfil, endereços, troca de senha e cancelamento de pedido.
 * O cancelamento só é permitido com pagamento pendente e restaura quantidades nos lotes (reverso do FEFO).
 *
 * @see docs/code-commenting.md
 */
const bcrypt = require('bcrypt');
const { pool } = require('../config/database');
const Customer = require('../models/Customer');
const User = require('../models/User');
const Order = require('../models/Order');
const OrderPendingItem = require('../models/OrderPendingItem');
const Payment = require('../models/Payment');
const InventoryBatch = require('../models/InventoryBatch');
const ServiceAppointment = require('../models/ServiceAppointment');

/**
 * Traduz `orders.status` + `orders.payment_status` para texto e estilo de badge na interface.
 *
 * @param {{ status?: string, payment_status?: string }} order
 * @returns {{ label: string, badge: string }}
 */
function mapOrderStatus(order) {
  const status = String(order.status || '').toUpperCase();
  const paymentStatus = String(order.payment_status || '').toUpperCase();
  if (status === 'CANCELLED') return { label: 'Cancelado', badge: 'danger' };
  if (paymentStatus === 'PENDING') return { label: 'Aguardando pagamento', badge: 'warning text-dark' };
  if (paymentStatus === 'PAID' && status === 'DELIVERED') return { label: 'Entregue', badge: 'success' };
  if (paymentStatus === 'PAID' && status === 'SHIPPED') return { label: 'Enviado', badge: 'primary' };
  if (paymentStatus === 'PAID' && status === 'PROCESSING') return { label: 'Preparando envio', badge: 'info text-dark' };
  if (paymentStatus === 'PAID') return { label: 'Pagamento recebido', badge: 'info text-dark' };
  if (paymentStatus === 'FAILED') return { label: 'Pagamento recusado', badge: 'danger' };
  return { label: 'Em processamento', badge: 'secondary' };
}

/**
 * GET /account - Página do perfil do usuário (requer login).
 */
async function getAccount(req, res, next) {
  try {
    const userId = req.session.userId;
    if (!userId) {
      return res.redirect('/login?redirect=/account');
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile) {
      return res.redirect('/login?redirect=/account');
    }
    const addresses = profile.customer_id
      ? await Customer.getAddressesByCustomerId(profile.customer_id)
      : [];
    const ordersRaw = profile.customer_id
      ? await Order.findByCustomerId(profile.customer_id, 50)
      : [];
    const orders = ordersRaw.map((o) => {
      const pay = String(o.payment_status || '').toUpperCase();
      const st = String(o.status || '').toUpperCase();
      // Só cancela antes de qualquer confirmação de pagamento.
      const can_cancel = pay === 'PENDING' && st !== 'CANCELLED';
      return {
        ...o,
        status_ui: mapOrderStatus(o),
        can_cancel,
        pay_status: pay,
        order_status: st,
      };
    });

    let upcomingAppointments = [];
    if (profile.customer_id) {
      const allAppts = await ServiceAppointment.listByCustomerId(profile.customer_id);
      const now = Date.now();
      upcomingAppointments = allAppts
        .filter((a) => {
          const st = String(a.status || '').toUpperCase();
          return ['CONFIRMED', 'RESERVED', 'IN_PROGRESS'].includes(st)
            && new Date(a.scheduled_start).getTime() >= now;
        })
        .slice(0, 3);
    }

    const paidOrders = orders.filter((o) => o.pay_status === 'PAID');
    const stats = {
      ordersTotal: orders.length,
      ordersPending: orders.filter((o) => o.pay_status === 'PENDING' && o.order_status !== 'CANCELLED').length,
      ordersDelivered: orders.filter((o) => o.order_status === 'DELIVERED').length,
      totalSpent: paidOrders.reduce((acc, o) => acc + Number(o.total || 0), 0),
      addressesCount: addresses.length,
      appointmentsUpcoming: upcomingAppointments.length,
      loyaltyPoints: Number(profile.loyalty_points || 0),
    };

    res.render('account', {
      title: 'Minha Conta - NeoFarma',
      bodyClass: 'account-page',
      profile,
      addresses,
      orders,
      ordersCount: orders.length,
      recentOrders: orders.slice(0, 3),
      upcomingAppointments,
      stats,
    });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /account - Atualiza apenas dados pessoais (nome, email, telefone, documento, nascimento, país). Sem endereço.
 */
async function postAccount(req, res, next) {
  try {
    const userId = req.session.userId;
    if (!userId) {
      return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }

    const body = req.body || {};
    const data = {
      full_name: (body.full_name || '').trim(),
      email: (body.email || '').trim().toLowerCase(),
      phone: (body.phone || body.telefone || '').trim() || null,
      document: (body.document || '').trim() || null,
      birth_date: (body.birth_date || '').trim() || null,
      country: (body.country || '').trim() || null,
    };

    if (!data.full_name) {
      return res.status(400).json({ ok: false, message: 'Nome completo é obrigatório.' });
    }
    if (!data.email) {
      return res.status(400).json({ ok: false, message: 'E-mail é obrigatório.' });
    }

    await Customer.updateUserOnly(profile.customer_id, data);
    res.json({ ok: true, message: 'Dados atualizados com sucesso.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /account/alterar-senha - Altera a senha do usuário logado.
 * Body: senha_atual, nova_senha, confirmar_nova_senha
 */
async function postAlterarSenha(req, res, next) {
  try {
    const userId = req.session.userId;
    if (!userId) {
      return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
    }
    const { senha_atual, nova_senha, confirmar_nova_senha } = req.body || {};
    if (!senha_atual || !String(senha_atual).trim()) {
      return res.status(400).json({ ok: false, message: 'Informe a senha atual.' });
    }
    if (!nova_senha || nova_senha.length < 6) {
      return res.status(400).json({ ok: false, message: 'A nova senha deve ter no mínimo 6 caracteres.' });
    }
    if (nova_senha !== confirmar_nova_senha) {
      return res.status(400).json({ ok: false, message: 'A nova senha e a confirmação não coincidem.' });
    }
    const user = await User.findById(userId);
    if (!user) {
      return res.status(404).json({ ok: false, message: 'Usuário não encontrado.' });
    }
    const senhaValida = await bcrypt.compare(String(senha_atual).trim(), user.password_hash || '');
    if (!senhaValida) {
      return res.status(400).json({ ok: false, message: 'Senha atual incorreta.' });
    }
    const passwordHash = await bcrypt.hash(nova_senha, 10);
    await User.updateById(userId, { password_hash: passwordHash });
    res.json({ ok: true, message: 'Senha alterada com sucesso.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /account/address - Adiciona novo endereço ao cliente.
 */
async function postAddress(req, res, next) {
  try {
    const userId = req.session.userId;
    if (!userId) {
      return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }

    const b = req.body || {};
    const cep = (b.cep || '').replace(/\D/g, '');
    if (cep.length !== 8) {
      return res.status(400).json({ ok: false, message: 'CEP inválido (8 dígitos).' });
    }
    if (!(b.street || '').trim() || !(b.number || '').trim() || !(b.district || '').trim() || !(b.city || '').trim() || !(b.state || '').trim()) {
      return res.status(400).json({ ok: false, message: 'Preencha rua, número, bairro, cidade e estado.' });
    }

    const addressId = await Customer.addAddressToCustomer(profile.customer_id, {
      street: b.street,
      number: b.number,
      complement: b.complement,
      district: b.district,
      city: b.city,
      state: b.state,
      country: b.country || 'Brasil',
      cep,
    }, b.label || 'Novo');
    res.status(201).json({ ok: true, message: 'Endereço adicionado.', address_id: addressId });
  } catch (err) {
    next(err);
  }
}

/**
 * PUT /account/address/:id - Atualiza endereço. O endereço deve pertencer ao cliente.
 */
async function putAddress(req, res, next) {
  try {
    const userId = req.session.userId;
    const addressId = parseInt(req.params.id, 10);
    if (!userId || !addressId) {
      return res.status(400).json({ ok: false, message: 'Requisição inválida.' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }
    const owns = await Customer.customerOwnsAddress(profile.customer_id, addressId);
    if (!owns) {
      return res.status(403).json({ ok: false, message: 'Endereço não pertence a você.' });
    }

    const b = req.body || {};
    const cep = (b.cep || '').replace(/\D/g, '');
    if (cep && cep.length !== 8) {
      return res.status(400).json({ ok: false, message: 'CEP deve ter 8 dígitos.' });
    }
    if (!(b.street || '').trim() || !(b.number || '').trim() || !(b.district || '').trim() || !(b.city || '').trim() || !(b.state || '').trim()) {
      return res.status(400).json({ ok: false, message: 'Preencha rua, número, bairro, cidade e estado.' });
    }

    await Customer.updateAddressForCustomer(addressId, {
      street: b.street,
      number: b.number,
      complement: b.complement,
      district: b.district,
      city: b.city,
      state: b.state,
      country: b.country || 'Brasil',
      cep: cep || b.cep,
    });
    res.json({ ok: true, message: 'Endereço atualizado.' });
  } catch (err) {
    next(err);
  }
}

/**
 * DELETE /account/address/:id - Remove endereço do cliente.
 */
async function deleteAddress(req, res, next) {
  try {
    const userId = req.session.userId;
    const addressId = parseInt(req.params.id, 10);
    if (!userId || !addressId) {
      return res.status(400).json({ ok: false, message: 'Requisição inválida.' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }
    const removed = await Customer.removeAddressFromCustomer(profile.customer_id, addressId);
    if (!removed) {
      return res.status(404).json({ ok: false, message: 'Endereço não encontrado.' });
    }
    res.json({ ok: true, message: 'Endereço removido.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /account/address/:id/default - Define endereço como padrão.
 */
async function setAddressDefault(req, res, next) {
  try {
    const userId = req.session.userId;
    const addressId = parseInt(req.params.id, 10);
    if (!userId || !addressId) {
      return res.status(400).json({ ok: false, message: 'Requisição inválida.' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }
    const ok = await Customer.setDefaultAddress(profile.customer_id, addressId);
    if (!ok) {
      return res.status(403).json({ ok: false, message: 'Endereço não pertence a você.' });
    }
    res.json({ ok: true, message: 'Endereço definido como padrão.' });
  } catch (err) {
    next(err);
  }
}

/**
 * POST /account/orders/:id/cancel
 * Cancela pedido apenas com pagamento pendente; devolve estoque aos lotes (FEFO reverso por linha).
 */
async function postCancelOrder(req, res, next) {
  const connection = await pool.getConnection();
  try {
    const userId = req.session.userId;
    if (!userId) {
      return res.status(401).json({ ok: false, message: 'Faça login para continuar.', redirect: '/login' });
    }
    const orderId = parseInt(req.params.id, 10);
    if (!orderId) {
      return res.status(400).json({ ok: false, message: 'Pedido inválido.' });
    }
    const profile = await Customer.getProfileByUserId(userId);
    if (!profile || !profile.customer_id) {
      return res.status(404).json({ ok: false, message: 'Perfil não encontrado.' });
    }

    await connection.beginTransaction();

    // Bloqueia o pedido para evitar corrida com outra ação (ex.: confirmação de pagamento).
    const order = await Order.findByIdForCustomer(orderId, profile.customer_id, connection, { forUpdate: true });
    if (!order) {
      await connection.rollback();
      return res.status(404).json({ ok: false, message: 'Pedido não encontrado.' });
    }
    const pay = String(order.payment_status || '').toUpperCase();
    const st = String(order.status || '').toUpperCase();
    if (st === 'CANCELLED' || pay !== 'PENDING') {
      await connection.rollback();
      return res.status(400).json({
        ok: false,
        message: 'Este pedido não pode ser cancelado (somente com pagamento pendente).',
      });
    }

    const [itemRows] = await connection.execute(
      'SELECT batch_id, quantity FROM order_items WHERE order_id = ? FOR UPDATE',
      [orderId]
    );
    if (itemRows && itemRows.length) {
      const allocations = itemRows.map((row) => ({
        batch_id: row.batch_id,
        quantity: row.quantity,
      }));
      await InventoryBatch.restoreAllocations(connection, allocations);
    }
    await OrderPendingItem.deleteByOrderId(orderId, connection);

    await Payment.updateStatusByOrderId(orderId, 'FAILED', connection);
    const cancelled = await Order.cancelPendingByIdForCustomer(orderId, profile.customer_id, connection);
    if (!cancelled) {
      throw new Error('Falha ao atualizar status do pedido.');
    }

    await connection.commit();
    return res.json({ ok: true, message: 'Pedido cancelado e estoque restaurado.' });
  } catch (err) {
    await connection.rollback();
    next(err);
  } finally {
    connection.release();
  }
}

module.exports = {
  getAccount,
  postAccount,
  postAlterarSenha,
  postAddress,
  putAddress,
  deleteAddress,
  setAddressDefault,
  postCancelOrder,
};
