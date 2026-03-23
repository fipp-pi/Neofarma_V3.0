
    window.neofarmaToast = window.neofarmaToast || function (message, type) {
      try {
        var toastEl = document.getElementById('neofarmaToast');
        if (!toastEl) return;
        var bodyEl = document.getElementById('neofarmaToastBody');
        var iconEl = document.getElementById('neofarmaToastIcon');

        if (bodyEl) bodyEl.textContent = (message == null ? '' : String(message));

        toastEl.classList.remove('text-bg-success', 'text-bg-danger', 'text-bg-warning', 'text-bg-info', 'text-bg-primary');

        var iconClass = 'bi bi-check2-circle';
        if (type === 'danger') { toastEl.classList.add('text-bg-danger'); iconClass = 'bi bi-exclamation-octagon'; }
        else if (type === 'success') { toastEl.classList.add('text-bg-success'); iconClass = 'bi bi-check2-circle'; }
        else if (type === 'warning') { toastEl.classList.add('text-bg-warning'); iconClass = 'bi bi-exclamation-triangle'; }
        else { toastEl.classList.add('text-bg-primary'); iconClass = 'bi bi-info-circle'; }

        if (iconEl) iconEl.innerHTML = '<i class="' + iconClass + '"></i>';

        if (window.bootstrap && window.bootstrap.Toast) {
          window.bootstrap.Toast.getOrCreateInstance(toastEl).show();
        } else {
          toastEl.classList.add('show');
          setTimeout(function () { toastEl.classList.remove('show'); }, 4000);
        }
      } catch (e) {
        // silencioso
      }
    };

    window.neofarmaConfirm = window.neofarmaConfirm || function (opts) {
      opts = opts || {};
      return new Promise(function (resolve) {
        try {
          var modalEl = document.getElementById('neofarmaConfirmModal');
          if (!modalEl) return resolve(false);

          var titleEl = document.getElementById('neofarmaConfirmTitle');
          var msgEl = document.getElementById('neofarmaConfirmMessage');
          var confirmBtn = document.getElementById('neofarmaConfirmConfirmBtn');
          var resolved = false;

          if (titleEl) titleEl.textContent = opts.title ? String(opts.title) : 'Confirmação';
          if (msgEl) msgEl.textContent = opts.message ? String(opts.message) : '';
          if (confirmBtn) confirmBtn.textContent = opts.confirmText ? String(opts.confirmText) : 'Confirmar';

          var modalInstance = null;
          if (window.bootstrap && window.bootstrap.Modal) {
            modalInstance = window.bootstrap.Modal.getOrCreateInstance(modalEl);
          }

          function finalize(value) {
            if (resolved) return;
            resolved = true;
            resolve(!!value);
          }

          if (confirmBtn) {
            confirmBtn.onclick = function () {
              if (modalInstance) modalInstance.hide();
              finalize(true);
            };
          }

          modalEl.addEventListener('hidden.bs.modal', function () {
            finalize(false);
          }, { once: true });

          if (modalInstance) modalInstance.show();
          else finalize(false);
        } catch (e) {
          resolve(false);
        }
      });
    };
  </script>
  <div class="d-flex">
    <nav class="admin-sidebar flex-shrink-0" style="width: 220px;">
      <div class="p-3 border-bottom border-secondary">
        <a href="/" class="d-flex align-items-center">
          <i class="bi bi-house me-2"></i> Voltar ao site
        </a>
      </div>
      <div class="p-2">
        <div class="small text-uppercase text-muted px-2 mb-2">Painel Admin</div>
        <a href="/admin" class="">
          <i class="bi bi-speedometer2 me-2"></i> Dashboard
        </a>
        <a href="/admin/produtos" class="">
          <i class="bi bi-box-seam me-2"></i> Produtos
        </a>
        <a href="/admin/lotes" class="">
          <i class="bi bi-archive me-2"></i> Lotes
        </a>
        <a href="/admin/laboratorios" class="">
          <i class="bi bi-bank me-2"></i> Laboratórios
        </a>
        <a href="/admin/fornecedores" class="">
          <i class="bi bi-truck me-2"></i> Fornecedores
        </a>
        <a href="/admin/categorias" class="">
          <i class="bi bi-tags me-2"></i> Categorias
        </a>
        <a href="/admin/financas" class="">
          <i class="bi bi-cash-stack me-2"></i> Finanças
        </a>
        <a href="/admin/agendamentos-servicos" class="active">
          <i class="bi bi-calendar2-check me-2"></i> Agendar Serviços
        </a>
        <a href="/admin/agendamentos-servicos/caixa" class="active">
          <i class="bi bi-cash-coin me-2"></i> Caixa de Serviços
        </a>
        <a href="/admin/clientes" class=" mt-2">
          <i class="bi bi-people me-2"></i> Clientes
        </a>
      </div>
    </nav>
    <main class="admin-content flex-grow-1">

