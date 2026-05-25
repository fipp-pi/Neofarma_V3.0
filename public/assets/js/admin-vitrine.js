(function () {
  'use strict';

  var FLASH_KEY = 'vitrineAdminFlash';

  function parseBoot(id) {
    var el = document.getElementById(id);
    if (!el) return null;
    try { return JSON.parse(el.textContent || '{}'); } catch (_) { return null; }
  }

  var homeConfig = parseBoot('bootHomeConfig') || {};
  var themeConfig = parseBoot('bootThemeConfig') || {};
  var promoOptions = parseBoot('bootPromotions') || [];
  var sectionColorSchema = parseBoot('bootSectionColorSchema') || {};

  var selectedProducts = [];
  var modalPromo = null;

  function showFlash(message, type) {
    var el = document.getElementById('pageFlash');
    if (!el) return;
    el.className = 'alert alert-' + (type === 'danger' ? 'danger' : 'success');
    el.textContent = message;
    el.classList.remove('d-none');
  }

  function storeFlash(message, type) {
    try {
      sessionStorage.setItem(FLASH_KEY, JSON.stringify({ message: message, type: type || 'success' }));
    } catch (_) { /* ignore */ }
  }

  (function initFlash() {
    try {
      var raw = sessionStorage.getItem(FLASH_KEY);
      if (!raw) return;
      sessionStorage.removeItem(FLASH_KEY);
      var data = JSON.parse(raw);
      if (data && data.message) showFlash(data.message, data.type);
    } catch (_) { /* ignore */ }
  })();

  function fmtMoney(v) {
    var n = Number(v);
    if (!Number.isFinite(n)) return '—';
    return 'R$ ' + n.toFixed(2).replace('.', ',');
  }

  function toDatetimeLocal(val) {
    if (!val) return '';
    var s = String(val).trim().replace(' ', 'T');
    return s.length >= 16 ? s.slice(0, 16) : s;
  }

  function localDatetimeInput(d) {
    var pad = function (n) { return String(n).padStart(2, '0'); };
    return d.getFullYear() + '-' + pad(d.getMonth() + 1) + '-' + pad(d.getDate()) +
      'T' + pad(d.getHours()) + ':' + pad(d.getMinutes());
  }

  function fromDatetimeLocal(val) {
    if (!val) return '';
    return String(val).trim().replace('T', ' ');
  }

  function postJson(url, body, method) {
    return fetch(url, {
      method: method || 'POST',
      headers: { 'Content-Type': 'application/json', Accept: 'application/json' },
      body: body != null ? JSON.stringify(body) : undefined,
    }).then(function (r) {
      return r.json().then(function (d) {
        return { ok: r.ok, status: r.status, data: d };
      });
    });
  }

  /* ── Tema global (catálogo + fontes) ── */
  var THEME_FIELDS = [
    { key: 'accentColor', label: 'Destaque (página catálogo)', type: 'color' },
    { key: 'headingColor', label: 'Títulos (página catálogo)', type: 'color' },
    { key: 'defaultColor', label: 'Cor principal (catálogo)', type: 'color' },
    { key: 'surfaceColor', label: 'Fundo dos cards (catálogo)', type: 'color' },
    { key: 'mutedBg', label: 'Fundo suave (catálogo)', type: 'color' },
    { key: 'badgeSaleColor', label: 'Badge oferta (catálogo)', type: 'color' },
    { key: 'badgeHotColor', label: 'Badge destaque (catálogo)', type: 'color' },
    { key: 'titleFont', label: 'Fonte dos títulos', type: 'font' },
    { key: 'bodyFont', label: 'Fonte do corpo', type: 'font' },
    { key: 'buttonText', label: 'Texto padrão do botão', type: 'text' },
    { key: 'badgeText', label: 'Texto padrão do badge', type: 'text' },
  ];

  function buildThemeForm() {
    var wrap = document.getElementById('themeFields');
    if (!wrap) return;
    wrap.innerHTML = THEME_FIELDS.map(function (f) {
      var val = themeConfig[f.key] != null ? themeConfig[f.key] : '';
      var input = '';
      if (f.type === 'color') {
        input = '<input type="color" class="form-control form-control-color w-100" data-theme-key="' + f.key + '" value="' + val + '">';
      } else if (f.type === 'font') {
        input = '<select class="form-select" data-theme-key="' + f.key + '">' +
          ['Montserrat', 'Roboto', 'Poppins'].map(function (font) {
            return '<option value="' + font + '"' + (val === font ? ' selected' : '') + '>' + font + '</option>';
          }).join('') + '</select>';
      } else {
        input = '<input type="text" class="form-control" data-theme-key="' + f.key + '" value="' + String(val).replace(/"/g, '&quot;') + '">';
      }
      return '<div class="col-md-4"><label class="form-label">' + f.label + '</label>' + input + '</div>';
    }).join('');
  }

  function readThemeForm() {
    var out = {};
    document.querySelectorAll('[data-theme-key]').forEach(function (el) {
      out[el.getAttribute('data-theme-key')] = el.value;
    });
    return out;
  }

  /* ── Home sections ── */
  var SECTION_META = {
    hero: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'titleHighlight', label: 'Destaque do título', type: 'text' },
      { key: 'description', label: 'Descrição', type: 'textarea' },
      { key: 'searchPlaceholder', label: 'Placeholder da busca', type: 'text' },
      { key: 'searchButton', label: 'Texto do botão buscar', type: 'text' },
      { key: 'badgeText', label: 'Texto do badge', type: 'text' },
      { key: 'promotionId', label: 'Campanha vinculada (opcional)', type: 'promotion' },
    ],
    benefits: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'items', label: 'Itens de benefício', type: 'benefits' },
    ],
    promoCarousel: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'subtitle', label: 'Subtítulo', type: 'textarea' },
      { key: 'linkText', label: 'Texto do link', type: 'text' },
      { key: 'linkUrl', label: 'URL do link', type: 'text' },
      { key: 'limit', label: 'Quantidade de produtos', type: 'number' },
      { key: 'promotionId', label: 'Filtrar por campanha (opcional)', type: 'promotion' },
      { key: 'badgeText', label: 'Texto do badge', type: 'text' },
      { key: 'buttonText', label: 'Texto do botão', type: 'text' },
    ],
    categories: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'subtitle', label: 'Subtítulo', type: 'text' },
      { key: 'linkText', label: 'Texto do link', type: 'text' },
      { key: 'limit', label: 'Quantidade', type: 'number' },
    ],
    bestsellers: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'subtitle', label: 'Subtítulo', type: 'textarea' },
      { key: 'linkText', label: 'Texto do link', type: 'text' },
      { key: 'linkUrl', label: 'URL do link', type: 'text' },
      { key: 'limit', label: 'Quantidade', type: 'number' },
      { key: 'days', label: 'Período (dias)', type: 'number' },
    ],
    flashOffer: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'label', label: 'Etiqueta superior', type: 'text' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'titleWithDiscount', label: 'Título com desconto ({discount})', type: 'text' },
      { key: 'description', label: 'Descrição', type: 'textarea' },
      { key: 'buttonText', label: 'Texto do botão', type: 'text' },
      { key: 'buttonUrl', label: 'URL do botão', type: 'text' },
      { key: 'limit', label: 'Quantidade de produtos', type: 'number' },
      { key: 'promotionId', label: 'Campanha do cronômetro', type: 'promotion' },
      { key: 'usePromotionEnd', label: 'Usar término da campanha no cronômetro', type: 'checkbox' },
    ],
    newArrivals: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'subtitle', label: 'Subtítulo', type: 'text' },
      { key: 'limit', label: 'Quantidade', type: 'number' },
    ],
    servicesCta: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'description', label: 'Descrição', type: 'textarea' },
      { key: 'primaryButton', label: 'Botão principal', type: 'text' },
      { key: 'primaryUrl', label: 'URL botão principal', type: 'text' },
      { key: 'secondaryButton', label: 'Botão secundário', type: 'text' },
      { key: 'secondaryUrl', label: 'URL botão secundário', type: 'text' },
    ],
    labHighlights: [
      { key: 'enabled', label: 'Exibir seção', type: 'checkbox' },
      { key: 'title', label: 'Título', type: 'text' },
      { key: 'subtitle', label: 'Subtítulo', type: 'textarea' },
      { key: 'linkText', label: 'Texto do link geral', type: 'text' },
      { key: 'linkUrl', label: 'URL do link geral', type: 'text' },
      { key: 'buttonText', label: 'Texto do botão no card', type: 'text' },
      { key: 'limit', label: 'Quantidade de marcas', type: 'number' },
    ],
  };

  function promoSelectHtml(key, val) {
    var opts = '<option value="">Automático / todas</option>';
    promoOptions.forEach(function (p) {
      opts += '<option value="' + p.id + '"' + (String(val) === String(p.id) ? ' selected' : '') + '>' + p.name + '</option>';
    });
    return '<select class="form-select" data-home-key="' + key + '">' + opts + '</select>';
  }

  function sectionColorsHtml(section, data) {
    var schema = sectionColorSchema[section] || [];
    if (!schema.length) return '';
    var colors = (data && data.colors) || {};
    return '<div class="col-12 mt-1"><hr class="my-3">' +
      '<h6 class="mb-3"><i class="bi bi-palette me-1"></i> Cores desta seção</h6>' +
      '<div class="row g-3">' +
      schema.map(function (f) {
        var val = colors[f.key] != null ? colors[f.key] : '#2E5C5C';
        if (String(val).indexOf('rgba') === 0) val = '#2E5C5C';
        return '<div class="col-6 col-md-4 col-lg-3">' +
          '<label class="form-label small mb-1">' + f.label + '</label>' +
          '<input type="color" class="form-control form-control-color w-100" data-home-color="' + f.key + '" value="' + val + '">' +
          '</div>';
      }).join('') +
      '</div></div>';
  }

  function fieldHtml(section, field, data) {
    var val = data[field.key];
    var id = 'home_' + section + '_' + field.key;
    if (field.type === 'checkbox') {
      var checked = val !== false && val !== '0' && val !== 0;
      return '<div class="col-12"><div class="form-check">' +
        '<input class="form-check-input" type="checkbox" id="' + id + '" data-home-key="' + field.key + '"' + (checked ? ' checked' : '') + '>' +
        '<label class="form-check-label" for="' + id + '">' + field.label + '</label></div></div>';
    }
    if (field.type === 'textarea') {
      return '<div class="col-12"><label class="form-label" for="' + id + '">' + field.label + '</label>' +
        '<textarea class="form-control" id="' + id + '" rows="2" data-home-key="' + field.key + '">' + (val != null ? val : '') + '</textarea></div>';
    }
    if (field.type === 'number') {
      return '<div class="col-md-4"><label class="form-label" for="' + id + '">' + field.label + '</label>' +
        '<input type="number" class="form-control" id="' + id + '" data-home-key="' + field.key + '" value="' + (val != null ? val : '') + '" min="1"></div>';
    }
    if (field.type === 'promotion') {
      return '<div class="col-md-6"><label class="form-label">' + field.label + '</label>' + promoSelectHtml(field.key, val) + '</div>';
    }
    if (field.type === 'benefits') {
      var items = Array.isArray(val) ? val : [];
      var rows = items.map(function (item, idx) {
        return '<div class="border rounded p-2 mb-2" data-benefit-row="' + idx + '">' +
          '<div class="row g-2">' +
          '<div class="col-md-2"><input class="form-control form-control-sm" placeholder="Ícone (bi-*)" data-benefit="icon" value="' + (item.icon || '') + '"></div>' +
          '<div class="col-md-4"><input class="form-control form-control-sm" placeholder="Título" data-benefit="title" value="' + (item.title || '') + '"></div>' +
          '<div class="col-md-5"><input class="form-control form-control-sm" placeholder="Texto" data-benefit="text" value="' + (item.text || '') + '"></div>' +
          '<div class="col-md-1"><button type="button" class="btn btn-sm btn-outline-danger w-100 btn-remove-benefit">&times;</button></div>' +
          '</div></div>';
      }).join('');
      return '<div class="col-12" data-home-benefits="1"><label class="form-label">' + field.label + '</label>' +
        '<div id="benefitsList">' + rows + '</div>' +
        '<button type="button" class="btn btn-sm btn-outline-primary mt-1" id="btnAddBenefit">+ Adicionar item</button></div>';
    }
    return '<div class="col-md-6"><label class="form-label" for="' + id + '">' + field.label + '</label>' +
      '<input type="text" class="form-control" id="' + id + '" data-home-key="' + field.key + '" value="' + (val != null ? String(val).replace(/"/g, '&quot;') : '') + '"></div>';
  }

  function buildHomeForms() {
    Object.keys(SECTION_META).forEach(function (section) {
      var body = document.querySelector('[data-home-section="' + section + '"]');
      if (!body) return;
      var data = homeConfig[section] || {};
      var fields = SECTION_META[section];
      body.innerHTML = '<div class="row g-3">' + fields.map(function (f) {
        return fieldHtml(section, f, data);
      }).join('') + sectionColorsHtml(section, data) + '</div>';
    });
  }

  function readHomeSection(section) {
    var body = document.querySelector('[data-home-section="' + section + '"]');
    if (!body) return {};
    var out = {};
    body.querySelectorAll('[data-home-key]').forEach(function (el) {
      var key = el.getAttribute('data-home-key');
      if (el.type === 'checkbox') out[key] = el.checked;
      else if (el.type === 'number') out[key] = el.value === '' ? null : Number(el.value);
      else if (el.tagName === 'SELECT' && key === 'promotionId') {
        out[key] = el.value ? parseInt(el.value, 10) : null;
      } else out[key] = el.value;
    });
    var benefitsWrap = body.querySelector('[data-home-benefits]');
    if (benefitsWrap) {
      out.items = [];
      benefitsWrap.querySelectorAll('[data-benefit-row]').forEach(function (row) {
        var item = {};
        row.querySelectorAll('[data-benefit]').forEach(function (inp) {
          item[inp.getAttribute('data-benefit')] = inp.value;
        });
        if (item.title || item.text) out.items.push(item);
      });
    }
    out.colors = {};
    body.querySelectorAll('[data-home-color]').forEach(function (el) {
      out.colors[el.getAttribute('data-home-color')] = el.value;
    });
    return out;
  }

  function readHomeForm() {
    var home = {};
    Object.keys(SECTION_META).forEach(function (section) {
      home[section] = readHomeSection(section);
    });
    return home;
  }

  /* ── Promoções ── */
  function resetPromoForm() {
    document.getElementById('promo_id').value = '';
    document.getElementById('promo_name').value = '';
    document.getElementById('promo_description').value = '';
    document.getElementById('promo_discount_type').value = 'PERCENT';
    document.getElementById('promo_discount_value').value = '';
    document.getElementById('promo_priority').value = '0';
    document.getElementById('promo_is_active').checked = true;
    var now = new Date();
    var later = new Date(now.getTime() + 7 * 24 * 60 * 60 * 1000);
    document.getElementById('promo_starts_at').value = localDatetimeInput(now);
    document.getElementById('promo_ends_at').value = localDatetimeInput(later);
    var defaults = {
      badgeColor: '#5B8851', badgeTextColor: '#ffffff', cardBg: '#ffffff',
      gradientStart: '#2E5C5C', gradientEnd: '#5B8851', titleFont: 'Montserrat',
      headlineText: 'Oferta especial', buttonText: 'Comprar agora', discountLabel: 'OFF',
    };
    Object.keys(defaults).forEach(function (k) {
      var el = document.getElementById('style_' + k);
      if (el) el.value = defaults[k];
    });
    selectedProducts = [];
    renderSelectedProducts();
    document.getElementById('productSearchResults').innerHTML = '';
    hidePromoError();
    document.getElementById('modalPromocaoTitle').textContent = 'Nova promoção';
  }

  function hidePromoError() {
    var el = document.getElementById('promoFormError');
    if (el) { el.classList.add('d-none'); el.textContent = ''; }
  }

  function showPromoError(msg) {
    var el = document.getElementById('promoFormError');
    if (!el) return;
    el.textContent = msg;
    el.classList.remove('d-none');
  }

  function renderSelectedProducts() {
    var wrap = document.getElementById('selectedProducts');
    if (!wrap) return;
    if (!selectedProducts.length) {
      wrap.innerHTML = '<p class="text-muted small mb-0">Nenhum produto selecionado.</p>';
      return;
    }
    wrap.innerHTML = selectedProducts.map(function (p, idx) {
      return '<div class="d-flex align-items-center gap-2 border rounded p-2" data-sel-idx="' + idx + '">' +
        '<div class="flex-grow-1"><strong>' + p.name + '</strong>' +
        '<div class="small text-muted">SKU: ' + (p.sku || '—') + ' · ' + fmtMoney(p.unit_price) + '</div></div>' +
        '<button type="button" class="btn btn-sm btn-outline-danger btn-remove-product" data-idx="' + idx + '">Remover</button></div>';
    }).join('');
  }

  function addProduct(p) {
    if (selectedProducts.some(function (x) { return x.id === p.id; })) return;
    selectedProducts.push({
      id: p.id,
      name: p.name,
      sku: p.sku,
      unit_price: p.unit_price,
    });
    renderSelectedProducts();
  }

  function searchProducts() {
    var q = document.getElementById('productSearch').value.trim();
    var wrap = document.getElementById('productSearchResults');
    wrap.innerHTML = '<span class="text-muted small">Buscando...</span>';
    fetch('/admin/vitrine/api/produtos?q=' + encodeURIComponent(q), { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        var list = (d && d.products) || [];
        if (!list.length) {
          wrap.innerHTML = '<span class="text-muted small">Nenhum produto encontrado.</span>';
          return;
        }
        wrap.innerHTML = list.map(function (p) {
          return '<button type="button" class="btn btn-sm btn-light w-100 text-start mb-1 btn-add-product" data-product=\'' +
            JSON.stringify({ id: p.id, name: p.name, sku: p.sku, unit_price: p.unit_price }).replace(/'/g, '&#39;') + '\'>' +
            '<strong>' + p.name + '</strong> <span class="text-muted">· ' + fmtMoney(p.unit_price) + '</span></button>';
        }).join('');
      })
      .catch(function () {
        wrap.innerHTML = '<span class="text-danger small">Erro ao buscar produtos.</span>';
      });
  }

  function openPromoModal(id) {
    resetPromoForm();
    if (!id) {
      modalPromo.show();
      return;
    }
    document.getElementById('modalPromocaoTitle').textContent = 'Editar promoção';
    fetch('/admin/vitrine/promocoes/' + id, { headers: { Accept: 'application/json' } })
      .then(function (r) { return r.json(); })
      .then(function (d) {
        if (!d || !d.ok || !d.promotion) {
          showFlash('Não foi possível carregar a promoção.', 'danger');
          return;
        }
        var p = d.promotion;
        document.getElementById('promo_id').value = p.id;
        document.getElementById('promo_name').value = p.name || '';
        document.getElementById('promo_description').value = p.description || '';
        document.getElementById('promo_discount_type').value = p.discount_type || 'PERCENT';
        document.getElementById('promo_discount_value').value = p.discount_value != null ? String(p.discount_value).replace('.', ',') : '';
        document.getElementById('promo_priority').value = p.priority || 0;
        document.getElementById('promo_is_active').checked = !!p.is_active;
        document.getElementById('promo_starts_at').value = toDatetimeLocal(p.starts_at);
        document.getElementById('promo_ends_at').value = toDatetimeLocal(p.ends_at);
        var style = p.style || {};
        Object.keys(style).forEach(function (k) {
          var el = document.getElementById('style_' + k);
          if (el) el.value = style[k];
        });
        selectedProducts = (d.products || []).map(function (row) {
          return {
            id: row.product_id || row.id,
            name: row.name || row.product_name || ('Produto #' + row.product_id),
            sku: row.sku,
            unit_price: row.unit_price,
          };
        });
        renderSelectedProducts();
        modalPromo.show();
      })
      .catch(function () {
        showFlash('Erro ao carregar promoção.', 'danger');
      });
  }

  function savePromo() {
    hidePromoError();
    var style = {};
    ['badgeColor', 'badgeTextColor', 'cardBg', 'gradientStart', 'gradientEnd', 'titleFont', 'headlineText', 'buttonText', 'discountLabel'].forEach(function (k) {
      var el = document.getElementById('style_' + k);
      if (el) style[k] = el.value;
    });
    var body = {
      id: document.getElementById('promo_id').value || undefined,
      name: document.getElementById('promo_name').value.trim(),
      description: document.getElementById('promo_description').value.trim(),
      discount_type: document.getElementById('promo_discount_type').value,
      discount_value: document.getElementById('promo_discount_value').value.trim(),
      starts_at: fromDatetimeLocal(document.getElementById('promo_starts_at').value),
      ends_at: fromDatetimeLocal(document.getElementById('promo_ends_at').value),
      is_active: document.getElementById('promo_is_active').checked,
      priority: document.getElementById('promo_priority').value,
      style: style,
      products: selectedProducts.map(function (p) { return { product_id: p.id }; }),
    };
    postJson('/admin/vitrine/promocoes', body).then(function (res) {
      if (!res.ok || !res.data.ok) {
        var msg = (res.data && res.data.message) || 'Erro ao salvar promoção.';
        if (res.data && res.data.fields && res.data.fields.products) msg = res.data.fields.products;
        showPromoError(msg);
        return;
      }
      storeFlash(res.data.message || 'Promoção salva.', 'success');
      modalPromo.hide();
      window.location.reload();
    }).catch(function () {
      showPromoError('Erro de comunicação com o servidor.');
    });
  }

  function deletePromo(id, name) {
    if (!window.confirm('Excluir a promoção "' + name + '"? Os preços dos produtos serão recalculados.')) return;
    postJson('/admin/vitrine/promocoes/' + id, null, 'DELETE').then(function (res) {
      if (!res.ok || !res.data.ok) {
        showFlash((res.data && res.data.message) || 'Erro ao excluir.', 'danger');
        return;
      }
      storeFlash(res.data.message || 'Promoção removida.', 'success');
      window.location.reload();
    });
  }

  function syncPrices() {
    postJson('/admin/vitrine/sync', {}).then(function (res) {
      if (!res.ok || !res.data.ok) {
        showFlash((res.data && res.data.message) || 'Erro ao sincronizar.', 'danger');
        return;
      }
      showFlash(res.data.message || 'Preços sincronizados.', 'success');
    });
  }

  /* ── Bind events ── */
  document.addEventListener('DOMContentLoaded', function () {
    var modalEl = document.getElementById('modalPromocao');
    if (modalEl && window.bootstrap) modalPromo = new bootstrap.Modal(modalEl);

    buildThemeForm();
    buildHomeForms();

    var btnNova = document.getElementById('btnNovaPromocao');
    if (btnNova) btnNova.addEventListener('click', function () { openPromoModal(null); });

    document.querySelectorAll('.btn-edit-promo').forEach(function (btn) {
      btn.addEventListener('click', function () { openPromoModal(btn.getAttribute('data-id')); });
    });

    document.querySelectorAll('.btn-del-promo').forEach(function (btn) {
      btn.addEventListener('click', function () {
        deletePromo(btn.getAttribute('data-id'), btn.getAttribute('data-name'));
      });
    });

    var btnSave = document.getElementById('btnSavePromocao');
    if (btnSave) btnSave.addEventListener('click', savePromo);

    var btnSearch = document.getElementById('btnSearchProducts');
    if (btnSearch) btnSearch.addEventListener('click', searchProducts);

    var productSearch = document.getElementById('productSearch');
    if (productSearch) {
      productSearch.addEventListener('keydown', function (e) {
        if (e.key === 'Enter') { e.preventDefault(); searchProducts(); }
      });
    }

    document.addEventListener('click', function (e) {
      var addBtn = e.target.closest('.btn-add-product');
      if (addBtn) {
        try { addProduct(JSON.parse(addBtn.getAttribute('data-product'))); } catch (_) { /* ignore */ }
      }
      var remBtn = e.target.closest('.btn-remove-product');
      if (remBtn) {
        var idx = parseInt(remBtn.getAttribute('data-idx'), 10);
        selectedProducts.splice(idx, 1);
        renderSelectedProducts();
      }
      var remBenefit = e.target.closest('.btn-remove-benefit');
      if (remBenefit) remBenefit.closest('[data-benefit-row]').remove();
    });

    document.addEventListener('click', function (e) {
      if (!e.target.closest('#btnAddBenefit')) return;
      var list = document.getElementById('benefitsList');
      if (!list) return;
      var idx = list.querySelectorAll('[data-benefit-row]').length;
      var div = document.createElement('div');
      div.className = 'border rounded p-2 mb-2';
      div.setAttribute('data-benefit-row', idx);
      div.innerHTML = '<div class="row g-2">' +
        '<div class="col-md-2"><input class="form-control form-control-sm" placeholder="Ícone (bi-*)" data-benefit="icon" value="bi-star"></div>' +
        '<div class="col-md-4"><input class="form-control form-control-sm" placeholder="Título" data-benefit="title"></div>' +
        '<div class="col-md-5"><input class="form-control form-control-sm" placeholder="Texto" data-benefit="text"></div>' +
        '<div class="col-md-1"><button type="button" class="btn btn-sm btn-outline-danger w-100 btn-remove-benefit">&times;</button></div></div>';
      list.appendChild(div);
    });

    var formHome = document.getElementById('formHomeConfig');
    if (formHome) {
      formHome.addEventListener('submit', function (e) {
        e.preventDefault();
        postJson('/admin/vitrine/home', { home: readHomeForm() }).then(function (res) {
          if (!res.ok || !res.data.ok) {
            showFlash((res.data && res.data.message) || 'Erro ao salvar.', 'danger');
            return;
          }
          homeConfig = res.data.home || readHomeForm();
          showFlash(res.data.message || 'Página inicial salva.', 'success');
        });
      });
    }

    var formTheme = document.getElementById('formThemeConfig');
    if (formTheme) {
      formTheme.addEventListener('submit', function (e) {
        e.preventDefault();
        postJson('/admin/vitrine/theme', { theme: readThemeForm() }).then(function (res) {
          if (!res.ok || !res.data.ok) {
            showFlash((res.data && res.data.message) || 'Erro ao salvar tema.', 'danger');
            return;
          }
          themeConfig = res.data.theme || readThemeForm();
          showFlash(res.data.message || 'Tema salvo.', 'success');
        });
      });
    }

    var btnSync = document.getElementById('btnSyncPrices');
    if (btnSync) btnSync.addEventListener('click', syncPrices);
  });
})();
