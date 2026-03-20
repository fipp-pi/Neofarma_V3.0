document.addEventListener("DOMContentLoaded", () => {
  const campos = [
    { id: "first-name", mensagem: "Preencha o primeiro nome" },
    { id: "last-name", mensagem: "Preencha o último nome" },
    { id: "email", mensagem: "Preencha o email" },
    { id: "phone", mensagem: "Preencha o telefone" }
  ];
  //mensagem de erro
  campos.forEach((c) => {
    const input = document.getElementById(c.id);
    let erro = document.createElement("small");
    erro.classList.add("erro-form");
    erro.style.color = "#2E5C5C";
    erro.style.display = "none";
    input.insertAdjacentElement("afterend", erro);
    input.addEventListener("input", () => {
      if (input.value.trim() === "") {
        erro.textContent = c.mensagem;
        erro.style.display = "block";
      } else {
        erro.style.display = "none";
      }
    });
  });
  // máscara de telefone
  const phoneInput = document.getElementById("phone");
  phoneInput.addEventListener("input", () => {
    let valor = phoneInput.value.replace(/\D/g, "");

    if (valor.length > 11) valor = valor.substring(0, 11);

    if (valor.length <= 10) {
      phoneInput.value = valor.replace(/(\d{2})(\d{4})(\d{0,4})/, "($1) $2-$3");
    } else {
      phoneInput.value = valor.replace(/(\d{2})(\d{5})(\d{0,4})/, "($1) $2-$3");
    }
  });
});
function buscarCep() {
  const cepInput = document.getElementById("cep");
  const erroCep = document.getElementById("erro-cep");

  const rua = document.getElementById("rua");
  const bairro = document.getElementById("bairro");
  const cidade = document.getElementById("cidade");
  const estado =
    document.getElementById("estado") || document.getElementById("esatdo");
  let cep = cepInput.value.replace(/\D/g, "");
  cepInput.value = cep.replace(/(\d{5})(\d{0,3})/, "$1-$2");
  if (cep.length < 8) {
    erroCep.textContent = "CEP inválido. Deve conter 8 dígitos.";
    erroCep.style.display = "block";

    rua.value = "";
    bairro.value = "";
    cidade.value = "";
    estado.value = "";
    return;
  }
  if (cep.length === 8) {
    fetch(`https://viacep.com.br/ws/${cep}/json/`)
      .then((res) => res.json())
      .then((data) => {
        if (data.erro) {
          erroCep.textContent = "CEP não encontrado.";
          erroCep.style.display = "block";

          rua.value = "";
          bairro.value = "";
          cidade.value = "";
          estado.value = "";

          rua.classList.add("is-invalid");
          bairro.classList.add("is-invalid");
          cidade.classList.add("is-invalid");
          estado.classList.add("is-invalid");

          return;
        }
        // CEP válido
        erroCep.style.display = "none";

        rua.value = data.logradouro || "";
        bairro.value = data.bairro || "";
        cidade.value = data.localidade || "";
        estado.value = data.uf || "";
        // REMOVE A BORDA VERMELHA
        rua.classList.remove("is-invalid");
        bairro.classList.remove("is-invalid");
        cidade.classList.remove("is-invalid");
        estado.classList.remove("is-invalid");

      })
      .catch(() => {
        erroCep.textContent = "Erro ao consultar o CEP.";
        erroCep.style.display = "block";
      });
  }
}
function validarSelect(campo, msgErro) {
  if (campo.value === "") {
    msgErro.style.display = "block";
  } else {
    msgErro.style.display = "none";
  }
}
const country = document.getElementById("country");
const countryError = document.getElementById("countryError");

country.addEventListener("change", () => validarSelect(country, countryError));
country.addEventListener("blur", () => validarSelect(country, countryError));
// Número do cartão
const cardNumber = document.getElementById("card-number");
const cardNumberError = document.getElementById("cardNumberError");

cardNumber.addEventListener("input", () => {
  let valor = cardNumber.value.replace(/\D/g, "");
  valor = valor.replace(/(.{4})/g, "$1 ").trim();
  cardNumber.value = valor;

  const invalido = valor.replace(/\s/g, "").length !== 16;
  mostrarErro(cardNumber, cardNumberError, invalido);
});