<div class="container-fluid">
  <div class="list-header mb-3">
    <div>
      <h2 class="neo-heading">Agendar Serviços</h2>
      <p class="text-muted mb-0">Reserva temporária (10 min), pagamento, execução profissional e conclusão clínica.</p>
    </div>
    <div class="d-flex gap-2">
      <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalService">
        <i class="bi bi-plus-lg me-1"></i> Novo Serviço
      </button>
      <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalProfessional">
        <i class="bi bi-person-plus me-1"></i> Novo Profissional
      </button>
      <button type="button" class="btn btn-outline-primary" data-bs-toggle="modal" data-bs-target="#modalHoliday">
        <i class="bi bi-calendar-x me-1"></i> Feriados
      </button>
      <button type="button" class="btn btn-primary" data-bs-toggle="modal" data-bs-target="#modalReserve">
        <i class="bi bi-calendar-plus me-1"></i> Novo Agendamento
      </button>
    </div>
  </div>

  <div class="row g-3 mb-3">
    <div class="col-md-2"><div class="card p-3"><div class="text-muted small">Total</div><div class="h4 mb-0">0</div></div></div>
    <div class="col-md-2"><div class="card p-3"><div class="text-muted small">Reservados</div><div class="h4 mb-0">0</div></div></div>
    <div class="col-md-2"><div class="card p-3"><div class="text-muted small">Confirmados</div><div class="h4 mb-0">0</div></div></div>
    <div class="col-md-2"><div class="card p-3"><div class="text-muted small">Em atendimento</div><div class="h4 mb-0">0</div></div></div>
    <div class="col-md-2"><div class="card p-3"><div class="text-muted small">Concluídos</div><div class="h4 mb-0">0</div></div></div>
  </div>

  <div class="table-container mb-4">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <h5 class="mb-0">Serviços cadastrados</h5>
    </div>
    <div class="table-responsive">
      <table class="table table-custom align-middle">
        <thead>
          <tr><th>Serviço</th><th>Preço</th><th>Duração</th><th>Domicílio</th><th>Receita</th><th>Status</th></tr>
        </thead>
        <tbody>
          
          
            <tr><td colspan="6" class="text-muted">Nenhum serviço cadastrado.</td></tr>
          
        </tbody>
      </table>
    </div>
  </div>

  <div class="table-container">
    <div class="d-flex justify-content-between align-items-center mb-2">
      <h5 class="mb-0">Agenda e atendimento</h5>
      <div class="btn-group btn-group-sm">
        <a class="btn btn-dark" href="/admin/agendamentos-servicos">Todos</a>
        <a class="btn btn-outline-dark" href="/admin/agendamentos-servicos?status=RESERVED">Reservados</a>
        <a class="btn btn-outline-dark" href="/admin/agendamentos-servicos?status=CONFIRMED">Confirmados</a>
        <a class="btn btn-outline-dark" href="/admin/agendamentos-servicos?status=IN_PROGRESS">Em atendimento</a>
      </div>
    </div>
    <div class="table-responsive">
      <table class="table table-custom align-middle">
        <thead>
          <tr>
            <th>#</th><th>Cliente</th><th>Serviço</th><th>Profissional</th><th>Modalidade</th><th>Horário</th><th>Pagamento</th><th>Status</th><th class="text-end">Ações</th>
          </tr>
        </thead>
        <tbody>
          
          
            <tr><td colspan="9" class="text-muted">Nenhum agendamento encontrado.</td></tr>
          
        </tbody>
      </table>
    </div>
  </div>
