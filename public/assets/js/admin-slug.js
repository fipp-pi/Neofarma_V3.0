/**
 * Verificação de slug com debounce (admin): validação local + API opcional.
 */
(function (global) {
  'use strict';

  var DEBOUNCE_MS = 450;
  var SLUG_REGEX = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

  function slugify(text) {
    return String(text || '')
      .toLowerCase()
      .trim()
      .replace(/\s+/g, '-')
      .replace(/[^\w\-]+/g, '')
      .replace(/\-\-+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  function normalizeInput(value) {
    return String(value || '')
      .toLowerCase()
      .replace(/\s+/g, '-')
      .replace(/[^a-z0-9\-]/g, '')
      .replace(/\-\-+/g, '-')
      .replace(/^-+|-+$/g, '');
  }

  function parseJsonResponse(response, text) {
    if (!text) return null;
    try {
      return JSON.parse(text);
    } catch (e) {
      var err = new Error('Resposta inválida do servidor ao verificar slug.');
      err.isParseError = true;
      err.status = response.status;
      throw err;
    }
  }

  function attach(options) {
    var slugInput = document.getElementById(options.slugInputId);
    var nameInput = options.nameInputId ? document.getElementById(options.nameInputId) : null;
    var statusEl = options.statusId ? document.getElementById(options.statusId) : null;
    var hintEl = options.hintId ? document.getElementById(options.hintId) : null;
    var errorEl = options.errorId ? document.getElementById(options.errorId) : null;
    var scope = options.scope || 'category';
    var localSlugs = options.localSlugs && typeof options.localSlugs === 'object' ? options.localSlugs : {};
    var getEditId = typeof options.getEditId === 'function' ? options.getEditId : function () { return null; };
    var onStatusChange = typeof options.onStatusChange === 'function' ? options.onStatusChange : null;

    if (!slugInput) return null;

    var state = {
      status: 'idle',
      slug: '',
      reason: '',
      message: '',
      requestId: 0,
      timer: null,
      pendingPromise: null,
      originalSlug: '',
      dirty: false,
      localOk: false,
      apiOk: null,
    };

    function setStatus(next) {
      state.status = next.status;
      state.reason = next.reason || '';
      state.message = next.message || '';
      state.slug = next.slug || '';
      if (typeof next.localOk === 'boolean') state.localOk = next.localOk;
      if (typeof next.apiOk === 'boolean') state.apiOk = next.apiOk;

      if (statusEl) {
        statusEl.className = 'input-group-text slug-status border-start-0';
        if (state.status === 'checking') {
          statusEl.innerHTML = '<span class="spinner-border spinner-border-sm text-secondary" role="status" aria-hidden="true"></span>';
          statusEl.title = 'Verificando disponibilidade...';
        } else if (state.status === 'available') {
          statusEl.classList.add('text-success', 'bg-white');
          statusEl.innerHTML = '<i class="bi bi-check-circle-fill" aria-hidden="true"></i>';
          statusEl.title = 'Slug disponível';
        } else if (state.status === 'taken') {
          statusEl.classList.add('text-danger', 'bg-white');
          statusEl.innerHTML = '<i class="bi bi-x-circle-fill" aria-hidden="true"></i>';
          statusEl.title = 'Slug em uso';
        } else if (state.status === 'invalid') {
          statusEl.classList.add('text-warning', 'bg-white');
          statusEl.innerHTML = '<i class="bi bi-exclamation-triangle-fill" aria-hidden="true"></i>';
          statusEl.title = 'Slug inválido';
        } else {
          statusEl.innerHTML = '';
          statusEl.title = '';
        }
      }

      if (hintEl) {
        var slugRaw = slugInput.value.trim().toLowerCase();
        var name = nameInput ? nameInput.value.trim() : '';
        var resolved = slugRaw || slugify(name);
        if (state.status === 'checking') {
          hintEl.textContent = 'Verificando slug "' + resolved + '"...';
        } else if (state.status === 'available') {
          hintEl.textContent = slugRaw
            ? 'Slug disponível.'
            : 'Será usado automaticamente: ' + resolved;
        } else if (state.status === 'taken') {
          hintEl.textContent = '';
        } else if (state.status === 'invalid') {
          hintEl.textContent = '';
        } else if (!slugRaw && resolved.length >= 2) {
          hintEl.textContent = 'Será gerado automaticamente: ' + resolved;
        } else {
          hintEl.textContent = options.hintDefault || 'Opcional. Use letras minúsculas, números e hífens. Deve ser único.';
        }
      }

      if (errorEl) {
        if (state.status === 'taken' || state.status === 'invalid') {
          errorEl.textContent = state.message || 'Slug inválido ou em uso.';
          errorEl.style.display = 'block';
          slugInput.classList.add('is-invalid');
        } else if (state.status === 'available') {
          errorEl.style.display = 'none';
          slugInput.classList.remove('is-invalid');
        }
      }

      slugInput.setAttribute('aria-invalid', (state.status === 'taken' || state.status === 'invalid') ? 'true' : 'false');
      if (onStatusChange) onStatusChange(state);
    }

    function localValidate(slugRaw, name) {
      var resolved = slugRaw || slugify(name);
      if (slugRaw && !SLUG_REGEX.test(slugRaw)) {
        return {
          ok: false,
          reason: 'invalid',
          slug: resolved,
          message: 'Use apenas letras minúsculas, números e hífens no slug.',
        };
      }
      if (resolved.length < 2) {
        return {
          ok: false,
          reason: 'invalid',
          slug: resolved,
          message: 'Informe o nome (mín. 2 caracteres) ou um slug válido.',
        };
      }
      return { ok: true, slug: resolved };
    }

    function findLocalConflict(slug, editId) {
      var entry = localSlugs[String(slug || '').toLowerCase()];
      if (!entry) return null;
      if (editId && Number(entry.id) === Number(editId)) return null;
      // Entrada sem id real (rascunho/cache) não deve bloquear cadastro novo
      if (!entry.id && !editId) return null;
      return entry;
    }

    function applyLocalCheck(local, editId) {
      var conflict = findLocalConflict(local.slug, editId);
      if (conflict) {
        setStatus({
          status: 'taken',
          reason: 'taken',
          localOk: false,
          apiOk: false,
          slug: local.slug,
          message: 'Este slug já está em uso por "' + (conflict.name || conflict.slug || 'outro registro') + '".',
        });
        return false;
      }
      state.localOk = true;
      return true;
    }

    function runCheck() {
      var slugRaw = slugInput.value.trim().toLowerCase();
      var name = nameInput ? nameInput.value.trim() : '';
      var editId = getEditId();
      var local = localValidate(slugRaw, name);

      if (!local.ok) {
        state.pendingPromise = Promise.resolve();
        setStatus({
          status: 'invalid',
          reason: local.reason,
          localOk: false,
          apiOk: false,
          message: local.message,
          slug: local.slug,
        });
        return state.pendingPromise;
      }

      if (!state.dirty && state.originalSlug && local.slug === state.originalSlug) {
        state.pendingPromise = Promise.resolve();
        setStatus({
          status: 'available',
          reason: 'unchanged',
          localOk: true,
          apiOk: true,
          message: 'Slug disponível.',
          slug: local.slug,
        });
        return state.pendingPromise;
      }

      if (!applyLocalCheck(local, editId)) {
        state.pendingPromise = Promise.resolve();
        return state.pendingPromise;
      }

      var currentRequest = ++state.requestId;
      setStatus({ status: 'checking', slug: local.slug, localOk: true });

      var url = '/admin/api/slug-disponivel?scope=' + encodeURIComponent(scope)
        + '&slug=' + encodeURIComponent(slugRaw)
        + '&name=' + encodeURIComponent(name);
      if (editId) url += '&excludeId=' + encodeURIComponent(editId);

      state.pendingPromise = fetch(url, {
        method: 'GET',
        credentials: 'same-origin',
        headers: {
          Accept: 'application/json',
          'X-Requested-With': 'XMLHttpRequest',
        },
      })
        .then(function (r) {
          return r.text().then(function (text) {
            var data = parseJsonResponse(r, text);
            return { response: r, data: data };
          });
        })
        .then(function (result) {
          if (currentRequest !== state.requestId) return;
          var r = result.response;
          var data = result.data || {};

          if (r.status === 401) {
            setStatus({
              status: 'available',
              reason: 'local_only',
              localOk: true,
              apiOk: false,
              slug: local.slug,
              message: 'Slug validado localmente. A confirmação final ocorrerá ao salvar.',
            });
            return;
          }

          if (!r.ok && r.status !== 400) {
            throw new Error((data && data.message) || 'Falha ao consultar disponibilidade do slug.');
          }

          if (data.available) {
            setStatus({
              status: 'available',
              reason: data.reason || 'available',
              localOk: true,
              apiOk: true,
              message: data.message || 'Slug disponível.',
              slug: data.slug || local.slug,
            });
            return;
          }

          if (data.reason === 'invalid') {
            setStatus({
              status: 'invalid',
              reason: 'invalid',
              localOk: false,
              apiOk: true,
              message: data.message || 'Slug inválido.',
              slug: data.slug || local.slug,
            });
            return;
          }

          setStatus({
            status: 'taken',
            reason: 'taken',
            localOk: false,
            apiOk: true,
            message: data.conflict && data.conflict.name
              ? 'Este slug já está em uso por "' + data.conflict.name + '".'
              : (data.message || 'Este slug já está em uso.'),
            slug: data.slug || local.slug,
          });
        })
        .catch(function (err) {
          if (currentRequest !== state.requestId) return;
          if (state.localOk) {
            setStatus({
              status: 'available',
              reason: 'local_only',
              localOk: true,
              apiOk: false,
              slug: local.slug,
              message: 'Slug validado localmente. A confirmação final ocorrerá ao salvar.',
            });
            return;
          }
          setStatus({
            status: 'invalid',
            reason: 'error',
            localOk: false,
            apiOk: false,
            message: (err && err.message) || 'Não foi possível verificar o slug. Tente novamente.',
            slug: local.slug,
          });
        });

      return state.pendingPromise;
    }

    function scheduleCheck() {
      state.dirty = true;
      if (state.timer) clearTimeout(state.timer);
      state.timer = setTimeout(runCheck, DEBOUNCE_MS);
    }

    slugInput.addEventListener('input', function () {
      var pos = slugInput.selectionStart;
      slugInput.value = normalizeInput(slugInput.value);
      if (typeof pos === 'number') slugInput.setSelectionRange(pos, pos);
      scheduleCheck();
    });

    if (nameInput) {
      nameInput.addEventListener('input', function () {
        if (!slugInput.value.trim()) scheduleCheck();
      });
    }

    return {
      setLocalSlugs: function (registry) {
        localSlugs = registry && typeof registry === 'object' ? registry : {};
      },
      reset: function (originalSlug) {
        if (state.timer) clearTimeout(state.timer);
        state.requestId += 1;
        state.originalSlug = String(originalSlug || '').trim().toLowerCase();
        state.dirty = false;
        state.localOk = false;
        state.apiOk = null;
        setStatus({ status: 'idle', slug: state.originalSlug });
      },
      checkNow: function () {
        if (state.timer) clearTimeout(state.timer);
        return runCheck();
      },
      ensureAvailable: function () {
        if (state.timer) clearTimeout(state.timer);
        return runCheck().then(function () {
          if (state.status === 'checking') {
            return state.pendingPromise || Promise.resolve();
          }
          return Promise.resolve();
        }).then(function () {
          if (state.status === 'available') {
            return { ok: true, slug: state.slug, localOnly: state.apiOk === false };
          }
          if (state.status === 'taken' || state.status === 'invalid') {
            return {
              ok: false,
              slug: state.slug,
              message: state.message || 'Este slug já está em uso.',
              fields: { slug: state.message || 'Este slug já está em uso.' },
            };
          }
          return { ok: true, slug: state.slug, localOnly: true };
        });
      },
      isBlocking: function () {
        return state.status === 'checking' || state.status === 'taken' || state.status === 'invalid';
      },
      getState: function () {
        return {
          status: state.status,
          slug: state.slug,
          message: state.message,
          reason: state.reason,
          localOk: state.localOk,
          apiOk: state.apiOk,
        };
      },
    };
  }

  global.NeofarmaSlugField = {
    attach: attach,
    slugify: slugify,
    normalizeInput: normalizeInput,
  };
})(window);
