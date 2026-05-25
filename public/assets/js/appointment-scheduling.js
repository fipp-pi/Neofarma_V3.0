/**
 * Seletor de data/horário para agendamentos (admin e conta do cliente).
 */
(function (global) {
  'use strict';

  function pad(n) {
    return String(n).padStart(2, '0');
  }

  function toLocalDateString(date) {
    if (window.NeoDates && NeoDates.toDateInput) return NeoDates.toDateInput(date);
    var d = date instanceof Date ? date : new Date(date);
    if (Number.isNaN(d.getTime())) return '';
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate());
  }

  function addDays(dateStr, days) {
    var parts = String(dateStr || '').split('-').map(Number);
    if (parts.length < 3) return dateStr;
    var d = new Date(parts[0], parts[1] - 1, parts[2], 12, 0, 0, 0);
    d.setDate(d.getDate() + days);
    return toLocalDateString(d);
  }

  function AppointmentSlotPicker(options) {
    this.prefix = options.prefix || 'bk';
    this.slotsUrl = options.slotsUrl;
    this.daysUrl = options.daysUrl || null;
    this.servicesCatalog = options.servicesCatalog || [];
    this.minDate = options.minDate || '';
    this.maxDate = options.maxDate || '';
    this.holidayDates = options.holidayDates || [];
    this.onToast = options.onToast || function () {};
    this.ignoreAppointmentId = options.ignoreAppointmentId || null;

    this._selectedSlot = '';
    this._availableDays = new Set();
    this._init();
  }

  AppointmentSlotPicker.prototype._el = function (id) {
    return document.getElementById(this.prefix + '_' + id);
  };

  AppointmentSlotPicker.prototype._init = function () {
    var self = this;
    var dateEl = this._el('scheduled_date');
    if (dateEl) {
      if (this.minDate) dateEl.min = this.minDate;
      if (this.maxDate) dateEl.max = this.maxDate;
      dateEl.addEventListener('change', function () { self.refreshSlots(); });
    }
    ['service_id', 'professional_id', 'modality'].forEach(function (field) {
      var el = self._el(field);
      if (el) el.addEventListener('change', function () {
        self.filterServicesByModality();
        self.refreshAvailableDays();
        self.refreshSlots();
      });
    });
    this.filterServicesByModality();
    this.refreshAvailableDays();
  };

  AppointmentSlotPicker.prototype.filterServicesByModality = function () {
    var modalityEl = this._el('modality');
    var serviceEl = this._el('service_id');
    if (!modalityEl || !serviceEl || !this.servicesCatalog.length) return;
    var mod = String(modalityEl.value || 'IN_STORE').toUpperCase();
    var current = serviceEl.value;
    var html = '';
    var count = 0;
    this.servicesCatalog.forEach(function (s) {
      var ok = mod === 'HOME' ? s.home_available : s.in_store_available;
      if (!ok) return;
      var price = Number(s.price || 0).toFixed(2).replace('.', ',');
      var selected = String(s.id) === String(current) ? ' selected' : '';
      html += '<option value="' + s.id + '"' + selected + '>' + s.name + ' - R$ ' + price + '</option>';
      count += 1;
    });
    if (!count) {
      html = '<option value="">Nenhum serviço para esta modalidade</option>';
    }
    serviceEl.innerHTML = html;
  };

  AppointmentSlotPicker.prototype.getParams = function () {
    var serviceEl = this._el('service_id');
    var proEl = this._el('professional_id');
    var dateEl = this._el('scheduled_date');
    return {
      service_id: serviceEl ? serviceEl.value : '',
      professional_id: proEl ? proEl.value : '',
      date: dateEl ? dateEl.value : '',
    };
  };

  AppointmentSlotPicker.prototype.setScheduledStart = function (iso) {
    this._selectedSlot = iso || '';
    var hidden = this._el('scheduled_start');
    if (hidden) hidden.value = this._selectedSlot;
  };

  AppointmentSlotPicker.prototype._clearSlotValidationError = function () {
    var err = document.getElementById(this.prefix + '_scheduled_start_error');
    if (err) err.style.display = 'none';
  };

  AppointmentSlotPicker.prototype._onSlotSelected = function (label) {
    this._clearSlotValidationError();
    var hint = this._el('slot_hint');
    if (!hint) return;
    if (label) {
      hint.textContent = 'Horário selecionado: ' + label;
      hint.className = 'small text-success mt-1';
    }
  };

  AppointmentSlotPicker.prototype.renderSlots = function (slots, message) {
    var host = this._el('slot_buttons');
    var hint = this._el('slot_hint');
    if (!host) return;
    host.innerHTML = '';
    this.setScheduledStart('');
    this._clearSlotValidationError();

    if (!slots || !slots.length) {
      if (hint) {
        hint.textContent = message || 'Nenhum horário livre nesta data. Escolha outro dia ou profissional.';
        hint.className = 'small text-muted mt-1';
      }
      return;
    }
    if (hint) {
      hint.textContent = 'Clique em um horário abaixo.';
      hint.className = 'small text-muted mt-1';
    }

    var self = this;
    slots.forEach(function (slot) {
      var btn = document.createElement('button');
      btn.type = 'button';
      btn.className = 'btn btn-sm btn-outline-primary';
      btn.textContent = slot.label;
      btn.dataset.value = slot.value;
      btn.addEventListener('click', function () {
        Array.prototype.forEach.call(host.querySelectorAll('button'), function (b) {
          b.classList.remove('active');
        });
        btn.classList.add('active');
        self.setScheduledStart(slot.value);
        self._onSlotSelected(slot.label);
      });
      host.appendChild(btn);
    });
  };

  AppointmentSlotPicker.prototype.refreshAvailableDays = function () {
    var self = this;
    if (!this.daysUrl) return Promise.resolve();
    var p = this.getParams();
    if (!p.service_id || !p.professional_id) {
      this._availableDays = new Set();
      return Promise.resolve();
    }
    var from = this.minDate || toLocalDateString(new Date());
    var to = this.maxDate || addDays(from, 60);
    var qs = new URLSearchParams({
      service_id: p.service_id,
      professional_id: p.professional_id,
      from: from,
      to: to,
    });
    if (this.ignoreAppointmentId) qs.set('ignore_appointment_id', String(this.ignoreAppointmentId));

    return fetch(this.daysUrl + '?' + qs.toString(), { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        self._availableDays = new Set((data && data.days) ? data.days : []);
        var dateEl = self._el('scheduled_date');
        if (dateEl && dateEl.value && !self._availableDays.has(dateEl.value)) {
          dateEl.value = '';
          self.setScheduledStart('');
        }
      })
      .catch(function () { self._availableDays = new Set(); });
  };

  AppointmentSlotPicker.prototype.refreshSlots = function () {
    var self = this;
    var p = this.getParams();
    var host = this._el('slot_buttons');
    if (host) host.innerHTML = '<span class="small text-muted">Carregando horários...</span>';
    this.setScheduledStart('');

    if (!p.service_id || !p.professional_id || !p.date) {
      this.renderSlots([], 'Selecione serviço, profissional e data.');
      return Promise.resolve();
    }
    if (this.holidayDates.indexOf(p.date) >= 0) {
      this.renderSlots([], 'Feriado — sem agendamentos nesta data.');
      return Promise.resolve();
    }
    var day = new Date(p.date + 'T12:00:00');
    if (day.getDay() === 0) {
      this.renderSlots([], 'Domingo indisponível.');
      return Promise.resolve();
    }
    if (this._availableDays.size && !this._availableDays.has(p.date)) {
      this.renderSlots([], 'Sem horários livres nesta data.');
      return Promise.resolve();
    }

    var qs = new URLSearchParams({
      service_id: p.service_id,
      professional_id: p.professional_id,
      date: p.date,
    });
    if (this.ignoreAppointmentId) qs.set('ignore_appointment_id', String(this.ignoreAppointmentId));

    return fetch(this.slotsUrl + '?' + qs.toString(), { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (data) {
        if (!data || !data.ok) {
          self.renderSlots([], (data && data.message) || 'Não foi possível carregar horários.');
          return;
        }
        self.renderSlots(data.slots || [], data.message);
        var preset = self._el('scheduled_start');
        if (preset && preset.value) {
          var match = (data.slots || []).find(function (s) { return s.value === preset.value; });
          if (match) {
            self.setScheduledStart(match.value);
            self._onSlotSelected(match.label);
            Array.prototype.forEach.call(host.querySelectorAll('button'), function (b) {
              if (b.dataset.value === match.value) b.classList.add('active');
            });
          }
        }
      })
      .catch(function () {
        self.renderSlots([], 'Erro ao carregar horários. Tente novamente.');
      });
  };

  AppointmentSlotPicker.prototype.selectSlotByIso = function (iso) {
    if (!iso) return;
    var d = new Date(iso);
    if (Number.isNaN(d.getTime())) return;
    var dateStr = toLocalDateString(d);
    var dateEl = this._el('scheduled_date');
    if (dateEl) dateEl.value = dateStr;
    var localVal = (window.NeoDates && NeoDates.toDatetimeLocal) ? NeoDates.toDatetimeLocal(iso) : iso.slice(0, 16);
    this.setScheduledStart(localVal);
    var self = this;
    this.refreshSlots().then(function () {
      var host = self._el('slot_buttons');
      if (!host) return;
      var val = localVal;
      Array.prototype.forEach.call(host.querySelectorAll('button'), function (b) {
        if (b.dataset.value === val) b.classList.add('active');
      });
    });
  };

  AppointmentSlotPicker.prototype.validateBeforeSubmit = function () {
    if (!this._selectedSlot && this._el('scheduled_start')) {
      this._selectedSlot = this._el('scheduled_start').value || '';
    }
    if (!this._selectedSlot) {
      this.onToast('Selecione um horário disponível.', 'danger');
      return false;
    }
    return true;
  };

  global.NeofarmaAppointmentSlots = {
    AppointmentSlotPicker: AppointmentSlotPicker,
    toLocalDateString: toLocalDateString,
  };
})(typeof window !== 'undefined' ? window : global);