function mostrarErro(campo, erroElemento, condicaoInvalida) {
  if (condicaoInvalida) {
    erroElemento.style.display = "block";
  } else {
    erroElemento.style.display = "none";
  }
}
// Função genérica de erro
function mostrarErro(campo, erroElemento, condicaoInvalida) {
  if (condicaoInvalida) {
    erroElemento.style.display = "block";
  } else {
    erroElemento.style.display = "none";
  }
}

function validarNumeroCartao() {
  const campo = document.getElementById("card-number");
  const erro = document.getElementById("cardNumberError");

  let valor = campo.value.replace(/\D/g, "");
  valor = valor.replace(/(.{4})/g, "$1 ").trim();
  campo.value = valor;
  const invalido = valor.replace(/\s/g, "").length !== 16;
  mostrarErro(campo, erro, invalido);
}

function validarValidade() {
  const campo = document.getElementById("expiry");
  const erro = document.getElementById("expiryError");

  let valor = campo.value.replace(/\D/g, "").slice(0, 4);
  if (valor.length >= 3) {
    valor = valor.slice(0, 2) + "/" + valor.slice(2);
  }

  campo.value = valor;
  const mes = parseInt(valor.slice(0, 2));
  const invalido =
    valor.length !== 5 ||
    mes < 1 ||
    mes > 12;
  mostrarErro(campo, erro, invalido);
}
function validarCVV() {
  const campo = document.getElementById("cvv");
  const erro = document.getElementById("cvvError");
  let valor = campo.value.replace(/\D/g, "").slice(0, 3);
  campo.value = valor;
  const invalido = valor.length !== 3;
  mostrarErro(campo, erro, invalido);
}
document.addEventListener("DOMContentLoaded", () => {
  document.getElementById("card-number")
    .addEventListener("input", validarNumeroCartao);

  document.getElementById("expiry")
    .addEventListener("input", validarValidade);

  document.getElementById("cvv")
    .addEventListener("input", validarCVV);
});

