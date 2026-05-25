/** Cores independentes por seção da página inicial. */

const SECTION_SELECTORS = {
  hero: '.storefront-home .sf-hero',
  benefits: '.storefront-home .sf-section--benefits',
  promoCarousel: '.storefront-home .sf-section--promo-carousel',
  categories: '.storefront-home .sf-section--categories',
  bestsellers: '.storefront-home .sf-section--bestsellers',
  flashOffer: '.storefront-home .sf-section--flash .sf-flash',
  newArrivals: '.storefront-home .sf-section--new-arrivals',
  servicesCta: '.storefront-home .sf-section--services .sf-flash--cta',
  labHighlights: '.storefront-home .sf-section--labs',
};

/** Schema para o admin (label + tipo). */
const SECTION_COLOR_SCHEMA = {
  hero: [
    { key: 'backgroundStart', label: 'Fundo (início do gradiente)', type: 'color' },
    { key: 'backgroundEnd', label: 'Fundo (fim do gradiente)', type: 'color' },
    { key: 'headingColor', label: 'Cor do título', type: 'color' },
    { key: 'highlightColor', label: 'Destaque do título', type: 'color' },
    { key: 'textColor', label: 'Cor do texto', type: 'color' },
    { key: 'accentColor', label: 'Cor de ícones / preços', type: 'color' },
    { key: 'surfaceColor', label: 'Fundo dos cards', type: 'color' },
    { key: 'buttonBg', label: 'Botão buscar (fundo)', type: 'color' },
    { key: 'buttonText', label: 'Botão buscar (texto)', type: 'color' },
    { key: 'badgeBg', label: 'Badge destaque (fundo)', type: 'color' },
    { key: 'badgeText', label: 'Badge destaque (texto)', type: 'color' },
  ],
  benefits: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'cardBg', label: 'Fundo dos cards', type: 'color' },
    { key: 'cardBorder', label: 'Borda dos cards', type: 'color' },
    { key: 'iconBg', label: 'Fundo do ícone', type: 'color' },
    { key: 'iconColor', label: 'Cor do ícone', type: 'color' },
    { key: 'titleColor', label: 'Título do item', type: 'color' },
    { key: 'textColor', label: 'Texto do item', type: 'color' },
  ],
  promoCarousel: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'sectionTitleColor', label: 'Título da seção ("Promoções imperdíveis")', type: 'color' },
    { key: 'subtitleColor', label: 'Subtítulo da seção', type: 'color' },
    { key: 'linkColor', label: 'Link "Ver todas"', type: 'color' },
    { key: 'gradientStart', label: 'Slide promo (gradiente início)', type: 'color' },
    { key: 'gradientEnd', label: 'Slide promo (gradiente fim)', type: 'color' },
    { key: 'slideTitleColor', label: 'Título do produto no slide', type: 'color' },
    { key: 'slideTextColor', label: 'Demais textos do slide', type: 'color' },
    { key: 'badgeColor', label: 'Destaque desconto', type: 'color' },
    { key: 'slideButtonBg', label: 'Botão do slide (fundo)', type: 'color' },
    { key: 'slideButtonText', label: 'Botão do slide (texto)', type: 'color' },
    { key: 'paginationColor', label: 'Paginação ativa', type: 'color' },
  ],
  categories: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'headingColor', label: 'Título', type: 'color' },
    { key: 'subtitleColor', label: 'Subtítulo', type: 'color' },
    { key: 'linkColor', label: 'Link', type: 'color' },
    { key: 'tileBg', label: 'Fundo do tile', type: 'color' },
    { key: 'tileBorder', label: 'Borda do tile', type: 'color' },
    { key: 'tileHoverBorder', label: 'Borda ao passar o mouse', type: 'color' },
    { key: 'iconBg', label: 'Fundo do ícone', type: 'color' },
    { key: 'iconColor', label: 'Cor do ícone', type: 'color' },
    { key: 'countColor', label: 'Contador de produtos', type: 'color' },
  ],
  bestsellers: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'headingColor', label: 'Título', type: 'color' },
    { key: 'subtitleColor', label: 'Subtítulo', type: 'color' },
    { key: 'linkColor', label: 'Link', type: 'color' },
    { key: 'accentColor', label: 'Preços / destaques', type: 'color' },
    { key: 'badgeSale', label: 'Badge oferta', type: 'color' },
    { key: 'badgeHot', label: 'Badge ranking', type: 'color' },
    { key: 'rankBg', label: 'Medalha ranking (fundo)', type: 'color' },
    { key: 'cardBg', label: 'Fundo do card', type: 'color' },
  ],
  flashOffer: [
    { key: 'gradientStart', label: 'Gradiente (início)', type: 'color' },
    { key: 'gradientEnd', label: 'Gradiente (fim)', type: 'color' },
    { key: 'textColor', label: 'Texto principal', type: 'color' },
    { key: 'labelBg', label: 'Etiqueta superior (fundo)', type: 'color' },
    { key: 'labelText', label: 'Etiqueta superior (texto)', type: 'color' },
    { key: 'countdownBg', label: 'Cronômetro (fundo)', type: 'color' },
    { key: 'countdownText', label: 'Cronômetro (texto)', type: 'color' },
    { key: 'buttonBg', label: 'Botão (fundo)', type: 'color' },
    { key: 'buttonText', label: 'Botão (texto)', type: 'color' },
    { key: 'productCardBg', label: 'Card produto (fundo)', type: 'color' },
    { key: 'productPriceColor', label: 'Preço no card', type: 'color' },
  ],
  newArrivals: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'headingColor', label: 'Título', type: 'color' },
    { key: 'subtitleColor', label: 'Subtítulo', type: 'color' },
    { key: 'accentColor', label: 'Preços / links', type: 'color' },
    { key: 'badgeSale', label: 'Badge oferta', type: 'color' },
    { key: 'navButtonColor', label: 'Setas do carrossel', type: 'color' },
    { key: 'cardBg', label: 'Fundo do card', type: 'color' },
  ],
  servicesCta: [
    { key: 'gradientStart', label: 'Gradiente (início)', type: 'color' },
    { key: 'gradientEnd', label: 'Gradiente (fim)', type: 'color' },
    { key: 'titleColor', label: 'Título', type: 'color' },
    { key: 'textColor', label: 'Descrição', type: 'color' },
    { key: 'primaryButtonBg', label: 'Botão principal (fundo)', type: 'color' },
    { key: 'primaryButtonText', label: 'Botão principal (texto)', type: 'color' },
    { key: 'secondaryButtonText', label: 'Botão secundário (texto)', type: 'color' },
    { key: 'secondaryButtonBorder', label: 'Botão secundário (borda)', type: 'color' },
  ],
  labHighlights: [
    { key: 'sectionBg', label: 'Fundo da seção', type: 'color' },
    { key: 'eyebrowColor', label: 'Etiqueta superior', type: 'color' },
    { key: 'titleColor', label: 'Título', type: 'color' },
    { key: 'subtitleColor', label: 'Subtítulo', type: 'color' },
    { key: 'linkColor', label: 'Links', type: 'color' },
    { key: 'cardBg', label: 'Fundo do card', type: 'color' },
    { key: 'cardBorder', label: 'Borda do card', type: 'color' },
    { key: 'logoBg', label: 'Avatar da marca (fundo)', type: 'color' },
    { key: 'logoText', label: 'Avatar da marca (texto)', type: 'color' },
    { key: 'promoBadge', label: 'Badge de ofertas', type: 'color' },
    { key: 'ctaColor', label: 'Botão / CTA', type: 'color' },
    { key: 'trustBg', label: 'Faixa de confiança (fundo)', type: 'color' },
  ],
};

