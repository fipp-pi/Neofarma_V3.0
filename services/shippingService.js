function normalizeCep(cep = '') {
  return String(cep).replace(/\D/g, '').slice(0, 8);
}

function calculateFallbackShipping({ cep, subtotal = 0 }) {
  const cleanCep = normalizeCep(cep);
  if (cleanCep.length !== 8) {
    const err = new Error('CEP inválido para cálculo de frete.');
    err.code = 'INVALID_ZIP';
    throw err;
  }

  const regionDigit = Number(cleanCep[0]);
  const base = subtotal >= 250 ? 0 : 14.9;
  const services = [
    {
      code: 'PAC',
      label: 'Entrega Padrão (PAC)',
      price: Number((base + regionDigit * 0.8).toFixed(2)),
      deadlineDays: 7 + regionDigit,
    },
    {
      code: 'SEDEX',
      label: 'Entrega Expressa (SEDEX)',
      price: Number((base + 12.5 + regionDigit * 1.2).toFixed(2)),
      deadlineDays: 2 + Math.ceil(regionDigit / 2),
    },
  ];

  return {
    destinationZip: cleanCep,
    services,
  };
}

async function quoteWithMelhorEnvio({ cep, subtotal = 0 }) {
  const cleanCep = normalizeCep(cep);
  if (cleanCep.length !== 8) {
    const err = new Error('CEP inválido para cálculo de frete.');
    err.code = 'INVALID_ZIP';
    throw err;
  }

  const token = process.env.MELHOR_ENVIO_TOKEN;
  const fromCep = normalizeCep(process.env.SHIP_FROM_CEP || '');
  if (!token || fromCep.length !== 8) return null;

  const requestBody = {
    from: { postal_code: fromCep },
    to: { postal_code: cleanCep },
    package: {
      // Valores padrão para farmácia, podem ser refinados por peso/volume do carrinho.
      height: Number(process.env.SHIP_PACKAGE_HEIGHT || 10),
      width: Number(process.env.SHIP_PACKAGE_WIDTH || 15),
      length: Number(process.env.SHIP_PACKAGE_LENGTH || 20),
      weight: Number(process.env.SHIP_PACKAGE_WEIGHT || 0.5),
    },
    options: {
      insurance_value: Number(subtotal || 0),
      receipt: false,
      own_hand: false,
    },
    services: process.env.MELHOR_ENVIO_SERVICES || '1,2', // 1=PAC, 2=SEDEX (quando disponível)
  };

  const resp = await fetch('https://www.melhorenvio.com.br/api/v2/me/shipment/calculate', {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${token}`,
      'Content-Type': 'application/json',
      'User-Agent': process.env.MELHOR_ENVIO_USER_AGENT || 'NeoFarma (dev@neofarma.local)',
    },
    body: JSON.stringify(requestBody),
  });

  if (!resp.ok) return null;
  const data = await resp.json();
  if (!Array.isArray(data) || !data.length) return null;

  const services = data
    .filter((s) => !s.error && s.price && Number(s.price) >= 0)
    .map((s) => ({
      code: String(s.id || s.name || 'SERVICE'),
      label: `Entrega ${s.name || 'Transportadora'}`,
      price: Number(Number(s.price).toFixed(2)),
      deadlineDays: Number(s.delivery_time || 0),
    }))
    .sort((a, b) => a.price - b.price);

  if (!services.length) return null;
  return { destinationZip: cleanCep, services };
}

async function calculateShipping({ cep, subtotal = 0 }) {
  const melhorEnvioQuote = await quoteWithMelhorEnvio({ cep, subtotal });
  if (melhorEnvioQuote) return melhorEnvioQuote;
  return calculateFallbackShipping({ cep, subtotal });
}

module.exports = {
  calculateShipping,
  calculateFallbackShipping,
  normalizeCep,
};
