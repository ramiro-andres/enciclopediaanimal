// @ts-check
const { test, expect } = require('@playwright/test');
const path = require('path');
const { pathToFileURL } = require('url');

// URL file:// al index.html en la raíz del repo (sin servidor).
const INDEX_URL = pathToFileURL(
  path.resolve(__dirname, '..', '..', 'index.html')
).href;

async function abrirAtlas(page) {
  await page.goto(INDEX_URL);
  // Espera a que la app termine de inicializar y exponga su estado E2E.
  await page.waitForFunction(() => window.__E2E_STATE__ && window.__E2E_STATE__.ready === true);
}

async function cerrarDisclaimer(page) {
  const aceptar = page.locator('#disclaimerAcceptBtn');
  if (await aceptar.isVisible()) {
    await aceptar.click();
    await expect(page.locator('#disclaimerOverlay')).toBeHidden();
  }
  // Sprint 8: el tour de bienvenida se abre al aceptar el aviso y su backdrop
  // intercepta clics en el resto de la UI (fallo E2E en CI).
  const tourSkip = page.locator('#welcomeTourSkipBtn');
  try {
    await tourSkip.waitFor({ state: 'visible', timeout: 5000 });
    await tourSkip.click();
    await expect(page.locator('#welcomeTourOverlay')).toBeHidden();
  } catch {
    // Tour ya completado o no mostrado en esta sesión.
  }
}

test.describe('Enciclopedia Animal — flujos E2E sin servidor', () => {
  test('carga inicial: datos disponibles y aviso educativo visible', async ({ page }) => {
    await abrirAtlas(page);

    // El modal educativo (disclaimer) debe aparecer en cada carga.
    await expect(page.locator('#disclaimerOverlay')).toBeVisible();
    await expect(page.locator('#disclaimerModal')).toContainText('Aviso importante');

    const estado = await page.evaluate(() => window.__E2E_STATE__);
    expect(estado.razas).toBeGreaterThanOrEqual(140);
    expect(estado.enfermedades).toBeGreaterThanOrEqual(800);
    expect(estado.dictionaryTerms).toBeGreaterThanOrEqual(150);

    await cerrarDisclaimer(page);
    await expect(page.locator('#welcomeView')).toHaveClass(/active/);
  });

  test('flujo raza → enfermedad → términos del glosario relacionados', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    // Explorar todas las razas.
    await page.locator('#btnExploreAll').click();
    await expect(page.locator('#homeView')).toHaveClass(/active/);
    const tarjetas = page.locator('#breedGrid .breed-card');
    await expect(tarjetas.first()).toBeVisible();

    // Abrir la primera raza.
    await tarjetas.first().click();
    await expect(page.locator('#detailView')).toHaveClass(/active/);
    await expect(page.locator('#breedDetail .diseases-section')).toBeVisible();

    // Abrir la primera enfermedad de la raza.
    await page.locator('#breedDetail .disease-card').first().click();
    await expect(page.locator('#diseaseView')).toHaveClass(/active/);
    await expect(page.locator('#diseaseDetail')).toContainText('Síntomas');
  });

  test('flujo glosario: enlaces cruzados a enfermedades (US-UX-04)', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    await page.locator('#goDictionaryBtn').click();
    await expect(page.locator('#dictionaryView')).toHaveClass(/active/);

    // Debe existir al menos un enlace cruzado a una enfermedad.
    const enlace = page.locator('.dictionary-term-link').first();
    await expect(enlace).toBeVisible();

    await enlace.click();
    // Al pulsar un término enlazado se abre la ficha de la enfermedad.
    await expect(page.locator('#diseaseView')).toHaveClass(/active/);
    await expect(page.locator('#diseaseDetail .disease-detail-card')).toBeVisible();
  });

  test('vuelta desde enfermedad al glosario mediante término relacionado', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    await page.locator('#goDictionaryBtn').click();
    await page.locator('.dictionary-term-link').first().click();
    await expect(page.locator('#diseaseView')).toHaveClass(/active/);

    const terminoGlosario = page.locator('.disease-term-link').first();
    // Puede o no haber términos según la enfermedad; si los hay, deben navegar al glosario.
    if (await terminoGlosario.count()) {
      // showView hace scroll al inicio; luego llevamos el chip al viewport y
      // disparamos el clic en el DOM (evita interceptación por layout 3D/sticky).
      await page.waitForFunction(() => window.scrollY === 0);
      await terminoGlosario.scrollIntoViewIfNeeded();
      await terminoGlosario.evaluate((el) => el.click());
      await expect(page.locator('#dictionaryView')).toHaveClass(/active/);
    }
  });

  test('búsqueda global por nombre de raza', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    await page.locator('#searchInputWelcome').fill('chihuahua');
    await expect(page.locator('#homeView')).toHaveClass(/active/);
    await expect(page.locator('#searchResults')).toContainText(/chihuahua/i);
  });

  test('Sprint 9: herramientas BCS y flashcards del glosario', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    // BCS: navegar por la UI (App no se expone en window).
    await page.locator('#openToolsCard').click();
    await expect(page.locator('#toolsView')).toHaveClass(/active/);
    await page.locator('.tools-card').filter({ hasText: /BCS/i }).click();
    await expect(page.locator('#bcsView')).toHaveClass(/active/);
    await expect(page.locator('.bcs-silhouette-svg')).toBeVisible();

    await page.locator('#goDictionaryBtn').click();
    await expect(page.locator('#dictionaryView')).toHaveClass(/active/);
    await page.locator('#openFlashcardsFromDict').click();
    await expect(page.locator('#flashcardsView')).toHaveClass(/active/);
    await expect(page.locator('.flashcard-term')).toBeVisible();
  });

  test('Sprint 10: triaje educativo, modo nocturno y resumen estudio', async ({ page }) => {
    await abrirAtlas(page);
    await cerrarDisclaimer(page);

    // Modo nocturno
    await page.locator('#themeToggleBtn').click();
    await expect(page.locator('html')).toHaveAttribute('data-theme', 'dark');

    // Triaje desde urgencias
    await page.locator('#goUrgencyBtn').click();
    await expect(page.locator('#urgencyView')).toHaveClass(/active/);
    await page.locator('.urgency-triaje-btn').click();
    await expect(page.locator('#triajeView')).toHaveClass(/active/);
    await page.locator('[data-triaje-category]').first().click();
    await page.locator('[data-triaje-symptom]').first().click();
    await page.locator('[data-triaje-cause]').first().click();
    await expect(page.locator('.triaje-result')).toBeVisible();
    await expect(page.locator('.triaje-severity')).toBeVisible();

    // Resumen modo estudio en ficha de enfermedad
    await page.locator('#focusSearchBtn').click();
    await page.locator('#searchInput').fill('hipoglucemia');
    await page.locator('#searchResults .search-result-item').first().click();
    await expect(page.locator('.study-summary')).toBeVisible();
    await expect(page.locator('.study-summary-text')).not.toBeEmpty();
  });
});