</div>

<div class="modal fade" id="modalService" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Novo serviço</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">Nome</label><input class="form-control" id="svc_name"></div>
        <div class="row g-2">
          <div class="col"><label class="form-label">Preço</label><input class="form-control" id="svc_price" type="number" step="0.01"></div>
          <div class="col"><label class="form-label">Duração (min)</label><input class="form-control" id="svc_duration" type="number" value="30"></div>
        </div>
        <div class="form-check mt-2"><input class="form-check-input" id="svc_home" type="checkbox" checked><label class="form-check-label" for="svc_home">Disponível em domicílio</label></div>
        <div class="form-check"><input class="form-check-input" id="svc_rx" type="checkbox"><label class="form-check-label" for="svc_rx">Exige receita</label></div>
      </div>
      <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-primary" onclick="salvarServico()">Salvar</button></div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalHoliday" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Feriados bloqueados</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2 mb-2">
          <div class="col-5"><input class="form-control" id="hol_date" type="date"></div>
          <div class="col-7"><input class="form-control" id="hol_name" placeholder="Nome do feriado"></div>
        </div>
        <div class="d-grid mb-3"><button type="button" class="btn btn-primary" onclick="salvarFeriado()">Adicionar feriado</button></div>
        <div class="table-responsive">
          <table class="table table-sm">
            <thead><tr><th>Data</th><th>Nome</th><th class="text-end">Ação</th></tr></thead>
            <tbody>
              
              
                <tr><td colspan="3" class="text-muted">Nenhum feriado cadastrado.</td></tr>
              
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalProfessional" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Novo profissional</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="mb-2"><label class="form-label">Nome</label><input class="form-control" id="pro_name"></div>
        <div class="mb-2">
          <label class="form-label">Cargo</label>
          <select class="form-select" id="pro_role">
            <option value="FARMACEUTICO">Farmacêutico</option>
            <option value="ENFERMEIRO">Enfermeiro</option>
          </select>
        </div>
        <div class="mb-2"><label class="form-label">E-mail</label><input class="form-control" id="pro_email"></div>
        <div class="mb-2"><label class="form-label">Telefone</label><input class="form-control" id="pro_phone"></div>
        <label class="form-label mt-2">Disponibilidade semanal</label>
        <div class="small text-muted mb-2">Formato HH:MM. Deixe em branco para não incluir o dia.</div>
        
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Dom</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_0_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_0_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Seg</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_1_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_1_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Ter</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_2_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_2_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Qua</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_3_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_3_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Qui</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_4_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_4_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Sex</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_5_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_5_end" placeholder="18:00"></div>
          </div>
        
          <div class="row g-1 mb-1">
            <div class="col-3 small pt-1">Sáb</div>
            <div class="col"><input class="form-control form-control-sm" id="pro_6_start" placeholder="08:00"></div>
            <div class="col"><input class="form-control form-control-sm" id="pro_6_end" placeholder="18:00"></div>
          </div>
        
      </div>
      <div id="pro_feedback" class="small px-3 pb-1" style="display:none;"></div>
      <div class="modal-footer"><button type="button" class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button type="button" class="btn btn-primary" id="btnSalvarProfissional" onclick="salvarProfissional()">Salvar</button></div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalReserve" tabindex="-1">
  <div class="modal-dialog modal-lg">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Novo agendamento</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <div class="row g-2">
          <div class="col-md-6">
            <label class="form-label">Serviço</label>
            <select class="form-select" id="res_service_id">
              
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Modalidade</label>
            <select class="form-select" id="res_modality">
              <option value="IN_STORE">Na farmácia</option>
              <option value="HOME">Em domicílio</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Forma de pagamento</label>
            <select class="form-select" id="res_payment_method">
              <option value="CASH">Dinheiro (presencial)</option>
              <option value="PIX">PIX</option>
              <option value="CREDIT_CARD">Cartão de crédito</option>
              <option value="DEBIT_CARD">Cartão de débito</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label">Profissional</label>
            <select class="form-select" id="res_professional_id">
              
            </select>
          </div>
          <div class="col-md-6"><label class="form-label">Cliente</label><input class="form-control" id="res_customer_name"></div>
          <div class="col-md-6"><label class="form-label">E-mail</label><input class="form-control" id="res_customer_email"></div>
          <div class="col-md-6"><label class="form-label">Telefone</label><input class="form-control" id="res_customer_phone" placeholder="(11) 99999-9999"></div>
          <div class="col-md-6"><label class="form-label">Data/Hora</label><input class="form-control" id="res_scheduled_start" type="datetime-local"></div>
          <div class="col-md-3" id="home_zip_wrap" style="display:none;"><label class="form-label">CEP</label><input class="form-control" id="res_zip_code" placeholder="00000-000"></div>
          <div class="col-md-6" id="home_street_wrap" style="display:none;"><label class="form-label">Rua</label><input class="form-control" id="res_street"></div>
          <div class="col-md-3" id="home_number_wrap" style="display:none;"><label class="form-label">Número</label><input class="form-control" id="res_number"></div>
          <div class="col-md-4" id="home_complement_wrap" style="display:none;"><label class="form-label">Complemento</label><input class="form-control" id="res_complement"></div>
          <div class="col-md-4" id="home_district_wrap" style="display:none;"><label class="form-label">Bairro</label><input class="form-control" id="res_district"></div>
          <div class="col-md-3" id="home_city_wrap" style="display:none;"><label class="form-label">Cidade</label><input class="form-control" id="res_city"></div>
          <div class="col-md-1" id="home_state_wrap" style="display:none;"><label class="form-label">UF</label><input class="form-control" id="res_state" maxlength="2"></div>
        </div>
      </div>
      <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button type="button" class="btn btn-primary" id="btnReservarAgendamento" onclick="reservar()">Reservar e gerar pagamento</button></div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalConcluir" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Concluir atendimento</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="finish_id">
        <div class="mb-2"><label class="form-label">Registro clínico *</label><textarea class="form-control" id="finish_clinical" rows="3"></textarea></div>
        <div class="mb-2"><label class="form-label">Lote da vacina</label><input class="form-control" id="finish_batch"></div>
        <div class="row g-2">
          <div class="col"><label class="form-label">Validade</label><input class="form-control" type="date" id="finish_batch_exp"></div>
          <div class="col"><label class="form-label">Local aplicado</label><input class="form-control" id="finish_site" placeholder="Braço esquerdo"></div>
        </div>
        <div class="mt-2"><label class="form-label">Observações</label><textarea class="form-control" id="finish_obs" rows="2"></textarea></div>
      </div>
      <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-success" onclick="concluir()">Concluir</button></div>
    </div>
  </div>