const DEFAULT_SECTION_COLORS = {
  hero: {
    backgroundStart: '#ffffff',
    backgroundEnd: '#f6f6f6',
    headingColor: '#2E5C5C',
    highlightColor: '#2E5C5C',
    textColor: '#5B8851',
    accentColor: '#2E5C5C',
    surfaceColor: '#ffffff',
    buttonBg: '#2E5C5C',
    buttonText: '#ffffff',
    badgeBg: '#2E5C5C',
    badgeText: '#ffffff',
  },
  benefits: {
    sectionBg: '#ffffff',
    cardBg: '#ffffff',
    cardBorder: '#e8efe8',
    iconBg: '#e8f0ef',
    iconColor: '#2E5C5C',
    titleColor: '#2E5C5C',
    textColor: '#5B8851',
  },
  promoCarousel: {
    sectionBg: '#f6f6f6',
    sectionTitleColor: '#2E5C5C',
    subtitleColor: '#5B8851',
    linkColor: '#2E5C5C',
    gradientStart: '#2E5C5C',
    gradientEnd: '#5B8851',
    slideTitleColor: '#ffffff',
    slideTextColor: '#ffffff',
    badgeColor: '#5B8851',
    slideButtonBg: '#ffffff',
    slideButtonText: '#2E5C5C',
    paginationColor: '#2E5C5C',
  },
  categories: {
    sectionBg: '#ffffff',
    headingColor: '#2E5C5C',
    subtitleColor: '#5B8851',
    linkColor: '#2E5C5C',
    tileBg: '#ffffff',
    tileBorder: '#e8efe8',
    tileHoverBorder: '#2E5C5C',
    iconBg: '#e8f0ef',
    iconColor: '#2E5C5C',
    countColor: '#5B8851',
  },
  bestsellers: {
    sectionBg: '#f6f6f6',
    headingColor: '#2E5C5C',
    subtitleColor: '#5B8851',
    linkColor: '#2E5C5C',
    accentColor: '#2E5C5C',
    badgeSale: '#5B8851',
    badgeHot: '#2E5C5C',
    rankBg: '#2E5C5C',
    cardBg: '#ffffff',
  },
  flashOffer: {
    gradientStart: '#2E5C5C',
    gradientEnd: '#234848',
    textColor: '#ffffff',
    labelBg: '#3a6666',
    labelText: '#ffffff',
    countdownBg: '#3a6666',
    countdownText: '#ffffff',
    buttonBg: '#ffffff',
    buttonText: '#2E5C5C',
    productCardBg: '#356060',
    productPriceColor: '#ffffff',
  },
  newArrivals: {
    sectionBg: '#f6f6f6',
    headingColor: '#2E5C5C',
    subtitleColor: '#5B8851',
    accentColor: '#2E5C5C',
    badgeSale: '#5B8851',
    navButtonColor: '#2E5C5C',
    cardBg: '#ffffff',
  },
  servicesCta: {
    gradientStart: '#2E5C5C',
    gradientEnd: '#5B8851',
    titleColor: '#ffffff',
    textColor: '#ffffff',
    primaryButtonBg: '#ffffff',
    primaryButtonText: '#2E5C5C',
    secondaryButtonText: '#ffffff',
    secondaryButtonBorder: '#a8c4c4',
  },
  labHighlights: {
    sectionBg: 'transparent',
    eyebrowColor: '#5B8851',
    titleColor: '#2E5C5C',
    subtitleColor: '#5B8851',
    linkColor: '#2E5C5C',
    cardBg: '#ffffff',
    cardBorder: '#e8efe8',
    logoBg: '#2E5C5C',
    logoText: '#ffffff',
    promoBadge: '#5B8851',
    ctaColor: '#2E5C5C',
    trustBg: '#f6f6f6',
  },
};

