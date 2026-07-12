# Política de privacidad y analítica

**Historia:** US-DEV-06  
**Última actualización:** 12 de julio de 2026

## Resumen

Atlas Animal es un sitio estático educativo. No recopilamos datos personales ni usamos cookies de seguimiento.

## Analítica (opcional)

El mantenedor puede activar [GoatCounter](https://www.goatcounter.com/) — analítica **sin cookies**, código abierto, métricas agregadas (páginas vistas, referrers).

### Activación

1. Crear sitio en GoatCounter
2. Editar `js/analytics-config.js`:

```javascript
window.GOATCOUNTER_ENDPOINT = 'https://TU_CODIGO.goatcounter.com/count';
```

3. El script `js/analytics.js` carga el contador solo si el endpoint está definido

### Datos recopilados (si está activo)

- URL visitada (agregada)
- Referrer
- Navegador/OS (genérico)
- **No** IP almacenada permanentemente (GoatCounter descarta IPs)

## Almacenamiento local

| Clave | Uso |
|-------|-----|
| `atlas_lang` | Preferencia de idioma ES/EN |
| `sessionStorage` historial | Últimas 5 fichas visitadas (solo en la sesión) |
| Service Worker cache | Assets para uso offline |

## Disclaimer educativo

El contenido no sustituye consulta veterinaria. Ver modal de aviso en cada visita.

## Contacto

Issues en [ramiro-andres/enciclopediaanimal](https://github.com/ramiro-andres/enciclopediaanimal).
