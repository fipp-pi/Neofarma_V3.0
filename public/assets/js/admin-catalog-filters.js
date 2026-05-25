(function (global) {
  'use strict';

  function norm(value) {
    return String(value || '').toLowerCase().trim();
  }

  function digits(value) {
    return String(value || '').replace(/\D/g, '');
  }

  function parseNum(value) {
    if (value === '' || value == null) return null;
    var n = parseFloat(String(value).replace(',', '.'));
    return Number.isFinite(n) ? n : null;
  }

  function readValues(ids) {
    var out = {};
    Object.keys(ids || {}).forEach(function (key) {
      var el = document.getElementById(ids[key]);
      if (!el) { out[key] = ''; return; }
      if (el.type === 'checkbox') out[key] = el.checked;
      else out[key] = el.value;
    });
    return out;
  }

  function updateResults(config, visible, total) {
    var el = document.getElementById(config.resultsId);
    if (el) el.textContent = visible + ' de ' + total + ' registro(s)';
    var wrap = document.getElementById(config.emptyFilterId);
    if (wrap) wrap.style.display = total > 0 && visible === 0 ? 'block' : 'none';
    var tableWrap = document.getElementById(config.tableWrapId);
    if (tableWrap) tableWrap.style.display = visible === 0 && total === 0 ? 'none' : '';
  }

  function bindTabs(config) {
    if (!config.tabs) return;
    config.tabs.forEach(function (tab) {
      var el = document.getElementById(tab.id);
      if (!el) return;
      el.addEventListener('click', function (e) {
        if (el.tagName === 'A') e.preventDefault();
        config.tabs.forEach(function (t) {
          var node = document.getElementById(t.id);
          if (node) node.classList.toggle('is-active', t.id === tab.id);
        });
        var hidden = document.getElementById(tab.targetInput);
        if (hidden) hidden.value = tab.value;
        config.apply();
      });
    });
  }

  function init(config) {
    if (!config || !config.tableBodySelector) return;

    config.apply = function applyFilters() {
      var values = readValues(config.inputs);
      var rows = document.querySelectorAll(config.tableBodySelector);
      var visible = 0;
      rows.forEach(function (tr) {
        var ok = typeof config.matchRow === 'function' ? config.matchRow(tr, values) : true;
        tr.style.display = ok ? '' : 'none';
        if (ok) visible += 1;
      });
      updateResults(config, visible, rows.length);
      if (typeof config.onApply === 'function') config.onApply(visible, rows.length, values);
    };

    Object.keys(config.inputs || {}).forEach(function (key) {
      var el = document.getElementById(config.inputs[key]);
      if (!el) return;
      el.addEventListener('input', config.apply);
      el.addEventListener('change', config.apply);
    });

    bindTabs(config);

    var btnClear = document.getElementById(config.clearBtnId);
    if (btnClear) {
      btnClear.addEventListener('click', function () {
        Object.keys(config.inputs || {}).forEach(function (key) {
          var el = document.getElementById(config.inputs[key]);
          if (!el) return;
          if (el.type === 'checkbox') el.checked = false;
          else if (el.tagName === 'SELECT') el.selectedIndex = 0;
          else el.value = '';
        });
        if (config.tabs && config.tabs.length) {
          config.tabs[0].click();
        }
        config.apply();
      });
    }

    var toggle = document.getElementById(config.filtersToggleId);
    var panel = document.getElementById(config.filtersPanelId);
    if (toggle && panel) {
      toggle.addEventListener('click', function () {
        var open = panel.hasAttribute('hidden');
        if (open) panel.removeAttribute('hidden');
        else panel.setAttribute('hidden', '');
        toggle.setAttribute('aria-expanded', open ? 'true' : 'false');
      });
    }

    config.apply();
    return config;
  }

  global.NeoFarmaCatalogFilters = {
    init: init,
    norm: norm,
    digits: digits,
    parseNum: parseNum,
    textMatch: function (tr, q, attr) {
      if (!q) return true;
      var hay = norm(tr.getAttribute(attr || 'data-filter-search'));
      return hay.indexOf(norm(q)) !== -1;
    },
    attrEq: function (tr, attr, value) {
      if (!value || value === 'ALL') return true;
      return String(tr.getAttribute(attr) || '') === String(value);
    },
  };
})(window);