</div>

<div class="modal fade" id="modalIncompleto" tabindex="-1">
  <div class="modal-dialog">
    <div class="modal-content">
      <div class="modal-header"><h5 class="modal-title">Marcar como não finalizado</h5><button class="btn-close" data-bs-dismiss="modal"></button></div>
      <div class="modal-body">
        <input type="hidden" id="incomplete_id">
        <label class="form-label">Motivo *</label>
        <textarea class="form-control" id="incomplete_reason" rows="3" placeholder="Ex.: Paciente apresentou febre e não pôde ser vacinado hoje."></textarea>
      </div>
      <div class="modal-footer"><button class="btn btn-outline-secondary" data-bs-dismiss="modal">Cancelar</button><button class="btn btn-warning" onclick="salvarIncompleto()">Salvar</button></div>
    </div>
  </div>
</div>

<script>
  function safeToast(message, type) {
    if (typeof window.neofarmaToast === 'function') {
      window.neofarmaToast(message, type);
      return;
    }
    console.log((type || 'info').toUpperCase() + ': ' + String(message || ''));
  }

  function updateHomeAddressVisibility() {
    var modalityEl = document.getElementById('res_modality');
    var home = modalityEl && modalityEl.value === 'HOME';
    document.getElementById('home_zip_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_street_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_number_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_complement_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_district_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_city_wrap').style.display = home ? '' : 'none';
    document.getElementById('home_state_wrap').style.display = home ? '' : 'none';
  }

  document.getElementById('res_modality').addEventListener('change', updateHomeAddressVisibility);
  document.getElementById('modalReserve').addEventListener('shown.bs.modal', updateHomeAddressVisibility);
  updateHomeAddressVisibility();

  function onlyDigits(v) { return String(v || '').replace(/\D/g, ''); }

  function formatCep(v) {
    const d = onlyDigits(v).slice(0, 8);
    if (d.length <= 5) return d;
    return d.slice(0, 5) + '-' + d.slice(5);
  }

  function formatPhoneBr(v) {
    const d = onlyDigits(v).slice(0, 11);
    if (d.length <= 2) return d ? '(' + d : '';
    if (d.length <= 6) return '(' + d.slice(0, 2) + ') ' + d.slice(2);
    if (d.length <= 10) return '(' + d.slice(0, 2) + ') ' + d.slice(2, 6) + '-' + d.slice(6);
    return '(' + d.slice(0, 2) + ') ' + d.slice(2, 7) + '-' + d.slice(7);
  }

  const resPhoneEl = document.getElementById('res_customer_phone');
  if (resPhoneEl) {
    resPhoneEl.addEventListener('input', function () {
      this.value = formatPhoneBr(this.value);
    });
  }

  const zipEl = document.getElementById('res_zip_code');
  if (zipEl) {
    zipEl.addEventListener('input', function () {
      this.value = formatCep(this.value);
    });
    zipEl.addEventListener('blur', async function () {
      const cep = onlyDigits(this.value);
      if (cep.length !== 8) return;
      try {
        const resp = await fetch('https://viacep.com.br/ws/' + cep + '/json/');
        const data = await resp.json();
        if (!data || data.erro) {
          safeToast('CEP não encontrado.', 'warning');
          return;
        }
        document.getElementById('res_street').value = data.logradouro || '';
        document.getElementById('res_district').value = data.bairro || '';
        document.getElementById('res_city').value = data.localidade || '';
        document.getElementById('res_state').value = data.uf || '';
      } catch (e) {
        safeToast('Falha ao consultar CEP.', 'warning');
      }
    });
  }

  async function postAct(url, body, opts) {
    opts = opts || {};
    const resp = await fetch(url, { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body || {}) });
    const data = await resp.json();
    if (data.ok) {
      safeToast(data.message || 'Operação realizada.', 'success');
      if (opts.reload !== false) setTimeout(function(){ location.reload(); }, opts.reloadDelayMs || 600);
    }
    else safeToast(data.message || 'Erro na operação.', 'danger');
    return data;
  }

  function abrirConcluir(id) {
    document.getElementById('finish_id').value = id;
    document.getElementById('finish_clinical').value = '';
    document.getElementById('finish_batch').value = '';
    document.getElementById('finish_batch_exp').value = '';
    document.getElementById('finish_site').value = '';
    document.getElementById('finish_obs').value = '';
    new bootstrap.Modal(document.getElementById('modalConcluir')).show();
  }

  async function concluir() {
    const id = document.getElementById('finish_id').value;
    await postAct('/admin/agendamentos-servicos/' + id + '/concluir', {
      clinical_record: document.getElementById('finish_clinical').value,
      vaccine_batch_code: document.getElementById('finish_batch').value,
      vaccine_expiry_date: document.getElementById('finish_batch_exp').value,
      application_site: document.getElementById('finish_site').value,
      observations: document.getElementById('finish_obs').value
    });
  }

  function abrirIncompleto(id) {
    document.getElementById('incomplete_id').value = id;
    document.getElementById('incomplete_reason').value = '';
    new bootstrap.Modal(document.getElementById('modalIncompleto')).show();
  }

  async function salvarIncompleto() {
    const id = document.getElementById('incomplete_id').value;
    const reason = document.getElementById('incomplete_reason').value.trim();
    if (!reason) return safeToast('Informe o motivo.', 'danger');
    await postAct('/admin/agendamentos-servicos/' + id + '/nao-finalizado', { reason: reason });
  }

  async function salvarServico() {
    await postAct('/admin/agendamentos-servicos/servicos', {
      name: document.getElementById('svc_name').value,
      price: document.getElementById('svc_price').value,
      duration_minutes: document.getElementById('svc_duration').value,
      home_available: document.getElementById('svc_home').checked,
      requires_prescription: document.getElementById('svc_rx').checked,
      is_active: true
    });
  }

  async function salvarProfissional() {
    const btn = document.getElementById('btnSalvarProfissional');
    const fb = document.getElementById('pro_feedback');
    if (btn && btn.disabled) return;
    if (btn) { btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Salvando...'; }
    if (fb) { fb.style.display = 'none'; fb.textContent = ''; }
    try {
      const availability = [];
      for (let d = 0; d < 7; d++) {
        const start = (document.getElementById('pro_' + d + '_start').value || '').trim();
        const end = (document.getElementById('pro_' + d + '_end').value || '').trim();
        if (start && end) availability.push({ day_of_week: d, start_time: start, end_time: end });
      }
      const payload = {
        full_name: document.getElementById('pro_name').value,
        role_name: document.getElementById('pro_role').value,
        email: document.getElementById('pro_email').value,
        phone: document.getElementById('pro_phone').value,
        availability
      };

      const resp = await fetch('/admin/agendamentos-servicos/profissionais', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload)
      });

      let result = {};
      const txt = await resp.text();
      try { result = txt ? JSON.parse(txt) : {}; } catch (e) { result = {}; }

      if (resp.ok && result && result.ok) {
        const okMsg = result.message || 'Profissional cadastrado com sucesso.';
        if (fb) {
          fb.className = 'small px-3 pb-1 text-success';
          fb.textContent = okMsg;
          fb.style.display = 'block';
        }
      safeToast(okMsg, 'success');
      } else {
        const errMsg = (result && result.message) || ('Não foi possível salvar o profissional. (HTTP ' + resp.status + ')');
        if (fb) {
          fb.className = 'small px-3 pb-1 text-danger';
          fb.textContent = errMsg;
          fb.style.display = 'block';
        }
        safeToast(errMsg, 'danger');
      }
    } catch (err) {
      var netMsg = 'Erro de comunicação ao salvar profissional.';
      if (err && err.message) netMsg += ' (' + err.message + ')';
      if (fb) {
        fb.className = 'small px-3 pb-1 text-danger';
        fb.textContent = netMsg;
        fb.style.display = 'block';
      }
      safeToast(netMsg, 'danger');
    } finally {
      if (btn) { btn.disabled = false; btn.innerHTML = 'Salvar'; }
    }
  }

  async function reservar() {
    const btn = document.getElementById('btnReservarAgendamento');
    if (btn && btn.disabled) return;
    if (btn) { btn.disabled = true; btn.innerHTML = '<span class="spinner-border spinner-border-sm me-1"></span> Reservando...'; }
    try {
    const whenStr = document.getElementById('res_scheduled_start').value;
    const when = whenStr ? new Date(whenStr) : null;
    const minLead = new Date(Date.now() + 24 * 60 * 60 * 1000);
    if (!when || Number.isNaN(when.getTime())) {
      safeToast('Informe uma data/hora válida.', 'danger');
      return;
    }
    if (when < minLead) {
      safeToast('Agendamento deve ser feito com no mínimo 1 dia de antecedência.', 'danger');
      return;
    }
    if (when.getDay() === 0) {
      safeToast('Não é possível agendar em domingo.', 'danger');
      return;
    }
    var dateOnly = whenStr.slice(0, 10);
    var holidayDates = [];
    if (holidayDates.indexOf(dateOnly) >= 0) {
      safeToast('Não é possível agendar em feriado cadastrado.', 'danger');
      return;
    }
    const body = {
      service_id: document.getElementById('res_service_id').value,
      professional_id: document.getElementById('res_professional_id').value,
      modality: document.getElementById('res_modality').value,
      payment_method: document.getElementById('res_payment_method').value,
      booking_channel: 'ADMIN',
      customer_name: document.getElementById('res_customer_name').value,
      customer_email: document.getElementById('res_customer_email').value,
      customer_phone: onlyDigits(document.getElementById('res_customer_phone').value),
      scheduled_start: whenStr,
      zip_code: document.getElementById('res_zip_code').value,
      street: document.getElementById('res_street').value,
      number: document.getElementById('res_number').value,
      complement: document.getElementById('res_complement').value,
      district: document.getElementById('res_district').value,
      city: document.getElementById('res_city').value,
      state: document.getElementById('res_state').value
    };
    if (body.modality === 'HOME') {
      const required = [body.zip_code, body.street, body.number, body.district, body.city, body.state];
      if (required.some(function(v){ return !String(v || '').trim(); })) {
        safeToast('Preencha endereço completo para atendimento em domicílio.', 'danger');
        return;
      }
    }
    const resp = await fetch('/admin/agendamentos-servicos/reservar', { method: 'POST', headers: { 'Content-Type': 'application/json' }, body: JSON.stringify(body) });
    const txt = await resp.text();
    let data = {};
    try { data = txt ? JSON.parse(txt) : {}; } catch (e) { data = {}; }
    if (!resp.ok && !data.message) data.message = 'Falha ao reservar (HTTP ' + resp.status + ').';
    if (data.ok) {
      if (data.payment_link) safeToast('Reserva criada. Link de pagamento: ' + data.payment_link, 'success');
      else safeToast(data.message || 'Agendamento confirmado.', 'success');
      setTimeout(function(){ location.reload(); }, 1000);
    } else {
      safeToast(data.message || 'Erro ao reservar.', 'danger');
    }
    } catch (err) {
      safeToast('Erro de comunicação ao reservar: ' + (err && err.message ? err.message : 'falha desconhecida'), 'danger');
    } finally {
      if (btn) { btn.disabled = false; btn.innerHTML = 'Reservar e gerar pagamento'; }
    }
  }

  async function salvarFeriado() {
    await postAct('/admin/agendamentos-servicos/feriados', {
      holiday_date: document.getElementById('hol_date').value,
      name: document.getElementById('hol_name').value
    });
  }

  async function removerFeriado(id) {
    const ok = (typeof window.neofarmaConfirm === 'function')
      ? await window.neofarmaConfirm({ title: 'Remover feriado', message: 'Deseja remover este feriado?' })
      : true;
    if (!ok) return;
    const resp = await fetch('/admin/agendamentos-servicos/feriados/' + id, { method: 'DELETE' });
    const data = await resp.json();
    if (data.ok) { safeToast(data.message || 'Feriado removido.', 'success'); setTimeout(function(){ location.reload(); }, 600); }
    else safeToast(data.message || 'Erro ao remover feriado.', 'danger');
  }
</script>
    </main>
  </div>
  <script src="/assets/vendor/bootstrap/js/bootstrap.bundle.min.js">