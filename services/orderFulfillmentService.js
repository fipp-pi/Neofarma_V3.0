const Order = require('../models/Order');
const OrderPendingItem = require('../models/OrderPendingItem');
const InventoryBatch = require('../models/InventoryBatch');

/**
 * Efetiva baixa de estoque (FEFO) após pagamento confirmado — alinhado à ERS RF_F2.
 */
async function fulfillOrderStock(orderId, connection) {
  const existing = await connection.execute('SELECT id FROM order_items WHERE order_id = ? LIMIT 1', [orderId]);
  if (existing[0] && existing[0].length) {
    return { ok: true, alreadyFulfilled: true };
  }

  const pending = await OrderPendingItem.findByOrderId(orderId, connection);
  if (!pending.length) {
    return { ok: false, code: 'NO_PENDING_ITEMS', message: 'Nenhum item pendente para este pedido.' };
  }

  for (const line of pending) {
    const allocations = await InventoryBatch.allocateFEFO(connection, line.product_id, line.quantity);
    for (const alloc of allocations) {
      await Order.createOrderItem(
        {
          order_id: orderId,
          product_id: line.product_id,
          batch_id: alloc.batch_id,
          quantity: alloc.quantity,
          unit_price: line.unit_price,
          line_total: Number((line.unit_price * alloc.quantity).toFixed(2)),
        },
        connection
      );
    }
  }

  await OrderPendingItem.deleteByOrderId(orderId, connection);
  return { ok: true, fulfilled: true };
}

module.exports = { fulfillOrderStock };
