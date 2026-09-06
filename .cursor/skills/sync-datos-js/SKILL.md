---
name: sync-datos-js
description: >-
  Regenera y sincroniza data/*.js desde JSON en Enciclopedia Animal. Usar al
  editar enciclopedia, diccionario, enlaces clínicos, o cuando CI falle en
  Validar datos JS derivados / actualizar_datos.
---

# Sincronizar datos JSON → JS

Los JSON en `data/` no se cargan solos en producción: se embeben como `data/*.js`.

## Flujo obligatorio

1. Editar `data/*.json` (o scripts Ruby de datos).
2. Ejecutar:

```bash
bash actualizar_datos.sh
```

3. Commitear **JSON y `.js`** juntos.
4. Antes de PR: `bash ejecutar_pruebas.sh`.

## Qué hace `actualizar_datos.sh`

1. `scripts/data/build_medical_dictionary.rb` → `diccionario_medicos.json`
2. `scripts/data/build_cross_links.rb` → `enlaces_clinicos.json`
3. Genera `enciclopedia.js`, `diccionario_medicos.js`, `enlaces_clinicos.js`

## Pipeline completo (lote)

```bash
ruby scripts/data/update_enciclopedia_full.rb
bash actualizar_datos.sh
```

## Fallos típicos

| Síntoma | Acción |
|---------|--------|
| CI: Validar datos JS derivados | Regenerar y `git add data/*.js` |
| Pantalla vacía con `file://` | `bash actualizar_datos.sh` |
| Olvido al commit | `bash scripts/setup/instalar_hooks.sh` (pre-commit) |

## Regla

Nunca abrir PR que toque `data/*.json` sin los `.js` regenerados en el mismo cambio.
