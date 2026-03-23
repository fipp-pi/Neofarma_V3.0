
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
    var holidayDates = [<% (holidays || []).forEach(function(h, idx){ %><%= idx ? ',' : '' %>'<%= String(h.holiday_date).slice(0, 10) %>'<% }) %>];
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
