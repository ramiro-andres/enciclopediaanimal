// @ts-check
const { defineConfig, devices } = require('@playwright/test');

// Configuración E2E: las pruebas cargan index.html mediante el protocolo file://
// porque los datos se inyectan como <script> (window.ENCICLOPEDIA_DATA, etc.).
// No se necesita ningún servidor HTTP ni proceso Ruby.
module.exports = defineConfig({
  testDir: './tests/e2e',
  timeout: process.env.CI ? 120_000 : 60_000,
  expect: { timeout: 15_000 },
  fullyParallel: false,
  workers: 1,
  retries: process.env.CI ? 1 : 0,
  reporter: process.env.CI ? [['list'], ['html', { open: 'never' }]] : 'list',
  use: {
    headless: true,
    screenshot: 'only-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    }
  ]
});
