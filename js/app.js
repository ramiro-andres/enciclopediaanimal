const App = {
  data: null,
  dictionaryData: null,
  dictionaryQuery: '',
  dictionaryCategory: 'todos',
  currentView: 'welcome',
  currentAnimal: 'todos',
  currentSize: 'todos',
  currentBreed: null,
  currentDisease: null,
  searchQuery: '',

  async init() {
    try {
      this.data = await this.loadData();
      if (!this.data?.animales?.length) throw new Error('Datos vacíos o corruptos');
      this.dictionaryData = await this.loadDictionaryData();
      this.renderNav();
      this.renderStats();
      this.renderCategoryCards();
      this.renderWelcome();
      this.bindEvents();
      this.showLoadStatus();
      this.showView('welcome');
      this.exportE2EState();
    } catch (err) {
      console.error('Error cargando enciclopedia:', err);
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
    document.getElementById('backDictionaryBtn')?.addEventListener('click', () => this.goWelcome());
    document.getElementById('dictionarySearchInput')?.addEventListener('input', (e) => {
      this.dictionaryQuery = e.target.value.toLowerCase().trim();
      this.renderDictionary();
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
      this.exportE2EState();
    });
    document.getElementById('backDiseaseBtn').addEventListener('click', () => {
      if (this.currentBreed) this.showBreedDetail(this.currentBreed);
    });
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
    return breeds;
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

  enterBrowse(animalId) {
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
  },

  goWelcome() {
    this.currentAnimal = 'todos';
    this.currentSize = 'todos';
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
    const stats = document.getElementById('welcomeStats');
    if (stats) {
      stats.innerHTML = `
        <div class="welcome-stat"><span class="welcome-stat-value">${this.data.animales.length}</span><span class="welcome-stat-label">Tipos de animal</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${breeds.length}</span><span class="welcome-stat-label">Razas</span></div>
        <div class="welcome-stat"><span class="welcome-stat-value">${diseases}</span><span class="welcome-stat-label">Enfermedades</span></div>
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
            <article class="dictionary-term-card">
              <h4>${this.esc(term.termino)}</h4>
              <p class="dictionary-definition">${this.esc(term.definicion)}</p>
              ${term.ejemplo ? `<p class="dictionary-example"><span>Ejemplo:</span> ${this.esc(term.ejemplo)}</p>` : ''}
            </article>
          `).join('')}
        </div>
      </section>
    `).join('');
  },

  showDictionary() {
    if (this.searchQuery) this.clearSearch(false);
    this.renderDictionary();
    this.showView('dictionary');
    this.exportE2EState();
    document.getElementById('dictionarySearchInput')?.focus();
  },

  updateResultsTitle() {
    const title = document.getElementById('resultsTitle');
    const hint = document.getElementById('searchHint');
    if (hint && !this.searchQuery) {
      hint.textContent = 'Búsqueda general por nombre. Atajo: Ctrl+K';
    }
    if (this.currentAnimal === 'todos') {
      title.textContent = 'Todas las razas';
    } else {
      const animal = this.data.animales.find(a => a.id === this.currentAnimal);
      title.textContent = `Razas de ${animal.nombre}`;
    }
  },

  sizeLabel(size) {
    return { pequena: 'Pequeña', mediana: 'Mediana', grande: 'Grande' }[size] || size;
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
    return `
      <div class="detail-block">
        <h4>💊 Protocolo farmacológico (mg/kg)</h4>
        <div class="protocol-table-wrap">
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
        <p style="font-size:0.8rem;color:#856404;margin-top:0.5rem">⚠️ Dosis orientativas. Solo un veterinario debe calcular y prescribir el tratamiento final.</p>
      </div>`;
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

  showBreedDetail(breed) {
    this.currentBreed = breed;
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
    `;

    el.querySelectorAll('.disease-card').forEach(card => {
      card.addEventListener('click', () => {
        const disease = breed.enfermedades[parseInt(card.dataset.index)];
        this.showDiseaseDetail(breed, disease);
      });
    });

    this.showView('detail');
  },

  showDiseaseDetail(breed, disease) {
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
              <span class="severity severity-${disease.gravedad || 'moderada'}" style="margin-top:0.5rem;display:inline-block">
                Gravedad: ${disease.gravedad || 'moderada'}
              </span>
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
          <div class="alert-box">
            ⚠️ Información educativa. No sustituye el criterio clínico de un veterinario colegiado. Las dosis requieren prescripción profesional individualizada.
          </div>
        </div>
      </div>
    `;
    this.showView('disease');
  },

  showView(view) {
    this.currentView = view;
    document.getElementById('welcomeView').classList.toggle('active', view === 'welcome');
    document.getElementById('homeView').classList.toggle('active', view === 'home');
    document.getElementById('dictionaryView').classList.toggle('active', view === 'dictionary');
    document.getElementById('detailView').classList.toggle('active', view === 'detail');
    document.getElementById('diseaseView').classList.toggle('active', view === 'disease');
    this.updateSidebar();
    window.scrollTo({ top: 0, behavior: 'smooth' });
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
      breedCards: inBrowse ? document.querySelectorAll('#breedGrid .breed-card').length : 0,
      statsAnimales: document.querySelector('#statsContent .stat-value')?.textContent,
      error: null
    };
  }
};

document.addEventListener('DOMContentLoaded', () => App.init());