function applyPromo() {
  const input = document.getElementById("promoInput").value.trim().toUpperCase();
  const message = document.getElementById("promoMessage");
  const error = document.getElementById("promoError");

  //Cupons e descontos
  const validCodes = {
    "PROMO25": 0.25,
    "DESCONTO25": 0.25,
    "SUPER25": 0.25
  };

  const orderTotalElement = document.querySelector(".order-total span:last-child");
  const buttonPriceElement = document.querySelector(".btn-price");

  const orderTotalsContainer = document.querySelector(".order-totals");
  // Obtém valor atual do TOTAL
  let totalAtual = parseFloat(
    orderTotalElement.textContent.replace("R$", "").replace(",", ".")
  );
  message.style.display = "none";
  error.style.display = "none";

  // Verifica cupom
  if (validCodes[input]) {
    // Porcentagem
    const desconto = validCodes[input];
    // Calcula o valor descontado
    const valorDesconto = (totalAtual * desconto).toFixed(2);
    // Calcula novo total
    const novoTotal = (totalAtual - valorDesconto).toFixed(2);
    // REMOVE desconto antigo
    const descontoAntigo = document.querySelector(".order-discount");
    if (descontoAntigo) descontoAntigo.remove();
    // CRIA linha de desconto
    const descontoElement = document.createElement("div");
    descontoElement.className = "order-discount d-flex justify-content-between";
    descontoElement.innerHTML = `
      <span>Desconto (${(desconto * 100).toFixed(0)}%)</span>
      <span>-R$${valorDesconto.replace(".", ",")}</span>
    `;
    // Insere ANTES do TOTAL
    const totalDiv = document.querySelector(".order-total");
    orderTotalsContainer.insertBefore(descontoElement, totalDiv);
    // Atualiza TOTAL
    orderTotalElement.textContent = "R$" + novoTotal.replace(".", ",");
    // Atualiza valor no botão
    buttonPriceElement.textContent = "R$" + novoTotal.replace(".", ",");
    // Mensagem de sucesso
    message.style.display = "block";

  } else {
    error.style.display = "block";
  }
}
// --- VALIDAÇÃO GERAL ANTES DE FAZER O PEDIDO ---
document.addEventListener("DOMContentLoaded", () => {
  const btnPlaceOrder = document.getElementById("btnPlaceOrder");
  const form = document.getElementById("checkoutForm");

  if (btnPlaceOrder) {
    btnPlaceOrder.addEventListener("click", function () {
      const camposObrigatorios = form.querySelectorAll("[required]");
      let tudoOk = true;
      let primeiroErro = null;

      camposObrigatorios.forEach((campo) => {
        if (!campo.value.trim()) {
          campo.classList.add("is-invalid");
          if (!primeiroErro) primeiroErro = campo;
          tudoOk = false;
        } else {
          campo.classList.remove("is-invalid");
        }
      });

      // erro de país selecionado
      const country = document.getElementById("country");
      const countryError = document.getElementById("countryError");

      if (country.value === "") {
        countryError.style.display = "block";
        tudoOk = false;
        if (!primeiroErro) primeiroErro = country;
      } else {
        countryError.style.display = "none";
      }

      // erro no CEP vindo das validações de API
      const erroCep = document.getElementById("erro-cep");
      if (erroCep.style.display === "block") {
        tudoOk = false;
        if (!primeiroErro) primeiroErro = document.getElementById("cep");
      }

      // erro no cartão (caso pagamento credit-card esteja selecionado)
      const paymentMethod = document.querySelector('input[name="payment-method"]:checked').id;
      if (paymentMethod === "credit-card") {
        const errosCartao = [
          "cardNumberError",
          "expiryError",
          "cvvError",
          "cardNameError"
        ];

        errosCartao.forEach((id) => {
          const elemento = document.getElementById(id);
          if (elemento.style.display === "block") {
            tudoOk = false;
          }
        });
      }

      // termos e condições
      const terms = document.getElementById("terms");
      if (!terms.checked) {
        tudoOk = false;
        terms.classList.add("is-invalid");
        if (!primeiroErro) primeiroErro = terms;
      } else {
        terms.classList.remove("is-invalid");
      }

      // Se algum erro existe ➜ impedir navegação
      if (!tudoOk) {
        const msg = document.getElementById("formErrorMessage");
        msg.textContent = "Por favor, preencha todos os campos obrigatórios.";
        msg.style.display = "block";

        // rolar até o campo do primeiro erro
        primeiroErro.scrollIntoView({ behavior: "smooth", block: "center" });
        primeiroErro.focus();

        return;
      }

      // Tudo OK ➜ pode enviar
      window.location.href = "order-confirmation.html";
    });
  }
});
//VALIDAR REGISTRAR
document.addEventListener("DOMContentLoaded", () => {

  const formRegister = document.querySelector(".register-page form");
  if (!formRegister) return;

  //LISTA DE CAMPOS
  const campos = [
    { id: "fullName", msg: "Preencha seu nome completo" },
    { id: "email", msg: "Preencha seu email" },
    { id: "password", msg: "Preencha sua senha (mín. 8 caracteres)" },
    { id: "confirmPassword", msg: "Confirme sua senha" }
  ];

  // CRIA MENSAGENS AUTOMÁTICAS
  campos.forEach(c => {
    const input = document.getElementById(c.id);
    if (!input) return;

    const erro = document.createElement("small");
    erro.classList.add("erro-form");
    erro.style.color = "#2E5C5C";
    erro.style.display = "none";
    erro.textContent = c.msg;

    input.insertAdjacentElement("afterend", erro);

    input.addEventListener("input", () => {
      if (input.value.trim() === "") {
        erro.style.display = "block";
        input.classList.add("is-invalid");
      } else {
        erro.style.display = "none";
        input.classList.remove("is-invalid");
      }

      if (c.id === "confirmPassword" || c.id === "password") validarSenha();
    });
  });

  // ---- VALIDAÇÃO DE SENHA ----
  function validarSenha() {
    const senha = document.getElementById("password");
    const confirmar = document.getElementById("confirmPassword");
    if (!senha || !confirmar) return true;

    let erroConfirm = confirmar.nextElementSibling;

    if (senha.value !== confirmar.value || confirmar.value.trim() === "") {
      erroConfirm.textContent = "As senhas não coincidem";
      erroConfirm.style.display = "block";
      confirmar.classList.add("is-invalid");
      return false;
    } else {
      erroConfirm.style.display = "none";
      confirmar.classList.remove("is-invalid");
      return true;
    }
  }

  //SELECT DO PAÍS
  const country = document.getElementById("country");
  if (country) {
    const erroPais = document.createElement("small");
    erroPais.style.color = "#2E5C5C";
    erroPais.style.display = "none";
    erroPais.textContent = "Selecione seu país.";
    country.insertAdjacentElement("afterend", erroPais);

    function validarPais() {
      if (country.value === "" || country.value === null) {
        erroPais.style.display = "block";
        country.classList.add("is-invalid");
        return false;
      }
      erroPais.style.display = "none";
      country.classList.remove("is-invalid");
      return true;
    }

    country.addEventListener("change", validarPais);
    country.addEventListener("blur", validarPais);
  }

  //TERMOS
  const terms = document.getElementById("termsCheck");
  let erroTermos = null;

  if (terms) {
    erroTermos = document.createElement("small");
    erroTermos.style.color = "#2E5C5C";
    erroTermos.style.display = "none";
    erroTermos.textContent = "Você deve aceitar os termos para continuar.";
    terms.insertAdjacentElement("afterend", erroTermos);

    function validarTermos() {
      if (!terms.checked) {
        erroTermos.style.display = "block";
        terms.classList.add("is-invalid");
        return false;
      }
      erroTermos.style.display = "none";
      terms.classList.remove("is-invalid");
      return true;
    }

    terms.addEventListener("change", validarTermos);
  }

  //SUBMISSÃO DO FORM
  formRegister.addEventListener("submit", (e) => {
    let valido = true;
    let primeiroErro = null;
    // valida campos
    campos.forEach(c => {
      const input = document.getElementById(c.id);
      const erro = input?.nextElementSibling;

      if (input && input.value.trim() === "") {
        erro.style.display = "block";
        input.classList.add("is-invalid");
        valido = false;
        if (!primeiroErro) primeiroErro = input;
      }
    });
    // valida senha
    if (!validarSenha()) {
      valido = false;
      if (!primeiroErro) primeiroErro = document.getElementById("confirmPassword");
    }
    // valida país
    if (country && !country.value) {
      valido = false;
      if (!primeiroErro) primeiroErro = country;
    }
    // valida termos
    if (terms && !terms.checked) {
      valido = false;
      if (!primeiroErro) primeiroErro = terms;
    }

    if (!valido) {
      e.preventDefault();
      primeiroErro.scrollIntoView({ behavior: "smooth", block: "center" });
      primeiroErro.focus();
    }
  });

});
function validarSenhaIgual() {
  const senha = document.getElementById("password");
  const confirmar = document.getElementById("confirmPassword");
  const erro = document.getElementById("erroSenha");

  if (senha.value !== confirmar.value) {
    erro.style.display = "block";
    senha.classList.add("is-invalid");
    confirmar.classList.add("is-invalid");
    return false;
  }

  erro.style.display = "none";
  senha.classList.remove("is-invalid");
  confirmar.classList.remove("is-invalid");
  return true;
}

