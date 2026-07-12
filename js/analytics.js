/**
 * Analytics sin cookies — GoatCounter (privacy-friendly).
 * El mantenedor configura GOATCOUNTER_ENDPOINT en js/analytics-config.js (opcional).
 */
const Analytics = {
  init() {
    const endpoint = window.GOATCOUNTER_ENDPOINT;
    if (!endpoint) return;
    const script = document.createElement('script');
    script.async = true;
    script.setAttribute('data-goatcounter', endpoint);
    script.src = 'https://gc.zgo.at/count.js';
    document.head.appendChild(script);
  }
};

window.Analytics = Analytics;
