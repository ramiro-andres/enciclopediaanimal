#!/usr/bin/env python3
"""Descarga imágenes de razas desde Wikimedia Commons."""

import os
import urllib.request

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
IMG_DIR = os.path.join(ROOT, "images")
os.makedirs(IMG_DIR, exist_ok=True)

IMAGES = {
    "chihuahua": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Chihuahua1_bvdb.jpg/440px-Chihuahua1_bvdb.jpg",
    "yorkshire": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/YorkshireTerrier.jpg/440px-YorkshireTerrier.jpg",
    "pomerania": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/ca/Pomeranian.JPG/440px-Pomeranian.JPG",
    "maltes": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/90/Maltese_600.jpg/440px-Maltese_600.jpg",
    "beagle": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/55/Beagle_600.jpg/440px-Beagle_600.jpg",
    "cocker": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/45/English_Cocker_Spaniel.jpg/440px-English_Cocker_Spaniel.jpg",
    "border_collie": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Border_Collie_600.jpg/440px-Border_Collie_600.jpg",
    "bulldog_frances": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Bulldog_frances.jpg/440px-Bulldog_frances.jpg",
    "labrador": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/26/YellowLabradorLooking_new.jpg/440px-YellowLabradorLooking_new.jpg",
    "pastor_aleman": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0f/German_Shepherd_Dog_600.jpg/440px-German_Shepherd_Dog_600.jpg",
    "golden_retriever": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/bd/Golden_Retriever_600.jpg/440px-Golden_Retriever_600.jpg",
    "gran_danes": "https://upload.wikimedia.org/wikipedia/commons/thumb/e/e8/Great_Dane_600.jpg/440px-Great_Dane_600.jpg",
    "siames": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Traditional_siamese_%28cat%29.jpg/440px-Traditional_siamese_%28cat%29.jpg",
    "persa": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/15/Persian_Cat_600.jpg/440px-Persian_Cat_600.jpg",
    "british_shorthair": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9d/British_shorthair_silver_tabby.jpg/440px-British_shorthair_silver_tabby.jpg",
    "maine_coon": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4e/Mainecoon_cat.jpg/440px-Mainecoon_cat.jpg",
    "ragdoll": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/63/Ragdoll_from_Gatil_Ragbelas.jpg/440px-Ragdoll_from_Gatil_Ragbelas.jpg",
    "bengala": "https://upload.wikimedia.org/wikipedia/commons/thumb/b/ba/Bengalcat-lil-spotted.jpg/440px-Bengalcat-lil-spotted.jpg",
    "singapura": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8e/Singapura_Cat.jpg/440px-Singapura_Cat.jpg",
    "canario": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/57/Serinus_canaria_-England-8.jpg/440px-Serinus_canaria_-England-8.jpg",
    "periquito": "https://upload.wikimedia.org/wikipedia/commons/thumb/7/7e/Melopsittacus_undulatus_-pet-8a.jpg/440px-Melopsittacus_undulatus_-pet-8a.jpg",
    "cacatua": "https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Cacatua_galerita_-perching_on_branch-8a.jpg/440px-Cacatua_galerita_-perching_on_branch-8a.jpg",
    "guacamayo": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5a/Ara_ararauna_Luc_Viatour.jpg/440px-Ara_ararauna_Luc_Viatour.jpg",
    "pony_shetland": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/48/Shetland_Pony_in_Shetland.jpg/440px-Shetland_Pony_in_Shetland.jpg",
    "cuarto_milla": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8d/American_Quarter_Horse.jpg/440px-American_Quarter_Horse.jpg",
    "caballo_andaluz": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1e/Andalusian_horse.jpg/440px-Andalusian_horse.jpg",
    "holstein": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/0c/Holstein_Friesian_cow.jpg/440px-Holstein_Friesian_cow.jpg",
    "angus": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3a/Angus_cattle.jpg/440px-Angus_cattle.jpg",
    "hereford": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4c/Hereford_bull.jpg/440px-Hereford_bull.jpg",
    "cerdo_iberico": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Iberian_pigs.jpg/440px-Iberian_pigs.jpg",
    "cerdo_landrace": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8a/Landrace_pig.jpg/440px-Landrace_pig.jpg",
    "cerdo_duroc": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Duroc_pig.jpg/440px-Duroc_pig.jpg",
    "conejo_mini": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/1f/Dwarf_rabbit.jpg/440px-Dwarf_rabbit.jpg",
    "conejo_angora": "https://upload.wikimedia.org/wikipedia/commons/thumb/6/6e/Angora_rabbit.jpg/440px-Angora_rabbit.jpg",
    "conejo_gigante": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/37/Flemish_Giant_rabbit.jpg/440px-Flemish_Giant_rabbit.jpg",
    "iguana": "https://upload.wikimedia.org/wikipedia/commons/thumb/8/8f/Iguana_iguana_Portoviejo_Ecuador.jpg/440px-Iguana_iguana_Portoviejo_Ecuador.jpg",
    "tortuga": "https://upload.wikimedia.org/wikipedia/commons/thumb/0/00/Testudo_graeca_iberia.jpg/440px-Testudo_graeca_iberia.jpg",
    "serpiente_corn": "https://upload.wikimedia.org/wikipedia/commons/thumb/c/c6/Pantherophis_guttatus.jpg/440px-Pantherophis_guttatus.jpg",
    "goldfish": "https://upload.wikimedia.org/wikipedia/commons/thumb/a/ae/Carassius_auratus.jpg/440px-Carassius_auratus.jpg",
    "betta": "https://upload.wikimedia.org/wikipedia/commons/thumb/1/12/Betta_splendens_male.jpg/440px-Betta_splendens_male.jpg",
    "carpa_koi": "https://upload.wikimedia.org/wikipedia/commons/thumb/4/4a/Koi_fish.jpg/440px-Koi_fish.jpg",
    "oveja_merino": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/Merino_sheep.jpg/440px-Merino_sheep.jpg",
    "cabra_nubia": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Nubian_goat.jpg/440px-Nubian_goat.jpg",
    "llama": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/9e/Llama_lying_down.jpg/440px-Llama_lying_down.jpg",
    "hamster": "https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/Syrian_hamster.jpg/440px-Syrian_hamster.jpg",
    "cobaya": "https://upload.wikimedia.org/wikipedia/commons/thumb/3/3d/Guinea_pig_-_Melbourne_Zoo.jpg/440px-Guinea_pig_-_Melbourne_Zoo.jpg",
    "hurón": "https://upload.wikimedia.org/wikipedia/commons/thumb/5/5f/Ferret_2008.png/440px-Ferret_2008.png",
}

HEADERS = {"User-Agent": "EnciclopediaAnimal/1.0 (educational local project)"}

for name, url in IMAGES.items():
    path = os.path.join(IMG_DIR, f"{name}.jpg")
    if os.path.exists(path) and os.path.getsize(path) > 1000:
        print(f"✓ {name} ya existe")
        continue
    try:
        req = urllib.request.Request(url, headers=HEADERS)
        with urllib.request.urlopen(req, timeout=30) as resp:
            data = resp.read()
        with open(path, "wb") as f:
            f.write(data)
        print(f"✓ Descargado: {name} ({len(data)} bytes)")
    except Exception as e:
        print(f"✗ Error {name}: {e}")

print("\nDescarga completada.")
