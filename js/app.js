const App = {
  data: null,
  dictionaryData: null,
  searchSynonyms: null,
  synonymGroups: null,
  crossLinks: null,
  toxicologyData: null,
  emergenciasLatamData: null,
  triajeData: null,
  triajeCategoryId: null,
  triajeSymptomId: null,
  triajeCauseId: null,
  themeMode: 'auto',
  THEME_KEY: 'atlas_theme',
  vaccinationCalendars: null,
  manifest: null,
  searchIndex: null,
  chunkCache: {},
  labReferenceData: null,
  changelogData: null,
  labSpecies: 'perros',
  toxicologyQuery: '',
  toxicologySpecies: 'todos',
  rerMerUnit: 'kg',
  fluidUnit: 'kg',
  fluidSpecies: 'perros',
  unitsDropsFactor: 20,
  predisposicionesQuery: '',
  predisposicionesAnimal: 'todos',
  predisposicionesIndex: null,
  dictionaryQuery: '',
  dictionaryCategory: 'todos',
  currentView: 'welcome',
  currentAnimal: 'todos',
  currentSize: 'todos',
  currentRegion: 'todos',
  REGION_MACRO_GROUPS: {
    LATAM: ['Colombia', 'México', 'Argentina', 'Chile', 'Perú', 'Brasil', 'Ecuador', 'Venezuela', 'Bolivia', 'Uruguay', 'Paraguay', 'Centroamérica', 'Cuba', 'República Dominicana', 'Costa Rica', 'Panamá', 'Guatemala', 'Honduras'],
    Europa: ['España', 'Francia', 'Alemania', 'Italia', 'Reino Unido', 'Países Bajos', 'Suiza', 'Escandinavia'],
    'Norteamérica': ['Estados Unidos', 'Canadá'],
    Asia: ['China', 'Japón', 'India', 'Tailandia'],
    Oceanía: ['Australia', 'Nueva Zelanda']
  },
  currentBreed: null,
  currentDisease: null,
  searchQuery: '',
  isRoutingFromHash: false,
  compareList: [],
  COMPARE_KEY: 'atlas_compare',
  FAVORITES_KEY: 'atlas_favorites',
  COMPARE_MAX: 3,
  SITE_URL: 'https://ramiro-andres.github.io/enciclopediaanimal/',
  GITHUB_ISSUES_REPO: 'ramiro-andres/enciclopediaanimal',
  GITHUB_REPO_URL: 'https://github.com/ramiro-andres/enciclopediaanimal',
  CONTRIBUTE_DOC_URL: 'https://github.com/ramiro-andres/enciclopediaanimal/blob/main/docs/CONTRIBUIR.md',
  GOOD_FIRST_ISSUE_URL: 'https://github.com/ramiro-andres/enciclopediaanimal/issues?q=label%3A%22good+first+issue%22',
  DEFAULT_META: {
    title: 'Enciclopedia Animal — Salud Veterinaria',
    description: 'Atlas Animal: enciclopedia veterinaria educativa con más de 350 razas, 2.000 enfermedades y glosario médico. Información de referencia que no sustituye la consulta con un veterinario colegiado.',
    image: 'https://ramiro-andres.github.io/enciclopediaanimal/images/og-image.svg',
    imageAlt: 'Atlas Animal, enciclopedia veterinaria educativa',
    url: 'https://ramiro-andres.github.io/enciclopediaanimal/',
    type: 'website'
  },
  currentDictionaryTerm: null,
  bcsSpecies: 'perros',
  bcsScore: 5,
  flashcardsDeck: [],
  flashcardsIndex: 0,
  flashcardsRevealed: false,
  flashcardsCategory: 'todos',
  FLASHCARDS_KEY: 'atlas_flashcards_progress',

  t(key) {
    return window.I18n ? I18n.t(key) : key;
  },

  absoluteUrl(path) {
    if (!path) return this.DEFAULT_META.url;
    if (/^https?:\/\//i.test(path)) return path;
    const origin = !window.location.origin || window.location.origin === 'null'
      ? 'https://ramiro-andres.github.io'
      : window.location.origin;
    const basePath = window.location.pathname.replace(/\/$/, '') || '/enciclopediaanimal';
    const clean = path.replace(/^\.\//, '');
    return clean.startsWith('/') ? `${origin}${clean}` : `${origin}${basePath}/${clean}`;
  },

  pageUrl(hash) {
    const base = `${window.location.origin}${window.location.pathname}`;
    if (!hash) return base;
    return `${base}${hash.startsWith('#') ? hash : `#${hash}`}`;
  },

  setMetaTag(attr, key, value) {
    let el = document.querySelector(`meta[${attr}="${key}"]`);
    if (!el) {
      el = document.createElement('meta');
      el.setAttribute(attr, key);
      document.head.appendChild(el);
    }
    el.setAttribute('content', value || '');
  },

  updatePageMeta(overrides = {}) {
    const meta = { ...this.DEFAULT_META, ...overrides };
    document.title = meta.title;
    const desc = document.querySelector('meta[name="description"]');
    if (desc) desc.setAttribute('content', meta.description);
    this.setMetaTag('property', 'og:type', meta.type);
    this.setMetaTag('property', 'og:site_name', 'Atlas Animal');
    this.setMetaTag('property', 'og:title', meta.title);
    this.setMetaTag('property', 'og:description', meta.description);
    this.setMetaTag('property', 'og:url', meta.url);
    this.setMetaTag('property', 'og:image', this.absoluteUrl(meta.image));
    this.setMetaTag('property', 'og:image:alt', meta.imageAlt || meta.title);
    this.setMetaTag('property', 'og:locale', 'es_ES');
    this.setMetaTag('name', 'twitter:card', 'summary_large_image');
    this.setMetaTag('name', 'twitter:title', meta.title);
    this.setMetaTag('name', 'twitter:description', meta.description);
    this.setMetaTag('name', 'twitter:image', this.absoluteUrl(meta.image));
    const canonical = document.querySelector('link[rel="canonical"]');
    if (canonical) canonical.setAttribute('href', meta.url);
  },

  resetPageMeta() {
    this.clearJsonLd();
    this.currentDictionaryTerm = null;
    this.updatePageMeta(this.DEFAULT_META);
  },

  setJsonLd(data) {
    this.clearJsonLd();
    const script = document.createElement('script');
    script.type = 'application/ld+json';
    script.id = 'atlas-jsonld';
    script.textContent = JSON.stringify(data);
    document.head.appendChild(script);
  },

  clearJsonLd() {
    document.getElementById('atlas-jsonld')?.remove();
  },

  jsonLdForDisease(breed, disease) {
    const symptoms = disease.sintomas || [];
    const payload = {
      '@context': 'https://schema.org',
      '@type': 'MedicalWebPage',
      name: disease.nombre,
      description: disease.diagnostico || disease.prevencion || `${disease.nombre} en ${breed.nombre}`,
      url: this.pageUrl(this.diseaseRoute(breed, disease)),
      about: {
        '@type': 'MedicalCondition',
        name: disease.nombre,
        description: disease.causas || disease.diagnostico || disease.nombre,
        signOrSymptom: symptoms.map(s => ({ '@type': 'MedicalSignOrSymptom', name: s }))
      },
      isPartOf: {
        '@type': 'WebSite',
        name: 'Atlas Animal',
        url: this.DEFAULT_META.url
      }
    };
    if (disease.tratamiento) {
      payload.about.possibleTreatment = { '@type': 'MedicalTherapy', name: disease.tratamiento };
    }
    return payload;
  },

  jsonLdForTerm(term) {
    return {
      '@context': 'https://schema.org',
      '@type': 'DefinedTerm',
      name: term.termino,
      description: term.definicion,
      url: this.pageUrl(this.termRoute(term)),
      inDefinedTermSet: {
        '@type': 'DefinedTermSet',
        name: this.dictionaryData?.titulo || 'Diccionario de términos médicos',
        url: this.pageUrl('#glosario')
      }
    };
  },

  termSlug(termino) {
    return this.diseaseSlug({ nombre: termino });
  },

  termRoute(term) {
    const name = typeof term === 'string' ? term : term?.termino;
    return `#glosario/${this.routePart(this.termSlug(name))}`;
  },

  findDictionaryTerm(slug) {
    const decoded = decodeURIComponent(slug || '');
    const target = this.normalizeSearch(decoded.replace(/-/g, ' '));
    return this.getDictionaryTerms().find(
      t => this.termSlug(t.termino) === decoded || this.normalizeSearch(t.termino) === target
    );
  },

  renderReportErrorButton({ kind, name, animalCategory, hash }) {
    const url = this.pageUrl(hash);
    const params = new URLSearchParams({
      template: 'content_request.yml',
      title: `[Contenido]: Error en ficha — ${name}`,
      content_type: 'Ampliación de ficha existente',
      title_name: name,
      description: `**Reporte de error de contenido**\n\n**Tipo de ficha:** ${kind}\n**Nombre:** ${name}\n` +
        (animalCategory ? `**Categoría animal:** ${animalCategory}\n` : '') +
        `**URL:** ${url}\n\nDescriba el error detectado (dato incorrecto, imagen, ortografía, etc.):`
    });
    if (animalCategory) params.set('animal_category', animalCategory);
    const href = `https://github.com/${this.GITHUB_ISSUES_REPO}/issues/new?${params.toString()}`;
    return `<a class="btn-report-error" href="${this.esc(href)}" target="_blank" rel="noopener noreferrer" aria-label="${this.esc(this.t('report.error_label'))}">${this.esc(this.t('report.error'))}</a>`;
  },

  async init() {
    try {
      if (window.I18n) {
        I18n.init();
        I18n.apply();
        this.bindLangSwitcher();
        this.bindThemeToggle();
        document.addEventListener('atlas:langchange', () => {
          I18n.apply();
          this.updateCompareBadge();
          if (this.currentView === 'compare') this.renderCompare();
          if (this.currentView === 'tools') this.renderTools();
          if (this.currentView === 'rerMer') this.renderRerMer();
          if (this.currentView === 'toxicologia') this.renderToxicologia();
          if (this.currentView === 'fluidoterapia') this.renderFluidoterapia();
          if (this.currentView === 'unidades') this.renderUnidades();
          if (this.currentView === 'predisposiciones') this.renderPredisposiciones();
          if (this.currentView === 'urgency') this.renderUrgency();
          if (this.currentView === 'bcs') this.renderBcs();
          if (this.currentView === 'flashcards') this.renderFlashcards();
          if (this.currentView === 'emergenciasLatam') this.renderEmergenciasLatam();
          if (this.currentView === 'triaje') this.renderTriaje();
          if (this.currentView === 'laboratorio') this.renderLaboratorio();
          if (this.currentView === 'changelog') this.renderChangelog();
          if (this.currentView === 'dictionary') this.renderDictionary();
          this.renderBreedOfWeek();
          this.renderFavorites();
          this.renderFooterContribute();
          this.updateMobileTabBar();
          this.updateResultsTitle();
        });
      }
      this.loadCompareList();
      this.data = await this.loadData();
      if (!this.data?.animales?.length) throw new Error('Datos vacíos o corruptos');
      this.searchIndex = await this.loadSearchIndex();
      this.dictionaryData = await this.loadDictionaryData();
      this.searchSynonyms = await this.loadSearchSynonyms();
      this.buildSynonymIndex();
      this.crossLinks = await this.loadCrossLinks();
      this.toxicologyData = await this.loadToxicologyData();
      this.emergenciasLatamData = await this.loadEmergenciasLatamData();
      this.triajeData = await this.loadTriajeData();
      this.labReferenceData = await this.loadLabReferenceData();
      this.changelogData = await this.loadChangelogData();
      this.initTheme();
      this.vaccinationCalendars = await this.loadVaccinationCalendars();
      this.renderNav();
      this.renderStats();
      this.renderCategoryCards();
      this.renderWelcome();
      this.renderFooterContribute();
      this.renderBreedOfWeek();
      this.bindEvents();
      this.showLoadStatus();
      this.renderRecentHistory();
      this.renderFavorites();
      this.bindMobileTabBar();
      this.exportE2EState();
      if (!(await this.openRouteFromHash())) this.showView('welcome');
      if (DisclaimerModal.wasAccepted() && !window.location.hash) WelcomeTour.tryStart();
      void this.preloadAllChunks();
    } catch (err) {
      console.error('Error cargando enciclopedia:', err);
      window.__E2E_STATE__ = { ready: false, error: err?.message || String(err) };
      const intro = document.getElementById('welcomeIntro');
      if (intro) intro.textContent = 'Error al cargar la enciclopedia.';
      const grid = document.getElementById('breedGrid');
      if (grid) {
        grid.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">⚠️</div>
          <p><strong>No se pudo cargar la enciclopedia.</strong></p>
          <p style="margin-top:0.5rem">Regenera los datos con <code>bash actualizar_datos.sh</code> o visita el sitio publicado:</p>
          <p><a href="https://ramiro-andres.github.io/enciclopediaanimal/" target="_blank" rel="noopener">ramiro-andres.github.io/enciclopediaanimal</a></p>
          <p style="margin-top:0.5rem;font-size:0.85rem;color:#888">${err.message}</p>
        </div>`;
      }
    }
  },

  async loadData() {
    if (window.ENCICLOPEDIA_DATA?.animales?.length) {
      this.manifest = null;
      return window.ENCICLOPEDIA_DATA;
    }
    if (window.ENCICLOPEDIA_MANIFEST?.animales?.length) {
      this.manifest = window.ENCICLOPEDIA_MANIFEST;
      return this.buildDataFromManifest(this.manifest);
    }
    try {
      const res = await fetch('data/chunks/manifest.json');
      if (res.ok) {
        this.manifest = await res.json();
        return this.buildDataFromManifest(this.manifest);
      }
    } catch (_) { /* fetch falla en file:// */ }
    try {
      const res = await fetch('data/enciclopedia.json');
      if (res.ok) {
        this.manifest = null;
        return await res.json();
      }
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  buildDataFromManifest(manifest) {
    return {
      animales: manifest.animales.map(a => ({
        id: a.id,
        nombre: a.nombre,
        icono: a.icono,
        razas: { pequena: [], mediana: [], grande: [] }
      }))
    };
  },

  async loadSearchIndex() {
    if (window.SEARCH_INDEX?.breeds?.length) return window.SEARCH_INDEX;
    try {
      const res = await fetch('data/search_index.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadChunk(animalId) {
    if (!animalId || animalId === 'todos' || this.chunkCache[animalId]) {
      return this.chunkCache[animalId] || null;
    }
    let chunk = window.ENCICLOPEDIA_CHUNKS?.[animalId] || null;
    if (!chunk) {
      try {
        const res = await fetch(`data/chunks/${animalId}.json`);
        if (res.ok) chunk = await res.json();
      } catch (_) { /* fetch falla en file:// */ }
    }
    if (!chunk) chunk = await this.loadChunkViaScript(animalId);
    if (!chunk) return null;
    this.chunkCache[animalId] = chunk;
    const animal = this.data?.animales?.find(a => a.id === animalId);
    if (animal) animal.razas = chunk.razas;
    return chunk;
  },

  loadChunkViaScript(animalId) {
    if (window.ENCICLOPEDIA_CHUNKS?.[animalId]) {
      return Promise.resolve(window.ENCICLOPEDIA_CHUNKS[animalId]);
    }
    this._chunkScriptPending = this._chunkScriptPending || {};
    if (this._chunkScriptPending[animalId]) return this._chunkScriptPending[animalId];
    this._chunkScriptPending[animalId] = new Promise((resolve) => {
      const finish = (value) => {
        clearTimeout(timer);
        resolve(value);
      };
      const timer = setTimeout(() => finish(null), 20_000);
      const script = document.createElement('script');
      script.src = `data/chunks/${animalId}.js`;
      script.onload = () => finish(window.ENCICLOPEDIA_CHUNKS?.[animalId] || null);
      script.onerror = () => finish(null);
      document.head.appendChild(script);
    });
    return this._chunkScriptPending[animalId];
  },

  isAllChunksLoaded() {
    if (!this.manifest?.animales?.length) return !this.manifest;
    return this.manifest.animales.every(a => this.chunkCache[a.id]);
  },

  async preloadAllChunks() {
    if (!this.manifest?.animales?.length) return;
    await Promise.all(this.manifest.animales.map(a => this.loadChunk(a.id)));
    this.renderWelcome();
    this.renderBreedOfWeek();
    this.renderStats();
    this.showLoadStatus();
    if (this.currentView === 'home') this.renderHome();
    this.exportE2EState();
  },

  getCatalogStats() {
    if (this.manifest) {
      return {
        breeds: this.manifest.total_breeds || 0,
        diseases: this.manifest.total_diseases || 0
      };
    }
    const breeds = this.getAllBreeds();
    return {
      breeds: breeds.length,
      diseases: breeds.reduce((n, b) => n + (b.enfermedades?.length || 0), 0)
    };
  },

  async loadLabReferenceData() {
    if (window.LAB_REFERENCE?.especies?.length) return window.LAB_REFERENCE;
    try {
      const res = await fetch('data/lab_reference.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadChangelogData() {
    if (window.ATLAS_CHANGELOG?.entries) return window.ATLAS_CHANGELOG;
    try {
      const res = await fetch('data/changelog.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return { entries: [], source: 'none' };
  },

  getWeekOfYear(date = new Date()) {
    const d = new Date(Date.UTC(date.getFullYear(), date.getMonth(), date.getDate()));
    const dayNum = d.getUTCDay() || 7;
    d.setUTCDate(d.getUTCDate() + 4 - dayNum);
    const yearStart = new Date(Date.UTC(d.getUTCFullYear(), 0, 1));
    return Math.ceil((((d - yearStart) / 86400000) + 1) / 7);
  },

  getBreedOfWeekEntry() {
    const breeds = (this.searchIndex?.breeds || [])
      .slice()
      .sort((a, b) => `${a.animalId}:${a.id}`.localeCompare(`${b.animalId}:${b.id}`, 'es'));
    if (!breeds.length) return null;
    const year = new Date().getFullYear();
    const week = this.getWeekOfYear();
    const idx = (year * 53 + week) % breeds.length;
    const entry = breeds[idx];
    const animal = this.data?.animales?.find(a => a.id === entry.animalId);
    return {
      ...entry,
      animalNombre: animal?.nombre || entry.animalId,
      animalIcono: animal?.icono || '🐾'
    };
  },

  renderBreedOfWeek() {
    const panel = document.getElementById('breedOfWeekPanel');
    if (!panel) return;
    const entry = this.getBreedOfWeekEntry();
    if (!entry) {
      panel.hidden = true;
      return;
    }
    const week = this.getWeekOfYear();
    const fullBreed = this.findBreed(entry.animalId, entry.id);
    const img = fullBreed?.imagen || 'images/placeholder.svg';
    panel.hidden = false;
    panel.innerHTML = `
      <div class="breed-of-week-header">
        <span class="eyebrow">${this.esc(this.t('breed_week.eyebrow'))}</span>
        <span class="breed-of-week-badge">${this.esc(this.t('breed_week.week').replace('{week}', week))}</span>
      </div>
      <article class="breed-of-week-card" role="button" tabindex="0"
        aria-label="${this.esc(this.t('breed_week.open').replace('{name}', entry.nombre))}"
        data-animal="${this.esc(entry.animalId)}" data-breed="${this.esc(entry.id)}">
        <img class="breed-of-week-img" src="${this.esc(img)}" alt="${this.esc(entry.nombre)}" loading="lazy">
        <div class="breed-of-week-copy">
          <span class="breed-of-week-species">${entry.animalIcono} ${this.esc(entry.animalNombre)}</span>
          <h3>${this.esc(entry.nombre)}</h3>
          <p>${this.esc(this.t('breed_week.desc'))}</p>
          <span class="breed-of-week-link">${this.esc(this.t('breed_week.cta'))} →</span>
        </div>
      </article>
    `;
    const open = async (card) => {
      await this.loadChunk(card.dataset.animal);
      const breed = this.findBreed(card.dataset.animal, card.dataset.breed);
      if (breed) this.showBreedDetail(breed);
    };
    const card = panel.querySelector('.breed-of-week-card');
    card?.addEventListener('click', () => open(card));
    card?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        open(card);
      }
    });
  },

  async loadDictionaryData() {
    if (window.DICCIONARIO_MEDICOS?.categorias?.length) {
      return window.DICCIONARIO_MEDICOS;
    }
    try {
      const res = await fetch('data/diccionario_medicos.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadSearchSynonyms() {
    if (window.SEARCH_SYNONYMS?.terms) {
      return window.SEARCH_SYNONYMS;
    }
    try {
      const res = await fetch('data/search_synonyms.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  buildSynonymIndex() {
    const terms = this.searchSynonyms?.terms || {};
    this.synonymGroups = Object.entries(terms).map(([canonical, synonyms]) => {
      const group = new Set([canonical, ...synonyms]);
      return [...group];
    });
  },

  async loadCrossLinks() {
    if (window.ENLACES_CLINICOS?.por_termino) {
      return window.ENLACES_CLINICOS;
    }
    try {
      const res = await fetch('data/enlaces_clinicos.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadToxicologyData() {
    if (window.TOXICOLOGIA_DATA?.sustancias?.length) {
      return window.TOXICOLOGIA_DATA;
    }
    try {
      const res = await fetch('data/toxicologia.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadEmergenciasLatamData() {
    if (window.EMERGENCIAS_LATAM?.paises?.length) {
      return window.EMERGENCIAS_LATAM;
    }
    try {
      const res = await fetch('data/emergencias_latam.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  async loadTriajeData() {
    if (window.TRIAJE_DATA?.categorias?.length) {
      return window.TRIAJE_DATA;
    }
    try {
      const res = await fetch('data/triaje.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  initTheme() {
    let mode = 'auto';
    try {
      const saved = localStorage.getItem(this.THEME_KEY);
      if (saved === 'light' || saved === 'dark' || saved === 'auto') mode = saved;
    } catch (_) { /* sin localStorage */ }
    this.applyTheme(mode);
    window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', () => {
      if (this.themeMode === 'auto') this.applyTheme('auto');
    });
  },

  applyTheme(mode) {
    this.themeMode = mode;
    try { localStorage.setItem(this.THEME_KEY, mode); } catch (_) { /* noop */ }
    document.documentElement.setAttribute('data-theme-mode', mode);
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isDark = mode === 'dark' || (mode === 'auto' && prefersDark);
    document.documentElement.setAttribute('data-theme', isDark ? 'dark' : 'light');
    const btn = document.getElementById('themeToggleBtn');
    if (btn) {
      const label = isDark ? this.t('theme.light') : this.t('theme.dark');
      btn.setAttribute('aria-label', label);
      btn.title = label;
    }
  },

  toggleTheme() {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const currentlyDark = this.themeMode === 'dark'
      || (this.themeMode === 'auto' && prefersDark);
    this.applyTheme(currentlyDark ? 'light' : 'dark');
  },

  bindThemeToggle() {
    document.getElementById('themeToggleBtn')?.addEventListener('click', () => this.toggleTheme());
  },

  async loadVaccinationCalendars() {
    if (window.CALENDARIO_VACUNACION?.especies) {
      return window.CALENDARIO_VACUNACION;
    }
    try {
      const res = await fetch('data/calendario_vacunacion.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
  },

  crossLinksForTerm(termino) {
    if (!this.crossLinks?.por_termino) return null;
    return this.crossLinks.por_termino[this.normalizeSearch(termino)] || null;
  },

  crossLinksForDisease(nombre) {
    if (!this.crossLinks?.por_enfermedad) return null;
    return this.crossLinks.por_enfermedad[this.normalizeSearch(nombre)] || null;
  },

  findBreedById(animalId, breedId) {
    return this.getAllBreeds().find(b => b.animalId === animalId && b.id === breedId) || null;
  },

  findDiseaseInBreed(breed, nombre) {
    if (!breed) return null;
    const target = this.normalizeSearch(nombre);
    return (breed.enfermedades || []).find(e => this.normalizeSearch(e.nombre) === target) || null;
  },

  openDiseaseFromLink(animalId, breedId, nombre) {
    const breed = this.findBreedById(animalId, breedId);
    const disease = this.findDiseaseInBreed(breed, nombre);
    if (breed && disease) this.showDiseaseDetail(breed, disease);
  },

  openDictionaryWithTerm(termino) {
    const term = this.getDictionaryTerms().find(t => this.normalizeSearch(t.termino) === this.normalizeSearch(termino));
    if (term) {
      this.showDictionaryTerm(term);
      return;
    }
    this.dictionaryCategory = 'todos';
    this.dictionaryQuery = this.normalizeSearch(termino);
    this.showDictionary();
    const input = document.getElementById('dictionarySearchInput');
    if (input) input.value = termino;
  },

  showLoadStatus() {
    const stats = this.getCatalogStats();
    const intro = document.getElementById('welcomeIntro');
    if (intro) {
      intro.textContent = this.t('welcome.intro_stats')
        .replace('{breeds}', stats.breeds)
        .replace('{diseases}', stats.diseases);
    }
    const btnAll = document.getElementById('btnExploreAll');
    if (btnAll) btnAll.textContent = this.t('welcome.explore_all_count').replace('{count}', stats.breeds);
  },

  bindEvents() {
    const searchInput = document.getElementById('searchInput');
    const searchInputWelcome = document.getElementById('searchInputWelcome');
    const searchClearBtn = document.getElementById('searchClearBtn');
    const focusSearchBtn = document.getElementById('focusSearchBtn');

    const handleSearchInput = (value) => {
      this.searchQuery = value.toLowerCase().trim();
      if (searchInput) searchInput.value = this.searchQuery;
      if (searchInputWelcome) searchInputWelcome.value = this.searchQuery;
      if (searchClearBtn) searchClearBtn.hidden = !this.searchQuery;
      this.showView('home');
      this.renderHome();
    };

    searchInput?.addEventListener('input', (e) => handleSearchInput(e.target.value));

    searchInput?.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') this.clearSearch();
    });

    searchInputWelcome?.addEventListener('input', (e) => handleSearchInput(e.target.value));

    searchInputWelcome?.addEventListener('keydown', (e) => {
      if (e.key === 'Escape') this.clearSearch();
    });

    searchClearBtn?.addEventListener('click', () => this.clearSearch());

    focusSearchBtn?.addEventListener('click', () => {
      const activeInput = this.currentView === 'welcome' ? searchInputWelcome : searchInput;
      if (!activeInput) return;
      if (this.currentView === 'welcome') this.showView('welcome');
      else this.showView('home');
      activeInput.scrollIntoView({ behavior: 'smooth', block: 'center' });
      activeInput.focus();
    });

    document.getElementById('goHomeBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('goDictionaryBtn')?.addEventListener('click', () => this.showDictionary());
    document.getElementById('goToolsBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('goUrgencyBtn')?.addEventListener('click', () => this.showUrgency());
    document.getElementById('goCompareBtn')?.addEventListener('click', () => this.showCompare());
    document.getElementById('backCompareBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('clearCompareBtn')?.addEventListener('click', () => this.clearCompare());
    document.getElementById('backUrgencyBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('backToolsBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('backRerMerBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backToxicologiaBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backFluidoterapiaBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backUnidadesBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backPredisposicionesBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('backBcsBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backFlashcardsBtn')?.addEventListener('click', () => this.showDictionary());
    document.getElementById('backEmergenciasLatamBtn')?.addEventListener('click', () => this.showUrgency());
    document.getElementById('backTriajeBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backLaboratorioBtn')?.addEventListener('click', () => this.showTools());
    document.getElementById('backChangelogBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('footerChangelogBtn')?.addEventListener('click', () => this.showChangelog());
    document.getElementById('welcomeChangelogBtn')?.addEventListener('click', () => this.showChangelog());
    document.getElementById('clearHistoryBtn')?.addEventListener('click', () => this.clearRecentHistory());
    document.getElementById('clearFavoritesBtn')?.addEventListener('click', () => this.clearFavorites());
    document.getElementById('changeCategoryBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('btnExploreAll')?.addEventListener('click', () => this.enterBrowse('todos'));
    document.querySelector('.logo')?.addEventListener('click', () => this.goWelcome());
    document.querySelector('.logo')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        this.goWelcome();
      }
    });
    document.querySelector('[data-focus-welcome-search]')?.addEventListener('click', () => {
      searchInputWelcome?.scrollIntoView({ behavior: 'smooth', block: 'center' });
      searchInputWelcome?.focus();
    });

    const openDictionary = () => this.showDictionary();
    document.getElementById('openDictionaryCard')?.addEventListener('click', openDictionary);
    document.getElementById('openDictionaryCard')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openDictionary();
      }
    });
    const openTools = () => this.showTools();
    document.getElementById('openToolsCard')?.addEventListener('click', openTools);
    document.getElementById('openToolsCard')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openTools();
      }
    });
    const openPredisposiciones = () => this.showPredisposiciones();
    document.getElementById('openPredisposicionesCard')?.addEventListener('click', openPredisposiciones);
    document.getElementById('openPredisposicionesCard')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        openPredisposiciones();
      }
    });
    document.getElementById('predisSearchInput')?.addEventListener('input', (e) => {
      this.predisposicionesQuery = e.target.value.toLowerCase().trim();
      this.renderPredisposiciones();
    });
    document.getElementById('toxicologiaSearchInput')?.addEventListener('input', (e) => {
      this.toxicologyQuery = e.target.value.toLowerCase().trim();
      this.renderToxicologia();
    });
    document.getElementById('backDictionaryBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('dictionarySearchInput')?.addEventListener('input', (e) => {
      this.dictionaryQuery = e.target.value.toLowerCase().trim();
      this.currentDictionaryTerm = null;
      this.renderDictionary();
      if (!this.isRoutingFromHash) this.updateHash('#glosario');
      this.updatePageMeta({
        title: 'Glosario médico — Atlas Animal',
        description: this.dictionaryData?.introduccion || this.DEFAULT_META.description,
        image: 'images/og-image.svg',
        url: this.pageUrl('#glosario'),
        type: 'website'
      });
      this.clearJsonLd();
    });

    document.addEventListener('keydown', (e) => {
      if ((e.ctrlKey || e.metaKey) && e.key.toLowerCase() === 'k') {
        e.preventDefault();
        const activeInput = this.currentView === 'welcome' ? searchInputWelcome : searchInput;
        if (!activeInput) return;
        if (this.currentView === 'welcome') this.showView('welcome');
        else this.showView('home');
        activeInput.focus();
        activeInput.select();
      }
    });

    document.querySelectorAll('.filter-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        document.querySelectorAll('.filter-btn').forEach(b => b.classList.remove('active'));
        btn.classList.add('active');
        this.currentSize = btn.dataset.size;
        if (this.searchQuery) this.clearSearch(false);
        this.renderHome();
      });
    });

    document.getElementById('backBtn').addEventListener('click', () => {
      this.showView('home');
      this.updateHash(this.browseRoute());
      this.exportE2EState();
    });
    document.getElementById('backDiseaseBtn').addEventListener('click', () => {
      if (this.currentBreed) this.showBreedDetail(this.currentBreed);
    });

    window.addEventListener('hashchange', () => this.openRouteFromHash());
  },

  getAllBreeds() {
    const breeds = [];
    this.data.animales.forEach(animal => {
      ['pequena', 'mediana', 'grande'].forEach(size => {
        (animal.razas[size] || []).forEach(raza => {
          breeds.push({ ...raza, animalId: animal.id, animalNombre: animal.nombre, animalIcono: animal.icono, tamano: size });
        });
      });
    });
    return breeds;
  },

  getFilteredBreeds() {
    let breeds = this.getAllBreeds();
    if (this.currentAnimal !== 'todos') {
      breeds = breeds.filter(b => b.animalId === this.currentAnimal);
    }
    if (this.currentSize !== 'todos') {
      breeds = breeds.filter(b => b.tamano === this.currentSize);
    }
    if (this.currentRegion !== 'todos') {
      breeds = breeds.filter(b => this.matchesRegionFilter(b));
    }
    return breeds;
  },

  getBreedRegion(breed) {
    return breed.region || this.inferRegion(breed.origen);
  },

  matchesRegionFilter(breed) {
    const region = this.getBreedRegion(breed);
    if (!region) return false;
    if (this.currentRegion === region) return true;
    const macroCountries = this.REGION_MACRO_GROUPS[this.currentRegion];
    return macroCountries ? macroCountries.includes(region) : false;
  },

  inferRegion(origen) {
    if (!origen) return null;
    const text = String(origen).toLowerCase();
    const map = {
      colombia: 'Colombia',
      méxico: 'México',
      mexico: 'México',
      argentina: 'Argentina',
      chile: 'Chile',
      perú: 'Perú',
      peru: 'Perú',
      brasil: 'Brasil',
      ecuador: 'Ecuador',
      venezuela: 'Venezuela',
      bolivia: 'Bolivia',
      uruguay: 'Uruguay',
      paraguay: 'Paraguay',
      centroamérica: 'Centroamérica',
      centroamerica: 'Centroamérica',
      cuba: 'Cuba',
      'república dominicana': 'República Dominicana',
      'republica dominicana': 'República Dominicana',
      'costa rica': 'Costa Rica',
      panamá: 'Panamá',
      panama: 'Panamá',
      guatemala: 'Guatemala',
      honduras: 'Honduras',
      españa: 'España',
      spain: 'España',
      francia: 'Francia',
      alemania: 'Alemania',
      italia: 'Italia',
      'reino unido': 'Reino Unido',
      inglaterra: 'Reino Unido',
      estados unidos: 'Estados Unidos',
      usa: 'Estados Unidos',
      canadá: 'Canadá',
      canada: 'Canadá',
      australia: 'Australia',
      china: 'China',
      japón: 'Japón',
      japon: 'Japón'
    };
    return Object.entries(map).find(([key]) => text.includes(key))?.[1] || null;
  },

  getAvailableRegions() {
    const countries = new Set();
    this.getAllBreeds().forEach(b => {
      const region = this.getBreedRegion(b);
      if (region) countries.add(region);
    });
    const macros = Object.keys(this.REGION_MACRO_GROUPS).filter(macro =>
      this.REGION_MACRO_GROUPS[macro].some(c => countries.has(c))
    );
    return { macros, countries: Array.from(countries).sort((a, b) => a.localeCompare(b, 'es')) };
  },

  renderRegionFilters() {
    const container = document.getElementById('regionFilters');
    if (!container) return;
    const { macros, countries } = this.getAvailableRegions();
    const items = [{ id: 'todos', label: this.t('region.all'), group: 'macro' }];
    macros.forEach(m => items.push({ id: m, label: this.t(`region.macro.${m}`) || m, group: 'macro' }));
    countries.forEach(c => items.push({ id: c, label: c, group: 'country' }));

    let html = '';
    let lastGroup = null;
    items.forEach(item => {
      if (item.group === 'country' && lastGroup !== 'country') {
        html += `<li class="region-filter-heading" aria-hidden="true">${this.esc(this.t('region.countries'))}</li>`;
        lastGroup = 'country';
      } else if (item.group === 'macro') {
        lastGroup = 'macro';
      }
      html += `
      <li>
        <button type="button" class="region-btn ${this.currentRegion === item.id ? 'active' : ''}" data-region="${this.esc(item.id)}">
          ${this.esc(item.label)}
        </button>
      </li>`;
    });
    container.innerHTML = html;
    container.querySelectorAll('.region-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        this.currentRegion = btn.dataset.region;
        this.renderRegionFilters();
        this.renderHome();
      });
    });
  },

  normalizeSearch(text) {
    return String(text || '')
      .toLowerCase()
      .normalize('NFD')
      .replace(/[\u0300-\u036f]/g, '');
  },

  levenshtein(a, b) {
    if (a === b) return 0;
    const m = a.length;
    const n = b.length;
    if (m === 0) return n;
    if (n === 0) return m;
    let prev = Array.from({ length: n + 1 }, (_, i) => i);
    for (let i = 1; i <= m; i++) {
      const curr = [i];
      for (let j = 1; j <= n; j++) {
        const cost = a[i - 1] === b[j - 1] ? 0 : 1;
        curr[j] = Math.min(prev[j] + 1, curr[j - 1] + 1, prev[j - 1] + cost);
      }
      prev = curr;
    }
    return prev[n];
  },

  findSynonymGroupFor(query) {
    const norm = this.normalizeSearch(query);
    if (!norm || !this.synonymGroups?.length) return null;
    for (const group of this.synonymGroups) {
      if (group.some(term => term === norm || term.includes(norm) || norm.includes(term))) {
        return group;
      }
    }
    return null;
  },

  matchesTypo(normText, normQuery) {
    if (normQuery.length < 4) return null;
    const maxDist = normQuery.length <= 5 ? 1 : 2;
    const words = normText.split(/[^a-z0-9]+/).filter(w => w.length >= 3);
    for (const word of words) {
      if (Math.abs(word.length - normQuery.length) > maxDist) continue;
      const dist = this.levenshtein(word, normQuery);
      if (dist > 0 && dist <= maxDist) return { word, distance: dist };
    }
    return null;
  },

  matchesSearch(text, query) {
    if (!query) return { matched: true, type: 'direct' };
    const normText = this.normalizeSearch(text);
    const normQuery = this.normalizeSearch(query);
    if (!normQuery) return { matched: false };

    if (normText.includes(normQuery)) {
      return { matched: true, type: 'direct' };
    }

    const group = this.findSynonymGroupFor(normQuery);
    if (group) {
      for (const term of group) {
        if (term !== normQuery && normText.includes(term)) {
          return { matched: true, type: 'synonym', term: query };
        }
      }
    }

    const typo = this.matchesTypo(normText, normQuery);
    if (typo) {
      return { matched: true, type: 'typo', term: typo.word };
    }

    return { matched: false };
  },

  nameMatches(value, query) {
    return this.matchesSearch(value, query).matched;
  },

  formatSearchHint(key, term) {
    return this.t(key).replace('{term}', term || '');
  },

  renderSearchMatchHint(match) {
    if (!match || match.type === 'direct') return '';
    if (match.type === 'synonym') {
      return `<span class="search-match-hint">${this.esc(this.formatSearchHint('search.synonym_match', match.term))}</span>`;
    }
    if (match.type === 'typo') {
      return `<span class="search-match-hint">${this.esc(this.formatSearchHint('search.typo_match', match.term))}</span>`;
    }
    return '';
  },

  routePart(value) {
    return encodeURIComponent(String(value || '').trim());
  },

  diseaseSlug(disease) {
    return this.normalizeSearch(disease?.nombre || '')
      .replace(/[^a-z0-9]+/g, '-')
      .replace(/^-+|-+$/g, '');
  },

  browseRoute() {
    return this.currentAnimal === 'todos' ? '#razas' : `#animal/${this.routePart(this.currentAnimal)}`;
  },

  breedRoute(breed) {
    return `#raza/${this.routePart(breed.animalId)}/${this.routePart(breed.id)}`;
  },

  diseaseRoute(breed, disease) {
    return `${this.breedRoute(breed).replace('#raza/', '#enfermedad/')}/${this.routePart(this.diseaseSlug(disease))}`;
  },

  updateHash(hash) {
    if (this.isRoutingFromHash || window.location.hash === hash) return;
    window.history.pushState(null, '', hash);
  },

  clearHash() {
    if (this.isRoutingFromHash || !window.location.hash) return;
    window.history.pushState(null, '', window.location.pathname + window.location.search);
  },

  findBreed(animalId, breedId) {
    return this.getAllBreeds().find(b => b.animalId === animalId && b.id === breedId)
      || this.getAllBreeds().find(b => b.id === breedId);
  },

  findDisease(breed, diseaseSlug) {
    return (breed?.enfermedades || []).find(d => this.diseaseSlug(d) === diseaseSlug);
  },

  async openRouteFromHash() {
    const hash = decodeURIComponent(window.location.hash || '').replace(/^#/, '');
    if (!hash) return false;

    const parts = hash.split('/').filter(Boolean);
    this.isRoutingFromHash = true;
    try {
      if (parts[0] === 'urgencias') {
        this.showUrgency({ updateHash: false });
        return true;
      }

      if (parts[0] === 'herramientas') {
        this.showTools({ updateHash: false });
        return true;
      }

      if (parts[0] === 'laboratorio') {
        this.showLaboratorio({ updateHash: false });
        return true;
      }

      if (parts[0] === 'changelog') {
        this.showChangelog({ updateHash: false });
        return true;
      }

      if (parts[0] === 'rer-mer') {
        this.showRerMer({ updateHash: false });
        return true;
      }

      if (parts[0] === 'toxicologia') {
        this.showToxicologia({ updateHash: false });
        return true;
      }

      if (parts[0] === 'fluidoterapia') {
        this.showFluidoterapia({ updateHash: false });
        return true;
      }

      if (parts[0] === 'unidades') {
        this.showUnidades({ updateHash: false });
        return true;
      }

      if (parts[0] === 'predisposiciones') {
        this.showPredisposiciones({ updateHash: false });
        return true;
      }

      if (parts[0] === 'bcs') {
        this.showBcs({ updateHash: false });
        return true;
      }

      if (parts[0] === 'flashcards') {
        this.showFlashcards({ updateHash: false });
        return true;
      }

      if (parts[0] === 'emergencias-latam') {
        this.showEmergenciasLatam({ updateHash: false });
        return true;
      }

      if (parts[0] === 'triaje') {
        this.showTriaje({ updateHash: false });
        return true;
      }

      if (parts[0] === 'comparar') {
        this.showCompare({ updateHash: false });
        return true;
      }

      if (parts[0] === 'glosario') {
        if (parts[1]) {
          const term = this.findDictionaryTerm(parts[1]);
          if (term) {
            this.showDictionaryTerm(term, { updateHash: false });
            return true;
          }
        }
        this.showDictionary({ updateHash: false, focus: false });
        return true;
      }

      if (parts[0] === 'razas') {
        this.enterBrowse('todos', { updateHash: false });
        return true;
      }

      if (parts[0] === 'animal' && parts[1]) {
        this.enterBrowse(parts[1], { updateHash: false });
        return true;
      }

      if (parts[0] === 'raza' && parts[1] && parts[2]) {
        await this.loadChunk(parts[1]);
        const breed = this.findBreed(parts[1], parts[2]);
        if (breed) {
          this.showBreedDetail(breed, { updateHash: false });
          return true;
        }
      }

      if (parts[0] === 'enfermedad' && parts[1] && parts[2] && parts[3]) {
        await this.loadChunk(parts[1]);
        const breed = this.findBreed(parts[1], parts[2]);
        const disease = this.findDisease(breed, parts[3]);
        if (breed && disease) {
          this.showDiseaseDetail(breed, disease, { updateHash: false });
          return true;
        }
      }
    } finally {
      this.isRoutingFromHash = false;
    }

    this.goWelcome({ updateHash: false });
    return false;
  },

  getGlobalSearchResultsFromIndex() {
    const breeds = [];
    const diseases = [];
    const glossary = [];
    const seenDiseases = new Set();
    const seenGlossary = new Set();
    const indexBreeds = this.searchIndex?.breeds || [];

    indexBreeds.forEach(entry => {
      const nameMatch = this.matchesSearch(entry.nombre, this.searchQuery);
      const idMatch = this.matchesSearch(entry.id, this.searchQuery);
      if (nameMatch.matched || idMatch.matched) {
        const animal = this.data.animales.find(a => a.id === entry.animalId);
        const stub = {
          id: entry.id,
          nombre: entry.nombre,
          animalId: entry.animalId,
          animalNombre: animal?.nombre || entry.animalId,
          animalIcono: animal?.icono || '🐾',
          enfermedades: (entry.diseases || []).map(n => ({ nombre: n }))
        };
        breeds.push({ breed: stub, match: nameMatch.matched ? nameMatch : idMatch });
      }
      (entry.diseases || []).forEach(diseaseName => {
        const match = this.matchesSearch(diseaseName, this.searchQuery);
        if (!match.matched) return;
        const key = `${entry.animalId}:${entry.id}:${diseaseName}`;
        if (seenDiseases.has(key)) return;
        seenDiseases.add(key);
        const animal = this.data.animales.find(a => a.id === entry.animalId);
        const stubBreed = {
          id: entry.id,
          nombre: entry.nombre,
          animalId: entry.animalId,
          animalNombre: animal?.nombre || entry.animalId,
          enfermedades: [{ nombre: diseaseName }]
        };
        diseases.push({ disease: { nombre: diseaseName }, breed: stubBreed, match });
      });
    });

    this.getDictionaryTerms().forEach(term => {
      const haystack = [term.termino, term.definicion, term.ejemplo, term.categoriaNombre].join(' ');
      const match = this.matchesSearch(haystack, this.searchQuery);
      if (!match.matched) return;
      if (seenGlossary.has(term.termino)) return;
      seenGlossary.add(term.termino);
      glossary.push({ term, match });
    });

    return { breeds, diseases, glossary };
  },

  getGlobalSearchResults() {
    if (!this.isAllChunksLoaded()) {
      return this.getGlobalSearchResultsFromIndex();
    }
    const breeds = [];
    const diseases = [];
    const glossary = [];
    const seenDiseases = new Set();
    const seenGlossary = new Set();

    this.getAllBreeds().forEach(breed => {
      const nameMatch = this.matchesSearch(breed.nombre, this.searchQuery);
      const idMatch = this.matchesSearch(breed.id, this.searchQuery);
      if (nameMatch.matched || idMatch.matched) {
        breeds.push({ breed, match: nameMatch.matched ? nameMatch : idMatch });
      }

      (breed.enfermedades || []).forEach(disease => {
        const match = this.matchesSearch(disease.nombre, this.searchQuery);
        if (!match.matched) return;
        const key = `${breed.animalId}:${breed.id}:${disease.nombre}`;
        if (seenDiseases.has(key)) return;
        seenDiseases.add(key);
        diseases.push({ disease, breed, match });
      });
    });

    this.getDictionaryTerms().forEach(term => {
      const haystack = [
        term.termino,
        term.definicion,
        term.ejemplo,
        term.categoriaNombre
      ].join(' ');
      const match = this.matchesSearch(haystack, this.searchQuery);
      if (!match.matched) return;
      if (seenGlossary.has(term.termino)) return;
      seenGlossary.add(term.termino);
      glossary.push({ term, match });
    });

    return { breeds, diseases, glossary };
  },

  renderHome() {
    if (this.searchQuery) {
      this.renderSearchResults();
      this.exportE2EState();
      return;
    }
    document.getElementById('searchResults').hidden = true;
    document.getElementById('browseSection').hidden = false;
    this.renderBreeds();
    this.updateResultsTitle();
    this.exportE2EState();
  },

  renderSearchResults() {
    const { breeds, diseases, glossary } = this.getGlobalSearchResults();
    const total = breeds.length + diseases.length + glossary.length;
    const container = document.getElementById('searchResults');
    const browse = document.getElementById('browseSection');

    browse.hidden = true;
    container.hidden = false;
    document.getElementById('resultsCount').textContent = breeds.length || total;

    const hint = document.getElementById('searchHint');
    if (hint) {
      hint.textContent = total
        ? this.formatSearchHint('search.results_summary', '')
          .replace('{total}', total)
          .replace('{breeds}', breeds.length)
          .replace('{diseases}', diseases.length)
          .replace('{glossary}', glossary.length)
        : this.t('search.no_matches');
    }

    if (!total) {
      container.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🔍</div>
          <p>${this.esc(this.t('search.no_results').replace('{query}', this.searchQuery))}</p>
        </div>`;
      return;
    }

    container.innerHTML = `
      <div class="search-results-header">
        <h3>${this.esc(this.t('search.results_for').replace('{query}', this.searchQuery))}</h3>
        <span class="badge">${total}</span>
      </div>
      ${breeds.length ? `
        <section class="search-section">
          <h4>🐾 ${this.esc(this.t('search.breeds_section'))} <span class="search-section-count">${breeds.length}</span></h4>
          <div class="search-breed-grid">
            ${breeds.map(({ breed, match }) => `
              <article class="breed-card search-hit-card" data-key="${breed.animalId}:${breed.id}">
                ${this.renderBreedImage(breed, 'breed-card-img')}
                <div class="breed-card-body">
                  <div class="breed-card-tags">
                    <span class="tag tag-${breed.tamano}">${this.sizeLabel(breed.tamano)}</span>
                    <span class="tag tag-animal">${breed.animalIcono} ${breed.animalNombre}</span>
                  </div>
                  <h4>${this.esc(breed.nombre)}</h4>
                  ${this.renderSearchMatchHint(match)}
                  <p>${this.esc(breed.descripcion)}</p>
                  <div class="breed-card-footer">
                    <span>${breed.enfermedades?.length || 0} enfermedades</span>
                    <span>Ver raza →</span>
                  </div>
                </div>
              </article>
            `).join('')}
          </div>
        </section>
      ` : ''}
      ${diseases.length ? `
        <section class="search-section">
          <h4>🩺 ${this.esc(this.t('search.diseases_section'))} <span class="search-section-count">${diseases.length}</span></h4>
          <div class="search-disease-list">
            ${diseases.map(({ disease, breed, match }, index) => `
              <button type="button" class="search-disease-item" data-index="${index}">
                <span class="severity severity-${disease.gravedad || 'moderada'}">${(disease.gravedad || 'moderada').toUpperCase()}</span>
                <span class="search-disease-name">${this.esc(disease.nombre)}</span>
                ${this.renderSearchMatchHint(match)}
                <span class="search-disease-breed">${breed.animalIcono} ${this.esc(breed.nombre)} · ${this.esc(breed.animalNombre)}</span>
              </button>
            `).join('')}
          </div>
        </section>
      ` : ''}
      ${glossary.length ? `
        <section class="search-section">
          <h4>📚 ${this.esc(this.t('search.glossary_section'))} <span class="search-section-count">${glossary.length}</span></h4>
          <div class="search-glossary-list">
            ${glossary.map(({ term, match }, index) => `
              <button type="button" class="search-glossary-item" data-index="${index}">
                <span class="search-glossary-icon">${term.categoriaIcono || '📖'}</span>
                <span class="search-glossary-name">${this.esc(term.termino)}</span>
                ${this.renderSearchMatchHint(match)}
                <span class="search-glossary-category">${this.esc(term.categoriaNombre)}</span>
              </button>
            `).join('')}
          </div>
        </section>
      ` : ''}
    `;

    container.querySelectorAll('.search-hit-card').forEach(card => {
      card.addEventListener('click', async () => {
        const [animalId, breedId] = card.dataset.key.split(':');
        await this.loadChunk(animalId);
        const hit = breeds.find(b => b.breed.animalId === animalId && b.breed.id === breedId);
        const breed = hit ? this.findBreed(animalId, breedId) || hit.breed : null;
        if (breed) this.showBreedDetail(breed);
      });
    });

    container.querySelectorAll('.search-disease-item').forEach(item => {
      item.addEventListener('click', async () => {
        const match = diseases[parseInt(item.dataset.index, 10)];
        if (!match) return;
        await this.loadChunk(match.breed.animalId);
        const breed = this.findBreed(match.breed.animalId, match.breed.id) || match.breed;
        const disease = this.findDiseaseInBreed(breed, match.disease.nombre) || match.disease;
        if (breed && disease) this.showDiseaseDetail(breed, disease);
      });
    });

    container.querySelectorAll('.search-glossary-item').forEach(item => {
      item.addEventListener('click', () => {
        const hit = glossary[parseInt(item.dataset.index, 10)];
        if (hit) this.showDictionaryTerm(hit.term);
      });
    });
  },

  clearSearch(focus = true) {
    const searchInput = document.getElementById('searchInput');
    const searchInputWelcome = document.getElementById('searchInputWelcome');
    if (searchInput) searchInput.value = '';
    if (searchInputWelcome) searchInputWelcome.value = '';
    this.searchQuery = '';
    const searchClearBtn = document.getElementById('searchClearBtn');
    if (searchClearBtn) searchClearBtn.hidden = true;
    if (this.currentView === 'detail' || this.currentView === 'disease') return;
    if (this.currentView === 'welcome') {
      if (focus && searchInputWelcome) searchInputWelcome.focus();
      this.exportE2EState();
      return;
    }
    this.renderHome();
    if (focus && searchInput) searchInput.focus();
  },

  async enterBrowse(animalId, options = {}) {
    if (animalId !== 'todos') {
      await this.loadChunk(animalId);
    } else if (!this.isAllChunksLoaded()) {
      void this.preloadAllChunks();
    }
    this.currentAnimal = animalId;
    this.currentSize = 'todos';
    document.querySelectorAll('.filter-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.size === 'todos');
    });
    document.querySelectorAll('.nav-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.animal === animalId);
    });
    if (this.searchQuery) this.clearSearch(false);
    this.showView('home');
    this.renderHome();
    if (options.updateHash !== false) this.updateHash(this.browseRoute());
  },

  goWelcome(options = {}) {
    this.currentAnimal = 'todos';
    this.currentSize = 'todos';
    this.currentRegion = 'todos';
    this.searchQuery = '';
    this.dictionaryQuery = '';
    this.dictionaryCategory = 'todos';
    const searchInput = document.getElementById('searchInput');
    const searchInputWelcome = document.getElementById('searchInputWelcome');
    const dictionarySearchInput = document.getElementById('dictionarySearchInput');
    if (searchInput) searchInput.value = '';
    if (searchInputWelcome) searchInputWelcome.value = '';
    if (dictionarySearchInput) dictionarySearchInput.value = '';
    const searchClearBtn = document.getElementById('searchClearBtn');
    if (searchClearBtn) searchClearBtn.hidden = true;
    document.querySelectorAll('.filter-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.size === 'todos');
    });
    document.querySelectorAll('.nav-btn').forEach(b => {
      b.classList.toggle('active', b.dataset.animal === 'todos');
    });
    this.showView('welcome');
    if (options.updateHash !== false) this.clearHash();
    this.resetPageMeta();
    this.exportE2EState();
  },

  updateSidebar() {
    const onBrowse = this.currentView === 'home' && !this.searchQuery;
    const sidebar = document.getElementById('appSidebar');
    const layout = document.getElementById('appLayout');
    const animalSection = document.getElementById('animalNavSection');
    if (sidebar) sidebar.hidden = !onBrowse;
    if (layout) layout.classList.toggle('layout--full', !onBrowse);

    const sizeSection = document.getElementById('sizeFiltersSection');
    const browseContext = document.getElementById('browseContext');
    const chip = document.getElementById('selectedAnimalChip');

    if (animalSection) animalSection.hidden = true;

    if (sizeSection) sizeSection.hidden = !onBrowse;

    const regionSection = document.getElementById('regionFiltersSection');
    if (regionSection) {
      const { countries } = this.getAvailableRegions();
      const showRegions = onBrowse && countries.length > 0;
      regionSection.hidden = !showRegions;
      if (showRegions) this.renderRegionFilters();
    }

    if (browseContext) {
      const showContext = onBrowse && this.currentAnimal !== 'todos';
      browseContext.hidden = !showContext;
      if (showContext && chip) {
        const animal = this.data.animales.find(a => a.id === this.currentAnimal);
        if (animal) {
          chip.innerHTML = `<span class="chip-icon">${animal.icono}</span><span>${animal.nombre}</span>`;
        }
      }
    }
  },

  renderWelcome() {
    const stats = this.getCatalogStats();
    const terms = this.dictionaryData?.total_terminos || this.getDictionaryTerms().length;
    const statsEl = document.getElementById('welcomeStats');
    if (statsEl) {
      statsEl.innerHTML = `
        <div class="welcome-stat"><span class="welcome-stat-value">${this.data.animales.length}</span><span class="welcome-stat-label">${this.esc(this.t('welcome.stat_animals'))}</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${stats.breeds}</span><span class="welcome-stat-label">${this.esc(this.t('welcome.stat_breeds'))}</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${stats.diseases}</span><span class="welcome-stat-label">${this.esc(this.t('welcome.stat_diseases'))}</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${terms}</span><span class="welcome-stat-label">${this.esc(this.t('welcome.stat_glossary'))}</span></div>
      `;
    }
  },

  renderNav() {
    const nav = document.getElementById('animalNav');
    if (!nav) return;
    const items = [{ id: 'todos', nombre: 'Todos', icono: '🌿' }, ...this.data.animales];
    nav.innerHTML = items.map(a => `
      <li><button class="nav-btn ${a.id === this.currentAnimal ? 'active' : ''}" data-animal="${a.id}">
        <span>${a.icono}</span> ${a.nombre}
      </button></li>
    `).join('');
    nav.querySelectorAll('.nav-btn').forEach(btn => {
      btn.addEventListener('click', () => this.enterBrowse(btn.dataset.animal));
    });
  },

  renderStats() {
    const stats = this.getCatalogStats();
    document.getElementById('statsContent').innerHTML = `
      <div class="stat-item"><span>${this.esc(this.t('welcome.stat_animals'))}</span><span class="stat-value">${this.data.animales.length}</span></div>
      <div class="stat-item"><span>${this.esc(this.t('welcome.stat_breeds'))}</span><span class="stat-value">${stats.breeds}</span></div>
      <div class="stat-item"><span>${this.esc(this.t('welcome.stat_diseases'))}</span><span class="stat-value">${stats.diseases}</span></div>
    `;
  },

  renderCategoryCards() {
    const grid = document.getElementById('welcomeCategoryCards');
    if (!grid) return;
    grid.innerHTML = this.data.animales.map(a => {
      const meta = this.manifest?.animales?.find(m => m.id === a.id);
      const count = meta?.total_breeds ?? ['pequena', 'mediana', 'grande'].reduce((n, s) => n + (a.razas[s]?.length || 0), 0);
      return `
        <div class="category-card" data-animal="${a.id}">
          <div class="cat-icon">${a.icono}</div>
          <h4>${a.nombre}</h4>
          <span>${count} razas</span>
        </div>`;
    }).join('');
    grid.querySelectorAll('.category-card').forEach(card => {
      card.addEventListener('click', () => this.enterBrowse(card.dataset.animal));
    });
  },

  getDictionaryTerms() {
    if (!this.dictionaryData?.categorias) return [];
    return this.dictionaryData.categorias.flatMap(cat =>
      (cat.terminos || []).map(term => ({
        ...term,
        categoriaId: cat.id,
        categoriaNombre: cat.nombre,
        categoriaIcono: cat.icono
      }))
    );
  },

  termMatchesQuery(term, query) {
    if (!query) return true;
    const haystack = [
      term.termino,
      term.definicion,
      term.ejemplo,
      term.categoriaNombre
    ].join(' ');
    return this.matchesSearch(haystack, query).matched;
  },

  renderDictionaryFilters() {
    const container = document.getElementById('dictionaryCategoryFilters');
    if (!container || !this.dictionaryData) return;
    const categories = [
      { id: 'todos', nombre: 'Todas', icono: '📚' },
      ...this.dictionaryData.categorias.map(c => ({ id: c.id, nombre: c.nombre, icono: c.icono }))
    ];
    container.innerHTML = categories.map(cat => `
      <button type="button"
        class="dictionary-filter-btn ${this.dictionaryCategory === cat.id ? 'active' : ''}"
        data-category="${cat.id}">
        <span>${cat.icono}</span> ${this.esc(cat.nombre)}
      </button>
    `).join('');
    container.querySelectorAll('.dictionary-filter-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        this.dictionaryCategory = btn.dataset.category;
        this.renderDictionary();
      });
    });
  },

  renderDictionary() {
    const title = document.getElementById('dictionaryTitle');
    const intro = document.getElementById('dictionaryIntro');
    const stats = document.getElementById('dictionaryStats');
    const list = document.getElementById('dictionaryList');

    if (!this.dictionaryData) {
      if (intro) intro.textContent = 'No se pudo cargar el diccionario médico.';
      if (list) list.innerHTML = '<div class="empty-state"><div class="empty-icon">⚠️</div><p>Glosario no disponible.</p></div>';
      return;
    }

    if (title) title.textContent = this.dictionaryData.titulo || 'Diccionario de términos médicos';
    if (intro) intro.textContent = this.dictionaryData.introduccion || '';

    this.renderDictionaryFilters();

    const filteredCategories = this.dictionaryData.categorias
      .filter(cat => this.dictionaryCategory === 'todos' || cat.id === this.dictionaryCategory)
      .map(cat => ({
        ...cat,
        terminos: (cat.terminos || []).filter(term => this.termMatchesQuery(term, this.dictionaryQuery))
      }))
      .filter(cat => cat.terminos.length > 0);

    const totalVisible = filteredCategories.reduce((n, cat) => n + cat.terminos.length, 0);
    const totalAll = this.dictionaryData.total_terminos || this.getDictionaryTerms().length;

    if (stats) {
      stats.innerHTML = `
        <span class="dictionary-stat"><strong>${totalVisible}</strong> término(s) mostrados</span>
        <span class="dictionary-stat-muted">de ${totalAll} en el glosario</span>
        <button type="button" class="dictionary-study-btn" id="openFlashcardsFromDict">${this.esc(this.t('flash.open'))} →</button>
        <button type="button" class="dictionary-study-btn dictionary-lab-btn" id="openLabFromDict">${this.esc(this.t('lab.open_from_dict'))}</button>
      `;
      stats.querySelector('#openFlashcardsFromDict')?.addEventListener('click', () => this.showFlashcards());
      stats.querySelector('#openLabFromDict')?.addEventListener('click', () => this.showLaboratorio());
    }

    if (!list) return;

    if (!totalVisible) {
      list.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🔍</div>
          <p>No hay términos que coincidan con <strong>“${this.esc(this.dictionaryQuery)}”</strong>.</p>
        </div>`;
      return;
    }

    list.innerHTML = filteredCategories.map(cat => `
      <section class="dictionary-category">
        <header class="dictionary-category-header">
          <span class="dictionary-category-icon">${cat.icono}</span>
          <div>
            <h3>${this.esc(cat.nombre)}</h3>
            <p>${this.esc(cat.descripcion)}</p>
          </div>
          <span class="badge">${cat.terminos.length}</span>
        </header>
        <div class="dictionary-term-grid">
          ${cat.terminos.map(term => `
            <article class="dictionary-term-card${this.currentDictionaryTerm?.termino === term.termino ? ' dictionary-term-card--active' : ''}"
              data-term-slug="${this.esc(this.termSlug(term.termino))}" role="button" tabindex="0"
              aria-label="${this.esc(term.termino)}">
              <h4>${this.esc(term.termino)}</h4>
              <p class="dictionary-definition">${this.esc(term.definicion)}</p>
              ${term.ejemplo ? `<p class="dictionary-example"><span>Ejemplo:</span> ${this.esc(term.ejemplo)}</p>` : ''}
              ${this.renderTermDiseaseLinks(term)}
            </article>
          `).join('')}
        </div>
      </section>
    `).join('');

    this.bindTermDiseaseLinks(list);
    this.bindDictionaryTermCards(list);
  },

  renderTermDiseaseLinks(term) {
    const links = this.crossLinksForTerm(term.termino);
    if (!links?.ejemplos?.length) return '';
    const chips = links.ejemplos.map(ej => `
      <button type="button" class="cross-link-chip dictionary-term-link"
        data-animal="${this.esc(ej.animalId)}"
        data-breed="${this.esc(ej.breedId)}"
        data-disease="${this.esc(ej.nombre)}">
        <span class="cross-link-dot severity-${ej.gravedad || 'moderada'}"></span>
        ${this.esc(ej.nombre)}
      </button>
    `).join('');
    const extra = links.total > links.ejemplos.length
      ? `<span class="cross-link-more">+${links.total - links.ejemplos.length} más</span>`
      : '';
    return `
      <div class="cross-link-block">
        <span class="cross-link-label">🩺 Enfermedades relacionadas (${links.total})</span>
        <div class="cross-link-chips">${chips}${extra}</div>
      </div>`;
  },

  bindTermDiseaseLinks(container) {
    if (!container) return;
    container.querySelectorAll('.dictionary-term-link').forEach(chip => {
      chip.addEventListener('click', () => {
        this.openDiseaseFromLink(chip.dataset.animal, chip.dataset.breed, chip.dataset.disease);
      });
    });
  },

  bindDictionaryTermCards(container) {
    if (!container) return;
    container.querySelectorAll('.dictionary-term-card[data-term-slug]').forEach(card => {
      const open = () => {
        const term = this.findDictionaryTerm(card.dataset.termSlug);
        if (term) this.showDictionaryTerm(term);
      };
      card.addEventListener('click', (e) => {
        if (e.target.closest('.dictionary-term-link')) return;
        open();
      });
      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          open();
        }
      });
    });
  },

  showDictionary(options = {}) {
    if (!options.keepTerm) this.currentDictionaryTerm = null;
    if (this.searchQuery) this.clearSearch(false);
    this.renderDictionary();
    this.showView('dictionary');
    if (options.updateHash !== false) this.updateHash('#glosario');
    if (!this.currentDictionaryTerm) {
      this.updatePageMeta({
        title: 'Glosario médico — Atlas Animal',
        description: this.dictionaryData?.introduccion || this.DEFAULT_META.description,
        image: 'images/og-image.svg',
        url: this.pageUrl('#glosario'),
        type: 'website'
      });
      this.clearJsonLd();
    }
    this.exportE2EState();
    if (options.focus !== false) document.getElementById('dictionarySearchInput')?.focus();
  },

  showDictionaryTerm(term, options = {}) {
    this.currentDictionaryTerm = term;
    this.dictionaryCategory = 'todos';
    this.dictionaryQuery = this.normalizeSearch(term.termino);
    const input = document.getElementById('dictionarySearchInput');
    if (input) input.value = term.termino;
    if (this.searchQuery) this.clearSearch(false);
    this.renderDictionary();
    this.showView('dictionary');
    if (options.updateHash !== false) this.updateHash(this.termRoute(term));
    this.updatePageMeta({
      title: `${term.termino} — Glosario — Atlas Animal`,
      description: term.definicion,
      image: 'images/og-image.svg',
      imageAlt: `Término del glosario: ${term.termino}`,
      url: this.pageUrl(this.termRoute(term)),
      type: 'article'
    });
    this.setJsonLd(this.jsonLdForTerm(term));
    this.exportE2EState();
    requestAnimationFrame(() => {
      document.querySelector('.dictionary-term-card--active')?.scrollIntoView({ behavior: 'smooth', block: 'nearest' });
    });
  },

  showUrgency(options = {}) {
    this.renderUrgency();
    this.showView('urgency');
    if (options.updateHash !== false) this.updateHash('#urgencias');
    this.exportE2EState();
  },

  showTools(options = {}) {
    this.renderTools();
    this.showView('tools');
    if (options.updateHash !== false) this.updateHash('#herramientas');
    this.exportE2EState();
  },

  showRerMer(options = {}) {
    this.renderRerMer();
    this.showView('rerMer');
    if (options.updateHash !== false) this.updateHash('#rer-mer');
    this.exportE2EState();
  },

  showToxicologia(options = {}) {
    this.renderToxicologia();
    this.showView('toxicologia');
    if (options.updateHash !== false) this.updateHash('#toxicologia');
    this.exportE2EState();
  },

  showFluidoterapia(options = {}) {
    this.renderFluidoterapia();
    this.showView('fluidoterapia');
    if (options.updateHash !== false) this.updateHash('#fluidoterapia');
    this.exportE2EState();
  },

  showUnidades(options = {}) {
    this.renderUnidades();
    this.showView('unidades');
    if (options.updateHash !== false) this.updateHash('#unidades');
    this.exportE2EState();
  },

  showPredisposiciones(options = {}) {
    this.renderPredisposiciones();
    this.showView('predisposiciones');
    if (options.updateHash !== false) this.updateHash('#predisposiciones');
    this.exportE2EState();
  },

  showBcs(options = {}) {
    this.renderBcs();
    this.showView('bcs');
    if (options.updateHash !== false) this.updateHash('#bcs');
    this.exportE2EState();
  },

  showFlashcards(options = {}) {
    if (!this.flashcardsDeck.length) this.buildFlashcardsDeck();
    this.renderFlashcards();
    this.showView('flashcards');
    if (options.updateHash !== false) this.updateHash('#flashcards');
    this.exportE2EState();
  },

  showEmergenciasLatam(options = {}) {
    this.renderEmergenciasLatam();
    this.showView('emergenciasLatam');
    if (options.updateHash !== false) this.updateHash('#emergencias-latam');
    this.exportE2EState();
  },

  showTriaje(options = {}) {
    this.renderTriaje();
    this.showView('triaje');
    if (options.updateHash !== false) this.updateHash('#triaje');
    this.exportE2EState();
  },

  showLaboratorio(options = {}) {
    this.renderLaboratorio();
    this.showView('laboratorio');
    if (options.updateHash !== false) this.updateHash('#laboratorio');
    this.exportE2EState();
  },

  renderLaboratorio() {
    const container = document.getElementById('laboratorioContent');
    if (!container || !this.labReferenceData?.especies?.length) return;
    const lang = I18n?.lang === 'en' ? 'en' : 'es';
    const species = this.labReferenceData.especies;
    const current = species.find(s => s.id === this.labSpecies) || species[0];
    this.labSpecies = current.id;

    const speciesTabs = species.map(s => `
      <button type="button" class="lab-species-btn ${s.id === current.id ? 'active' : ''}"
        data-lab-species="${this.esc(s.id)}" aria-pressed="${s.id === current.id}">
        <span aria-hidden="true">${s.icono}</span> ${this.esc(lang === 'en' ? s.nombre_en : s.nombre_es)}
      </button>
    `).join('');

    const renderTable = (titleKey, rows, type) => {
      if (!rows?.length) return '';
      const nameKey = lang === 'en' ? 'parametro_en' : 'parametro_es';
      const notesKey = lang === 'en' ? 'notas_en' : 'notas_es';
      return `
        <section class="lab-table-section" aria-labelledby="lab-${type}-title">
          <h3 id="lab-${type}-title">${this.esc(this.t(titleKey))}</h3>
          <div class="lab-table-wrap">
            <table class="lab-table">
              <thead>
                <tr>
                  <th scope="col">${this.esc(this.t('lab.col.parameter'))}</th>
                  <th scope="col">${this.esc(this.t('lab.col.unit'))}</th>
                  <th scope="col">${this.esc(this.t('lab.col.range'))}</th>
                  <th scope="col">${this.esc(this.t('lab.col.notes'))}</th>
                </tr>
              </thead>
              <tbody>
                ${rows.map(row => `
                  <tr>
                    <td>${this.esc(row[nameKey])}</td>
                    <td>${this.esc(row.unidad)}</td>
                    <td>${this.esc(this.formatLabRange(row))}</td>
                    <td>${this.esc(row[notesKey] || '—')}</td>
                  </tr>
                `).join('')}
              </tbody>
            </table>
          </div>
        </section>
      `;
    };

    container.innerHTML = `
      <div class="lab-toolbar">
        <div class="lab-species-tabs" role="group" aria-label="${this.esc(this.t('lab.species_filter'))}">
          ${speciesTabs}
        </div>
        <button type="button" id="labPrintBtn" class="btn-text-link lab-print-btn" data-i18n="lab.print">${this.esc(this.t('lab.print'))}</button>
      </div>
      <p class="lab-species-notes">${this.esc(lang === 'en' ? current.notas_en : current.notas_es)}</p>
      ${renderTable('lab.hemogram', current.hemograma, 'hemogram')}
      ${renderTable('lab.biochemistry', current.bioquimica, 'biochem')}
      <p class="lab-disclaimer" role="note">⚕️ ${this.esc(lang === 'en' ? this.labReferenceData.disclaimer_en : this.labReferenceData.disclaimer_es)}</p>
    `;

    container.querySelectorAll('[data-lab-species]').forEach(btn => {
      btn.addEventListener('click', () => {
        this.labSpecies = btn.dataset.labSpecies;
        this.renderLaboratorio();
      });
    });
    container.querySelector('#labPrintBtn')?.addEventListener('click', () => window.print());
  },

  showChangelog(options = {}) {
    this.renderChangelog();
    this.showView('changelog');
    if (options.updateHash !== false) this.updateHash('#changelog');
    this.exportE2EState();
  },

  renderChangelog() {
    const container = document.getElementById('changelogContent');
    if (!container) return;
    const entries = this.changelogData?.entries || [];
    const source = this.changelogData?.source || 'git';

    if (!entries.length) {
      container.innerHTML = `<p class="changelog-empty">${this.esc(this.t('changelog.empty'))}</p>`;
      return;
    }

    const sourceLabel = source === 'changelog.md'
      ? this.t('changelog.source_md')
      : this.t('changelog.source_git');

    container.innerHTML = `
      <p class="changelog-source">${this.esc(sourceLabel)}</p>
      <ol class="changelog-list">
        ${entries.map(entry => `
          <li class="changelog-entry">
            <header class="changelog-entry-header">
              <h3>${this.esc(entry.title || entry.version || '')}</h3>
              ${entry.date ? `<time datetime="${this.esc(entry.date)}">${this.esc(entry.date)}</time>` : ''}
            </header>
            ${(entry.items || []).length ? `
              <ul class="changelog-items">
                ${entry.items.map(item => `<li>${this.esc(item)}</li>`).join('')}
              </ul>
            ` : ''}
          </li>
        `).join('')}
      </ol>
    `;
  },

  renderFooterContribute() {
    const el = document.getElementById('footerContribute');
    if (!el) return;
    const stats = this.getCatalogStats();
    const terms = this.dictionaryData?.total_terminos || this.getDictionaryTerms().length;
    el.innerHTML = `
      <div class="footer-contribute-inner">
        <h2 class="footer-contribute-title">${this.esc(this.t('contribute.title'))}</h2>
        <p class="footer-contribute-desc">${this.esc(this.t('contribute.desc'))}</p>
        <dl class="footer-contribute-stats">
          <div><dt>${this.esc(this.t('welcome.stat_breeds'))}</dt><dd>${stats.breeds}</dd></div>
          <div><dt>${this.esc(this.t('welcome.stat_diseases'))}</dt><dd>${stats.diseases}</dd></div>
          <div><dt>${this.esc(this.t('welcome.stat_glossary'))}</dt><dd>${terms}</dd></div>
        </dl>
        <div class="footer-contribute-links">
          <a href="${this.GITHUB_REPO_URL}" target="_blank" rel="noopener noreferrer">${this.esc(this.t('contribute.github'))}</a>
          <a href="${this.CONTRIBUTE_DOC_URL}" target="_blank" rel="noopener noreferrer">${this.esc(this.t('contribute.guide'))}</a>
          <a href="${this.GOOD_FIRST_ISSUE_URL}" target="_blank" rel="noopener noreferrer">${this.esc(this.t('contribute.good_first'))}</a>
        </div>
      </div>
    `;
  },

  formatLabRange(row) {
    const min = row.min;
    const max = row.max;
    if (min != null && max != null) return `${min} – ${max}`;
    if (min != null) return `≥ ${min}`;
    if (max != null) return `≤ ${max}`;
    return '—';
  },

  BCS_DOG_CAT_SCORES: [1, 2, 3, 4, 5, 6, 7, 8, 9],
  BCS_EQUINE_SCORES: [1, 2, 3, 4, 5],

  FLUID_PROFILES: {
    perros: { mlKgDay: 60, shockMin: 10, shockMax: 20 },
    gatos: { mlKgDay: 50, shockMin: 10, shockMax: 15 },
    equinos: { mlKgDay: 50, shockMin: 10, shockMax: 20 },
    bovinos: { mlKgDay: 50, shockMin: 10, shockMax: 20 },
    aves: { mlKgDay: 80, shockMin: 5, shockMax: 10 },
    conejos: { mlKgDay: 100, shockMin: 5, shockMax: 10 },
    _default: { mlKgDay: 50, shockMin: 10, shockMax: 20 }
  },

  getFluidProfile(speciesId) {
    return this.FLUID_PROFILES[speciesId] || this.FLUID_PROFILES._default;
  },

  renderTools() {
    const grid = document.getElementById('toolsGrid');
    if (!grid) return;
    const cards = [
      {
        icon: '🧮',
        title: this.t('rer.title'),
        desc: this.t('rer.card_desc'),
        action: () => this.showRerMer()
      },
      {
        icon: '💧',
        title: this.t('fluid.title'),
        desc: this.t('fluid.card_desc'),
        action: () => this.showFluidoterapia()
      },
      {
        icon: '⚖️',
        title: this.t('units.title'),
        desc: this.t('units.card_desc'),
        action: () => this.showUnidades()
      },
      {
        icon: '☠️',
        title: this.t('tox.title'),
        desc: this.t('tox.card_desc'),
        action: () => this.showToxicologia()
      },
      {
        icon: '📊',
        title: this.t('bcs.title'),
        desc: this.t('bcs.card_desc'),
        action: () => this.showBcs()
      },
      {
        icon: '🩺',
        title: this.t('triaje.title'),
        desc: this.t('triaje.card_desc'),
        action: () => this.showTriaje()
      },
      {
        icon: '🧪',
        title: this.t('lab.title'),
        desc: this.t('lab.card_desc'),
        action: () => this.showLaboratorio()
      }
    ];
    grid.innerHTML = cards.map((c, i) => `
      <article class="tools-card" role="button" tabindex="0" data-tool-index="${i}" aria-label="${this.esc(c.title)}">
        <span class="tools-card-icon" aria-hidden="true">${c.icon}</span>
        <h3>${this.esc(c.title)}</h3>
        <p>${this.esc(c.desc)}</p>
        <span class="tools-card-link">${this.esc(this.t('tools.open'))} →</span>
      </article>
    `).join('');
    grid.querySelectorAll('.tools-card').forEach(card => {
      const idx = parseInt(card.dataset.toolIndex, 10);
      const open = () => cards[idx]?.action();
      card.addEventListener('click', open);
      card.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
          e.preventDefault();
          open();
        }
      });
    });
  },

  MER_FACTORS: [
    { id: 'castrado', labelKey: 'rer.factor.neutered', factor: 1.6 },
    { id: 'intacto', labelKey: 'rer.factor.intact', factor: 1.8 },
    { id: 'perdida', labelKey: 'rer.factor.weight_loss', factor: 1.0 },
    { id: 'trabajo_ligero', labelKey: 'rer.factor.light_work', factor: 2.0 },
    { id: 'trabajo_moderado', labelKey: 'rer.factor.moderate_work', factor: 3.0 },
    { id: 'trabajo_pesado', labelKey: 'rer.factor.heavy_work', factor: 4.0 },
    { id: 'cachorro_joven', labelKey: 'rer.factor.puppy_young', factor: 3.0 },
    { id: 'cachorro_mayor', labelKey: 'rer.factor.puppy_older', factor: 2.0 },
    { id: 'gestacion', labelKey: 'rer.factor.gestation', factor: 3.0 },
    { id: 'lactancia', labelKey: 'rer.factor.lactation', factor: 4.0 }
  ],

  kgToLb(kg) {
    return kg * 2.2046226218;
  },

  lbToKg(lb) {
    return lb / 2.2046226218;
  },

  calculateRer(kg) {
    if (!kg || kg <= 0) return null;
    return 70 * Math.pow(kg, 0.75);
  },

  formatEnergy(kcal) {
    if (kcal == null) return '—';
    return `${Math.round(kcal)} kcal/día`;
  },

  renderRerMer() {
    const container = document.getElementById('rerMerContent');
    if (!container) return;
    const factorOptions = this.MER_FACTORS.map(f => `
      <option value="${f.factor}">${this.esc(this.t(f.labelKey))} (×${f.factor})</option>
    `).join('');
    const unitKg = this.rerMerUnit === 'kg';
    container.innerHTML = `
      <form class="rer-mer-form" id="rerMerForm" novalidate>
        <div class="rer-mer-grid">
          <div class="rer-field">
            <fieldset class="rer-unit-toggle">
              <legend>${this.esc(this.t('rer.weight'))}</legend>
              <label class="rer-unit-label">
                <input type="radio" name="rer_unit" value="kg" ${unitKg ? 'checked' : ''}>
                kg
              </label>
              <label class="rer-unit-label">
                <input type="radio" name="rer_unit" value="lb" ${!unitKg ? 'checked' : ''}>
                lb
              </label>
            </fieldset>
            <label for="rerWeightInput">${this.esc(this.t('rer.weight_value'))}</label>
            <input type="number" id="rerWeightInput" name="peso" min="0.01" step="0.01" value="10" inputmode="decimal" required aria-describedby="rerResult rerDisclaimer">
          </div>
          <div class="rer-field">
            <label for="rerFactorSelect">${this.esc(this.t('rer.mer_factor'))}</label>
            <select id="rerFactorSelect" name="factor" aria-describedby="rerResult">
              ${factorOptions}
            </select>
          </div>
        </div>
        <div class="rer-result" id="rerResult" role="status" aria-live="polite" aria-atomic="true"></div>
        <p id="rerDisclaimer" class="rer-disclaimer" role="note">
          ⚕️ ${this.esc(this.t('rer.disclaimer'))}
        </p>
      </form>
    `;
    this.bindRerMerCalculator(container);
  },

  bindRerMerCalculator(root) {
    const form = root.querySelector('#rerMerForm');
    const weightInput = root.querySelector('#rerWeightInput');
    const factorSelect = root.querySelector('#rerFactorSelect');
    const resultEl = root.querySelector('#rerResult');
    const unitRadios = root.querySelectorAll('input[name="rer_unit"]');
    if (!form || !weightInput || !factorSelect || !resultEl) return;

    const update = () => {
      const unit = root.querySelector('input[name="rer_unit"]:checked')?.value || 'kg';
      this.rerMerUnit = unit;
      let weight = parseFloat(String(weightInput.value).replace(',', '.'));
      if (!weight || weight <= 0) {
        resultEl.innerHTML = `<p class="rer-result-warn">${this.esc(this.t('rer.invalid_weight'))}</p>`;
        return;
      }
      const kg = unit === 'lb' ? this.lbToKg(weight) : weight;
      const rer = this.calculateRer(kg);
      const factor = parseFloat(factorSelect.value);
      const mer = rer * factor;
      const altWeight = unit === 'kg'
        ? `${this.formatDoseNumber(this.kgToLb(kg))} lb`
        : `${this.formatDoseNumber(kg)} kg`;
      resultEl.innerHTML = `
        <div class="rer-result-card">
          <dl class="rer-metrics">
            <div><dt>RER</dt><dd><strong>${this.formatEnergy(rer)}</strong></dd></div>
            <div><dt>MER (×${factor})</dt><dd><strong>${this.formatEnergy(mer)}</strong></dd></div>
            <div><dt>${this.esc(this.t('rer.equivalent'))}</dt><dd>${this.esc(altWeight)}</dd></div>
          </dl>
          <p class="rer-formula">${this.esc(this.t('rer.formula'))}</p>
        </div>`;
    };

    form.addEventListener('input', update);
    form.addEventListener('change', update);
    update();
  },

  renderFluidoterapia() {
    const container = document.getElementById('fluidoterapiaContent');
    if (!container) return;
    const speciesOptions = (this.data?.animales || []).map(a => `
      <option value="${this.esc(a.id)}" ${this.fluidSpecies === a.id ? 'selected' : ''}>
        ${this.esc(a.icono || '')} ${this.esc(a.nombre)}
      </option>
    `).join('');
    const unitKg = this.fluidUnit === 'kg';
    container.innerHTML = `
      <form class="fluidoterapia-form" id="fluidoterapiaForm" novalidate>
        <div class="fluidoterapia-grid">
          <div class="fluid-field">
            <fieldset class="fluid-unit-toggle">
              <legend>${this.esc(this.t('fluid.weight'))}</legend>
              <label class="fluid-unit-label">
                <input type="radio" name="fluid_unit" value="kg" ${unitKg ? 'checked' : ''}> kg
              </label>
              <label class="fluid-unit-label">
                <input type="radio" name="fluid_unit" value="lb" ${!unitKg ? 'checked' : ''}> lb
              </label>
            </fieldset>
            <label for="fluidWeightInput">${this.esc(this.t('fluid.weight_value'))}</label>
            <input type="number" id="fluidWeightInput" min="0.01" step="0.01" value="10" inputmode="decimal" required aria-describedby="fluidResult fluidDisclaimer">
          </div>
          <div class="fluid-field">
            <label for="fluidSpeciesSelect">${this.esc(this.t('fluid.species'))}</label>
            <select id="fluidSpeciesSelect" aria-describedby="fluidResult">${speciesOptions}</select>
          </div>
        </div>
        <div class="fluid-result" id="fluidResult" role="status" aria-live="polite" aria-atomic="true"></div>
        <div class="fluid-shock-panel" id="fluidShockPanel" aria-labelledby="fluidShockTitle"></div>
        <p id="fluidDisclaimer" class="fluid-disclaimer" role="note">
          ⚕️ ${this.esc(this.t('fluid.disclaimer'))}
        </p>
      </form>
    `;
    this.bindFluidoterapiaCalculator(container);
  },

  bindFluidoterapiaCalculator(root) {
    const weightInput = root.querySelector('#fluidWeightInput');
    const speciesSelect = root.querySelector('#fluidSpeciesSelect');
    const resultEl = root.querySelector('#fluidResult');
    const shockEl = root.querySelector('#fluidShockPanel');
    if (!weightInput || !speciesSelect || !resultEl || !shockEl) return;

    const update = () => {
      const unit = root.querySelector('input[name="fluid_unit"]:checked')?.value || 'kg';
      this.fluidUnit = unit;
      this.fluidSpecies = speciesSelect.value;
      let weight = parseFloat(String(weightInput.value).replace(',', '.'));
      if (!weight || weight <= 0) {
        resultEl.innerHTML = `<p class="fluid-result-warn">${this.esc(this.t('fluid.invalid_weight'))}</p>`;
        shockEl.innerHTML = '';
        return;
      }
      const kg = unit === 'lb' ? this.lbToKg(weight) : weight;
      const profile = this.getFluidProfile(this.fluidSpecies);
      const mlPerDay = Math.round(profile.mlKgDay * kg);
      const mlPerHour = Math.round((mlPerDay / 24) * 10) / 10;
      const shockMinVol = Math.round(profile.shockMin * kg);
      const shockMaxVol = Math.round(profile.shockMax * kg);
      const altWeight = unit === 'kg'
        ? `${this.formatDoseNumber(this.kgToLb(kg))} lb`
        : `${this.formatDoseNumber(kg)} kg`;
      resultEl.innerHTML = `
        <div class="fluid-result-card">
          <h3>${this.esc(this.t('fluid.maintenance'))}</h3>
          <dl class="fluid-metrics">
            <div><dt>${this.esc(this.t('fluid.rate'))}</dt><dd>${profile.mlKgDay} ml/kg/día</dd></div>
            <div><dt>${this.esc(this.t('fluid.per_day'))}</dt><dd><strong>${this.formatDoseNumber(mlPerDay)} ml</strong></dd></div>
            <div><dt>${this.esc(this.t('fluid.per_hour'))}</dt><dd>${this.formatDoseNumber(mlPerHour)} ml/h</dd></div>
            <div><dt>${this.esc(this.t('fluid.equivalent'))}</dt><dd>${this.esc(altWeight)}</dd></div>
          </dl>
        </div>`;
      shockEl.innerHTML = `
        <h3 id="fluidShockTitle">${this.esc(this.t('fluid.shock_title'))}</h3>
        <p class="fluid-shock-desc">${this.esc(this.t('fluid.shock_desc'))}</p>
        <dl class="fluid-metrics fluid-metrics--shock">
          <div><dt>${this.esc(this.t('fluid.shock_bolus'))}</dt>
            <dd><strong>${shockMinVol === shockMaxVol ? `${shockMinVol} ml` : `${shockMinVol}–${shockMaxVol} ml`}</strong>
            <span class="fluid-shock-detail">(${profile.shockMin}–${profile.shockMax} ml/kg)</span></dd></div>
        </dl>
        <p class="fluid-shock-repeat">${this.esc(this.t('fluid.shock_repeat'))}</p>`;
    };

    root.querySelector('#fluidoterapiaForm')?.addEventListener('input', update);
    root.querySelector('#fluidoterapiaForm')?.addEventListener('change', update);
    update();
  },

  celsiusToFahrenheit(c) {
    return (c * 9 / 5) + 32;
  },

  fahrenheitToCelsius(f) {
    return (f - 32) * 5 / 9;
  },

  renderUnidades() {
    const container = document.getElementById('unidadesContent');
    if (!container) return;
    container.innerHTML = `
      <div class="unidades-panels">
        <section class="units-panel" aria-labelledby="unitsMgGTitle">
          <h3 id="unitsMgGTitle">${this.esc(this.t('units.mg_g'))}</h3>
          <div class="units-row">
            <label for="unitsMgInput">${this.esc(this.t('units.mg_value'))}</label>
            <input type="number" id="unitsMgInput" min="0" step="any" value="500" inputmode="decimal">
            <span class="units-equals">=</span>
            <output id="unitsGOutput" for="unitsMgInput">0,5 g</output>
          </div>
        </section>
        <section class="units-panel" aria-labelledby="unitsDoseTitle">
          <h3 id="unitsDoseTitle">${this.esc(this.t('units.dose'))}</h3>
          <div class="units-grid">
            <div>
              <label for="unitsDoseMgKg">${this.esc(this.t('units.dose_mg_kg'))}</label>
              <input type="number" id="unitsDoseMgKg" min="0" step="any" value="10" inputmode="decimal">
            </div>
            <div>
              <label for="unitsDoseWeight">${this.esc(this.t('units.dose_weight'))}</label>
              <input type="number" id="unitsDoseWeight" min="0.01" step="any" value="5" inputmode="decimal">
            </div>
          </div>
          <p class="units-result-line"><strong>${this.esc(this.t('units.dose_total'))}:</strong> <output id="unitsDoseTotal">50 mg</output></p>
        </section>
        <section class="units-panel" aria-labelledby="unitsTempTitle">
          <h3 id="unitsTempTitle">${this.esc(this.t('units.temp'))}</h3>
          <div class="units-row">
            <label for="unitsCelsiusInput">${this.esc(this.t('units.celsius'))}</label>
            <input type="number" id="unitsCelsiusInput" step="any" value="38.5" inputmode="decimal">
            <span class="units-equals">↔</span>
            <label for="unitsFahrenheitInput" class="visually-hidden">${this.esc(this.t('units.fahrenheit'))}</label>
            <input type="number" id="unitsFahrenheitInput" step="any" value="101.3" inputmode="decimal">
            <span class="units-unit">°F</span>
          </div>
        </section>
        <section class="units-panel" aria-labelledby="unitsDropsTitle">
          <h3 id="unitsDropsTitle">${this.esc(this.t('units.drops'))}</h3>
          <div class="units-grid">
            <div>
              <label for="unitsMlInput">${this.esc(this.t('units.ml'))}</label>
              <input type="number" id="unitsMlInput" min="0" step="any" value="1" inputmode="decimal">
            </div>
            <div>
              <label for="unitsDropsFactor">${this.esc(this.t('units.drops_factor'))}</label>
              <select id="unitsDropsFactor">
                <option value="20" ${this.unitsDropsFactor === 20 ? 'selected' : ''}>${this.esc(this.t('units.drops_macro'))}</option>
                <option value="60" ${this.unitsDropsFactor === 60 ? 'selected' : ''}>${this.esc(this.t('units.drops_micro'))}</option>
              </select>
            </div>
          </div>
          <p class="units-result-line"><strong>${this.esc(this.t('units.drops_value'))}:</strong> <output id="unitsDropsOutput">20</output></p>
          <p class="units-note">${this.esc(this.t('units.drops_note'))}</p>
        </section>
      </div>
    `;
    this.bindUnidadesConverter(container);
  },

  bindUnidadesConverter(root) {
    const mgInput = root.querySelector('#unitsMgInput');
    const gOutput = root.querySelector('#unitsGOutput');
    const doseMgKg = root.querySelector('#unitsDoseMgKg');
    const doseWeight = root.querySelector('#unitsDoseWeight');
    const doseTotal = root.querySelector('#unitsDoseTotal');
    const celsiusInput = root.querySelector('#unitsCelsiusInput');
    const fahrenheitInput = root.querySelector('#unitsFahrenheitInput');
    const mlInput = root.querySelector('#unitsMlInput');
    const dropsFactor = root.querySelector('#unitsDropsFactor');
    const dropsOutput = root.querySelector('#unitsDropsOutput');
    let syncingTemp = false;

    const updateMgG = () => {
      const mg = parseFloat(String(mgInput?.value || '').replace(',', '.'));
      if (!mgInput || !gOutput || Number.isNaN(mg)) return;
      gOutput.textContent = `${this.formatDoseNumber(mg / 1000)} g`;
    };

    const updateDose = () => {
      const mgKg = parseFloat(String(doseMgKg?.value || '').replace(',', '.'));
      const kg = parseFloat(String(doseWeight?.value || '').replace(',', '.'));
      if (!doseTotal || Number.isNaN(mgKg) || !kg || kg <= 0) return;
      doseTotal.textContent = `${this.formatDoseNumber(mgKg * kg)} mg`;
    };

    const updateDrops = () => {
      const ml = parseFloat(String(mlInput?.value || '').replace(',', '.'));
      const factor = parseInt(dropsFactor?.value || '20', 10);
      this.unitsDropsFactor = factor;
      if (!dropsOutput || Number.isNaN(ml)) return;
      dropsOutput.textContent = this.formatDoseNumber(ml * factor);
    };

    celsiusInput?.addEventListener('input', () => {
      if (syncingTemp) return;
      syncingTemp = true;
      const c = parseFloat(String(celsiusInput.value).replace(',', '.'));
      if (!Number.isNaN(c) && fahrenheitInput) {
        fahrenheitInput.value = (Math.round(this.celsiusToFahrenheit(c) * 10) / 10).toString();
      }
      syncingTemp = false;
    });

    fahrenheitInput?.addEventListener('input', () => {
      if (syncingTemp) return;
      syncingTemp = true;
      const f = parseFloat(String(fahrenheitInput.value).replace(',', '.'));
      if (!Number.isNaN(f) && celsiusInput) {
        celsiusInput.value = (Math.round(this.fahrenheitToCelsius(f) * 10) / 10).toString();
      }
      syncingTemp = false;
    });

    mgInput?.addEventListener('input', updateMgG);
    doseMgKg?.addEventListener('input', updateDose);
    doseWeight?.addEventListener('input', updateDose);
    mlInput?.addEventListener('input', updateDrops);
    dropsFactor?.addEventListener('change', updateDrops);
    updateMgG();
    updateDose();
    updateDrops();
  },

  getPredisposicionesIndex() {
    if (this.predisposicionesIndex) return this.predisposicionesIndex;
    const map = new Map();
    this.getAllBreeds().forEach(breed => {
      (breed.predisposiciones_geneticas || []).forEach(raw => {
        const name = String(raw).trim();
        if (!name) return;
        const key = this.normalizeSearch(name);
        if (!map.has(key)) map.set(key, { name, breeds: [] });
        map.get(key).breeds.push(breed);
      });
    });
    this.predisposicionesIndex = Array.from(map.values()).sort((a, b) => {
      if (b.breeds.length !== a.breeds.length) return b.breeds.length - a.breeds.length;
      return a.name.localeCompare(b.name, 'es');
    });
    return this.predisposicionesIndex;
  },

  getFilteredPredisposiciones() {
    const query = this.predisposicionesQuery;
    const animal = this.predisposicionesAnimal;
    return this.getPredisposicionesIndex().filter(entry => {
      if (query && !this.normalizeSearch(entry.name).includes(this.normalizeSearch(query))) return false;
      if (animal !== 'todos' && !entry.breeds.some(b => b.animalId === animal)) return false;
      return true;
    }).map(entry => ({
      ...entry,
      breeds: animal === 'todos' ? entry.breeds : entry.breeds.filter(b => b.animalId === animal)
    }));
  },

  renderPredisposiciones() {
    const filters = document.getElementById('predisAnimalFilters');
    const summary = document.getElementById('predisSummary');
    const list = document.getElementById('predisList');
    if (!list) return;

    if (filters) {
      const items = [
        { id: 'todos', label: this.t('predis.all_animals') },
        ...(this.data?.animales || []).map(a => ({ id: a.id, label: `${a.icono || ''} ${a.nombre}`.trim() }))
      ];
      filters.innerHTML = items.map(item => `
        <button type="button" class="predis-filter-btn ${this.predisposicionesAnimal === item.id ? 'active' : ''}"
          data-animal="${this.esc(item.id)}">${this.esc(item.label)}</button>
      `).join('');
      filters.querySelectorAll('.predis-filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          this.predisposicionesAnimal = btn.dataset.animal;
          this.renderPredisposiciones();
        });
      });
    }

    const entries = this.getFilteredPredisposiciones();
    const breedMentions = entries.reduce((n, e) => n + e.breeds.length, 0);
    if (summary) {
      summary.textContent = this.t('predis.summary')
        .replace('{conditions}', String(entries.length))
        .replace('{breeds}', String(breedMentions));
    }

    if (!entries.length) {
      list.innerHTML = `<p class="predis-empty">${this.esc(this.t('predis.empty'))}</p>`;
      return;
    }

    list.innerHTML = entries.map(entry => {
      const breedLinks = entry.breeds.map(b => `
        <button type="button" class="predis-breed-link" data-animal="${this.esc(b.animalId)}" data-breed="${this.esc(b.id)}"
          aria-label="${this.esc(this.t('predis.view_breed'))}: ${this.esc(b.nombre)}">
          ${this.esc(b.animalIcono || '')} ${this.esc(b.nombre)}
        </button>
      `).join('');
      return `
        <article class="predis-card">
          <header class="predis-card-header">
            <h3>🧬 ${this.esc(entry.name)}</h3>
            <span class="predis-count">${this.esc(this.t('predis.breeds_count').replace('{count}', String(entry.breeds.length)))}</span>
          </header>
          <div class="predis-breed-chips">${breedLinks}</div>
        </article>`;
    }).join('');

    list.querySelectorAll('.predis-breed-link').forEach(btn => {
      btn.addEventListener('click', () => {
        const breed = this.findBreed(btn.dataset.animal, btn.dataset.breed);
        if (breed) this.showBreedDetail(breed);
      });
    });
  },

  getFilteredToxicology() {
    const items = this.toxicologyData?.sustancias || [];
    return items.filter(item => {
      if (this.toxicologySpecies !== 'todos' && !(item.especies || []).includes(this.toxicologySpecies)) {
        return false;
      }
      if (!this.toxicologyQuery) return true;
      const haystack = [
        item.nombre, item.categoria, item.toxicidad, item.accion,
        item.mecanismo, item.antidoto,
        ...(item.sintomas || []),
        ...(item.especies || [])
      ].join(' ').toLowerCase();
      return haystack.includes(this.toxicologyQuery);
    });
  },

  renderToxicologia() {
    const title = document.getElementById('toxicologiaTitle');
    const intro = document.getElementById('toxicologiaIntro');
    const filters = document.getElementById('toxicologiaSpeciesFilters');
    const list = document.getElementById('toxicologiaList');
    if (!list) return;

    if (title) title.textContent = this.toxicologyData?.titulo || this.t('tox.title');
    if (intro) intro.textContent = this.toxicologyData?.introduccion || '';

    if (filters) {
      const species = [{ id: 'todos', label: this.t('tox.all_species') }];
      (this.data?.animales || []).forEach(a => {
        species.push({ id: a.id, label: `${a.icono} ${a.nombre}` });
      });
      filters.innerHTML = species.map(s => `
        <button type="button" class="tox-filter-btn ${this.toxicologySpecies === s.id ? 'active' : ''}"
          data-species="${s.id}" aria-pressed="${this.toxicologySpecies === s.id}">
          ${this.esc(s.label)}
        </button>
      `).join('');
      filters.querySelectorAll('.tox-filter-btn').forEach(btn => {
        btn.addEventListener('click', () => {
          this.toxicologySpecies = btn.dataset.species;
          this.renderToxicologia();
        });
      });
    }

    const items = this.getFilteredToxicology();
    if (!items.length) {
      list.innerHTML = `<div class="empty-state"><div class="empty-icon">🔍</div><p>${this.esc(this.t('tox.empty'))}</p></div>`;
      return;
    }

    list.innerHTML = items.map(item => `
      <article class="tox-card tox-card--${item.toxicidad}" aria-labelledby="tox-${item.id}">
        <header class="tox-card-header">
          <h3 id="tox-${item.id}">${this.esc(item.nombre)}</h3>
          <span class="tox-badge tox-badge--${item.toxicidad}">${this.esc(item.toxicidad)}</span>
        </header>
        <p class="tox-meta">
          <span>${this.esc(this.t('tox.category'))}: ${this.esc(item.categoria)}</span>
          <span>${this.esc(this.t('tox.species'))}: ${(item.especies || []).map(e => this.esc(e)).join(', ')}</span>
        </p>
        ${item.umbral_orientativo ? `<p class="tox-threshold"><strong>${this.esc(this.t('tox.threshold'))}:</strong> ${this.esc(item.umbral_orientativo)}</p>` : ''}
        <div class="tox-block">
          <h4>${this.esc(this.t('tox.symptoms'))}</h4>
          <ul>${(item.sintomas || []).map(s => `<li>${this.esc(s)}</li>`).join('')}</ul>
        </div>
        ${item.mecanismo ? `<div class="tox-block"><h4>${this.esc(this.t('tox.mechanism'))}</h4><p>${this.esc(item.mecanismo)}</p></div>` : ''}
        <div class="tox-block tox-block--action">
          <h4>${this.esc(this.t('tox.action'))}</h4>
          <p>${this.esc(item.accion)}</p>
        </div>
        ${item.antidoto ? `<div class="tox-block"><h4>${this.esc(this.t('tox.antidote'))}</h4><p>${this.esc(item.antidoto)}</p></div>` : ''}
      </article>
    `).join('');
  },

  getBcsScores() {
    return this.bcsSpecies === 'equinos' ? this.BCS_EQUINE_SCORES : this.BCS_DOG_CAT_SCORES;
  },

  getBcsRibOpacity(score) {
    const max = this.bcsSpecies === 'equinos' ? 5 : 9;
    const mid = Math.ceil(max / 2);
    if (score <= 2) return 1;
    if (score <= mid - 1) return 0.85;
    if (score === mid) return 0.55;
    if (score <= mid + 1) return 0.35;
    return 0.15;
  },

  getBcsWaistScale(score) {
    const max = this.bcsSpecies === 'equinos' ? 5 : 9;
    const mid = Math.ceil(max / 2);
    if (score <= 2) return 1.35;
    if (score <= mid - 1) return 1.15;
    if (score === mid) return 1;
    if (score <= mid + 1) return 0.88;
    return 0.72;
  },

  renderBcsSvg(score) {
    const ribOpacity = this.getBcsRibOpacity(score);
    const waist = this.getBcsWaistScale(score);
    const isEquine = this.bcsSpecies === 'equinos';
    const bodyPath = isEquine
      ? 'M30 55 Q55 40 80 48 Q105 56 120 70 L118 95 Q90 102 62 98 Q35 94 30 70 Z'
      : 'M35 58 Q60 42 85 50 Q110 58 115 72 L112 92 Q85 98 58 94 Q32 90 35 72 Z';
  const ribLines = isEquine
      ? [48, 58, 68, 78].map(y => `<line x1="52" y1="${y}" x2="98" y2="${y}" stroke="currentColor" stroke-width="1.5" opacity="${ribOpacity}"/>`).join('')
      : [50, 58, 66, 74].map(y => `<line x1="48" y1="${y}" x2="102" y2="${y}" stroke="currentColor" stroke-width="1.5" opacity="${ribOpacity}"/>`).join('');
    return `
      <svg class="bcs-silhouette-svg" viewBox="0 0 150 120" role="img" aria-hidden="true">
        <g transform="scale(${waist}, 1) translate(${(1 - waist) * 75}, 0)">
          <path d="${bodyPath}" fill="var(--bcs-fill, #c8d6e5)" stroke="var(--bcs-stroke, #576574)" stroke-width="2"/>
          ${ribLines}
        </g>
        <text x="75" y="115" text-anchor="middle" class="bcs-svg-score">${score}</text>
      </svg>`;
  },

  renderBcs() {
    const container = document.getElementById('bcsContent');
    if (!container) return;
    const scores = this.getBcsScores();
    const maxScore = scores[scores.length - 1];
    if (!scores.includes(this.bcsScore)) this.bcsScore = Math.ceil(maxScore / 2);
    const speciesOptions = [
      { id: 'perros', label: this.t('bcs.species.dog') },
      { id: 'gatos', label: this.t('bcs.species.cat') },
      { id: 'equinos', label: this.t('bcs.species.horse') }
    ];
    const scoreKey = this.bcsSpecies === 'equinos'
      ? `bcs.equine.${this.bcsScore}`
      : `bcs.dog_cat.${this.bcsScore}`;
    container.innerHTML = `
      <div class="bcs-toolbar">
        <fieldset class="bcs-species-toggle">
          <legend>${this.esc(this.t('bcs.select_species'))}</legend>
          ${speciesOptions.map(s => `
            <label class="bcs-species-label">
              <input type="radio" name="bcs_species" value="${s.id}" ${this.bcsSpecies === s.id ? 'checked' : ''}>
              ${this.esc(s.label)}
            </label>
          `).join('')}
        </fieldset>
        <div class="bcs-scale-label">
          ${this.esc(this.t(this.bcsSpecies === 'equinos' ? 'bcs.scale_equine' : 'bcs.scale_dog_cat'))}
        </div>
      </div>
      <div class="bcs-main">
        <div class="bcs-visual" aria-live="polite">
          ${this.renderBcsSvg(this.bcsScore)}
        </div>
        <div class="bcs-controls">
          <label for="bcsScoreRange">${this.esc(this.t('bcs.score_label'))}: <strong id="bcsScoreValue">${this.bcsScore}</strong> / ${maxScore}</label>
          <input type="range" id="bcsScoreRange" min="${scores[0]}" max="${maxScore}" step="1" value="${this.bcsScore}">
          <div class="bcs-score-buttons" role="group" aria-label="${this.esc(this.t('bcs.score_label'))}">
            ${scores.map(n => `
              <button type="button" class="bcs-score-btn ${n === this.bcsScore ? 'active' : ''}" data-score="${n}">${n}</button>
            `).join('')}
          </div>
        </div>
      </div>
      <article class="bcs-description">
        <h3>${this.esc(this.t('bcs.score_heading').replace('{score}', String(this.bcsScore)))}</h3>
        <p>${this.esc(this.t(scoreKey))}</p>
      </article>
      <p class="bcs-disclaimer" role="note">⚕️ ${this.esc(this.t('bcs.disclaimer'))}</p>
    `;
    const updateScore = (score) => {
      this.bcsScore = score;
      container.querySelector('.bcs-visual').innerHTML = this.renderBcsSvg(score);
      const valueEl = container.querySelector('#bcsScoreValue');
      if (valueEl) valueEl.textContent = String(score);
      const range = container.querySelector('#bcsScoreRange');
      if (range) range.value = String(score);
      container.querySelectorAll('.bcs-score-btn').forEach(btn => {
        btn.classList.toggle('active', parseInt(btn.dataset.score, 10) === score);
      });
      const desc = container.querySelector('.bcs-description');
      if (desc) {
        const key = this.bcsSpecies === 'equinos' ? `bcs.equine.${score}` : `bcs.dog_cat.${score}`;
        desc.innerHTML = `
          <h3>${this.esc(this.t('bcs.score_heading').replace('{score}', String(score)))}</h3>
          <p>${this.esc(this.t(key))}</p>`;
      }
    };
    container.querySelectorAll('input[name="bcs_species"]').forEach(radio => {
      radio.addEventListener('change', () => {
        this.bcsSpecies = radio.value;
        const newScores = this.getBcsScores();
        if (!newScores.includes(this.bcsScore)) this.bcsScore = Math.ceil(newScores[newScores.length - 1] / 2);
        this.renderBcs();
      });
    });
    container.querySelector('#bcsScoreRange')?.addEventListener('input', (e) => {
      updateScore(parseInt(e.target.value, 10));
    });
    container.querySelectorAll('.bcs-score-btn').forEach(btn => {
      btn.addEventListener('click', () => updateScore(parseInt(btn.dataset.score, 10)));
    });
  },

  getFlashcardsProgress() {
    try {
      const raw = localStorage.getItem(this.FLASHCARDS_KEY);
      return raw ? JSON.parse(raw) : { known: [], stats: { studied: 0, sessions: 0 } };
    } catch (_) {
      return { known: [], stats: { studied: 0, sessions: 0 } };
    }
  },

  saveFlashcardsProgress(progress) {
    try {
      localStorage.setItem(this.FLASHCARDS_KEY, JSON.stringify(progress));
    } catch (_) { /* sin almacenamiento */ }
  },

  shuffleArray(arr) {
    const a = [...arr];
    for (let i = a.length - 1; i > 0; i -= 1) {
      const j = Math.floor(Math.random() * (i + 1));
      [a[i], a[j]] = [a[j], a[i]];
    }
    return a;
  },

  buildFlashcardsDeck() {
    const terms = this.getDictionaryTerms().filter(term => {
      if (this.flashcardsCategory === 'todos') return true;
      return term.categoriaId === this.flashcardsCategory;
    });
    this.flashcardsDeck = this.shuffleArray(terms);
    this.flashcardsIndex = 0;
    this.flashcardsRevealed = false;
    const progress = this.getFlashcardsProgress();
    progress.stats = progress.stats || { studied: 0, sessions: 0 };
    progress.stats.sessions += 1;
    this.saveFlashcardsProgress(progress);
  },

  renderFlashcards() {
    const container = document.getElementById('flashcardsContent');
    if (!container) return;
    if (!this.dictionaryData) {
      container.innerHTML = `<div class="empty-state"><div class="empty-icon">⚠️</div><p>${this.esc(this.t('flash.no_glossary'))}</p></div>`;
      return;
    }
    if (!this.flashcardsDeck.length) this.buildFlashcardsDeck();
    const progress = this.getFlashcardsProgress();
    const knownSet = new Set(progress.known || []);
    const total = this.flashcardsDeck.length;
    const current = this.flashcardsDeck[this.flashcardsIndex];
    const categories = [
      { id: 'todos', nombre: this.t('flash.all_categories') },
      ...this.dictionaryData.categorias.map(c => ({ id: c.id, nombre: c.nombre }))
    ];
    if (!current) {
      container.innerHTML = `
        <div class="flashcards-done">
          <div class="empty-icon">🎉</div>
          <h3>${this.esc(this.t('flash.session_done'))}</h3>
          <p>${this.esc(this.t('flash.known_count').replace('{count}', String(knownSet.size)))}</p>
          <button type="button" class="disclaimer-accept-btn" id="flashRestartBtn">${this.esc(this.t('flash.restart'))}</button>
        </div>`;
      container.querySelector('#flashRestartBtn')?.addEventListener('click', () => {
        this.buildFlashcardsDeck();
        this.renderFlashcards();
      });
      return;
    }
    const pct = total ? Math.round((this.flashcardsIndex / total) * 100) : 0;
    container.innerHTML = `
      <div class="flashcards-toolbar">
        <label for="flashCategorySelect">${this.esc(this.t('flash.category'))}</label>
        <select id="flashCategorySelect">
          ${categories.map(c => `<option value="${c.id}" ${this.flashcardsCategory === c.id ? 'selected' : ''}>${this.esc(c.nombre)}</option>`).join('')}
        </select>
        <button type="button" class="btn-text-link" id="flashShuffleBtn">${this.esc(this.t('flash.shuffle'))}</button>
        <button type="button" class="btn-text-link" id="flashResetProgressBtn">${this.esc(this.t('flash.reset_progress'))}</button>
      </div>
      <div class="flashcards-progress" role="status" aria-live="polite">
        <div class="flashcards-progress-bar" style="width:${pct}%"></div>
        <span>${this.esc(this.t('flash.progress').replace('{current}', String(this.flashcardsIndex + 1)).replace('{total}', String(total)).replace('{known}', String(knownSet.size)))}</span>
      </div>
      <div class="flashcard ${this.flashcardsRevealed ? 'flashcard--revealed' : ''}" id="flashcard" role="button" tabindex="0" aria-pressed="${this.flashcardsRevealed}">
        <p class="flashcard-eyebrow">${this.esc(current.categoriaNombre || '')}</p>
        <h3 class="flashcard-term">${this.esc(current.termino)}</h3>
        <div class="flashcard-back" ${this.flashcardsRevealed ? '' : 'hidden'}>
          <p class="flashcard-definition">${this.esc(current.definicion)}</p>
          ${current.ejemplo ? `<p class="flashcard-example"><em>${this.esc(this.t('flash.example'))}:</em> ${this.esc(current.ejemplo)}</p>` : ''}
        </div>
        <p class="flashcard-hint">${this.esc(this.t(this.flashcardsRevealed ? 'flash.tap_hide' : 'flash.tap_reveal'))}</p>
      </div>
      <div class="flashcards-actions">
        <button type="button" class="btn-text-link" id="flashPrevBtn" ${this.flashcardsIndex === 0 ? 'disabled' : ''}>← ${this.esc(this.t('flash.prev'))}</button>
        <button type="button" class="flashcards-know-btn" id="flashKnowBtn" ${this.flashcardsRevealed ? '' : 'disabled'}>${this.esc(this.t('flash.mark_known'))}</button>
        <button type="button" class="flashcards-learning-btn" id="flashLearningBtn">${this.esc(this.t('flash.still_learning'))}</button>
        <button type="button" class="btn-text-link" id="flashNextBtn">${this.esc(this.t('flash.next'))} →</button>
      </div>
    `;
    const reveal = () => {
      this.flashcardsRevealed = true;
      this.renderFlashcards();
    };
    const hide = () => {
      this.flashcardsRevealed = false;
      this.renderFlashcards();
    };
    container.querySelector('#flashcard')?.addEventListener('click', () => {
      if (this.flashcardsRevealed) hide();
      else reveal();
    });
    container.querySelector('#flashcard')?.addEventListener('keydown', (e) => {
      if (e.key === 'Enter' || e.key === ' ') {
        e.preventDefault();
        if (this.flashcardsRevealed) hide();
        else reveal();
      }
    });
    container.querySelector('#flashCategorySelect')?.addEventListener('change', (e) => {
      this.flashcardsCategory = e.target.value;
      this.buildFlashcardsDeck();
      this.renderFlashcards();
    });
    container.querySelector('#flashShuffleBtn')?.addEventListener('click', () => {
      this.flashcardsDeck = this.shuffleArray(this.flashcardsDeck);
      this.flashcardsIndex = 0;
      this.flashcardsRevealed = false;
      this.renderFlashcards();
    });
    container.querySelector('#flashResetProgressBtn')?.addEventListener('click', () => {
      this.saveFlashcardsProgress({ known: [], stats: { studied: 0, sessions: 0 } });
      this.renderFlashcards();
    });
    container.querySelector('#flashPrevBtn')?.addEventListener('click', () => {
      if (this.flashcardsIndex > 0) {
        this.flashcardsIndex -= 1;
        this.flashcardsRevealed = false;
        this.renderFlashcards();
      }
    });
    container.querySelector('#flashNextBtn')?.addEventListener('click', () => {
      this.flashcardsIndex += 1;
      this.flashcardsRevealed = false;
      if (this.flashcardsIndex >= this.flashcardsDeck.length) {
        this.renderFlashcards();
        return;
      }
      this.renderFlashcards();
    });
    container.querySelector('#flashKnowBtn')?.addEventListener('click', () => {
      const slug = this.termSlug(current.termino);
      if (!knownSet.has(slug)) {
        progress.known = [...(progress.known || []), slug];
        progress.stats.studied = (progress.stats.studied || 0) + 1;
        this.saveFlashcardsProgress(progress);
      }
      this.flashcardsIndex += 1;
      this.flashcardsRevealed = false;
      this.renderFlashcards();
    });
    container.querySelector('#flashLearningBtn')?.addEventListener('click', () => {
      this.flashcardsIndex += 1;
      this.flashcardsRevealed = false;
      this.renderFlashcards();
    });
  },

  renderEmergenciasLatam() {
    const title = document.getElementById('emergenciasLatamTitle');
    const intro = document.getElementById('emergenciasLatamIntro');
    const list = document.getElementById('emergenciasLatamList');
    if (!list) return;
    const data = this.emergenciasLatamData;
    if (title) title.textContent = data?.titulo || this.t('emerg.title');
    if (intro) intro.textContent = data?.introduccion || this.t('emerg.intro');
    if (!data?.paises?.length) {
      list.innerHTML = `<div class="empty-state"><div class="empty-icon">⚠️</div><p>${this.esc(this.t('emerg.empty'))}</p></div>`;
      return;
    }
    list.innerHTML = `
      <p class="emergencias-latam-disclaimer" role="note">⚕️ ${this.esc(data.disclaimer || this.t('emerg.disclaimer'))}</p>
      ${data.paises.map(p => `
        <article class="emergencias-latam-card" aria-labelledby="emerg-${p.id}">
          <header>
            <span class="emergencias-latam-flag" aria-hidden="true">${p.bandera || '🌎'}</span>
            <h3 id="emerg-${p.id}">${this.esc(p.nombre)}</h3>
          </header>
          <div class="emergencias-latam-section">
            <h4>${this.esc(this.t('emerg.colleges'))}</h4>
            <ul>
              ${(p.colegios || []).map(c => `
                <li><a href="${this.esc(c.url)}" target="_blank" rel="noopener noreferrer">${this.esc(c.nombre)}</a></li>
              `).join('')}
            </ul>
          </div>
          ${(p.lineas || []).length ? `
            <div class="emergencias-latam-section">
              <h4>${this.esc(this.t('emerg.hotlines'))}</h4>
              <ul>
                ${p.lineas.map(l => `
                  <li>
                    <strong>${this.esc(l.nombre)}</strong>
                    ${l.telefono ? ` — <a href="tel:${this.esc(l.telefono.replace(/\s/g, ''))}">${this.esc(l.telefono)}</a>` : ''}
                    ${l.notas ? `<br><small>${this.esc(l.notas)}</small>` : ''}
                  </li>
                `).join('')}
              </ul>
            </div>
          ` : ''}
        </article>
      `).join('')}`;
  },

  triajeLabel(item, field) {
    if (!item) return '';
    const lang = window.I18n?.lang || 'es';
    const key = lang === 'en' ? `${field}_en` : `${field}_es`;
    return item[key] || item[`${field}_es`] || item.nombre || '';
  },

  resetTriajeFlow() {
    this.triajeCategoryId = null;
    this.triajeSymptomId = null;
    this.triajeCauseId = null;
  },

  renderTriaje() {
    const container = document.getElementById('triajeContent');
    if (!container) return;
    const data = this.triajeData;
    const disclaimer = data
      ? (window.I18n?.lang === 'en' ? data.disclaimer_en : data.disclaimer_es)
      : this.t('triaje.disclaimer');

    if (!data?.categorias?.length) {
      container.innerHTML = `<div class="empty-state"><div class="empty-icon">⚠️</div><p>${this.esc(this.t('triaje.empty'))}</p></div>`;
      return;
    }

    const category = data.categorias.find(c => c.id === this.triajeCategoryId);
    const symptom = category?.sintomas?.find(s => s.id === this.triajeSymptomId);
    const cause = symptom?.causas?.find(c => c.id === this.triajeCauseId);

    const steps = [
      { id: 'category', label: this.t('triaje.step_category'), active: !category },
      { id: 'symptom', label: this.t('triaje.step_symptom'), active: category && !symptom },
      { id: 'cause', label: this.t('triaje.step_cause'), active: symptom && !cause },
      { id: 'result', label: this.t('triaje.step_result'), active: !!cause }
    ];

    const breadcrumb = steps.map((s, i) => {
      const sep = i > 0 ? ' › ' : '';
      return `${sep}<span class="${s.active ? 'active' : ''}">${this.esc(s.label)}</span>`;
    }).join('');

    let body = '';

    if (!category) {
      body = `
        <h3>${this.esc(this.t('triaje.select_category'))}</h3>
        <div class="triaje-grid">
          ${data.categorias.map(cat => `
            <button type="button" class="triaje-card" data-triaje-category="${this.esc(cat.id)}">
              <h3>${this.esc(this.triajeLabel(cat, 'nombre'))}</h3>
              <p>${(cat.sintomas || []).length} ${this.esc(this.t('triaje.step_symptom').toLowerCase())}(s)</p>
            </button>
          `).join('')}
        </div>`;
    } else if (!symptom) {
      body = `
        <h3>${this.esc(this.t('triaje.select_symptom'))}</h3>
        <div class="triaje-grid">
          ${(category.sintomas || []).map(sym => `
            <button type="button" class="triaje-card" data-triaje-symptom="${this.esc(sym.id)}">
              <h3>${this.esc(this.triajeLabel(sym, 'nombre'))}</h3>
            </button>
          `).join('')}
        </div>`;
    } else if (!cause) {
      body = `
        <h3>${this.esc(this.t('triaje.select_cause'))}</h3>
        <div class="triaje-grid">
          ${(symptom.causas || []).map(c => `
            <button type="button" class="triaje-card" data-triaje-cause="${this.esc(c.id)}">
              <h3>${this.esc(this.triajeLabel(c, 'nombre'))}</h3>
            </button>
          `).join('')}
        </div>`;
    } else {
      const severityKey = `triaje.severity.${cause.gravedad || 'moderada'}`;
      const action = this.triajeLabel(cause, 'accion');
      body = `
        <div class="triaje-result">
          <span class="triaje-severity triaje-severity--${this.esc(cause.gravedad || 'moderada')}">
            ${this.esc(this.t('triaje.severity'))}: ${this.esc(this.t(severityKey))}
          </span>
          <h3>${this.esc(this.triajeLabel(cause, 'nombre'))}</h3>
          <p><strong>${this.esc(this.t('triaje.action'))}:</strong> ${this.esc(action)}</p>
          <p class="triaje-disclaimer" role="note">⚕️ ${this.esc(this.t('triaje.consult_vet'))}: ${this.esc(disclaimer)}</p>
        </div>`;
    }

    container.innerHTML = `
      <p class="triaje-disclaimer" role="note">⚕️ ${this.esc(disclaimer)}</p>
      <nav class="triaje-breadcrumb" aria-label="Pasos de triaje">${breadcrumb}</nav>
      ${body}
      <div class="triaje-actions">
        ${category ? `<button type="button" id="triajeBackBtn">${this.esc(this.t('triaje.back_step'))}</button>` : ''}
        <button type="button" id="triajeRestartBtn">${this.esc(this.t('triaje.restart'))}</button>
      </div>`;

    container.querySelectorAll('[data-triaje-category]').forEach(btn => {
      btn.addEventListener('click', () => {
        this.triajeCategoryId = btn.dataset.triajeCategory;
        this.triajeSymptomId = null;
        this.triajeCauseId = null;
        this.renderTriaje();
      });
    });
    container.querySelectorAll('[data-triaje-symptom]').forEach(btn => {
      btn.addEventListener('click', () => {
        this.triajeSymptomId = btn.dataset.triajeSymptom;
        this.triajeCauseId = null;
        this.renderTriaje();
      });
    });
    container.querySelectorAll('[data-triaje-cause]').forEach(btn => {
      btn.addEventListener('click', () => {
        this.triajeCauseId = btn.dataset.triajeCause;
        this.renderTriaje();
      });
    });
    container.querySelector('#triajeBackBtn')?.addEventListener('click', () => {
      if (cause) this.triajeCauseId = null;
      else if (symptom) this.triajeSymptomId = null;
      else if (category) this.triajeCategoryId = null;
      this.renderTriaje();
    });
    container.querySelector('#triajeRestartBtn')?.addEventListener('click', () => {
      this.resetTriajeFlow();
      this.renderTriaje();
    });
  },

  showToast(message) {
    const container = document.getElementById('toastContainer');
    if (!container) return;
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.setAttribute('role', 'status');
    toast.textContent = message;
    container.appendChild(toast);
    requestAnimationFrame(() => toast.classList.add('toast--visible'));
    setTimeout(() => {
      toast.classList.remove('toast--visible');
      setTimeout(() => toast.remove(), 300);
    }, 3200);
  },

  async shareUrl(url, title) {
    const shareData = { title: title || 'Atlas Animal', url };
    try {
      if (navigator.share && navigator.canShare?.(shareData)) {
        await navigator.share(shareData);
        this.showToast(this.t('share.shared'));
        return;
      }
    } catch (err) {
      if (err?.name === 'AbortError') return;
    }
    try {
      await navigator.clipboard.writeText(url);
      this.showToast(this.t('share.copied'));
    } catch (_) {
      this.showToast(this.t('share.failed'));
    }
  },

  renderShareButton(hash, title) {
    return `
      <button type="button" class="btn-share" data-share-hash="${this.esc(hash)}" data-share-title="${this.esc(title)}"
        aria-label="${this.esc(this.t('share.label'))}">
        <span aria-hidden="true">🔗</span> ${this.esc(this.t('share.button'))}
      </button>`;
  },

  bindShareButtons(root) {
    if (!root) return;
    root.querySelectorAll('.btn-share').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const hash = btn.dataset.shareHash || '';
        const title = btn.dataset.shareTitle || 'Atlas Animal';
        const url = `${window.location.origin}${window.location.pathname}${hash}`;
        this.shareUrl(url, title);
      });
    });
  },

  renderVaccinationCalendar(breed) {
    const cal = this.vaccinationCalendars?.especies?.[breed.animalId];
    if (!cal) return '';
    const phases = [
      { key: 'cachorro', label: this.t('vax.puppy') },
      { key: 'adulto', label: this.t('vax.adult') },
      { key: 'senior', label: this.t('vax.senior') }
    ];
    const columns = phases.map(phase => `
      <div class="vax-phase">
        <h4>${this.esc(phase.label)}</h4>
        <ul>${(cal[phase.key] || []).map(item => `<li>${this.esc(item)}</li>`).join('')}</ul>
      </div>
    `).join('');
    const disclaimer = this.vaccinationCalendars?.disclaimer || this.t('vax.disclaimer');
    return `
      <section class="vax-calendar-section" aria-labelledby="vaxCalTitle">
        <div class="detail-panel vax-calendar-panel">
          <h4 id="vaxCalTitle">📆 ${this.esc(this.t('vax.title'))} — ${cal.icono} ${this.esc(cal.nombre)}</h4>
          <p class="vax-ref">${this.esc(cal.referencia || '')}</p>
          <div class="vax-calendar-grid">${columns}</div>
          <p class="vax-disclaimer" role="note">⚠️ ${this.esc(disclaimer)}</p>
        </div>
      </section>`;
  },

  renderZoonoticBadge(disease) {
    if (!disease?.zoonotica) return '';
    return `<span class="zoonotic-badge" title="${this.esc(this.t('zoonotic.hint'))}">🦠 ${this.esc(this.t('zoonotic.label'))}</span>`;
  },

  bindLangSwitcher() {
    document.querySelectorAll('.lang-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        I18n.setLang(btn.dataset.lang);
        document.querySelectorAll('.lang-btn').forEach(b => {
          b.classList.toggle('active', b.dataset.lang === I18n.lang);
          b.setAttribute('aria-pressed', b.dataset.lang === I18n.lang ? 'true' : 'false');
        });
      });
      btn.classList.toggle('active', btn.dataset.lang === I18n.lang);
      btn.setAttribute('aria-pressed', btn.dataset.lang === I18n.lang ? 'true' : 'false');
    });
  },

  loadCompareList() {
    try {
      const raw = localStorage.getItem(this.COMPARE_KEY);
      this.compareList = raw ? JSON.parse(raw) : [];
    } catch (_) {
      this.compareList = [];
    }
    this.updateCompareBadge();
  },

  saveCompareList() {
    try {
      localStorage.setItem(this.COMPARE_KEY, JSON.stringify(this.compareList));
    } catch (_) { /* sin almacenamiento */ }
    this.updateCompareBadge();
  },

  updateCompareBadge() {
    const badge = document.getElementById('compareBadge');
    const btn = document.getElementById('goCompareBtn');
    const count = this.compareList.length;
    if (badge) {
      badge.hidden = count === 0;
      badge.textContent = String(count);
    }
    if (btn) btn.setAttribute('aria-label', `${this.t('nav.compare')} (${count})`);
  },

  isInCompare(animalId, breedId) {
    return this.compareList.some(item => item.animalId === animalId && item.breedId === breedId);
  },

  addToCompare(breed) {
    if (!breed) return;
    if (this.isInCompare(breed.animalId, breed.id)) return;
    if (this.compareList.length >= this.COMPARE_MAX) {
      alert(this.t('compare.full'));
      return;
    }
    this.compareList.push({ animalId: breed.animalId, breedId: breed.id, nombre: breed.nombre });
    this.saveCompareList();
  },

  removeFromCompare(animalId, breedId) {
    this.compareList = this.compareList.filter(item => !(item.animalId === animalId && item.breedId === breedId));
    this.saveCompareList();
    if (this.currentView === 'compare') this.renderCompare();
  },

  clearCompare() {
    this.compareList = [];
    this.saveCompareList();
    if (this.currentView === 'compare') this.renderCompare();
  },

  getCompareBreeds() {
    return this.compareList
      .map(item => this.findBreed(item.animalId, item.breedId))
      .filter(Boolean);
  },

  showCompare(options = {}) {
    this.renderCompare();
    this.showView('compare');
    if (options.updateHash !== false) this.updateHash('#comparar');
    this.exportE2EState();
  },

  renderCompare() {
    const container = document.getElementById('compareContent');
    if (!container) return;
    const breeds = this.getCompareBreeds();
    if (!breeds.length) {
      container.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">⚖️</div>
          <p>${this.esc(this.t('compare.empty'))}</p>
        </div>`;
      return;
    }

    const fields = [
      { key: 'origen', label: this.t('compare.field.origin') },
      { key: 'peso', label: this.t('compare.field.weight') },
      { key: 'esperanza_vida', label: this.t('compare.field.lifespan') },
      { key: 'temperamento', label: this.t('compare.field.temperament') },
      { key: 'cuidados', label: this.t('compare.field.care') },
      { key: 'alimentacion', label: this.t('compare.field.nutrition') }
    ];

    container.innerHTML = `
      <div class="compare-grid" role="table" aria-label="${this.esc(this.t('compare.title'))}">
        <div class="compare-row compare-row--header" role="row">
          <div class="compare-cell compare-cell--label" role="columnheader"></div>
          ${breeds.map(b => `
            <div class="compare-cell compare-cell--breed" role="columnheader">
              ${this.renderBreedImage(b, 'compare-breed-img')}
              <h3>${this.esc(b.nombre)}</h3>
              <p>${b.animalIcono} ${this.esc(b.animalNombre)} · ${this.sizeLabel(b.tamano)}</p>
              <button type="button" class="compare-remove-btn" data-key="${b.animalId}:${b.id}">${this.esc(this.t('compare.remove'))}</button>
            </div>
          `).join('')}
        </div>
        ${fields.map(field => `
          <div class="compare-row" role="row">
            <div class="compare-cell compare-cell--label" role="rowheader">${this.esc(field.label)}</div>
            ${breeds.map(b => `
              <div class="compare-cell" role="cell">${this.esc(b[field.key] || 'N/D')}</div>
            `).join('')}
          </div>
        `).join('')}
        <div class="compare-row" role="row">
          <div class="compare-cell compare-cell--label" role="rowheader">${this.esc(this.t('compare.field.diseases'))}</div>
          ${breeds.map(b => `
            <div class="compare-cell" role="cell">${b.enfermedades?.length || 0}</div>
          `).join('')}
        </div>
      </div>
    `;

    container.querySelectorAll('.compare-remove-btn').forEach(btn => {
      btn.addEventListener('click', () => {
        const [animalId, breedId] = btn.dataset.key.split(':');
        this.removeFromCompare(animalId, breedId);
      });
    });
  },

  renderUrgency() {
    const container = document.getElementById('urgencyContent');
    if (!container) return;
    const toxLink = `
      <div class="urgency-tools-banner">
        <p>${this.esc(this.t('tox.urgency_link'))}</p>
        <button type="button" class="btn-text-link urgency-tox-btn">${this.esc(this.t('tox.open'))} →</button>
      </div>`;
    const emergLink = `
      <div class="urgency-tools-banner urgency-tools-banner--latam">
        <p>${this.esc(this.t('emerg.urgency_link'))}</p>
        <button type="button" class="btn-text-link urgency-emerg-latam-btn">${this.esc(this.t('emerg.open'))} →</button>
      </div>`;
    const triajeLink = `
      <div class="urgency-tools-banner urgency-tools-banner--triaje">
        <p>${this.esc(this.t('triaje.urgency_link'))}</p>
        <button type="button" class="btn-text-link urgency-triaje-btn">${this.esc(this.t('triaje.open'))} →</button>
      </div>`;
    container.innerHTML = toxLink + emergLink + triajeLink + this.data.animales.map(animal => {
      const breeds = ['pequena', 'mediana', 'grande'].flatMap(size => animal.razas?.[size] || []);
      const alerts = breeds
        .flatMap(b => (Array.isArray(b.senales_alerta) ? b.senales_alerta : [b.senales_alerta]).filter(Boolean))
        .slice(0, 6);
      const emergencies = breeds.map(b => b.emergencias).filter(Boolean).slice(0, 3);
      return `
        <section class="urgency-species-card">
          <header>
            <span class="urgency-species-icon">${animal.icono}</span>
            <div>
              <h3>${this.esc(animal.nombre)}</h3>
              <p>${breeds.length} razas documentadas</p>
            </div>
          </header>
          ${alerts.length ? `
            <div class="urgency-block">
              <h4>⚠️ Señales de alerta</h4>
              <ul>${alerts.map(a => `<li>${this.esc(a)}</li>`).join('')}</ul>
            </div>
          ` : ''}
          ${emergencies.length ? `
            <div class="urgency-block urgency-block--alert">
              <h4>🚨 Emergencias frecuentes</h4>
              ${emergencies.map(e => `<p>${this.esc(e)}</p>`).join('')}
            </div>
          ` : ''}
        </section>
      `;
    }).join('');
    container.querySelector('.urgency-tox-btn')?.addEventListener('click', () => this.showToxicologia());
    container.querySelector('.urgency-emerg-latam-btn')?.addEventListener('click', () => this.showEmergenciasLatam());
    container.querySelector('.urgency-triaje-btn')?.addEventListener('click', () => this.showTriaje());
  },

  getRecentHistory() {
    try {
      const raw = sessionStorage.getItem('atlas_recent_history');
      return raw ? JSON.parse(raw) : [];
    } catch (_) {
      return [];
    }
  },

  saveRecentHistory(items) {
    try {
      sessionStorage.setItem('atlas_recent_history', JSON.stringify(items.slice(0, 5)));
    } catch (_) { /* sin almacenamiento */ }
  },

  trackVisit(entry) {
    const history = this.getRecentHistory().filter(item => item.key !== entry.key);
    history.unshift({ ...entry, visitedAt: Date.now() });
    this.saveRecentHistory(history);
    this.renderRecentHistory();
  },

  renderRecentHistory() {
    const wrapper = document.getElementById('recentHistory');
    const list = document.getElementById('recentHistoryList');
    if (!wrapper || !list) return;
    const history = this.getRecentHistory();
    wrapper.hidden = history.length === 0;
    if (!history.length) {
      list.innerHTML = '';
      return;
    }
    list.innerHTML = history.map(item => `
      <button type="button" class="recent-history-item" data-key="${this.esc(item.key)}" data-type="${this.esc(item.type)}">
        <span class="recent-history-type">${item.type === 'disease' ? '🩺' : '🐾'}</span>
        <span class="recent-history-label">${this.esc(item.label)}</span>
      </button>
    `).join('');
    list.querySelectorAll('.recent-history-item').forEach(btn => {
      btn.addEventListener('click', () => {
        const [animalId, breedId, diseaseSlug] = btn.dataset.key.split(':');
        const breed = this.findBreed(animalId, breedId);
        if (!breed) return;
        if (btn.dataset.type === 'disease' && diseaseSlug) {
          const disease = this.findDisease(breed, diseaseSlug);
          if (disease) this.showDiseaseDetail(breed, disease);
        } else {
          this.showBreedDetail(breed);
        }
      });
    });
  },

  clearRecentHistory() {
    try { sessionStorage.removeItem('atlas_recent_history'); } catch (_) { /* noop */ }
    this.renderRecentHistory();
  },

  getFavorites() {
    try {
      const raw = localStorage.getItem(this.FAVORITES_KEY);
      return raw ? JSON.parse(raw) : [];
    } catch (_) {
      return [];
    }
  },

  saveFavorites(items) {
    try {
      localStorage.setItem(this.FAVORITES_KEY, JSON.stringify(items));
    } catch (_) { /* sin almacenamiento */ }
  },

  isFavorite(hash) {
    return this.getFavorites().some(item => item.hash === hash);
  },

  toggleFavorite(entry) {
    const wasFavorite = this.isFavorite(entry.hash);
    let favorites = this.getFavorites().filter(item => item.hash !== entry.hash);
    if (!wasFavorite) {
      favorites.unshift({
        type: entry.type,
        id: entry.id,
        nombre: entry.nombre,
        hash: entry.hash,
        savedAt: Date.now()
      });
      this.showToast(this.t('favorites.added'));
    } else {
      this.showToast(this.t('favorites.removed'));
    }
    this.saveFavorites(favorites.slice(0, 50));
    this.renderFavorites();
    return !wasFavorite;
  },

  clearFavorites() {
    try { localStorage.removeItem(this.FAVORITES_KEY); } catch (_) { /* noop */ }
    this.renderFavorites();
  },

  renderFavorites() {
    const wrapper = document.getElementById('favoritesPanel');
    const list = document.getElementById('favoritesList');
    if (!wrapper || !list) return;
    const favorites = this.getFavorites();
    wrapper.hidden = favorites.length === 0;
    if (!favorites.length) {
      list.innerHTML = '';
      return;
    }
    list.innerHTML = favorites.map(item => `
      <button type="button" class="favorite-item" data-hash="${this.esc(item.hash)}">
        <span class="favorite-item-icon" aria-hidden="true">${item.type === 'disease' ? '🩺' : '🐾'}</span>
        <span class="favorite-item-label">${this.esc(item.nombre)}</span>
      </button>
    `).join('');
    list.querySelectorAll('.favorite-item').forEach(btn => {
      btn.addEventListener('click', () => {
        const hash = btn.dataset.hash;
        if (!hash) return;
        window.location.hash = hash;
        this.openRouteFromHash();
      });
    });
  },

  renderFavoriteButton(entry) {
    const isFav = this.isFavorite(entry.hash);
    return `
      <button type="button" class="btn-favorite${isFav ? ' btn-favorite--active' : ''}"
        data-favorite-type="${this.esc(entry.type)}"
        data-favorite-id="${this.esc(entry.id)}"
        data-favorite-nombre="${this.esc(entry.nombre)}"
        data-favorite-hash="${this.esc(entry.hash)}"
        aria-pressed="${isFav}"
        aria-label="${this.esc(this.t(isFav ? 'favorites.remove' : 'favorites.add'))}">
        <span aria-hidden="true">${isFav ? '★' : '☆'}</span>
      </button>`;
  },

  bindFavoriteButtons(root) {
    if (!root) return;
    root.querySelectorAll('.btn-favorite').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        const entry = {
          type: btn.dataset.favoriteType,
          id: btn.dataset.favoriteId,
          nombre: btn.dataset.favoriteNombre,
          hash: btn.dataset.favoriteHash
        };
        const isFav = this.toggleFavorite(entry);
        btn.classList.toggle('btn-favorite--active', isFav);
        btn.setAttribute('aria-pressed', String(isFav));
        btn.setAttribute('aria-label', this.t(isFav ? 'favorites.remove' : 'favorites.add'));
        btn.querySelector('span')?.replaceChildren(document.createTextNode(isFav ? '★' : '☆'));
      });
    });
  },

  renderPrintButton() {
    return `
      <button type="button" class="btn-print" aria-label="${this.esc(this.t('print.label'))}">
        <span aria-hidden="true">🖨</span> ${this.esc(this.t('print.button'))}
      </button>`;
  },

  renderPrintDisclaimer() {
    return `<footer class="print-disclaimer" role="note">${this.esc(this.t('print.disclaimer'))}</footer>`;
  },

  bindPrintButtons(root) {
    if (!root) return;
    root.querySelectorAll('.btn-print').forEach(btn => {
      btn.addEventListener('click', (e) => {
        e.stopPropagation();
        window.print();
      });
    });
  },

  renderBibliographicSources(sources) {
    if (!sources?.length) return '';
    const items = sources.map(src => {
      if (typeof src === 'string') {
        return `<li>${this.esc(src)}</li>`;
      }
      const parts = [];
      if (src.titulo) parts.push(`<strong>${this.esc(src.titulo)}</strong>`);
      if (src.autor) parts.push(this.esc(src.autor));
      const meta = [];
      if (src.doi) meta.push(`DOI: ${this.esc(src.doi)}`);
      let body = parts.join(' — ');
      if (src.url) {
        body = `<a href="${this.esc(src.url)}" target="_blank" rel="noopener noreferrer">${body || this.esc(src.url)}</a>`;
      }
      if (meta.length) body += ` <span class="source-meta">(${meta.join(' · ')})</span>`;
      return `<li>${body}</li>`;
    }).join('');
    return `
      <div class="detail-block bibliographic-sources">
        <h4>📚 ${this.esc(this.t('sources.title'))}</h4>
        <ul class="bibliographic-list">${items}</ul>
      </div>`;
  },

  mobileTabForView(view) {
    const map = {
      welcome: 'welcome',
      home: 'explore',
      detail: 'explore',
      disease: 'explore',
      dictionary: 'glossary',
      urgency: 'urgency',
      tools: 'tools',
      rerMer: 'tools',
      toxicologia: 'tools',
      fluidoterapia: 'tools',
      unidades: 'tools',
      predisposiciones: 'explore',
      bcs: 'tools',
      triaje: 'tools',
      flashcards: 'glossary',
      emergenciasLatam: 'urgency',
      compare: 'explore'
    };
    return map[view] || 'welcome';
  },

  updateMobileTabBar(view = this.currentView) {
    const tab = this.mobileTabForView(view);
    document.querySelectorAll('#mobileTabBar .mobile-tab').forEach(btn => {
      const active = btn.dataset.tab === tab;
      btn.classList.toggle('mobile-tab--active', active);
      if (active) btn.setAttribute('aria-current', 'page');
      else btn.removeAttribute('aria-current');
    });
  },

  bindMobileTabBar() {
    const bar = document.getElementById('mobileTabBar');
    if (!bar) return;
    const mq = window.matchMedia('(max-width: 768px)');
    const syncBodyClass = () => {
      document.body.classList.toggle('has-mobile-tab', mq.matches);
    };
    syncBodyClass();
    mq.addEventListener('change', syncBodyClass);

    const actions = {
      welcome: () => this.goWelcome(),
      explore: () => this.enterBrowse('todos'),
      glossary: () => this.showDictionary(),
      urgency: () => this.showUrgency(),
      tools: () => this.showTools()
    };
    bar.querySelectorAll('.mobile-tab').forEach(btn => {
      btn.addEventListener('click', () => {
        const action = actions[btn.dataset.tab];
        if (action) action();
      });
    });
    if (window.I18n) I18n.apply(bar);
    this.updateMobileTabBar();
  },

  updateResultsTitle() {
    const title = document.getElementById('resultsTitle');
    const hint = document.getElementById('searchHint');
    if (hint && !this.searchQuery) {
      hint.textContent = this.t('search.hint');
    }
    if (this.currentAnimal === 'todos') {
      title.textContent = this.t('results.all_breeds');
    } else {
      const animal = this.data.animales.find(a => a.id === this.currentAnimal);
      title.textContent = `${this.t('results.breeds_of')} ${animal.nombre}`;
    }
  },

  sizeLabel(size) {
    const map = {
      pequena: this.t('size.small'),
      mediana: this.t('size.medium'),
      grande: this.t('size.large')
    };
    return map[size] || size;
  },

  esc(text) {
    if (!text) return '';
    return String(text).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;');
  },

  renderList(items) {
    if (!items?.length) return '';
    return `<ul>${items.map(i => `<li>${this.esc(i)}</li>`).join('')}</ul>`;
  },

  renderPanel(title, content, icon = '') {
    if (!content) return '';
    const body = Array.isArray(content) ? this.renderList(content) : `<p>${this.esc(content)}</p>`;
    return `<div class="detail-panel"><h4>${icon} ${title}</h4>${body}</div>`;
  },

  renderNutritionSection(nutricion) {
    if (!nutricion) return '';
    const dietTags = (nutricion.tipos_dietas || [])
      .map(d => `<span class="nutrition-tag">${this.esc(d)}</span>`)
      .join('');
    const etapas = nutricion.dietas_por_etapa || {};
    const etapasHtml = Object.keys(etapas).length
      ? `<div class="nutrition-stages">${Object.entries(etapas).map(([etapa, texto]) => `
          <div class="nutrition-stage">
            <strong>${this.esc(etapa)}</strong>
            <p>${this.esc(texto)}</p>
          </div>`).join('')}</div>`
      : '';

    return `
      <div class="detail-panel nutrition-panel">
        <h4>🥗 Nutrición de la raza</h4>
        <p class="nutrition-summary">${this.esc(nutricion.resumen)}</p>
        ${dietTags ? `<div class="nutrition-block"><h5>Tipos de dieta</h5><div class="nutrition-tags">${dietTags}</div></div>` : ''}
        ${nutricion.frecuencia_alimentacion ? `<div class="nutrition-block"><h5>Frecuencia</h5><p>${this.esc(nutricion.frecuencia_alimentacion)}</p></div>` : ''}
        ${nutricion.porcion_diaria ? `<div class="nutrition-block"><h5>Porciones y cantidad</h5><p>${this.esc(nutricion.porcion_diaria)}</p></div>` : ''}
        ${nutricion.requerimientos_nutricionales?.length ? `<div class="nutrition-block"><h5>Requerimientos nutricionales</h5>${this.renderList(nutricion.requerimientos_nutricionales)}</div>` : ''}
        ${nutricion.alimentos_recomendados?.length ? `<div class="nutrition-block"><h5>Alimentos recomendados</h5>${this.renderList(nutricion.alimentos_recomendados)}</div>` : ''}
        ${nutricion.alimentos_evitar?.length ? `<div class="nutrition-block nutrition-block--warn"><h5>Evitar</h5>${this.renderList(nutricion.alimentos_evitar)}</div>` : ''}
        ${etapasHtml ? `<div class="nutrition-block"><h5>Dietas por etapa</h5>${etapasHtml}</div>` : ''}
        ${nutricion.produccion ? `<div class="nutrition-block"><h5>Nutrición productiva</h5><p>${this.esc(nutricion.produccion)}</p></div>` : ''}
      </div>`;
  },

  renderBreedImage(breed, className) {
    const src = breed.imagen.replace(/\.svg$/, '.jpg');
    return `<img class="${className}" src="${src}"
      sizes="(max-width: 600px) 100vw, (max-width: 900px) 50vw, 400px"
      alt="${this.esc(breed.nombre)}" loading="lazy" decoding="async"
      onerror="this.onerror=null;this.src=this.src.replace('.jpg','.svg')">`;
  },

  renderDiseaseImage(disease, className) {
    const base = disease.imagen || 'images/placeholder.svg';
    const src = base.replace(/\.svg$/, '.jpg');
    const fallback = base.replace(/\.jpg$/, '.svg');
    return `<img class="${className}" src="${src}"
      alt="${this.esc(disease.nombre)}" loading="lazy" decoding="async"
      onerror="this.onerror=null;this.src='${fallback}'">`;
  },

  renderExams(examenes) {
    if (!examenes?.length) return '';
    return `<div class="detail-panel"><h4>🔬 Exámenes complementarios</h4><div class="exam-tags">${examenes.map(e => `<span class="exam-tag">${this.esc(e)}</span>`).join('')}</div></div>`;
  },

  renderProtocolo(protocolo) {
    if (!protocolo?.length) return '';
    const accordion = protocolo.map((p, index) => `
      <details class="protocol-accordion-item" ${index === 0 ? 'open' : ''}>
        <summary>${this.esc(p.principio_activo || 'Fármaco')} — ${this.esc(p.dosis_mg_kg || p.dosis || 'N/D')} mg/kg</summary>
        <dl class="protocol-accordion-body">
          <div><dt>Nombre comercial</dt><dd>${this.esc(p.nombre_comercial || '—')}</dd></div>
          <div><dt>Vía</dt><dd>${this.esc(p.via || '—')}</dd></div>
          <div><dt>Frecuencia</dt><dd>${this.esc(p.frecuencia || '—')}</dd></div>
          <div><dt>Duración</dt><dd>${this.esc(p.duracion || '—')}</dd></div>
          <div><dt>Notas</dt><dd>${this.esc(p.notas || '—')}</dd></div>
        </dl>
      </details>
    `).join('');
    return `
      <div class="detail-block protocol-block">
        <h4>💊 Protocolo farmacológico (mg/kg)</h4>
        <div class="protocol-accordion protocol-mobile-only">${accordion}</div>
        <div class="protocol-table-wrap protocol-desktop-only">
          <table class="protocol-table">
            <thead>
              <tr>
                <th>Principio activo</th>
                <th>Nombre comercial</th>
                <th>Dosis mg/kg</th>
                <th>Vía</th>
                <th>Frecuencia</th>
                <th>Duración</th>
                <th>Notas</th>
              </tr>
            </thead>
            <tbody>
              ${protocolo.map(p => `
                <tr>
                  <td><strong>${this.esc(p.principio_activo || 'N/D')}</strong></td>
                  <td>${this.esc(p.nombre_comercial || '—')}</td>
                  <td><span class="dosis-badge">${this.esc(p.dosis_mg_kg || p.dosis || 'N/D')}</span></td>
                  <td>${this.esc(p.via || '—')}</td>
                  <td>${this.esc(p.frecuencia || '—')}</td>
                  <td>${this.esc(p.duracion || '—')}</td>
                  <td>${this.esc(p.notas || '—')}</td>
                </tr>
              `).join('')}
            </tbody>
          </table>
        </div>
        <p class="protocol-note">⚠️ Dosis orientativas. Solo un veterinario debe calcular y prescribir el tratamiento final.</p>
      </div>`;
  },

  getDoseCalculatorData(breed) {
    const calc = breed.calculadora_dosis;
    if (calc?.farmacos?.length) return calc;
    const farmacos = [];
    const seen = new Set();
    (breed.enfermedades || []).forEach(enf => {
      (enf.protocolo_farmacologico || []).forEach(p => {
        const key = (p.principio_activo || '').toLowerCase();
        if (!key || seen.has(key)) return;
        seen.add(key);
        farmacos.push({
          id: key.replace(/[^a-z0-9]+/g, '_'),
          principio_activo: p.principio_activo,
          nombre_comercial: p.nombre_comercial,
          dosis_texto: p.dosis_mg_kg,
          via: p.via,
          frecuencia: p.frecuencia,
          duracion: p.duracion,
          notas: p.notas,
          enfermedad_origen: enf.nombre,
          calculable: false
        });
      });
    });
    return {
      peso_tipico_kg: this.parseTypicalWeightKg(breed.peso),
      peso_texto: breed.peso,
      farmacos
    };
  },

  parseTypicalWeightKg(pesoTexto) {
    if (!pesoTexto) return 10;
    const range = String(pesoTexto).match(/(\d[\d.,]*)\s*-\s*(\d[\d.,]*)\s*kg/i);
    if (range) {
      const min = parseFloat(range[1].replace(',', '.'));
      const max = parseFloat(range[2].replace(',', '.'));
      return Math.round(((min + max) / 2) * 100) / 100;
    }
    const single = String(pesoTexto).match(/(\d[\d.,]*)\s*kg/i);
    if (single) return parseFloat(single[1].replace(',', '.'));
    return 10;
  },

  calculateDoseForDrug(weightKg, drug) {
    if (!drug?.calculable || !weightKg || weightKg <= 0) {
      return {
        calculable: false,
        message: 'Esta presentación requiere criterio veterinario individual (baño acuario, dosis fija por animal, etc.).'
      };
    }

    const minTotal = Math.round(drug.min_por_kg * weightKg * 1000) / 1000;
    const maxTotal = Math.round(drug.max_por_kg * weightKg * 1000) / 1000;
    const unit = (drug.unidad || '').split('/')[0] || 'mg';
    const rangeText = minTotal === maxTotal
      ? `${this.formatDoseNumber(minTotal)} ${unit}`
      : `${this.formatDoseNumber(minTotal)} – ${this.formatDoseNumber(maxTotal)} ${unit}`;

    const result = {
      calculable: true,
      unit,
      minTotal,
      maxTotal,
      rangeText,
      perKgText: drug.dosis_texto,
      via: drug.via,
      frecuencia: drug.frecuencia
    };

    if (unit === 'mg' && drug.concentracion_mg_ml) {
      const minVol = Math.round((minTotal / drug.concentracion_mg_ml) * 100) / 100;
      const maxVol = Math.round((maxTotal / drug.concentracion_mg_ml) * 100) / 100;
      result.volumeText = minVol === maxVol
        ? `${this.formatDoseNumber(minVol)} ml`
        : `${this.formatDoseNumber(minVol)} – ${this.formatDoseNumber(maxVol)} ml`;
      result.concentracionText = `${drug.concentracion_mg_ml} mg/ml (referencia comercial orientativa)`;
    } else if (unit === 'ml') {
      result.volumeText = rangeText;
    }

    return result;
  },

  formatDoseNumber(value) {
    if (value >= 100) return Math.round(value).toString();
    if (value >= 10) return (Math.round(value * 10) / 10).toString();
    return (Math.round(value * 100) / 100).toString().replace('.', ',');
  },

  renderDoseCalculator(breed) {
    const calc = this.getDoseCalculatorData(breed);
    const farmacos = calc.farmacos || [];
    if (!farmacos.length) return '';

    const defaultWeight = calc.peso_tipico_kg || this.parseTypicalWeightKg(breed.peso);
    const options = farmacos.map((f, i) => `
      <option value="${i}" ${f.calculable ? '' : 'data-noncalc="1"'}>
        ${this.esc(f.principio_activo)} — ${this.esc(f.dosis_texto)} (${this.esc(f.via || 'N/D')})
      </option>`).join('');

    return `
      <section class="dose-calculator-section" aria-labelledby="doseCalcTitle">
        <div class="dose-calculator-panel">
          <h3 id="doseCalcTitle">🧮 Calculadora de dosis</h3>
          <p class="dose-calculator-intro">
            Estima dosis totales a partir de los protocolos documentados para esta raza.
            Peso típico de referencia: <strong>${this.esc(calc.peso_texto || breed.peso || 'N/D')}</strong>.
          </p>
          <form class="dose-calculator-form" id="doseCalculatorForm" novalidate>
            <div class="dose-calculator-grid">
              <div class="dose-field">
                <label for="doseWeightInput">Peso del animal (kg)</label>
                <input
                  type="number"
                  id="doseWeightInput"
                  name="peso_kg"
                  min="0.01"
                  step="0.01"
                  value="${defaultWeight}"
                  inputmode="decimal"
                  aria-describedby="doseWeightHint doseCalcDisclaimer"
                  required
                >
                <span id="doseWeightHint" class="dose-field-hint">Ajusta al peso real medido en consulta.</span>
              </div>
              <div class="dose-field">
                <label for="doseDrugSelect">Fármaco / medicamento</label>
                <select id="doseDrugSelect" name="farmaco" aria-describedby="doseDrugMeta">
                  ${options}
                </select>
                <span id="doseDrugMeta" class="dose-field-hint">Protocolos de enfermedades de esta raza y catálogo de especie.</span>
              </div>
            </div>
            <div class="dose-result" id="doseCalcResult" role="status" aria-live="polite" aria-atomic="true"></div>
            <p class="dose-units-link-wrap">
              <button type="button" class="btn-text-link dose-units-link" data-action="open-units">
                ${this.esc(this.t('units.open_from_dose'))} →
              </button>
            </p>
            <p id="doseCalcDisclaimer" class="dose-calculator-disclaimer" role="note">
              ⚕️ <strong>Aviso educativo:</strong> esta calculadora no sustituye el diagnóstico ni la prescripción de un veterinario colegiado.
              Las dosis deben individualizarse según edad, comorbilidades, vía, formulación y normativa local.
            </p>
          </form>
        </div>
      </section>`;
  },

  bindDoseCalculator(root, breed) {
    const form = root.querySelector('#doseCalculatorForm');
    const weightInput = root.querySelector('#doseWeightInput');
    const drugSelect = root.querySelector('#doseDrugSelect');
    const resultEl = root.querySelector('#doseCalcResult');
    if (!form || !weightInput || !drugSelect || !resultEl) return;

    const calc = this.getDoseCalculatorData(breed);
    const update = () => {
      const weight = parseFloat(String(weightInput.value).replace(',', '.'));
      const drug = calc.farmacos[parseInt(drugSelect.value, 10)];
      if (!drug) {
        resultEl.innerHTML = '<p class="dose-result-empty">Selecciona un fármaco.</p>';
        return;
      }
      if (!weight || weight <= 0) {
        resultEl.innerHTML = '<p class="dose-result-warn">Introduce un peso válido en kilogramos.</p>';
        return;
      }

      const outcome = this.calculateDoseForDrug(weight, drug);
      if (!outcome.calculable) {
        resultEl.innerHTML = `
          <div class="dose-result-card dose-result-card--info">
            <p><strong>${this.esc(drug.principio_activo)}</strong> — ${this.esc(drug.dosis_texto)}</p>
            <p>${this.esc(outcome.message)}</p>
            ${drug.notas ? `<p class="dose-result-note">${this.esc(drug.notas)}</p>` : ''}
          </div>`;
        return;
      }

      resultEl.innerHTML = `
        <div class="dose-result-card">
          <p class="dose-result-heading">Dosis estimada para <strong>${this.formatDoseNumber(weight)} kg</strong></p>
          <dl class="dose-result-metrics">
            <div><dt>Dosis por kg</dt><dd>${this.esc(outcome.perKgText)}</dd></div>
            <div><dt>Dosis total</dt><dd><span class="dosis-badge">${this.esc(outcome.rangeText)}</span></dd></div>
            ${outcome.volumeText ? `<div><dt>Volumen aprox.</dt><dd>${this.esc(outcome.volumeText)}</dd></div>` : ''}
            ${outcome.concentracionText ? `<div><dt>Concentración ref.</dt><dd>${this.esc(outcome.concentracionText)}</dd></div>` : ''}
            <div><dt>Vía</dt><dd>${this.esc(outcome.via || drug.via || '—')}</dd></div>
            <div><dt>Frecuencia</dt><dd>${this.esc(outcome.frecuencia || drug.frecuencia || '—')}</dd></div>
          </dl>
          ${drug.enfermedad_origen ? `<p class="dose-result-source">Fuente protocolo: ${this.esc(drug.enfermedad_origen)}</p>` : ''}
          ${drug.notas ? `<p class="dose-result-note">${this.esc(drug.notas)}</p>` : ''}
        </div>`;
    };

    weightInput.addEventListener('input', update);
    drugSelect.addEventListener('change', update);
    root.querySelector('.dose-units-link')?.addEventListener('click', () => this.showUnidades());
    update();
  },

  renderBreeds() {
    const breeds = this.getFilteredBreeds();
    const grid = document.getElementById('breedGrid');
    document.getElementById('resultsCount').textContent = breeds.length;

    if (!breeds.length) {
      grid.innerHTML = `<div class="empty-state"><div class="empty-icon">🔍</div><p>No se encontraron razas con los filtros del menú lateral.</p></div>`;
      return;
    }

    grid.innerHTML = breeds.map(b => `
      <article class="breed-card" data-key="${b.animalId}:${b.id}">
        ${this.renderBreedImage(b, 'breed-card-img')}
        <div class="breed-card-body">
          <div class="breed-card-tags">
            <span class="tag tag-${b.tamano}">${this.sizeLabel(b.tamano)}</span>
            <span class="tag tag-animal">${b.animalIcono} ${b.animalNombre}</span>
            ${this.getBreedRegion(b) ? `<span class="tag tag-region">🌎 ${this.esc(this.getBreedRegion(b))}</span>` : ''}
            ${b.enfoque_produccion ? `<span class="tag tag-production">🏭 Producción: ${this.esc(b.tipo_produccion)}</span>` : ''}
          </div>
          <h4>${b.nombre}</h4>
          <p>${b.descripcion}</p>
          <div class="breed-card-footer">
            <span>${b.enfermedades?.length || 0} enfermedades documentadas</span>
            <span>Ver detalle →</span>
          </div>
        </div>
      </article>
    `).join('');

    grid.querySelectorAll('.breed-card').forEach(card => {
      card.addEventListener('click', () => {
        const [animalId, breedId] = card.dataset.key.split(':');
        const breed = breeds.find(b => b.animalId === animalId && b.id === breedId);
        if (breed) this.showBreedDetail(breed);
      });
    });
  },

  showBreedDetail(breed, options = {}) {
    this.currentBreed = breed;
    this.currentDisease = null;
    const el = document.getElementById('breedDetail');
    el.innerHTML = `
      <div class="breed-hero">
        <div class="breed-hero-media">${this.renderBreedImage(breed, 'breed-hero-img')}</div>
        <div class="breed-hero-info">
          <h2>${this.esc(breed.nombre)}</h2>
          <div class="breed-meta">
            <span class="meta-chip">${breed.animalIcono} ${this.esc(breed.animalNombre)}</span>
            <span class="meta-chip">Tamaño: ${this.sizeLabel(breed.tamano)}</span>
            <span class="meta-chip">Origen: ${this.esc(breed.origen || 'N/D')}</span>
            <span class="meta-chip">Esperanza de vida: ${this.esc(breed.esperanza_vida || 'N/D')}</span>
            ${breed.altura ? `<span class="meta-chip">Altura: ${this.esc(breed.altura)}</span>` : ''}
          </div>
          <p>${this.esc(breed.descripcion)}</p>
          <div class="breed-hero-actions">
            <button type="button" class="btn-compare-add" data-compare-key="${breed.animalId}:${breed.id}">
              ${this.isInCompare(breed.animalId, breed.id) ? '✓ ' : '+ '}${this.esc(this.t('compare.add'))}
            </button>
            ${this.renderFavoriteButton({
              type: 'breed',
              id: `${breed.animalId}:${breed.id}`,
              nombre: breed.nombre,
              hash: this.breedRoute(breed)
            })}
            ${this.renderPrintButton()}
            ${this.renderShareButton(this.breedRoute(breed), breed.nombre)}
            ${this.renderReportErrorButton({ kind: 'Raza', name: breed.nombre, animalCategory: breed.animalNombre, hash: this.breedRoute(breed) })}
          </div>
          <div class="info-grid">
            <div class="info-item"><label>Peso promedio</label><span>${this.esc(breed.peso || 'N/D')}</span></div>
            <div class="info-item"><label>Temperamento</label><span>${this.esc(breed.temperamento || 'N/D')}</span></div>
            <div class="info-item"><label>Cuidados especiales</label><span>${this.esc(breed.cuidados || 'N/D')}</span></div>
            <div class="info-item"><label>Alimentación</label><span>${this.esc(breed.alimentacion || 'N/D')}</span></div>
          </div>
        </div>
      </div>
      <div class="detail-sections">
        ${this.renderPanel('Historia y origen', breed.historia, '📜')}
        ${this.renderPanel('Características físicas', breed.caracteristicas, '📋')}
        ${this.renderPanel('Aptitudes y uso', breed.aptitudes, '⭐')}
        ${this.renderNutritionSection(breed.nutricion_detallada)}
        ${breed.enfoque_produccion ? this.renderPanel('Tipo de producción', breed.tipo_produccion, '🏭') : ''}
        ${breed.sistema_productivo ? this.renderPanel('Sistema productivo', breed.sistema_productivo, '🏡') : ''}
        ${breed.rendimiento_productivo ? this.renderPanel('Rendimiento productivo', breed.rendimiento_productivo, '📈') : ''}
        ${breed.indicadores_productivos ? this.renderPanel('Indicadores productivos', breed.indicadores_productivos, '📊') : ''}
        ${breed.manejo_productivo ? this.renderPanel('Manejo productivo', breed.manejo_productivo, '🧑‍🌾') : ''}
        ${breed.nutricion_productiva ? this.renderPanel('Nutrición para producción', breed.nutricion_productiva, '🌾') : ''}
        ${breed.bioseguridad_productiva ? this.renderPanel('Bioseguridad productiva', breed.bioseguridad_productiva, '🛡️') : ''}
        ${breed.bienestar_productivo ? this.renderPanel('Bienestar animal', breed.bienestar_productivo, '💚') : ''}
        ${breed.registros_productivos ? this.renderPanel('Registros recomendados', breed.registros_productivos, '🗂️') : ''}
        ${this.renderPanel('Parámetros de salud', breed.parametros_salud, '🩺')}
        ${this.renderPanel('Vacunación recomendada', breed.vacunacion, '💉')}
        ${breed.vacunacion_detallada ? this.renderPanel('Calendario de vacunación', breed.vacunacion_detallada, '📆') : ''}
        ${this.renderPanel('Desparasitación', breed.desparasitacion, '🐛')}
        ${breed.predisposiciones_geneticas ? `${this.renderPanel('Predisposiciones genéticas', breed.predisposiciones_geneticas, '🧬')}<p class="predis-map-link-wrap"><button type="button" class="btn-text-link predis-map-link">${this.esc(this.t('predis.map_link'))} →</button></p>` : ''}
        ${breed.cribado_salud_recomendado ? this.renderPanel('Cribado de salud recomendado', breed.cribado_salud_recomendado, '🔍') : ''}
        ${breed.nutricion_clinica ? this.renderPanel('Nutrición clínica', breed.nutricion_clinica, '🥗') : ''}
        ${breed.manejo_clinico ? this.renderPanel('Manejo clínico', breed.manejo_clinico, '🏥') : ''}
        ${breed.contraindicaciones_especie ? this.renderPanel('Contraindicaciones de especie', breed.contraindicaciones_especie, '⛔') : ''}
        ${this.renderPanel('Señales de alerta', breed.senales_alerta, '⚠️')}
        ${this.renderPanel('Revisiones veterinarias', breed.revisiones, '📅')}
        ${breed.emergencias ? `<div class="detail-panel alert-panel urgent"><h4>🚨 Emergencias frecuentes</h4><p>${this.esc(breed.emergencias)}</p></div>` : ''}
      </div>
      ${this.renderVaccinationCalendar(breed)}
      ${this.renderDoseCalculator(breed)}
      <section class="diseases-section">
        <h3>Enfermedades y condiciones (${breed.enfermedades?.length || 0})</h3>
        <div class="disease-list">
          ${(breed.enfermedades || []).map((e, i) => `
            <div class="disease-card" data-index="${i}">
              ${this.renderDiseaseImage(e, 'disease-card-img')}
              <div class="disease-card-body">
                <span class="severity severity-${e.gravedad || 'moderada'}">${(e.gravedad || 'moderada').toUpperCase()}</span>
                <h4>${this.esc(e.nombre)}</h4>
                <p>${this.esc((e.sintomas || []).slice(0, 3).join(', '))}...</p>
              </div>
            </div>
          `).join('')}
        </div>
      </section>
      ${this.renderPrintDisclaimer()}
    `;

    el.querySelectorAll('.disease-card').forEach(card => {
      card.addEventListener('click', () => {
        const disease = breed.enfermedades[parseInt(card.dataset.index)];
        this.showDiseaseDetail(breed, disease);
      });
    });

    el.querySelector('.btn-compare-add')?.addEventListener('click', (e) => {
      e.stopPropagation();
      this.addToCompare(breed);
      const btn = e.currentTarget;
      btn.textContent = `${this.isInCompare(breed.animalId, breed.id) ? '✓ ' : '+ '}${this.t('compare.add')}`;
    });
    this.bindShareButtons(el);
    this.bindFavoriteButtons(el);
    this.bindPrintButtons(el);
    el.querySelector('.predis-map-link')?.addEventListener('click', () => this.showPredisposiciones());
    this.bindDoseCalculator(el, breed);

    this.showView('detail');
    if (options.updateHash !== false) this.updateHash(this.breedRoute(breed));
    this.updatePageMeta({
      title: `${breed.nombre} — Atlas Animal`,
      description: breed.descripcion || this.DEFAULT_META.description,
      image: breed.imagen,
      imageAlt: `${breed.nombre} — ${breed.animalNombre}`,
      url: this.pageUrl(this.breedRoute(breed)),
      type: 'article'
    });
    this.clearJsonLd();
    this.trackVisit({
      key: `${breed.animalId}:${breed.id}`,
      type: 'breed',
      label: `${breed.nombre} (${breed.animalNombre})`
    });
    this.exportE2EState();
  },

  showDiseaseDetail(breed, disease, options = {}) {
    this.currentBreed = breed;
    this.currentDisease = disease;
    const el = document.getElementById('diseaseDetail');
    el.innerHTML = `
      <div class="disease-detail-card">
        <div class="disease-detail-header">
          <div class="disease-detail-hero">
            ${this.renderDiseaseImage(disease, 'disease-hero-img')}
            <div>
              <h2>${this.esc(disease.nombre)}</h2>
              <p class="breed-ref">${breed.animalIcono} ${this.esc(breed.nombre)} — ${this.esc(breed.animalNombre)}</p>
              <div class="disease-badges">
                <span class="severity severity-${disease.gravedad || 'moderada'}" style="margin-top:0.5rem;display:inline-block">
                  Gravedad: ${disease.gravedad || 'moderada'}
                </span>
                ${this.renderZoonoticBadge(disease)}
              </div>
              <div class="disease-share-row">
                ${this.renderFavoriteButton({
                  type: 'disease',
                  id: `${breed.animalId}:${breed.id}:${this.diseaseSlug(disease)}`,
                  nombre: `${disease.nombre} — ${breed.nombre}`,
                  hash: this.diseaseRoute(breed, disease)
                })}
                ${this.renderPrintButton()}
                ${this.renderShareButton(this.diseaseRoute(breed, disease), `${disease.nombre} — ${breed.nombre}`)}
                ${this.renderReportErrorButton({ kind: 'Enfermedad', name: disease.nombre, animalCategory: breed.animalNombre, hash: this.diseaseRoute(breed, disease) })}
              </div>
            </div>
          </div>
        </div>
        <div class="disease-detail-body">
          ${disease.resumen_1min ? `
          <div class="detail-block study-summary">
            <h4>📖 ${this.esc(this.t('study.summary_title'))}</h4>
            <p class="study-summary-text">${this.esc(disease.resumen_1min)}</p>
            <p class="study-summary-hint">${this.esc(this.t('study.summary_hint'))}</p>
          </div>` : ''}
          <div class="detail-block">
            <h4>🩺 Síntomas</h4>
            ${this.renderList(disease.sintomas)}
          </div>
          ${disease.causas ? `<div class="detail-block"><h4>🔍 Causas</h4><p>${this.esc(disease.causas)}</p></div>` : ''}
          ${disease.factores_riesgo ? `<div class="detail-block"><h4>⚡ Factores de riesgo</h4>${this.renderList(disease.factores_riesgo)}</div>` : ''}
          ${disease.criterios_diagnostico ? `<div class="detail-block"><h4>✅ Criterios diagnósticos</h4><p>${this.esc(disease.criterios_diagnostico)}</p></div>` : ''}
          ${disease.diagnostico_diferencial ? `<div class="detail-block"><h4>↔️ Diagnóstico diferencial</h4>${this.renderList(disease.diagnostico_diferencial)}</div>` : ''}
          ${disease.clasificacion ? `<div class="detail-block"><h4>📊 Clasificación / estadiamiento</h4><p>${this.esc(disease.clasificacion)}</p></div>` : ''}
          <div class="detail-block">
            <h4>🔬 Diagnóstico</h4>
            <p>${this.esc(disease.diagnostico)}</p>
          </div>
          ${this.renderExams(disease.examenes)}
          <div class="detail-block">
            <h4>💊 Tratamiento</h4>
            <p>${this.esc(disease.tratamiento)}</p>
          </div>
          ${this.renderProtocolo(disease.protocolo_farmacologico)}
          ${!disease.protocolo_farmacologico?.length && disease.medicamentos ? `<div class="detail-block"><h4>💉 Medicamentos habituales</h4>${this.renderList(disease.medicamentos)}</div>` : ''}
          <div class="detail-block">
            <h4>🛡️ Prevención</h4>
            <p>${this.esc(disease.prevencion)}</p>
          </div>
          ${disease.cuidados_casa ? `<div class="detail-block"><h4>🏠 Cuidados en casa</h4><p>${this.esc(disease.cuidados_casa)}</p></div>` : ''}
          ${disease.evolucion ? `<div class="detail-block"><h4>📈 Evolución</h4><p>${this.esc(disease.evolucion)}</p></div>` : ''}
          ${disease.pronostico ? `<div class="detail-block"><h4>📊 Pronóstico</h4><p>${this.esc(disease.pronostico)}</p></div>` : ''}
          ${disease.contraindicaciones ? `<div class="detail-block"><h4>⛔ Contraindicaciones</h4>${this.renderList(disease.contraindicaciones)}</div>` : ''}
          ${disease.notas_clinicas ? `<div class="detail-block clinical-note"><h4>📝 Notas clínicas</h4><p>${this.esc(disease.notas_clinicas)}</p></div>` : ''}
          ${disease.notas ? `<div class="detail-block"><h4>📋 Notas adicionales</h4><p>${this.esc(disease.notas)}</p></div>` : ''}
          ${disease.urgencia ? `<div class="alert-panel urgent"><strong>🚨 Cuándo acudir de urgencia:</strong> ${this.esc(disease.urgencia)}</div>` : ''}
          ${this.renderDiseaseTermLinks(disease)}
          ${this.renderBibliographicSources(disease.fuentes_bibliograficas || disease.referencias)}
          <div class="alert-box">
            ⚠️ Información educativa. No sustituye el criterio clínico de un veterinario colegiado. Las dosis requieren prescripción profesional individualizada.
          </div>
        </div>
        ${this.renderPrintDisclaimer()}
      </div>
    `;

    this.bindDiseaseTermLinks(el);
    this.bindShareButtons(el);
    this.bindFavoriteButtons(el);
    this.bindPrintButtons(el);
    this.showView('disease');
    if (options.updateHash !== false) this.updateHash(this.diseaseRoute(breed, disease));
    this.updatePageMeta({
      title: `${disease.nombre} — Atlas Animal`,
      description: disease.diagnostico || disease.prevencion || `${disease.nombre} en ${breed.nombre}`,
      image: disease.imagen || breed.imagen,
      imageAlt: `${disease.nombre} — ${breed.nombre}`,
      url: this.pageUrl(this.diseaseRoute(breed, disease)),
      type: 'article'
    });
    this.setJsonLd(this.jsonLdForDisease(breed, disease));
    this.trackVisit({
      key: `${breed.animalId}:${breed.id}:${this.diseaseSlug(disease)}`,
      type: 'disease',
      label: `${disease.nombre} — ${breed.nombre}`
    });
    this.exportE2EState();
  },

  updateDocumentTitle() {
    const suffix = 'Atlas Animal';
    if (this.currentView === 'detail' && this.currentBreed) {
      document.title = `${this.currentBreed.nombre} — ${suffix}`;
      return;
    }
    if (this.currentView === 'disease' && this.currentDisease) {
      document.title = `${this.currentDisease.nombre} — ${suffix}`;
      return;
    }
    if (this.currentView === 'dictionary') {
      document.title = `Glosario médico — ${suffix}`;
      return;
    }
    if (this.currentView === 'urgency') {
      document.title = `${this.t('nav.urgency')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'compare') {
      document.title = `${this.t('compare.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'tools') {
      document.title = `${this.t('tools.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'rerMer') {
      document.title = `${this.t('rer.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'toxicologia') {
      document.title = `${this.t('tox.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'fluidoterapia') {
      document.title = `${this.t('fluid.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'unidades') {
      document.title = `${this.t('units.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'predisposiciones') {
      document.title = `${this.t('predis.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'bcs') {
      document.title = `${this.t('bcs.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'flashcards') {
      document.title = `${this.t('flash.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'emergenciasLatam') {
      document.title = `${this.t('emerg.title')} — ${suffix}`;
      return;
    }
    if (this.currentView === 'triaje') {
      document.title = `${this.t('triaje.title')} — ${suffix}`;
      return;
    }
    document.title = 'Enciclopedia Animal — Salud Veterinaria';
  },

  renderDiseaseTermLinks(disease) {
    const links = this.crossLinksForDisease(disease.nombre);
    if (!links?.terminos?.length) return '';
    const chips = links.terminos.map(t => `
      <button type="button" class="cross-link-chip disease-term-link"
        data-termino="${this.esc(t.termino)}">
        📖 ${this.esc(t.termino)}
      </button>
    `).join('');
    return `
      <div class="detail-block cross-link-block cross-link-block--terms">
        <h4>📚 Términos del glosario relacionados</h4>
        <p class="cross-link-hint">Consulta la definición clínica de los conceptos que aparecen en esta ficha.</p>
        <div class="cross-link-chips">${chips}</div>
      </div>`;
  },

  bindDiseaseTermLinks(container) {
    if (!container) return;
    container.querySelectorAll('.disease-term-link').forEach(chip => {
      chip.addEventListener('click', () => this.openDictionaryWithTerm(chip.dataset.termino));
    });
  },

  showView(view) {
    this.currentView = view;
    document.getElementById('welcomeView').classList.toggle('active', view === 'welcome');
    document.getElementById('homeView').classList.toggle('active', view === 'home');
    document.getElementById('dictionaryView').classList.toggle('active', view === 'dictionary');
    document.getElementById('urgencyView').classList.toggle('active', view === 'urgency');
    document.getElementById('compareView').classList.toggle('active', view === 'compare');
    document.getElementById('toolsView').classList.toggle('active', view === 'tools');
    document.getElementById('rerMerView').classList.toggle('active', view === 'rerMer');
    document.getElementById('toxicologiaView').classList.toggle('active', view === 'toxicologia');
    document.getElementById('fluidoterapiaView').classList.toggle('active', view === 'fluidoterapia');
    document.getElementById('unidadesView').classList.toggle('active', view === 'unidades');
    document.getElementById('predisposicionesView').classList.toggle('active', view === 'predisposiciones');
    document.getElementById('bcsView').classList.toggle('active', view === 'bcs');
    document.getElementById('flashcardsView').classList.toggle('active', view === 'flashcards');
    document.getElementById('emergenciasLatamView').classList.toggle('active', view === 'emergenciasLatam');
    document.getElementById('triajeView').classList.toggle('active', view === 'triaje');
    document.getElementById('laboratorioView').classList.toggle('active', view === 'laboratorio');
    document.getElementById('changelogView').classList.toggle('active', view === 'changelog');
    document.getElementById('detailView').classList.toggle('active', view === 'detail');
    document.getElementById('diseaseView').classList.toggle('active', view === 'disease');
    this.updateSidebar();
    this.updateMobileTabBar(view);
    this.updateDocumentTitle();
    window.scrollTo({ top: 0, behavior: 'auto' });
  },

  exportE2EState() {
    const stats = this.getCatalogStats();
    const breeds = this.getAllBreeds();
    const inBrowse = this.currentView === 'home' && !this.searchQuery;
    window.__E2E_STATE__ = {
      ready: true,
      view: this.currentView,
      welcomeActive: this.currentView === 'welcome',
      currentAnimal: this.currentAnimal,
      animales: this.data.animales.length,
      razas: stats.breeds || breeds.length,
      enfermedades: stats.diseases || breeds.reduce((n, b) => n + (b.enfermedades?.length || 0), 0),
      chunksLoaded: Object.keys(this.chunkCache).length,
      lazyLoad: !!this.manifest,
      navItems: document.querySelectorAll('#animalNav .nav-btn').length,
      categoryCards: document.querySelectorAll('#welcomeCategoryCards .category-card').length,
      dictionaryTerms: this.getDictionaryTerms().length,
      crossLinkTerms: this.crossLinks?.total_terminos_enlazados || 0,
      crossLinkDiseases: this.crossLinks?.total_enfermedades_enlazadas || 0,
      breedCards: inBrowse ? document.querySelectorAll('#breedGrid .breed-card').length : 0,
      statsAnimales: document.querySelector('#statsContent .stat-value')?.textContent,
      breedOfWeek: !!document.getElementById('breedOfWeekPanel') && !document.getElementById('breedOfWeekPanel').hidden,
      error: null
    };
  }
};

const DisclaimerModal = {
  SESSION_KEY: 'atlas_disclaimer_accepted',

  wasAccepted() {
    try {
      return sessionStorage.getItem(this.SESSION_KEY) === '1';
    } catch (_) {
      return false;
    }
  },

  init() {
    this.overlay = document.getElementById('disclaimerOverlay');
    this.modal = document.getElementById('disclaimerModal');
    this.acceptBtn = document.getElementById('disclaimerAcceptBtn');
    if (!this.overlay || !this.modal || !this.acceptBtn) return;
    if (this.wasAccepted()) return;

    this.isOpen = false;
    this.previousFocus = document.activeElement;
    this.onKeydown = (e) => {
      if (!this.isOpen) return;
      if (e.key === 'Escape') this.dismiss();
      if (e.key === 'Tab') this.trapFocus(e);
    };

    this.acceptBtn.addEventListener('click', () => this.dismiss());
    document.getElementById('disclaimerUrgencyLink')?.addEventListener('click', () => {
      this.dismiss();
      App.showUrgency();
    });
    this.overlay.addEventListener('click', (e) => {
      if (e.target === this.overlay) this.dismiss();
    });
    document.addEventListener('keydown', this.onKeydown);
    this.show();
  },

  show() {
    this.isOpen = true;
    this.overlay.hidden = false;
    this.overlay.setAttribute('aria-hidden', 'false');
    document.body.classList.add('disclaimer-open');
    requestAnimationFrame(() => this.acceptBtn.focus());
  },

  dismiss() {
    this.isOpen = false;
    try { sessionStorage.setItem(this.SESSION_KEY, '1'); } catch (_) { /* noop */ }
    this.overlay.hidden = true;
    this.overlay.setAttribute('aria-hidden', 'true');
    document.body.classList.remove('disclaimer-open');
    document.removeEventListener('keydown', this.onKeydown);
    (this.previousFocus || document.getElementById('goHomeBtn'))?.focus();
    WelcomeTour.tryStart();
  },

  trapFocus(e) {
    const focusable = this.modal.querySelectorAll(
      'button, [href], input, select, textarea, [tabindex]:not([tabindex="-1"])'
    );
    const items = Array.from(focusable).filter((el) => !el.disabled && el.offsetParent !== null);
    if (items.length < 2) return;
    const first = items[0];
    const last = items[items.length - 1];
    if (e.shiftKey && document.activeElement === first) {
      e.preventDefault();
      last.focus();
    } else if (!e.shiftKey && document.activeElement === last) {
      e.preventDefault();
      first.focus();
    }
  }
};

const WelcomeTour = {
  SESSION_KEY: 'atlas_welcome_tour_done',

  steps() {
    return [
      { target: '#welcomeCategoryCards', titleKey: 'tour.step1.title', bodyKey: 'tour.step1.body' },
      { target: '.welcome-search', titleKey: 'tour.step2.title', bodyKey: 'tour.step2.body' },
      { target: '#openDictionaryCard', titleKey: 'tour.step3.title', bodyKey: 'tour.step3.body' },
      { target: '#openToolsCard', titleKey: 'tour.step4.title', bodyKey: 'tour.step4.body' },
      { target: '#favoritesPanel', titleKey: 'tour.step5.title', bodyKey: 'tour.step5.body' }
    ];
  },

  wasDone() {
    try {
      return sessionStorage.getItem(this.SESSION_KEY) === '1';
    } catch (_) {
      return false;
    }
  },

  t(key) {
    return window.I18n ? I18n.t(key) : key;
  },

  tryStart() {
    if (this.wasDone() || window.location.hash) return;
    const overlay = document.getElementById('welcomeTourOverlay');
    if (!overlay) return;
    this.overlay = overlay;
    this.popover = document.getElementById('welcomeTourPopover');
    this.stepLabel = document.getElementById('welcomeTourStepLabel');
    this.titleEl = document.getElementById('welcomeTourTitle');
    this.bodyEl = document.getElementById('welcomeTourBody');
    this.skipBtn = document.getElementById('welcomeTourSkipBtn');
    this.nextBtn = document.getElementById('welcomeTourNextBtn');
    if (!this.popover || !this.nextBtn) return;
    this.currentStep = 0;
    this.highlightEl = null;
    this.skipBtn?.addEventListener('click', () => this.finish());
    this.nextBtn.addEventListener('click', () => this.next());
    this.onKeydown = (e) => {
      if (e.key === 'Escape') this.finish();
    };
    document.addEventListener('keydown', this.onKeydown);
    this.showStep(0);
  },

  showStep(index) {
    const steps = this.steps();
    const step = steps[index];
    if (!step) {
      this.finish();
      return;
    }
    this.clearHighlight();
    const target = document.querySelector(step.target);
    if (target) {
      target.classList.add('welcome-tour-highlight');
      this.highlightEl = target;
      target.scrollIntoView({ behavior: 'smooth', block: 'center' });
    }
    const total = steps.length;
    this.stepLabel.textContent = this.t('tour.step_label')
      .replace('{current}', String(index + 1))
      .replace('{total}', String(total));
    this.titleEl.textContent = this.t(step.titleKey);
    this.bodyEl.textContent = this.t(step.bodyKey);
    this.nextBtn.textContent = index === total - 1 ? this.t('tour.finish') : this.t('tour.next');
    this.overlay.hidden = false;
    this.overlay.setAttribute('aria-hidden', 'false');
    document.body.classList.add('welcome-tour-open');
    requestAnimationFrame(() => this.nextBtn.focus());
    this.currentStep = index;
  },

  next() {
    const nextIndex = this.currentStep + 1;
    if (nextIndex >= this.steps().length) this.finish();
    else this.showStep(nextIndex);
  },

  clearHighlight() {
    if (this.highlightEl) {
      this.highlightEl.classList.remove('welcome-tour-highlight');
      this.highlightEl = null;
    }
  },

  finish() {
    try { sessionStorage.setItem(this.SESSION_KEY, '1'); } catch (_) { /* noop */ }
    this.clearHighlight();
    if (this.overlay) {
      this.overlay.hidden = true;
      this.overlay.setAttribute('aria-hidden', 'true');
    }
    document.body.classList.remove('welcome-tour-open');
    document.removeEventListener('keydown', this.onKeydown);
  }
};

document.addEventListener('DOMContentLoaded', () => {
  DisclaimerModal.init();
  App.init();
});