document.getElementById("password").addEventListener("input", validarSenhaIgual);
document.getElementById("confirmPassword").addEventListener("input", validarSenhaIgual);

document.querySelector("form").addEventListener("submit", (e) => {
  if (!validarSenhaIgual()) {
    e.preventDefault();
    document.getElementById("confirmPassword").scrollIntoView({ behavior: "smooth", block: "center" });
  }
});
document.addEventListener("DOMContentLoaded", () => {

  const cep = document.getElementById("cep");
  const rua = document.getElementById("rua");
  const bairro = document.getElementById("bairro");
  const cidade = document.getElementById("cidade");
  const estado = document.getElementById("estado");
  const pais = document.getElementById("pais");
  // Máscara de CEP
  cep.addEventListener("input", () => {
    cep.value = cep.value.replace(/\D/g, "").replace(/(\d{5})(\d)/, "$1-$2");
  });
  cep.addEventListener("blur", () => {
    const somenteNumeros = cep.value.replace(/\D/g, "");

    if (somenteNumeros.length !== 8) {
      mostrarErroCEP("CEP inválido.");
      return;
    }

    fetch(`https://viacep.com.br/ws/${somenteNumeros}/json/`)
      .then(response => response.json())
      .then(data => {
        if (data.erro) {
          mostrarErroCEP("CEP não encontrado.");
          return;
        }
        // Preenche automaticamente
        rua.value = data.logradouro || "";
        bairro.value = data.bairro || "";
        cidade.value = data.localidade || "";
        estado.value = data.uf || "";
        // país sempre Brasil quando usar viaCEP!!!!!!
        pais.value = "BR";

        removerErroCEP();

      })
      .catch(() => {
        mostrarErroCEP("Erro ao consultar CEP.");
      });
  });

  // Funções de erro
  function mostrarErroCEP(msg) {
    let small = cep.nextElementSibling;
    if (!small || small.tagName.toLowerCase() !== "small") {
      small = document.createElement("small");
      small.style.color = "#2E5C5C";
      small.style.display = "block";
      cep.insertAdjacentElement("afterend", small);
    }
    small.textContent = msg;
    cep.classList.add("is-invalid");
  }

  function removerErroCEP() {
    let small = cep.nextElementSibling;
    if (small && small.tagName.toLowerCase() === "small") {
      small.style.display = "none";
    }
    cep.classList.remove("is-invalid");
  }

});
function buscarCep() {
  const cep = document.getElementById("cep");
  const rua = document.getElementById("rua");
  const bairro = document.getElementById("bairro");
  const cidade = document.getElementById("cidade");
  const estado = document.getElementById("estado");
  const pais = document.getElementById("pais");

  let valor = cep.value.replace(/\D/g, "");
  // Máscara de CEP
  cep.value = valor.replace(/(\d{5})(\d)/, "$1-$2");
  // Só consulta quando tiver 8 dígitos
  if (valor.length !== 8) {
    mostrarErroCEP("CEP inválido.");
    return;
  }

  fetch(`https://viacep.com.br/ws/${valor}/json/`)
    .then(res => res.json())
    .then(data => {
      if (data.erro) {
        mostrarErroCEP("CEP não encontrado.");
        return;
      }
      // Preenche automaticamente
      rua.value = data.logradouro || "";
      bairro.value = data.bairro || "";
      cidade.value = data.localidade || "";
      estado.value = data.uf || "";
      pais.value = "BR"; // ViaCEP sempre Brasil!!!!!

      removerErroCEP();
    })
    .catch(() => {
      mostrarErroCEP("Erro ao consultar o CEP.");
    });

  // Função de erro
  function mostrarErroCEP(msg) {
    let small = cep.nextElementSibling;
    if (!small || small.tagName.toLowerCase() !== "small") {
      small = document.createElement("small");
      small.style.color = "#2E5C5C";
      small.style.display = "block";
      cep.insertAdjacentElement("afterend", small);
    }
    small.textContent = msg;
    cep.classList.add("is-invalid");
  }

  // Remover erro
  function removerErroCEP() {
    let small = cep.nextElementSibling;
    if (small && small.tagName.toLowerCase() === "small") {
      small.style.display = "none";
    }
    cep.classList.remove("is-invalid");
  }
}
function mascaraTelefone(input) {
  let valor = input.value.replace(/\D/g, "");
  // Limita no máximo 11 dígitos
  if (valor.length > 11) valor = valor.slice(0, 11);
  // Formatação dinâmica
  if (valor.length > 10) {
    // Formato celular 9 dígitos: (11) 99999-9999
    input.value = valor.replace(/(\d{2})(\d{5})(\d{4})/, "($1) $2-$3");
  } else if (valor.length > 6) {
    // Telefone fixo incompleto
    input.value = valor.replace(/(\d{2})(\d{4})(\d+)/, "($1) $2-$3");
  } else if (valor.length > 2) {
    input.value = valor.replace(/(\d{2})(\d+)/, "($1) $2");
  } else {
    input.value = valor.replace(/(\d*)/, "($1");
  }
}
document.addEventListener("DOMContentLoaded", () => {
  let clientes = JSON.parse(localStorage.getItem("clientes")) || [];
  atualizarTabela();
  const form = document.getElementById("cadastroForm");

  form.addEventListener("submit", (e) => {
    e.preventDefault();

    const novoCliente = {
      id: Date.now(),
      nome: document.getElementById("nome").value,
      email: document.getElementById("email").value,
      telefone: document.getElementById("telefone").value,
      rua: document.getElementById("rua").value,
      numero: document.getElementById("numero").value,
      bairro: document.getElementById("bairro").value,
      cidade: document.getElementById("cidade").value,
      estado: document.getElementById("estado").value,
      cep: document.getElementById("cep").value,
      pais: document.getElementById("pais").value
    };

    clientes.push(novoCliente);
    localStorage.setItem("clientes", JSON.stringify(clientes));

    atualizarTabela();
    mostrarMensagem("Cliente cadastrado com sucesso!");

    form.reset();
  });
  function atualizarTabela() {
    const tabela = document.getElementById("tabelaClientes");
    tabela.innerHTML = "";

    clientes.forEach(cliente => {
      const tr = document.createElement("tr");

      tr.innerHTML = `
        <td>${cliente.nome}</td>
        <td>${cliente.email}</td>
        <td>
          <a href="#popup-editar" class="btn-editar" onclick="editarCliente(${cliente.id})">
            <i class="bi bi-pencil me-1"></i>
          </a>
          <a href="#popup-excluir" class="btn-excluir" onclick="prepararExclusao(${cliente.id})">
            <i class="bi bi-trash me-1"></i>
          </a>
          <a href="#popup-visualizar" class="btn-visualizar" onclick="visualizarCliente(${cliente.id})">
            <i class="bi bi-eye me-1"></i>
          </a>
        </td>
      `;

      tabela.appendChild(tr);
    });
  }
  function mostrarMensagem(texto) {
    const div = document.createElement("div");
    div.textContent = texto;

    div.style.position = "fixed";
    div.style.bottom = "20px";
    div.style.right = "20px";
    div.style.background = "#198754";
    div.style.padding = "12px 20px";
    div.style.borderRadius = "8px";
    div.style.color = "white";
    div.style.boxShadow = "0px 4px 15px rgba(0,0,0,0.2)";
    div.style.zIndex = "99999";

    document.body.appendChild(div);

    setTimeout(() => div.remove(), 3000);
  }
  window.visualizarCliente = function(id) {
    const c = clientes.find(x => x.id === id);

    document.getElementById("detalhe-nome").textContent = c.nome;
    document.getElementById("detalhe-email").textContent = c.email;
    document.getElementById("detalhe-telefone").textContent = c.telefone;
    document.getElementById("detalhe-endereco").textContent = `${c.rua}, ${c.numero} - ${c.bairro} - ${c.cidade}/${c.estado}`;
    document.getElementById("detalhe-cep").textContent = c.cep;
    document.getElementById("detalhe-pais").textContent = c.pais;
  };
  window.editarCliente = function(id) {
    const c = clientes.find(x => x.id === id);
    window.clienteEditando = id;

    document.getElementById("editar-nome").value = c.nome;
    document.getElementById("editar-email").value = c.email;
    document.getElementById("editar-telefone").value = c.telefone;
    document.getElementById("editar-rua").value = c.rua;
    document.getElementById("editar-numero").value = c.numero;
    document.getElementById("editar-bairro").value = c.bairro;
    document.getElementById("editar-cidade").value = c.cidade;
    document.getElementById("editar-uf").value = c.estado;
    document.getElementById("editar-cep").value = c.cep;
    document.getElementById("editar-pais").value = c.pais;
  };
  document.getElementById("formEditar").addEventListener("submit", function(e) {
    e.preventDefault();

    let id = window.clienteEditando;
    let index = clientes.findIndex(c => c.id === id);

    clientes[index] = {
      id,
      nome: document.getElementById("editar-nome").value,
      email: document.getElementById("editar-email").value,
      telefone: document.getElementById("editar-telefone").value,
      rua: document.getElementById("editar-rua").value,
      numero: document.getElementById("editar-numero").value,
      bairro: document.getElementById("editar-bairro").value,
      cidade: document.getElementById("editar-cidade").value,
      estado: document.getElementById("editar-uf").value,
      cep: document.getElementById("editar-cep").value,
      pais: document.getElementById("editar-pais").value
    };

    localStorage.setItem("clientes", JSON.stringify(clientes));
    atualizarTabela();
    mostrarMensagem("Cliente atualizado!");

    window.location.href = "#";
  });
  window.prepararExclusao = function(id) {
    window.excluirID = id;
  };

  window.confirmarExclusao = function() {
    clientes = clientes.filter(c => c.id !== window.excluirID);
    localStorage.setItem("clientes", JSON.stringify(clientes));

    atualizarTabela();
    mostrarMensagem("Cliente excluído!");

    window.location.href = "#";
  };

});
function mascaraTelefone(campo) {
    let v = campo.value.replace(/\D/g, "");
    v = v.replace(/^(\d{2})(\d)/g, "($1) $2");
    v = v.replace(/(\d{5})(\d)/, "$1-$2");
    campo.value = v;
}

