# Imágenes pendientes de reemplazo

Revisión visual de las 482 fotos de razas y las 204 imágenes únicas de enfermedades
(hoja de contactos en navegador, 22-11-2026). Todas las rutas existen y pasan
`list_missing_images.rb` / `list_missing_disease_images.rb`. El problema es la **calidad o
pertinencia** de la imagen, que esos scripts no detectan.

Criterio para reemplazar: foto real del animal (o de la lesión), sin texto incrustado,
sin marca de agua y con licencia libre (Wikimedia Commons o generación propia).

## 1. Razas sin foto (solo SVG de relleno)

| Especie | ID | Raza |
|---|---|---|
| aves | `gallina_criolla_centroamerica` | Gallina Criolla Centroamericana |
| equinos | `caballo_criollo_centroamerica` | Caballo Criollo Centroamericano |
| conejos | `conejo_criollo_centroamerica` | Conejo Criollo Centroamericano |
| ovinos | `borrego_altiplano_bolivia` | Borrego del Altiplano Boliviano |

## 2. Razas con foto equivocada (otra raza u otra especie)

| Especie | ID | Problema |
|---|---|---|
| ovinos | `australiano_chileno` | Muestra un **perro** (pastor australiano), no una oveja |
| aves | `minorca` | Infografía de **Leghorn Blanca**, no Minorca |
| roedores | `rata_fancy` | Parece un hámster, no una rata |
| peces | `pangasius` | Filetes de pescado, no el animal |
| conejos | `conejo_chileno_criollo` | Collage genérico «Razas de conejos» con otras razas |
| porcinos | `lacombe` | Portada de folleto «Porcinos: sementales» |

## 3. Razas con infografía, texto o marca de agua

| Especie | ID | Problema |
|---|---|---|
| perros | `pomerania` | Infografía con texto |
| perros | `pinscher_miniatura` | Infografía con texto |
| perros | `cavalier_king_charles` | Infografía con texto |
| perros | `shiba_inu` | Infografía con texto |
| perros | `basenji` | Infografía con texto |
| perros | `newfoundland` | Panel con texto |
| perros | `shih_tzu` | Foto centrada en una persona sosteniendo cachorros |
| gatos | `sphynx` | Marca de agua |
| gatos | `scottish_fold` | Banner con texto «El gato escocés» |
| aves | `rosella` | Lámina ilustrada de varias aves |
| aves | `codorniz_japonesa` | Página de documento |
| aves | `guajolote_criollo_mexicano` | Portada de artículo académico |
| bovinos | `shorthorn` | Infografía de redes sociales con marca de agua |
| peces | `cherry_barb` | Ficha de acuario con texto «pH GH» |
| ovinos | `ideal_chileno` | Gráfico «Tipos de ovinos» |
| caprinos | `kiko` | Montaje «Boer vs Kiko» |
| caprinos | `oberhasli` | Ilustración con marca de agua de banco de imágenes |
| caprinos | `cabra_nubia_mexicana` | Gráfico «10 tipos de cabras» |
| caprinos | `boer_intl` | Captura de tabla comparativa |
| caprinos | `myotonic_goat` | Marca de agua de banco de imágenes |
| caprinos | `damasco` | Marca de agua de banco de imágenes, muy oscura |
| camelidos | `dromedario` | Infografía «Diferencia entre camello y dromedario» |

## 4. Enfermedades con imagen poco útil

### Diapositivas, documentos o infografías con texto

- `perros_hipoglucemia.jpg`, `perros_enfermedad_periodontal.jpg`, `perros_obesidad.jpg`,
  `perros_epilepsia_idiopatica.jpg`, `perros_sensibilidad_a_farmacos_mutacion_mdr1.jpg`,
  `perros_dermatitis_en_pliegues.jpg`, `perros_mielopatia_degenerativa.jpg`,
  `perros_cancer_hemangiosarcoma_y_linfoma.jpg`
- `gatos_problemas_respiratorios_braquicefalicos.jpg`, `gatos_calculos_urinarios.jpg`
- `equinos_sindrome_metabolico_equino.jpg`
- `bovinos_pododermatitis_digital.jpg`, `bovinos_mastitis.jpg`,
  `bovinos_cojeras_laminitis_y_dermatitis_digital.jpg`
- `porcinos_disenteria_porcina.jpg`, `porcinos_erisipela.jpg`, `porcinos_mycoplasma.jpg`,
  `porcinos_sindrome_de_estres_porcino_pss.jpg`
- `conejos_pasteurelosis.jpg`, `conejos_artritis_por_peso.jpg`
- `reptiles_estomatitis.jpg`
- `peces_intoxicacion_por_amoniaco.jpg`, `peces_parasitos_externos_anclas_piojos_gusanos.jpg`,
  `peces_costia_ichthyobodo.jpg`
- `ovinos_clostridiosis.jpg`
- `caprinos_mastitis.jpg`, `caprinos_listeriosis.jpg`
- `camelidos_anemia_parasitaria.jpg`, `camelidos_meningeal_worm.jpg`, `camelidos_golpe_de_calor.jpg`,
  `camelidos_neumonia.jpg`, `camelidos_parasitos_internos.jpg`,
  `camelidos_parasitos_incluida_la_barberpole.jpg`

### Especie equivocada

- `perros_anemia_de_estres_eritrocitario_imha.jpg`: muestra un gato.

### La misma imagen para enfermedades distintas

- `roedores`: «Cálculos urinarios» e «Insuficiencia cardíaca».
- `aves`: «Ácaros de las vías respiratorias» y «Ácaros de patas».
- `reptiles` «Abscesos y parásitos» y `roedores` «Abscesos por mordeduras».
- `aves` «Obesidad y lipomas» / «Tumores» y `perros` «Lipoma múltiple».

Compartir imagen es aceptable para la misma enfermedad en especies parecidas (mastitis en
rumiantes, cólico en équidos), pero no para enfermedades distintas.

## 5. Otras imágenes del sitio

- Tarjeta «Herramientas clínicas» de la portada: foto de material de oficina lila que no
  encaja con la paleta verde y ámbar del tema.

## Cómo reemplazar

1. Guardar la nueva foto como `images/<id>.jpg` (o `images/enfermedades/<archivo>.jpg`),
   de unos 800 px de ancho y más de 15 KB.
2. Para las razas que hoy usan `.svg`, cambiar `imagen` a `.jpg` en `data/enciclopedia.json`.
3. Ejecutar `bash actualizar_datos.sh` y `bash ejecutar_pruebas.sh`.
4. Subir `CACHE_VERSION` en `sw.js` para que la caché de imágenes se renueve.
