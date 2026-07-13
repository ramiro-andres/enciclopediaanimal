// US-DEV-11 — Service Worker para PWA offline real.
// Precachea el "app shell" y los datos JS críticos (enciclopedia, diccionario y
// enlaces clínicos) para que la app funcione sin red tras la primera visita.
// Las imágenes de razas/enfermedades usan stale-while-revalidate en una caché
// aparte para no invalidar el shell al renovar versión.
const CACHE_VERSION = 'atlas-v13';
const STATIC_CACHE = `${CACHE_VERSION}-static`;
const IMAGE_CACHE = `${CACHE_VERSION}-images`;
const CURRENT_CACHES = [STATIC_CACHE, IMAGE_CACHE];

// App shell + datos JS derivados imprescindibles para funcionar offline.
const PRECACHE_URLS = [
  './',
  './index.html',
  './css/styles.css',
  './js/app.js',
  './js/i18n.js',
  './js/analytics.js',
  './js/analytics-config.js',
  './data/chunks/manifest.js',
  './data/search_index.js',
  './data/lab_reference.js',
  './data/changelog.js',
  './data/diccionario_medicos.js',
  './data/enlaces_clinicos.js',
  './data/toxicologia.js',
  './data/emergencias_latam.js',
  './data/triaje.js',
  './data/calendario_vacunacion.js',
  './data/search_synonyms.js',
  './manifest.webmanifest',
  './images/favicon.svg',
  './images/placeholder.svg',
  './images/og-image.svg'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(STATIC_CACHE).then((cache) => cache.addAll(PRECACHE_URLS)).then(() => self.skipWaiting())
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(
        keys
          .filter((k) => k.startsWith('atlas-') && !CURRENT_CACHES.includes(k))
          .map((k) => caches.delete(k))
      )
    ).then(() => self.clients.claim())
  );
});

function isImageRequest(request, url) {
  return request.destination === 'image' || /\.(png|jpe?g|svg|webp|gif|avif)$/i.test(url.pathname);
}

// Stale-while-revalidate: responde con la caché al instante y actualiza en 2.º plano.
function staleWhileRevalidate(request, cacheName) {
  return caches.open(cacheName).then((cache) =>
    cache.match(request).then((cached) => {
      const network = fetch(request)
        .then((response) => {
          if (response && response.status === 200 && response.type === 'basic') {
            cache.put(request, response.clone());
          }
          return response;
        })
        .catch(() => cached);
      return cached || network;
    })
  );
}

// Cache-first con actualización en red para el app shell y datos JS.
function cacheFirstWithUpdate(request) {
  return caches.match(request).then((cached) => {
    const network = fetch(request)
      .then((response) => {
        if (response && response.status === 200 && response.type === 'basic') {
          const clone = response.clone();
          caches.open(STATIC_CACHE).then((cache) => cache.put(request, clone));
        }
        return response;
      })
      .catch(() => cached);
    return cached || network;
  });
}

self.addEventListener('fetch', (event) => {
  const { request } = event;
  if (request.method !== 'GET') return;

  const url = new URL(request.url);
  if (url.origin !== self.location.origin) return;

  if (isImageRequest(request, url)) {
    event.respondWith(staleWhileRevalidate(request, IMAGE_CACHE));
    return;
  }

  event.respondWith(cacheFirstWithUpdate(request));
});
