   const DB_KEY = 'neofarma_clientes';
   function getClientesBD() {
       return JSON.parse(localStorage.getItem(DB_KEY)) || [];
   }
   function setClientesBD(lista) {
       localStorage.setItem(DB_KEY, JSON.stringify(lista));
   }
   if (!localStorage.getItem(DB_KEY)) {
       const dadosIniciais = [
           { id: 1, nome: "Ana Pereira", email: "ana@gmail.com", telefone: "(11) 98888-7777", cidade: "São Paulo", estado: "SP", rua: "Av. Paulista", numero: "1000", bairro: "Bela Vista", cep: "01310-100", pais: "Brasil" },
           { id: 2, nome: "Carlos Souza", email: "carlos@empresa.com", telefone: "(21) 97777-6666", cidade: "Rio de Janeiro", estado: "RJ", rua: "Rua das Pedras", numero: "50", bairro: "Centro", cep: "20000-000", pais: "Brasil" }
       ];
       setClientesBD(dadosIniciais);
   }
   //CADASTRO
   function salvarCliente() {
       const nome = document.getElementById('nome').value.trim();
       const email = document.getElementById('email').value.trim();
       const telefone = document.getElementById('telefone').value.trim();
       const cep = document.getElementById('cep').value;
       const rua = document.getElementById('rua').value;
       const numero = document.getElementById('numero').value.trim();
       const bairro = document.getElementById('bairro').value;
       const cidade = document.getElementById('cidade').value;
       const estado = document.getElementById('estado').value;
       const pais = document.getElementById('pais').value;
   
       let valido = true;
       if (nome.length < 3) { mostrarErro('nome', 'Nome inválido'); valido = false; }
       if (!email.includes('@')) { mostrarErro('email', 'Email inválido'); valido = false; }
       if (telefone === '') { mostrarErro('telefone', 'Obrigatório'); valido = false; }
       if (cep === '') { mostrarErro('cep', 'Obrigatório'); valido = false; }
       if (numero === '') { mostrarErro('numero', 'Obrigatório'); valido = false; }
   
       if (!valido) return;
   
       const novoCliente = {
           id: new Date().getTime(),
           nome, email, telefone, cep, rua, numero, bairro, cidade, estado, pais
       };
   
       const lista = getClientesBD();
       lista.push(novoCliente);
       setClientesBD(lista);
   
       const modalSucesso = new bootstrap.Modal(document.getElementById('modalSucessoCadastro'));
       modalSucesso.show();
   }
   
   function irParaLista() {
       window.location.href = "list_clients.html";
   }
   //LISTAGEM
   function carregarClientes() {
       const tbody = document.getElementById('tabelaClientesBody');
       if (!tbody) return; 
   
       const lista = getClientesBD();
       const msgVazia = document.getElementById('mensagemVazia');
       
       tbody.innerHTML = '';
       document.getElementById('btnExcluirMassa').classList.add('d-none');
       document.getElementById('checkAll').checked = false;
   
       if (lista.length === 0) {
           msgVazia.style.display = 'block';
           return;
       }
       msgVazia.style.display = 'none';
   
       lista.forEach(c => {
           const tr = document.createElement('tr');
           tr.innerHTML = `
               <td>
                   <input type="checkbox" class="form-check-input check-item" value="${c.id}" onclick="verificarSelecao()">
               </td>
               <td class="fw-bold">${c.nome}</td>
               <td>${c.email}</td>
               <td>${c.telefone}</td>
               <td>${c.cidade}/${c.estado}</td>
               <td class="col-actions">
                   <div class="table-actions table-actions--2">
                   <button class="btn-action btn-view" onclick="verDetalhes(${c.id})" title="Ver informações" aria-label="Ver informações"><i class="bi bi-info-circle"></i></button>
                   <button class="btn-action btn-edit" onclick="prepararEdicao(${c.id})" title="Editar"><i class="bi bi-pencil"></i></button>
                   </div>
               </td>
           `;
           tbody.appendChild(tr);
       });
   }
   
   function alternarTodos(source) {
       const checkboxes = document.querySelectorAll('.check-item');
       checkboxes.forEach(cb => cb.checked = source.checked);
       verificarSelecao();
   }

   function verificarSelecao() {
       const selecionados = document.querySelectorAll('.check-item:checked');
       const btnExcluir = document.getElementById('btnExcluirMassa');
       const contador = document.getElementById('contadorSelecao');
       
       if (selecionados.length > 0) {
           btnExcluir.classList.remove('d-none');
           contador.innerText = selecionados.length;
       } else {
           btnExcluir.classList.add('d-none');
       }
   }
   
   function abrirModalExclusaoMassa() {
       const modal = new bootstrap.Modal(document.getElementById('modalExclusaoMassa'));
       modal.show();
   }
   
   function executarExclusaoMassa() {
       const checkboxes = document.querySelectorAll('.check-item:checked');
       const idsParaExcluir = Array.from(checkboxes).map(cb => parseInt(cb.value));
       
       let lista = getClientesBD();
       lista = lista.filter(c => !idsParaExcluir.includes(c.id));
       setClientesBD(lista);
       
       const modalEl = document.getElementById('modalExclusaoMassa');
       const modal = bootstrap.Modal.getInstance(modalEl);
       modal.hide();
       
       mostrarMensagemSucesso("Registros excluídos com sucesso!");
       carregarClientes();
   }
   
   //AÇÕES (VER, EDITAR)
   function verDetalhes(id) {
       const lista = getClientesBD();
       const c = lista.find(cliente => cliente.id === id);
       if (!c) return;
   
       const html = `
           <div class="view-avatar-section">
               <div class="avatar-large">${c.nome.charAt(0).toUpperCase()}</div>
               <h4>${c.nome}</h4>
               <span class="badge bg-success bg-opacity-10 text-success">Cliente Ativo</span>
           </div>
           
           <div class="view-grid">
               <div class="view-item">
                   <span class="view-label">Email</span>
                   <div class="view-value"><i class="bi bi-envelope"></i> ${c.email}</div>
               </div>
               <div class="view-item">
                   <span class="view-label">Telefone</span>
                   <div class="view-value"><i class="bi bi-telephone"></i> ${c.telefone}</div>
               </div>
               <div class="view-item">
                   <span class="view-label">Endereço</span>
                   <div class="view-value"><i class="bi bi-geo-alt"></i> ${c.rua}, ${c.numero}</div>
               </div>
               <div class="view-item">
                   <span class="view-label">Bairro</span>
                   <div class="view-value"><i class="bi bi-map"></i> ${c.bairro}</div>
               </div>
               <div class="view-item">
                   <span class="view-label">Cidade/UF</span>
                   <div class="view-value"><i class="bi bi-building"></i> ${c.cidade} - ${c.estado}</div>
               </div>
               <div class="view-item">
                   <span class="view-label">CEP</span>
                   <div class="view-value"><i class="bi bi-mailbox"></i> ${c.cep}</div>
               </div>
           </div>
       `;
       
       document.getElementById('conteudoVisualizacao').innerHTML = html;
       const modal = new bootstrap.Modal(document.getElementById('modalVisualizar'));
       modal.show();
   }
   
   function prepararEdicao(id) {
       const lista = getClientesBD();
       const c = lista.find(cliente => cliente.id === id);
       
       document.getElementById('edit-id').value = c.id;
       document.getElementById('edit-nome').value = c.nome;
       document.getElementById('edit-email').value = c.email;
       document.getElementById('edit-telefone').value = c.telefone;
       document.getElementById('edit-cep').value = c.cep;
       document.getElementById('edit-rua').value = c.rua;
       document.getElementById('edit-numero').value = c.numero;
       document.getElementById('edit-bairro').value = c.bairro;
       document.getElementById('edit-cidade').value = c.cidade;
       document.getElementById('edit-estado').value = c.estado;
       document.getElementById('edit-pais').value = c.pais;
   
       const modal = new bootstrap.Modal(document.getElementById('modalEditar'));
       modal.show();
   }
   
   function salvarEdicao() {
       const id = parseInt(document.getElementById('edit-id').value);
       let lista = getClientesBD();
       const index = lista.findIndex(c => c.id === id);
   
       if (index > -1) {
           lista[index].nome = document.getElementById('edit-nome').value;
           lista[index].email = document.getElementById('edit-email').value;
           lista[index].telefone = document.getElementById('edit-telefone').value;
           lista[index].cep = document.getElementById('edit-cep').value;
           lista[index].rua = document.getElementById('edit-rua').value;
           lista[index].numero = document.getElementById('edit-numero').value;
           lista[index].bairro = document.getElementById('edit-bairro').value;
           lista[index].cidade = document.getElementById('edit-cidade').value;
           lista[index].estado = document.getElementById('edit-estado').value;
           lista[index].pais = document.getElementById('edit-pais').value;
           
           setClientesBD(lista);
           
           const modalEditEl = document.getElementById('modalEditar');
           const modalEdit = bootstrap.Modal.getInstance(modalEditEl);
           modalEdit.hide();
   
           carregarClientes();
           mostrarMensagemSucesso("Dados atualizados!");
       }
   }
   //UTILITÁRIOS (MÁSCARAS, CEP, MENSAGENS)
   function mostrarMensagemSucesso(texto) {
       document.getElementById('msgSucesso').innerText = texto;
       const modalEl = document.getElementById('modalSucesso');
       if(modalEl) {
           const modal = new bootstrap.Modal(modalEl);
           modal.show();
           setTimeout(() => modal.hide(), 1500);
       } else {
        window.neofarmaToast(texto, 'success');
       }
   }
   
   function aplicarMascaraTelefone(input) {
       let v = input.value.replace(/\D/g, "");
       if (v.length > 11) v = v.slice(0, 11);
       if (v.length > 10) v = v.replace(/^(\d{2})(\d{5})(\d{4}).*/, "($1) $2-$3");
       else if (v.length > 5) v = v.replace(/^(\d{2})(\d{4})(\d{0,4}).*/, "($1) $2-$3");
       else if (v.length > 2) v = v.replace(/^(\d{2})(\d{0,5}).*/, "($1) $2");
       input.value = v;
   }
   
   function aplicarMascaraCep(input) {
       let v = input.value.replace(/\D/g, "");
       if (v.length > 8) v = v.slice(0, 8);
       v = v.replace(/^(\d{5})(\d)/, "$1-$2");
       input.value = v;
   }
   function buscarCep(valor, contexto = 'cadastro') {
       const cep = valor.replace(/\D/g, '');
       const prefixo = contexto === 'edicao' ? 'edit-' : '';
   
       if (cep.length === 8) {
           document.getElementById(prefixo + 'rua').value = "...";
           
           fetch(`https://viacep.com.br/ws/${cep}/json/`)
               .then(res => res.json())
               .then(d => {
                   if(!d.erro) {
                       document.getElementById(prefixo + 'rua').value = d.logradouro;
                       document.getElementById(prefixo + 'bairro').value = d.bairro;
                       document.getElementById(prefixo + 'cidade').value = d.localidade;
                       document.getElementById(prefixo + 'estado').value = d.uf;
                       document.getElementById(prefixo + 'numero').focus();
                       
                       if(contexto === 'cadastro') limparErro('cep');
                   } else {
                       document.getElementById(prefixo + 'rua').value = "";
                      if(contexto === 'cadastro') mostrarErro('cep', 'CEP não encontrado');
                      else window.neofarmaToast('CEP não encontrado', 'danger');
                   }
               })
               .catch(() => {
                   document.getElementById(prefixo + 'rua').value = "";
               });
       }
   }
   function mostrarErro(id, msg) {
       const el = document.getElementById(`erro-${id}`);
       const input = document.getElementById(id);
       if(el) { el.innerText = msg; el.classList.add('ativo'); }
       if(input) input.classList.add('input-erro');
   }
   
   function limparErro(id) {
       const el = document.getElementById(`erro-${id}`);
       const input = document.getElementById(id);
       if(el) el.classList.remove('ativo');
       if(input) input.classList.remove('input-erro');
   }
   
   function limparFormulario() {
       const form = document.getElementById('formCadastro');
       if(form) {
           form.reset();
           document.querySelectorAll('.msg-erro').forEach(el => el.classList.remove('ativo'));
           document.querySelectorAll('.form-control').forEach(el => el.classList.remove('input-erro'));
       }
   }
   
   function filtrarTabela() {
       const termo = document.getElementById('buscaInput').value.toLowerCase();
       const linhas = document.querySelectorAll('#tabelaClientesBody tr');
       linhas.forEach(linha => {
           const texto = linha.innerText.toLowerCase();
           linha.style.display = texto.includes(termo) ? '' : 'none';
       });
   }