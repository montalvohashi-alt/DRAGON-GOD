'use strict';

// St. Cecilia's College Global Alumni Association - PWA Service Worker
// Synchronized caching strategy mirroring Vite & Workbox configuration

const CACHE_VERSION = 'cecilian-pwa-v1';
const CORE_CACHE = `cecilian-core-${CACHE_VERSION}`;
const FONT_CACHE = 'google-fonts-cache';
const GSTATIC_CACHE = 'gstatic-fonts-cache';
const IMAGE_CACHE = 'images-cache';

const PRECACHE_ASSETS = [
  '/',
  'index.html',
  'manifest.json',
  'favicon.png',
  'icons/Icon-192.png',
  'icons/Icon-512.png',
  'icons/Icon-maskable-512.png',
  'assets/cecilians-seal.jpg',
  'assets/landing-building-1.jpg',
  'assets/landing-building-2.jpg',
  'assets/landing-building-3.jpg',
  'assets/FontManifest.json',
  'main.dart.js',
  'flutter.js'
];

self.addEventListener('install', (event) => {
  self.skipWaiting();
  event.waitUntil(
    caches.open(CORE_CACHE).then((cache) => {
      // Gracefully attempt precache
      return Promise.allSettled(
        PRECACHE_ASSETS.map((url) =>
          cache.add(new Request(url, { cache: 'reload' })).catch((err) => {
            console.warn(`[PWA SW] Precache skip: ${url}`, err);
          })
        )
      );
    })
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((keys) => {
      return Promise.all(
        keys.map((key) => {
          if (
            key !== CORE_CACHE &&
            key !== FONT_CACHE &&
            key !== GSTATIC_CACHE &&
            key !== IMAGE_CACHE
          ) {
            console.log('[PWA SW] Removing outdated cache:', key);
            return caches.delete(key);
          }
        })
      );
    }).then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', (event) => {
  const req = event.request;
  const url = new URL(req.url);

  // Only handle HTTP/HTTPS GET requests
  if (req.method !== 'GET' || !url.protocol.startsWith('http')) {
    return;
  }

  // 1. Google Fonts & Web Fonts: Cache First strategy
  if (url.hostname === 'fonts.googleapis.com') {
    event.respondWith(cacheFirst(req, FONT_CACHE, 365 * 24 * 60 * 60));
    return;
  }
  if (url.hostname === 'fonts.gstatic.com') {
    event.respondWith(cacheFirst(req, GSTATIC_CACHE, 365 * 24 * 60 * 60));
    return;
  }

  // 2. Images: Cache First strategy with network fallback
  if (
    url.hostname.includes('unsplash.com') ||
    req.destination === 'image' ||
    url.pathname.match(/\.(png|jpg|jpeg|svg|gif|webp|ico)$/i)
  ) {
    event.respondWith(cacheFirst(req, IMAGE_CACHE, 30 * 24 * 60 * 60));
    return;
  }

  // 3. Navigation & App Shell: Network First with offline Cache fallback
  if (req.mode === 'navigate') {
    event.respondWith(
      fetch(req)
        .then((response) => {
          if (response && response.status === 200) {
            const clone = response.clone();
            caches.open(CORE_CACHE).then((cache) => cache.put(req, clone));
          }
          return response;
        })
        .catch(async () => {
          const cached = await caches.match(req);
          if (cached) return cached;
          const fallback = await caches.match('index.html');
          return fallback || new Response('Offline: St. Cecilia Alumni Network cached mode active.', {
            headers: { 'Content-Type': 'text/html' }
          });
        })
    );
    return;
  }

  // 4. Default: Stale While Revalidate
  event.respondWith(
    caches.match(req).then((cachedResponse) => {
      const fetchPromise = fetch(req)
        .then((networkResponse) => {
          if (networkResponse && networkResponse.status === 200) {
            const clone = networkResponse.clone();
            caches.open(CORE_CACHE).then((cache) => cache.put(req, clone));
          }
          return networkResponse;
        })
        .catch(() => cachedResponse);

      return cachedResponse || fetchPromise;
    })
  );
});

// Cache-first helper with expiration
async function cacheFirst(request, cacheName, maxAgeSeconds) {
  const cache = await caches.open(cacheName);
  const cachedResponse = await cache.match(request);
  if (cachedResponse) {
    return cachedResponse;
  }

  try {
    const networkResponse = await fetch(request);
    if (networkResponse && networkResponse.status === 200) {
      cache.put(request, networkResponse.clone());
    }
    return networkResponse;
  } catch (err) {
    if (cachedResponse) return cachedResponse;
    throw err;
  }
}