async function buscarCepEditar() {
    let cep = document.getElementById("editar-cep").value.replace(/\D/g, "");

    if (cep.length !== 8) return;

    try {
        const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
        const data = await response.json();

        if (!data.erro) {
            document.getElementById("editar-rua").value = data.logradouro;
            document.getElementById("editar-bairro").value = data.bairro;
            document.getElementById("editar-cidade").value = data.localidade;
            document.getElementById("editar-estado").value = data.uf;
        }
    } catch (error) {
        console.log("Erro ao buscar CEP:", error);
    }
}
  const form = document.getElementById("registerForm");

  form.addEventListener("submit", async function (e) {
    e.preventDefault();
    window.location.href = "cadastro.html";
  });
document.addEventListener("DOMContentLoaded", function () {

  const stepEmail = document.getElementById("stepEmail");
  const stepEmailSent = document.getElementById("stepEmailSent");
  const sendEmailBtn = document.getElementById("sendEmailBtn");

  sendEmailBtn.addEventListener("click", function (e) {
    e.preventDefault();
    stepEmail.classList.add("d-none");
    stepEmailSent.classList.remove("d-none");
  });

});
function verificarDataValidade() {
    const inputData = document.getElementById('expiry');
    const smallError = document.getElementById('expiryError');
    const dataDigitada = inputData.value.trim();
    smallError.style.display = 'none';
    if (dataDigitada === '') {
        return;
    }
    //Regex formato MM/AA
    const regex = /^(\d{2})\/(\d{2})$/;
    const match = dataDigitada.match(regex);
    if (!match) {
        smallError.textContent = 'Formato inválido. Use MM/AA.';
        smallError.style.display = 'block';
        return false;
    }
    //Extrai Mês e Ano e converte para números
    const mesDigitado = parseInt(match[1], 10);
    const anoDigitado = parseInt(match[2], 10);
    //Pega a Data Atual
    const dataAtual = new Date();
    const mesAtual = dataAtual.getMonth() + 1;
    const anoAtual = dataAtual.getFullYear() % 100; //25
    //(2025 -> 25)
    const anoMinimoAceitavel = 25; 
    let dataEhValida = true;
    let mensagemErro = 'Data de validade expirada ou inválida.';
    //verifica se o ano é menor que 2025
    if (anoDigitado < anoMinimoAceitavel) {
        dataEhValida = false;
        mensagemErro = 'Ano inválido. A data de validade deve ser 2025 ou superior.';
    }
    //verifica se o mês é válido
    else if (mesDigitado < 1 || mesDigitado > 12) {
        dataEhValida = false;
        mensagemErro = 'Mês inválido.';
    } 
    //verifica se o ano digitado é menor que o ano atual
    else if (anoDigitado === anoAtual) {
        //se for o ano atual (25), verifica se o mês expirou
        if (mesDigitado < mesAtual) {
            dataEhValida = false;
        }
    }
    if (!dataEhValida) {
        smallError.textContent = mensagemErro;
        smallError.style.display = 'block'; 
        return false; 
    } else {
        return true; 
    }
}
function enviarRecuperacao() {
  const emailInput = document.getElementById('emailInput');
  if (!emailInput.checkValidity()) {
    emailInput.reportValidity();
    return;
  }
  const successMsg = document.getElementById('successMsg');
  successMsg.classList.remove('d-none');
}
let clientes = [
  {
    nome: "João Silva",
    email: "joao@email.com",
    telefone: "(11) 98888-7777",
    cep: "01001-000",
    rua: "Praça da Sé",
    numero: "100",
    bairro: "Sé",
    cidade: "São Paulo",
    estado: "SP",
    pais: "BR"
  },
  {
    nome: "Maria Oliveira",
    email: "maria@email.com",
    telefone: "(21) 97777-5555",
    cep: "20040-010",
    rua: "Rua da Assembleia",
    numero: "200",
    bairro: "Centro",
    cidade: "Rio de Janeiro",
    estado: "RJ",
    pais: "BR"
  }
];

