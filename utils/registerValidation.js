const { isValidCpf } = require('./cpf');

function stripDigits(value) {
  return String(value || '').replace(/\D/g, '');
}

const PUBLIC_FIELD_MAP = {
  nome: 'full_name',
  email: 'email',
  telefone: 'register_phone',
  cpf: 'document',
  birth_date: 'birth_date',
  senha: 'password',
  confirmar_senha: 'confirmPassword',
  cep: 'cep',
  rua: 'street',
  numero: 'number',
  bairro: 'district',
  cidade: 'city',
  estado: 'state',
};

const ADMIN_FIELD_MAP = {
  ...PUBLIC_FIELD_MAP,
  telefone: 'telefone',
  cpf: 'cpf',
};

function validateRegisterPayload(data) {
  const fields = {};
  const nome = String(data.nome || data.full_name || '').trim();
  const email = String(data.email || '').trim().toLowerCase();
  const telefoneDigits = stripDigits(data.telefone || data.phone);
  const cpfDigits = stripDigits(data.document || data.cpf);
  const senha = data.senha || data.password || '';
  const confirmarSenha = data.confirmar_senha || data.confirmPassword || '';
  const cepDigits = stripDigits(data.cep || data.zip_code);
  const rua = String(data.rua || data.street || '').trim();
  const numero = String(data.numero || data.number || '').trim();
  const bairro = String(data.bairro || data.district || '').trim();
  const cidade = String(data.cidade || data.city || '').trim();
  const estado = String(data.estado || data.state || '').trim().toUpperCase();
  const birthDate = data.birth_date ? String(data.birth_date).trim() : '';

  if (!nome) fields.nome = 'Informe o nome completo.';
  else if (nome.length < 3) fields.nome = 'O nome deve ter pelo menos 3 caracteres.';
  else if (!/\s/.test(nome)) fields.nome = 'Informe nome e sobrenome.';

  if (!email) fields.email = 'Informe o e-mail.';
  else if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) fields.email = 'Informe um e-mail válido.';

  if (!telefoneDigits) fields.telefone = 'Informe o telefone.';
  else if (telefoneDigits.length < 10) fields.telefone = 'Informe um telefone válido (mínimo 10 dígitos).';

  if (!cpfDigits) fields.cpf = 'Informe o CPF.';
  else if (cpfDigits.length !== 11) fields.cpf = 'O CPF deve conter 11 dígitos.';
  else if (!isValidCpf(cpfDigits)) fields.cpf = 'CPF inválido — verifique os dígitos verificadores.';

  if (birthDate) {
    const today = new Date();
    today.setHours(0, 0, 0, 0);
    const bd = new Date(`${birthDate}T00:00:00`);
    if (bd > today) fields.birth_date = 'A data de nascimento não pode ser futura.';
  }

  if (!senha) fields.senha = 'Informe a senha de acesso.';
  else if (senha.length < 6) fields.senha = 'A senha deve ter no mínimo 6 caracteres.';

  if (!confirmarSenha) fields.confirmar_senha = 'Confirme a senha de acesso.';
  else if (senha !== confirmarSenha) fields.confirmar_senha = 'As senhas não coincidem.';

  if (!cepDigits) fields.cep = 'Informe o CEP do endereço.';
  else if (cepDigits.length !== 8) fields.cep = 'Informe um CEP válido (8 dígitos).';

  if (!rua) fields.rua = 'Informe o logradouro.';
  if (!numero) fields.numero = 'Informe o número do endereço.';
  if (!bairro) fields.bairro = 'Informe o bairro.';
  if (!cidade) fields.cidade = 'Informe a cidade.';
  if (!estado || estado.length !== 2) fields.estado = 'Informe a UF com 2 letras.';

  return {
    fields,
    payload: {
      nome,
      email,
      telefone: telefoneDigits,
      telefoneDigits,
      document: cpfDigits,
      birth_date: birthDate || null,
      pais: data.pais || data.country || 'Brasil',
      cep: cepDigits,
      rua,
      numero,
      complement: data.complement ? String(data.complement).trim() : null,
      bairro,
      cidade,
      estado,
      senha,
    },
  };
}

function mapRegisterFieldsToPublic(fields, fieldMap = PUBLIC_FIELD_MAP) {
  const out = {};
  Object.keys(fields || {}).forEach((key) => {
    out[fieldMap[key] || key] = fields[key];
  });
  return out;
}

/**
 * Verifica e-mail, CPF e telefone já cadastrados.
 * @param {object} payload - saída de validateRegisterPayload().payload
 * @param {object} userModel - módulo User
 * @param {number|null} [excludeUserId]
 */
async function findRegisterDuplicateFields(payload, userModel, excludeUserId = null) {
  const fields = {};
  const email = payload.email;
  const documentDigits = payload.document;
  const phoneDigits = payload.telefoneDigits || stripDigits(payload.telefone);

  const [byEmail, byDocument, byPhone] = await Promise.all([
    email ? userModel.findByEmail(email) : null,
    documentDigits ? userModel.findByDocument(documentDigits) : null,
    phoneDigits ? userModel.findByPhoneDigits(phoneDigits) : null,
  ]);

  const sameUser = (row) => row && (!excludeUserId || Number(row.id) !== Number(excludeUserId));

  if (sameUser(byEmail)) {
    fields.email = 'Este e-mail já está em uso. Faça login ou use outro endereço.';
  }
  if (sameUser(byDocument)) {
    fields.cpf = 'Este CPF já está vinculado a outra conta.';
  }
  if (sameUser(byPhone)) {
    fields.telefone = 'Este telefone já está vinculado a outra conta.';
  }

  return fields;
}

module.exports = {
  stripDigits,
  validateRegisterPayload,
  mapRegisterFieldsToPublic,
  findRegisterDuplicateFields,
  PUBLIC_FIELD_MAP,
  ADMIN_FIELD_MAP,
};
