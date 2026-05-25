/** Configurações padrão da vitrine (home + tema). */

const { DEFAULT_SECTION_COLORS, mergeSectionColors, ensureHomeSectionColors } = require('./sectionColors');

/** Tema global — fontes e fallback do catálogo (cores da home ficam por seção). */
const DEFAULT_THEME = {
  accentColor: '#2E5C5C',
  headingColor: '#2E5C5C',
  defaultColor: '#5B8851',
  surfaceColor: '#ffffff',
  mutedBg: '#f6f6f6',
  badgeSaleColor: '#5B8851',
  badgeHotColor: '#2E5C5C',
  titleFont: 'Montserrat',
  bodyFont: 'Roboto',
  buttonText: 'Comprar agora',
  badgeText: 'Oferta',
};

function withSectionColors(sectionKey, base) {
  return {
    ...base,
    colors: mergeSectionColors(sectionKey, base.colors),
  };
}

const DEFAULT_HOME = {
  hero: withSectionColors('hero', {
    enabled: true,
    title: 'Sua farmácia online com',
    titleHighlight: 'cuidado de verdade',
    description: 'Medicamentos, dermocosméticos e serviços de saúde com entrega rápida, preços justos e atendimento farmacêutico especializado.',
    searchPlaceholder: 'Buscar produtos, marcas ou SKU...',
    searchButton: 'Buscar',
    badgeText: 'Oferta especial',
    promotionId: null,
    source: 'featured_promo',
  }),
  benefits: withSectionColors('benefits', {
    enabled: true,
    items: [
      { icon: 'bi-percent', title: 'Ofertas semanais', text: 'Descontos reais em produtos selecionados' },
      { icon: 'bi-credit-card', title: 'Pagamento seguro', text: 'PIX, cartão e débito' },
      { icon: 'bi-calendar2-check', title: 'Agende serviços', text: 'Exames e consultas na farmácia' },
      { icon: 'bi-headset', title: 'Suporte humano', text: 'Equipe pronta para ajudar' },
    ],
  }),
  promoCarousel: withSectionColors('promoCarousel', {
    enabled: true,
    title: 'Promoções imperdíveis',
    subtitle: 'Ofertas ativas com desconto real — aproveite enquanto durarem',
    linkText: 'Ver todas',
    linkUrl: '/category?promo=1',
    limit: 16,
    promotionId: null,
    badgeText: 'OFF',
    buttonText: 'Comprar agora',
  }),
  categories: withSectionColors('categories', {
    enabled: true,
    title: 'Compre por categoria',
    subtitle: 'Encontre rapidamente o que você precisa',
    linkText: 'Ver catálogo completo',
    limit: 8,
  }),
  bestsellers: withSectionColors('bestsellers', {
    enabled: true,
    title: 'Mais vendidos',
    subtitle: 'Ranking baseado em vendas reais dos últimos 90 dias',
    linkText: 'Ver ranking',
    linkUrl: '/category?sort=bestsellers',
    limit: 8,
    days: 90,
  }),
  flashOffer: withSectionColors('flashOffer', {
    enabled: true,
    label: 'Oferta relâmpago',
    title: 'Promoções com tempo limitado',
    titleWithDiscount: 'Até {discount}% de desconto esta semana',
    description: 'Preços especiais válidos até o fim da campanha. Estoque limitado — garanta o seu antes que acabe.',
    buttonText: 'Ver todas as ofertas',
    buttonUrl: '/category?promo=1&sort=discount',
    limit: 4,
    promotionId: null,
    usePromotionEnd: true,
  }),
  newArrivals: withSectionColors('newArrivals', {
    enabled: true,
    title: 'Novidades no catálogo',
    subtitle: 'Produtos recém-adicionados à nossa loja',
    limit: 8,
  }),
  servicesCta: withSectionColors('servicesCta', {
    enabled: true,
    title: 'Serviços de saúde na NeoFarma',
    description: 'Agende exames, aplicações e consultas com profissionais qualificados — na loja ou em domicílio.',
    primaryButton: 'Agendar serviço',
    primaryUrl: '/account/agendamentos',
    secondaryButton: 'Fale conosco',
    secondaryUrl: '/contact',
  }),
  labHighlights: withSectionColors('labHighlights', {
    enabled: true,
    title: 'Marcas em destaque',
    subtitle: 'Laboratórios e fabricantes parceiros com produtos originais disponíveis na NeoFarma',
    linkText: 'Ver todas as marcas',
    linkUrl: '/category',
    buttonText: 'Explorar marca',
    limit: 6,
  }),
};

const DEFAULT_PROMO_STYLE = {
  badgeColor: '#5B8851',
  badgeTextColor: '#ffffff',
  cardBg: '#ffffff',
  gradientStart: '#2E5C5C',
  gradientEnd: '#5B8851',
  titleFont: 'Montserrat',
  headlineText: 'Oferta especial',
  buttonText: 'Comprar agora',
  discountLabel: 'OFF',
};

function deepMerge(base, patch) {
  if (!patch || typeof patch !== 'object') return base;
  const out = { ...base };
  Object.keys(patch).forEach((key) => {
    if (patch[key] && typeof patch[key] === 'object' && !Array.isArray(patch[key])) {
      out[key] = deepMerge(base[key] || {}, patch[key]);
    } else if (patch[key] !== undefined) {
      out[key] = patch[key];
    }
  });
  return out;
}

function mergeHomeConfig(saved) {
  return ensureHomeSectionColors(deepMerge(DEFAULT_HOME, saved || {}));
}

function mergeThemeConfig(saved) {
  return { ...DEFAULT_THEME, ...(saved || {}) };
}

function mergePromoStyle(saved) {
  return { ...DEFAULT_PROMO_STYLE, ...(saved || {}) };
}

module.exports = {
  DEFAULT_THEME,
  DEFAULT_HOME,
  DEFAULT_PROMO_STYLE,
  DEFAULT_SECTION_COLORS,
  mergeHomeConfig,
  mergeThemeConfig,
  mergePromoStyle,
};
