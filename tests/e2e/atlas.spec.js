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
});