function atualizarTabela() {
  const tabela = document.querySelector("#tabelaClientes tbody");
  tabela.innerHTML = "";

  clientes.forEach((c, index) => {
    const row = `
      <tr>
        <td>${c.nome}</td>
        <td>${c.email}</td>
        <td>${c.telefone}</td>
        <td>${c.cidade}</td>
        <td>
          <button class="btn-excluir" onclick="excluirCliente(${index})">
            Excluir
          </button>
        </td>
      </tr>
    `;
    tabela.insertAdjacentHTML("beforeend", row);
  });
}
function cadastrarCliente() {
  const nome = document.querySelector("#nome").value.trim();
  const email = document.querySelector("#email").value.trim();
  const telefone = document.querySelector("#telefone").value.trim();
  const cep = document.querySelector("#cep").value.trim();
  const rua = document.querySelector("#rua").value.trim();
  const numero = document.querySelector("#numero").value.trim();
  const bairro = document.querySelector("#bairro").value.trim();
  const cidade = document.querySelector("#cidade").value.trim();
  const estado = document.querySelector("#estado").value.trim();
  const pais = document.querySelector("#pais").value;

  if (!nome || !email || !telefone || !cep || !rua || !bairro || !cidade || !estado || !pais) {
    window.neofarmaToast("Preencha todos os campos antes de cadastrar!", "danger");
    return;
  }

  const novoCliente = {
    nome,
    email,
    telefone,
    cep,
    rua,
    numero,
    bairro,
    cidade,
    estado,
    pais
  };

  clientes.push(novoCliente);
  atualizarTabela();
  limparFormulario();

  window.neofarmaToast("Cliente cadastrado com sucesso!", "success");
}
function excluirCliente(index) {
  window.neofarmaConfirm({
    title: 'Excluir cliente',
    message: 'Tem certeza que deseja excluir este cliente?'
  }).then(function(ok) {
    if (!ok) return;
    clientes.splice(index, 1);
    atualizarTabela();
  });
}
function limparFormulario() {
  document.querySelector("#cadastroForm").reset();

  document.querySelector("#rua").value = "";
  document.querySelector("#numero").value = "";
  document.querySelector("#bairro").value = "";
  document.querySelector("#cidade").value = "";
  document.querySelector("#estado").value = "";
}
function mascaraTelefone(input) {
  let value = input.value.replace(/\D/g, "");

  if (value.length > 11) value = value.slice(0, 11);

  if (value.length <= 10) {
    input.value = value.replace(/(\d{2})(\d{4})(\d{0,4})/, "($1) $2-$3");
  } else {
    input.value = value.replace(/(\d{2})(\d{5})(\d{0,4})/, "($1) $2-$3");
  }
}
async function buscarCep() {
  const cep = document.querySelector("#cep").value.replace(/\D/g, "");

  if (cep.length !== 8) return;

  try {
    const response = await fetch(`https://viacep.com.br/ws/${cep}/json/`);
    const data = await response.json();

    if (data.erro) {
      window.neofarmaToast("CEP não encontrado!", "danger");
      return;
    }

    document.querySelector("#rua").value = data.logradouro;
    document.querySelector("#bairro").value = data.bairro;
    document.querySelector("#cidade").value = data.localidade;
    document.querySelector("#estado").value = data.uf;
    document.querySelector("#numero").removeAttribute("readonly");

  } catch (error) {
    window.neofarmaToast("Erro ao buscar CEP!", "danger");
  }
}
document.addEventListener("DOMContentLoaded", atualizarTabela);o
const contactForm = document.getElementById('contactForm');
const contactSuccess = document.getElementById('contactSuccess');

// Função para exibir mensagem de sucesso
function enviarMensagem() {
  const contactSuccess = document.getElementById('contactSuccess');
  contactSuccess.classList.remove('d-none');
  setTimeout(() => {
    contactSuccess.classList.add('d-none');
  }, 5000);
  document.getElementById('contactForm').reset();
}
console.log("api.js carregado corretamente!");

