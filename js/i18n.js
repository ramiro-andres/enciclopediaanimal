/**
 * Internacionalización UI (ES/EN) — fase 1: cromo de interfaz.
 * Contenido clínico (razas/enfermedades) permanece en español; ver docs/I18N.md.
 */
const I18n = {
  STORAGE_KEY: 'atlas_lang',
  lang: 'es',

  strings: {
    es: {
      'nav.home': 'Inicio',
      'nav.glossary': 'Glosario',
      'nav.urgency': 'Urgencias',
      'nav.compare': 'Comparar',
      'nav.explore': 'Explorar atlas',
      'nav.lang': 'Idioma',
      'skip.main': 'Saltar al contenido principal',
      'footer.text': 'Enciclopedia Animal — Aprende, explora y cuida mejor. Siempre consulta a un veterinario.',
      'disclaimer.title': 'Aviso importante',
      'disclaimer.accept': 'Entendido',
      'disclaimer.urgency': 'Ver urgencias por especie →',
      'welcome.explore_all': 'Explorar todas las razas',
      'welcome.search_label': '¿Qué quieres conocer hoy?',
      'search.label': 'Buscar en toda la enciclopedia',
      'search.hint': 'Búsqueda general por nombre. Atajo: Ctrl+K',
      'search.clear': 'Limpiar búsqueda',
      'results.all_breeds': 'Todas las razas',
      'results.breeds_of': 'Razas de',
      'size.all': 'Todos',
      'size.small': 'Pequeñas',
      'size.medium': 'Medianas',
      'size.large': 'Grandes',
      'sidebar.animal_type': 'Tipo de animal',
      'sidebar.size': 'Tamaño de raza',
      'sidebar.region': 'Región LATAM',
      'sidebar.summary': 'Resumen',
      'sidebar.change_category': '← Cambiar categoría',
      'back.default': 'Volver',
      'back.home': 'Volver al inicio',
      'back.breed': 'Volver a la raza',
      'compare.title': 'Comparador de razas',
      'compare.intro': 'Compara hasta 3 razas lado a lado: origen, peso, temperamento, nutrición y salud.',
      'compare.add': 'Añadir al comparador',
      'compare.remove': 'Quitar',
      'compare.open': 'Ver comparación',
      'compare.empty': 'Aún no hay razas en el comparador. Abre una ficha y pulsa «Añadir al comparador».',
      'compare.clear': 'Vaciar comparador',
      'compare.full': 'Máximo 3 razas en el comparador.',
      'compare.field.origin': 'Origen',
      'compare.field.weight': 'Peso',
      'compare.field.lifespan': 'Esperanza de vida',
      'compare.field.temperament': 'Temperamento',
      'compare.field.diseases': 'Enfermedades',
      'compare.field.nutrition': 'Nutrición',
      'compare.field.care': 'Cuidados',
      'offline.ready': 'Contenido disponible sin conexión',
      'stats.animals': 'Tipos de animal',
      'stats.breeds': 'Razas',
      'stats.diseases': 'Enfermedades',
      'privacy.analytics': 'Este sitio usa analítica sin cookies (GoatCounter) para métricas agregadas. Ver docs/PRIVACIDAD.md.'
    },
    en: {
      'nav.home': 'Home',
      'nav.glossary': 'Glossary',
      'nav.urgency': 'Emergencies',
      'nav.compare': 'Compare',
      'nav.explore': 'Explore atlas',
      'nav.lang': 'Language',
      'skip.main': 'Skip to main content',
      'footer.text': 'Animal Encyclopedia — Learn, explore and care better. Always consult a veterinarian.',
      'disclaimer.title': 'Important notice',
      'disclaimer.accept': 'Understood',
      'disclaimer.urgency': 'View species emergencies →',
      'welcome.explore_all': 'Explore all breeds',
      'welcome.search_label': 'What do you want to learn today?',
      'search.label': 'Search the entire encyclopedia',
      'search.hint': 'Search by name. Shortcut: Ctrl+K',
      'search.clear': 'Clear search',
      'results.all_breeds': 'All breeds',
      'results.breeds_of': 'Breeds of',
      'size.all': 'All',
      'size.small': 'Small',
      'size.medium': 'Medium',
      'size.large': 'Large',
      'sidebar.animal_type': 'Animal type',
      'sidebar.size': 'Breed size',
      'sidebar.region': 'LATAM region',
      'sidebar.summary': 'Summary',
      'sidebar.change_category': '← Change category',
      'back.default': 'Back',
      'back.home': 'Back to home',
      'back.breed': 'Back to breed',
      'compare.title': 'Breed comparator',
      'compare.intro': 'Compare up to 3 breeds side by side: origin, weight, temperament, nutrition and health.',
      'compare.add': 'Add to comparator',
      'compare.remove': 'Remove',
      'compare.open': 'View comparison',
      'compare.empty': 'No breeds in the comparator yet. Open a breed page and tap «Add to comparator».',
      'compare.clear': 'Clear comparator',
      'compare.full': 'Maximum 3 breeds in the comparator.',
      'compare.field.origin': 'Origin',
      'compare.field.weight': 'Weight',
      'compare.field.lifespan': 'Lifespan',
      'compare.field.temperament': 'Temperament',
      'compare.field.diseases': 'Diseases',
      'compare.field.nutrition': 'Nutrition',
      'compare.field.care': 'Care',
      'offline.ready': 'Content available offline',
      'stats.animals': 'Animal types',
      'stats.breeds': 'Breeds',
      'stats.diseases': 'Diseases',
      'privacy.analytics': 'This site uses cookie-free analytics (GoatCounter) for aggregate metrics. See docs/PRIVACIDAD.md.'
    }
  },

  init() {
    try {
      const saved = localStorage.getItem(this.STORAGE_KEY);
      if (saved === 'en' || saved === 'es') this.lang = saved;
    } catch (_) { /* sin localStorage */ }
    document.documentElement.lang = this.lang;
  },

  t(key) {
    return this.strings[this.lang]?.[key] || this.strings.es[key] || key;
  },

  setLang(lang) {
    if (lang !== 'es' && lang !== 'en') return;
    this.lang = lang;
    try { localStorage.setItem(this.STORAGE_KEY, lang); } catch (_) { /* noop */ }
    document.documentElement.lang = lang;
    document.dispatchEvent(new CustomEvent('atlas:langchange', { detail: { lang } }));
  },

  apply(root = document) {
    root.querySelectorAll('[data-i18n]').forEach(el => {
      const key = el.getAttribute('data-i18n');
      const text = this.t(key);
      if (el.tagName === 'INPUT' || el.tagName === 'TEXTAREA') {
        if (el.hasAttribute('data-i18n-placeholder')) el.placeholder = text;
      } else {
        el.textContent = text;
      }
    });
    root.querySelectorAll('[data-i18n-placeholder]').forEach(el => {
      el.placeholder = this.t(el.getAttribute('data-i18n-placeholder'));
    });
    root.querySelectorAll('[data-i18n-aria]').forEach(el => {
      el.setAttribute('aria-label', this.t(el.getAttribute('data-i18n-aria')));
    });
  }
};

window.I18n = I18n;