function mergeSectionColors(sectionKey, saved) {
  const base = DEFAULT_SECTION_COLORS[sectionKey] || {};
  const patch = saved && typeof saved === 'object' ? { ...saved } : {};
  if (sectionKey === 'promoCarousel' && patch.headingColor != null) {
    patch.sectionTitleColor = patch.headingColor;
    delete patch.headingColor;
  }
  return { ...base, ...patch };
}

function cssDecl(prop, value) {
  if (value == null || value === '') return null;
  return `${prop}:${value}`;
}

function buildSectionCssRules(sectionKey, c) {
  const rules = [];
  switch (sectionKey) {
    case 'hero':
      rules.push(
        cssDecl('--accent-color', c.accentColor),
        cssDecl('--heading-color', c.headingColor),
        cssDecl('--default-color', c.textColor),
        cssDecl('--surface-color', c.surfaceColor),
        cssDecl('--sf-hero-highlight', c.highlightColor),
        cssDecl('--sf-hero-gradient', `linear-gradient(135deg, ${c.backgroundStart} 0%, ${c.backgroundEnd} 55%, ${c.backgroundEnd} 100%)`),
        cssDecl('--sf-hero-btn-bg', c.buttonBg),
        cssDecl('--sf-hero-btn-text', c.buttonText),
        cssDecl('--sf-hero-badge-bg', c.badgeBg),
        cssDecl('--sf-hero-badge-text', c.badgeText)
      );
      break;
    case 'benefits':
      rules.push(
        cssDecl('background', c.sectionBg),
        cssDecl('--sf-surface', c.cardBg),
        cssDecl('--sf-border-soft', c.cardBorder),
        cssDecl('--sf-benefit-icon-bg', c.iconBg),
        cssDecl('--accent-color', c.iconColor),
        cssDecl('--heading-color', c.titleColor),
        cssDecl('--default-color', c.textColor)
      );
      break;
    case 'promoCarousel':
      rules.push(
        cssDecl('background', c.sectionBg),
        cssDecl('--accent-color', c.linkColor),
        cssDecl('--default-color', c.subtitleColor),
        cssDecl('--sf-promo-section-title', c.sectionTitleColor),
        cssDecl('--sf-promo-slide-title', c.slideTitleColor),
        cssDecl('--sf-promo-gradient', `linear-gradient(120deg, ${c.gradientStart} 0%, ${c.gradientEnd} 100%)`),
        cssDecl('--sf-promo-text', c.slideTextColor),
        cssDecl('--sf-badge-sale', c.badgeColor),
        cssDecl('--sf-promo-btn-bg', c.slideButtonBg),
        cssDecl('--sf-promo-btn-text', c.slideButtonText),
        cssDecl('--sf-promo-pagination', c.paginationColor)
      );
      break;
    case 'categories':
      rules.push(
        cssDecl('background', c.sectionBg),
        cssDecl('--accent-color', c.linkColor),
        cssDecl('--heading-color', c.headingColor),
        cssDecl('--default-color', c.subtitleColor),
        cssDecl('--sf-surface', c.tileBg),
        cssDecl('--sf-border-soft', c.tileBorder),
        cssDecl('--sf-cat-hover-border', c.tileHoverBorder),
        cssDecl('--sf-cat-icon-bg', c.iconBg),
        cssDecl('--sf-cat-icon-color', c.iconColor),
        cssDecl('--sf-cat-count', c.countColor)
      );
      break;
    case 'bestsellers':
      rules.push(
        cssDecl('background', c.sectionBg),
        cssDecl('--accent-color', c.accentColor),
        cssDecl('--heading-color', c.headingColor),
        cssDecl('--default-color', c.subtitleColor),
        cssDecl('--sf-section-link', c.linkColor),
        cssDecl('--sf-badge-sale', c.badgeSale),
        cssDecl('--sf-badge-hot', c.badgeHot),
        cssDecl('--sf-rank-bg', c.rankBg),
        cssDecl('--sf-surface', c.cardBg)
      );
      break;
    case 'flashOffer':
      rules.push(
        cssDecl('--sf-flash-gradient', `linear-gradient(135deg, ${c.gradientStart} 0%, ${c.gradientEnd} 100%)`),
        cssDecl('--contrast-color', c.textColor),
        cssDecl('--sf-flash-label-bg', c.labelBg),
        cssDecl('--sf-flash-label-text', c.labelText),
        cssDecl('--sf-flash-countdown-bg', c.countdownBg),
        cssDecl('--sf-flash-countdown-text', c.countdownText),
        cssDecl('--sf-flash-btn-bg', c.buttonBg),
        cssDecl('--sf-flash-btn-text', c.buttonText),
        cssDecl('--sf-flash-product-bg', c.productCardBg),
        cssDecl('--sf-flash-price', c.productPriceColor)
      );
      break;
    case 'newArrivals':
      rules.push(
        cssDecl('background', c.sectionBg),
        cssDecl('--accent-color', c.accentColor),
        cssDecl('--heading-color', c.headingColor),
        cssDecl('--default-color', c.subtitleColor),
        cssDecl('--sf-badge-sale', c.badgeSale),
        cssDecl('--sf-nav-btn-color', c.navButtonColor),
        cssDecl('--sf-surface', c.cardBg)
      );
      break;
    case 'servicesCta':
      rules.push(
        cssDecl('--sf-flash-gradient', `linear-gradient(135deg, ${c.gradientStart} 0%, ${c.gradientEnd} 100%)`),
        cssDecl('--contrast-color', c.titleColor),
        cssDecl('--sf-cta-text', c.textColor),
        cssDecl('--sf-cta-primary-bg', c.primaryButtonBg),
        cssDecl('--sf-cta-primary-text', c.primaryButtonText),
        cssDecl('--sf-cta-secondary-text', c.secondaryButtonText),
        cssDecl('--sf-cta-secondary-border', c.secondaryButtonBorder)
      );
      break;
    case 'labHighlights':
      rules.push(
        cssDecl('background', c.sectionBg !== 'transparent' ? c.sectionBg : null),
        cssDecl('--sf-brands-eyebrow', c.eyebrowColor),
        cssDecl('--heading-color', c.titleColor),
        cssDecl('--default-color', c.subtitleColor),
        cssDecl('--accent-color', c.linkColor),
        cssDecl('--sf-brand-card-bg', c.cardBg),
        cssDecl('--sf-brand-card-border', c.cardBorder),
        cssDecl('--sf-brand-logo-bg', c.logoBg),
        cssDecl('--sf-brand-logo-text', c.logoText),
        cssDecl('--sf-brand-promo', c.promoBadge),
        cssDecl('--sf-brand-cta', c.ctaColor),
        cssDecl('--sf-brands-trust-bg', c.trustBg)
      );
      break;
    default:
      break;
  }
  return rules.filter(Boolean);
}

function buildSectionCssBlock(sectionKey, colors) {
  const selector = SECTION_SELECTORS[sectionKey];
  if (!selector) return '';
  const merged = mergeSectionColors(sectionKey, colors);
  const rules = buildSectionCssRules(sectionKey, merged);
  if (!rules.length) return '';
  return `${selector}{${rules.join(';')}}`;
}

function buildHomeSectionStyles(homeConfig) {
  if (!homeConfig || typeof homeConfig !== 'object') return '';
  return Object.keys(SECTION_SELECTORS)
    .map((key) => {
      const section = homeConfig[key] || {};
      return buildSectionCssBlock(key, section.colors);
    })
    .filter(Boolean)
    .join('\n');
}

function ensureHomeSectionColors(homeConfig) {
  const out = { ...homeConfig };
  Object.keys(SECTION_SELECTORS).forEach((key) => {
    const section = { ...(out[key] || {}) };
    section.colors = mergeSectionColors(key, section.colors);
    out[key] = section;
  });
  return out;
}

module.exports = {
  SECTION_SELECTORS,
  SECTION_COLOR_SCHEMA,
  DEFAULT_SECTION_COLORS,
  mergeSectionColors,
  buildHomeSectionStyles,
  ensureHomeSectionColors,
};
