// Utilidades compartidas del atlas (sin bundler).
// App mantiene fachada: this.esc / prefersReducedMotion / scrollBehaviorPref.
(function (global) {
  'use strict';

  function prefersReducedMotion() {
    try {
      return window.matchMedia('(prefers-reduced-motion: reduce)').matches;
    } catch (_) {
      return false;
    }
  }

  function scrollBehaviorPref() {
    return prefersReducedMotion() ? 'auto' : 'smooth';
  }

  /** Escape HTML para texto y atributos (incluye " y '). */
  function esc(text) {
    if (text == null || text === false) return '';
    return String(text)
      .replace(/&/g, '&amp;')
      .replace(/</g, '&lt;')
      .replace(/>/g, '&gt;')
      .replace(/"/g, '&quot;')
      .replace(/'/g, '&#39;');
  }

  /** Resuelve modo light/dark a partir de 'light' | 'dark' | 'auto'. */
  function resolveTheme(mode) {
    const prefersDark = window.matchMedia('(prefers-color-scheme: dark)').matches;
    const isDark = mode === 'dark' || (mode === 'auto' && prefersDark);
    return {
      prefersDark,
      isDark,
      dataTheme: isDark ? 'dark' : 'light'
    };
  }

  global.AtlasUtils = {
    prefersReducedMotion,
    scrollBehaviorPref,
    esc,
    resolveTheme
  };
})(typeof window !== 'undefined' ? window : globalThis);
