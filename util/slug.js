const SLUG_MIN_LENGTH = 2;
const SLUG_MAX_LENGTH = 120;
const SLUG_FORMAT_REGEX = /^[a-z0-9]+(?:-[a-z0-9]+)*$/;

/**
 * Converte texto livre em slug URL-safe.
 */
function slugify(text) {
  return String(text || '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^\w\-]+/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Normaliza entrada digitada no campo slug (cliente ou servidor).
 */
function normalizeSlugInput(raw) {
  return String(raw || '')
    .toLowerCase()
    .trim()
    .replace(/\s+/g, '-')
    .replace(/[^a-z0-9\-]/g, '')
    .replace(/\-\-+/g, '-')
    .replace(/^-+|-+$/g, '');
}

/**
 * Resolve slug final: explícito ou gerado a partir do nome.
 */
function resolveSlug(slugRaw, name) {
  const explicit = String(slugRaw || '').trim().toLowerCase();
  if (explicit) return explicit;
  return slugify(name);
}

/**
 * Valida formato e tamanho do slug.
 */
function validateSlug(slug, options = {}) {
  const {
    explicit = false,
    minLength = SLUG_MIN_LENGTH,
    maxLength = SLUG_MAX_LENGTH,
  } = options;
  const code = String(slug || '').trim().toLowerCase();

  if (!code) {
    return { ok: false, error: 'O slug deve ter pelo menos 2 caracteres.', slug: code };
  }
  if (code.length < minLength) {
    return { ok: false, error: 'O slug deve ter pelo menos 2 caracteres.', slug: code };
  }
  if (code.length > maxLength) {
    return { ok: false, error: `O slug deve ter no máximo ${maxLength} caracteres.`, slug: code };
  }
  if (!SLUG_FORMAT_REGEX.test(code)) {
    return {
      ok: false,
      error: explicit
        ? 'Use apenas letras minúsculas, números e hífens no slug.'
        : 'Slug inválido. Ajuste o nome ou informe um slug manualmente.',
      slug: code,
    };
  }
  return { ok: true, slug: code };
}

module.exports = {
  SLUG_FORMAT_REGEX,
  SLUG_MIN_LENGTH,
  SLUG_MAX_LENGTH,
  slugify,
  normalizeSlugInput,
  resolveSlug,
  validateSlug,
};
