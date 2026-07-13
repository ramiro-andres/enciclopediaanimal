// Lógica pura de calculadoras clínicas (RER/MER, fluidos, dosis, BCS scores).
// App.js conserva el UI/render y delega aquí el cómputo.
(function (global) {
  'use strict';

  const MER_FACTORS = [
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
  ];

  const BCS_DOG_CAT_SCORES = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  const BCS_EQUINE_SCORES = [1, 2, 3, 4, 5];

  const FLUID_PROFILES = {
    perros: { mlKgDay: 60, shockMin: 10, shockMax: 20 },
    gatos: { mlKgDay: 50, shockMin: 10, shockMax: 15 },
    equinos: { mlKgDay: 50, shockMin: 10, shockMax: 20 },
    bovinos: { mlKgDay: 50, shockMin: 10, shockMax: 20 },
    aves: { mlKgDay: 80, shockMin: 5, shockMax: 10 },
    conejos: { mlKgDay: 100, shockMin: 5, shockMax: 10 },
    _default: { mlKgDay: 50, shockMin: 10, shockMax: 20 }
  };

  function kgToLb(kg) {
    return kg * 2.2046226218;
  }

  function lbToKg(lb) {
    return lb / 2.2046226218;
  }

  function calculateRer(kg) {
    if (!kg || kg <= 0) return null;
    return 70 * Math.pow(kg, 0.75);
  }

  function formatDoseNumber(value) {
    if (value >= 100) return Math.round(value).toString();
    if (value >= 10) return (Math.round(value * 10) / 10).toString();
    return (Math.round(value * 100) / 100).toString().replace('.', ',');
  }

  function getFluidProfile(speciesId) {
    return FLUID_PROFILES[speciesId] || FLUID_PROFILES._default;
  }

  function parseTypicalWeightKg(pesoTexto) {
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
  }

  /**
   * Cálculo puro de dosis. Sin i18n: el caller añade message localizado.
   * @returns {{calculable:false}|{calculable:true, unit, minTotal, maxTotal, rangeText, perKgText, via, frecuencia, volumeText?, concentracionMgMl?}}
   */
  function calculateDoseTotals(weightKg, drug) {
    if (!drug?.calculable || !weightKg || weightKg <= 0) {
      return { calculable: false };
    }

    const minTotal = Math.round(drug.min_por_kg * weightKg * 1000) / 1000;
    const maxTotal = Math.round(drug.max_por_kg * weightKg * 1000) / 1000;
    const unit = (drug.unidad || '').split('/')[0] || 'mg';
    const rangeText = minTotal === maxTotal
      ? `${formatDoseNumber(minTotal)} ${unit}`
      : `${formatDoseNumber(minTotal)} – ${formatDoseNumber(maxTotal)} ${unit}`;

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
        ? `${formatDoseNumber(minVol)} ml`
        : `${formatDoseNumber(minVol)} – ${formatDoseNumber(maxVol)} ml`;
      result.concentracionMgMl = drug.concentracion_mg_ml;
    } else if (unit === 'ml') {
      result.volumeText = rangeText;
    }

    return result;
  }

  global.AtlasTools = {
    MER_FACTORS,
    BCS_DOG_CAT_SCORES,
    BCS_EQUINE_SCORES,
    FLUID_PROFILES,
    kgToLb,
    lbToKg,
    calculateRer,
    formatDoseNumber,
    getFluidProfile,
    parseTypicalWeightKg,
    calculateDoseTotals
  };
})(typeof window !== 'undefined' ? window : globalThis);
