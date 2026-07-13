const App = {
  data: null,
  dictionaryData: null,
  crossLinks: null,
  toxicologyData: null,
  vaccinationCalendars: null,
  toxicologyQuery: '',
  toxicologySpecies: 'todos',
  rerMerUnit: 'kg',
  dictionaryQuery: '',
  dictionaryCategory: 'todos',
  currentView: 'welcome',
  currentAnimal: 'todos',
  currentSize: 'todos',
  currentRegion: 'todos',
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
  DEFAULT_META: {
    title: 'Enciclopedia Animal — Salud Veterinaria',
    description: 'Atlas Animal: enciclopedia veterinaria educativa con más de 350 razas, 2.000 enfermedades y glosario médico. Información de referencia que no sustituye la consulta con un veterinario colegiado.',
    image: 'https://ramiro-andres.github.io/enciclopediaanimal/images/og-image.svg',
    imageAlt: 'Atlas Animal, enciclopedia veterinaria educativa',
    url: 'https://ramiro-andres.github.io/enciclopediaanimal/',
    type: 'website'
  },
  currentDictionaryTerm: null,

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
        document.addEventListener('atlas:langchange', () => {
          I18n.apply();
          this.updateCompareBadge();
          if (this.currentView === 'compare') this.renderCompare();
          if (this.currentView === 'tools') this.renderTools();
          if (this.currentView === 'rerMer') this.renderRerMer();
          if (this.currentView === 'toxicologia') this.renderToxicologia();
          if (this.currentView === 'urgency') this.renderUrgency();
          this.renderFavorites();
          this.updateMobileTabBar();
          this.updateResultsTitle();
        });
      }
      this.loadCompareList();
      this.data = await this.loadData();
      if (!this.data?.animales?.length) throw new Error('Datos vacíos o corruptos');
      this.dictionaryData = await this.loadDictionaryData();
      this.crossLinks = await this.loadCrossLinks();
      this.toxicologyData = await this.loadToxicologyData();
      this.vaccinationCalendars = await this.loadVaccinationCalendars();
      this.renderNav();
      this.renderStats();
      this.renderCategoryCards();
      this.renderWelcome();
      this.bindEvents();
      this.showLoadStatus();
      this.renderRecentHistory();
      this.renderFavorites();
      this.bindMobileTabBar();
      if (!this.openRouteFromHash()) this.showView('welcome');
      this.exportE2EState();
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
      return window.ENCICLOPEDIA_DATA;
    }
    try {
      const res = await fetch('data/enciclopedia.json');
      if (res.ok) return await res.json();
    } catch (_) { /* fetch falla en file:// */ }
    return null;
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
    const total = this.getAllBreeds().length;
    const diseases = this.getAllBreeds().reduce((acc, b) => acc + (b.enfermedades?.length || 0), 0);
    const intro = document.getElementById('welcomeIntro');
    if (intro) {
      intro.textContent = `Más de ${total} razas y ${diseases} enfermedades documentadas. Elige una categoría para explorar solo ese tipo, o busca por nombre en toda la enciclopedia.`;
    }
    const btnAll = document.getElementById('btnExploreAll');
    if (btnAll) btnAll.textContent = `Ver todas las razas (${total})`;
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
      breeds = breeds.filter(b => (b.region || this.inferRegion(b.origen)) === this.currentRegion);
    }
    return breeds;
  },

  inferRegion(origen) {
    if (!origen) return null;
    const text = String(origen).toLowerCase();
    const map = {
      colombia: 'Colombia',
      méxico: 'México',
      mexico: 'México',
      argentina: 'Argentina',
      chile: 'Chile'
    };
    return Object.entries(map).find(([key]) => text.includes(key))?.[1] || null;
  },

  getAvailableRegions() {
    const regions = new Set();
    this.getAllBreeds().forEach(b => {
      const region = b.region || this.inferRegion(b.origen);
      if (region) regions.add(region);
    });
    return Array.from(regions).sort((a, b) => a.localeCompare(b, 'es'));
  },

  renderRegionFilters() {
    const container = document.getElementById('regionFilters');
    if (!container) return;
    const regions = this.getAvailableRegions();
    const items = [{ id: 'todos', label: 'Todas' }, ...regions.map(r => ({ id: r, label: r }))];
    container.innerHTML = items.map(item => `
      <li>
        <button type="button" class="region-btn ${this.currentRegion === item.id ? 'active' : ''}" data-region="${this.esc(item.id)}">
          ${this.esc(item.label)}
        </button>
      </li>
    `).join('');
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

  nameMatches(value, query) {
    return this.normalizeSearch(value).includes(this.normalizeSearch(query));
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

  openRouteFromHash() {
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

      if (parts[0] === 'rer-mer') {
        this.showRerMer({ updateHash: false });
        return true;
      }

      if (parts[0] === 'toxicologia') {
        this.showToxicologia({ updateHash: false });
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
        const breed = this.findBreed(parts[1], parts[2]);
        if (breed) {
          this.showBreedDetail(breed, { updateHash: false });
          return true;
        }
      }

      if (parts[0] === 'enfermedad' && parts[1] && parts[2] && parts[3]) {
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

  getGlobalSearchResults() {
    const breeds = [];
    const diseases = [];
    const seenDiseases = new Set();

    this.getAllBreeds().forEach(breed => {
      if (
        this.nameMatches(breed.nombre, this.searchQuery) ||
        this.nameMatches(breed.id, this.searchQuery)
      ) {
        breeds.push(breed);
      }

      (breed.enfermedades || []).forEach(disease => {
        if (!this.nameMatches(disease.nombre, this.searchQuery)) return;
        const key = `${breed.animalId}:${breed.id}:${disease.nombre}`;
        if (seenDiseases.has(key)) return;
        seenDiseases.add(key);
        diseases.push({ disease, breed });
      });
    });

    return { breeds, diseases };
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
    const { breeds, diseases } = this.getGlobalSearchResults();
    const total = breeds.length + diseases.length;
    const container = document.getElementById('searchResults');
    const browse = document.getElementById('browseSection');

    browse.hidden = true;
    container.hidden = false;
    document.getElementById('resultsCount').textContent = breeds.length || total;

    const hint = document.getElementById('searchHint');
    if (hint) {
      hint.textContent = total
        ? `${total} resultado(s): ${breeds.length} raza(s) y ${diseases.length} enfermedad(es). Pulsa Esc para volver al listado.`
        : 'Sin coincidencias por nombre. Prueba otro término o pulsa Esc.';
    }

    if (!total) {
      container.innerHTML = `
        <div class="empty-state">
          <div class="empty-icon">🔍</div>
          <p>No hay razas ni enfermedades con el nombre <strong>“${this.esc(this.searchQuery)}”</strong>.</p>
        </div>`;
      return;
    }

    container.innerHTML = `
      <div class="search-results-header">
        <h3>Resultados para “${this.esc(this.searchQuery)}”</h3>
        <span class="badge">${total}</span>
      </div>
      ${breeds.length ? `
        <section class="search-section">
          <h4>🐾 Razas <span class="search-section-count">${breeds.length}</span></h4>
          <div class="search-breed-grid">
            ${breeds.map(b => `
              <article class="breed-card search-hit-card" data-key="${b.animalId}:${b.id}">
                ${this.renderBreedImage(b, 'breed-card-img')}
                <div class="breed-card-body">
                  <div class="breed-card-tags">
                    <span class="tag tag-${b.tamano}">${this.sizeLabel(b.tamano)}</span>
                    <span class="tag tag-animal">${b.animalIcono} ${b.animalNombre}</span>
                  </div>
                  <h4>${this.esc(b.nombre)}</h4>
                  <p>${this.esc(b.descripcion)}</p>
                  <div class="breed-card-footer">
                    <span>${b.enfermedades?.length || 0} enfermedades</span>
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
          <h4>🩺 Enfermedades <span class="search-section-count">${diseases.length}</span></h4>
          <div class="search-disease-list">
            ${diseases.map(({ disease, breed }, index) => `
              <button type="button" class="search-disease-item" data-index="${index}">
                <span class="severity severity-${disease.gravedad || 'moderada'}">${(disease.gravedad || 'moderada').toUpperCase()}</span>
                <span class="search-disease-name">${this.esc(disease.nombre)}</span>
                <span class="search-disease-breed">${breed.animalIcono} ${this.esc(breed.nombre)} · ${this.esc(breed.animalNombre)}</span>
              </button>
            `).join('')}
          </div>
        </section>
      ` : ''}
    `;

    container.querySelectorAll('.search-hit-card').forEach(card => {
      card.addEventListener('click', () => {
        const [animalId, breedId] = card.dataset.key.split(':');
        const breed = breeds.find(b => b.animalId === animalId && b.id === breedId);
        if (breed) this.showBreedDetail(breed);
      });
    });

    container.querySelectorAll('.search-disease-item').forEach(item => {
      item.addEventListener('click', () => {
        const match = diseases[parseInt(item.dataset.index, 10)];
        if (match) this.showDiseaseDetail(match.breed, match.disease);
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

  enterBrowse(animalId, options = {}) {
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
      const showRegions = onBrowse && this.getAvailableRegions().length > 0;
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
    const breeds = this.getAllBreeds();
    const diseases = breeds.reduce((acc, b) => acc + (b.enfermedades?.length || 0), 0);
    const terms = this.dictionaryData?.total_terminos || this.getDictionaryTerms().length;
    const stats = document.getElementById('welcomeStats');
    if (stats) {
      stats.innerHTML = `
        <div class="welcome-stat"><span class="welcome-stat-value">${this.data.animales.length}</span><span class="welcome-stat-label">Tipos de animal</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${breeds.length}</span><span class="welcome-stat-label">Razas</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${diseases}</span><span class="welcome-stat-label">Enfermedades</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${terms}</span><span class="welcome-stat-label">Términos glosario</span></div>
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
    const breeds = this.getAllBreeds();
    const diseases = breeds.reduce((acc, b) => acc + (b.enfermedades?.length || 0), 0);
    document.getElementById('statsContent').innerHTML = `
      <div class="stat-item"><span>Animales</span><span class="stat-value">${this.data.animales.length}</span></div>
      <div class="stat-item"><span>Razas</span><span class="stat-value">${breeds.length}</span></div>
      <div class="stat-item"><span>Enfermedades</span><span class="stat-value">${diseases}</span></div>
    `;
  },

  renderCategoryCards() {
    const grid = document.getElementById('welcomeCategoryCards');
    if (!grid) return;
    grid.innerHTML = this.data.animales.map(a => {
      const count = ['pequena','mediana','grande'].reduce((n, s) => n + (a.razas[s]?.length || 0), 0);
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
    return this.nameMatches(haystack, query);
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
      `;
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
        icon: '☠️',
        title: this.t('tox.title'),
        desc: this.t('tox.card_desc'),
        action: () => this.showToxicologia()
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
    container.innerHTML = toxLink + this.data.animales.map(animal => {
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
            ${b.region || this.inferRegion(b.origen) ? `<span class="tag tag-region">🌎 ${this.esc(b.region || this.inferRegion(b.origen))}</span>` : ''}
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
        ${breed.predisposiciones_geneticas ? this.renderPanel('Predisposiciones genéticas', breed.predisposiciones_geneticas, '🧬') : ''}
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
    document.getElementById('detailView').classList.toggle('active', view === 'detail');
    document.getElementById('diseaseView').classList.toggle('active', view === 'disease');
    this.updateSidebar();
    this.updateMobileTabBar(view);
    this.updateDocumentTitle();
    window.scrollTo({ top: 0, behavior: 'auto' });
  },

  exportE2EState() {
    const breeds = this.getAllBreeds();
    const inBrowse = this.currentView === 'home' && !this.searchQuery;
    window.__E2E_STATE__ = {
      ready: true,
      view: this.currentView,
      welcomeActive: this.currentView === 'welcome',
      currentAnimal: this.currentAnimal,
      animales: this.data.animales.length,
      razas: breeds.length,
      enfermedades: breeds.reduce((n, b) => n + (b.enfermedades?.length || 0), 0),
      navItems: document.querySelectorAll('#animalNav .nav-btn').length,
      categoryCards: document.querySelectorAll('#welcomeCategoryCards .category-card').length,
      dictionaryTerms: this.getDictionaryTerms().length,
      crossLinkTerms: this.crossLinks?.total_terminos_enlazados || 0,
      crossLinkDiseases: this.crossLinks?.total_enfermedades_enlazadas || 0,
      breedCards: inBrowse ? document.querySelectorAll('#breedGrid .breed-card').length : 0,
      statsAnimales: document.querySelector('#statsContent .stat-value')?.textContent,
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

document.addEventListener('DOMContentLoaded', () => {
  DisclaimerModal.init();
  App.init();
});
