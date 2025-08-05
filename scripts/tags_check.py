# import sys
# import os
# import json
# import yaml
# import argparse
# import requests
# import logging

# logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s', stream=sys.stderr)

# # --- Arguments ---
# parser = argparse.ArgumentParser(description="Génère les tags depuis un YAML et les crée dans Confluent s'ils n'existent pas.")
# parser.add_argument('--config', required=True, help="Chemin vers le fichier config.yaml")
# parser.add_argument('--endpoint', required=True, help="Endpoint du Schema Registry (ex: https://...confluent.cloud:443)")
# parser.add_argument('--key', required=True, help="Clé API")
# parser.add_argument('--secret', required=True, help="Secret API")
# args = parser.parse_args()

# # --- Fonctions ---

# def load_yaml_config(config_path):
#     with open(config_path, 'r') as file:
#         return yaml.safe_load(file)

# def build_tags_from_config(config):
#     keys_of_interest = ["environment", "team", "cost_center", "domain", "owner"]
#     project_info = config.get("project", {})
#     raw_tags = {}

#     for key in keys_of_interest:
#         value = project_info.get(key)
#         if value:
#             if key == "environment":
#                 value = value.split("-")[-1]
#             raw_tags[key] = f"{value}_{key}"

#     return list(raw_tags.values())

# def fetch_existing_tag_names(endpoint, api_key, api_secret):
#     headers = {'Accept': 'application/json'}
#     url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
#     try:
#         response = requests.get(url, headers=headers, auth=(api_key, api_secret), timeout=10)
#         response.raise_for_status()
#         tags_data = response.json()
#         return set(tag.get('name') for tag in tags_data if tag.get('name'))
#     except Exception as e:
#         logging.error(f"Erreur lors de la récupération des tags existants: {e}")
#         return set()

# def create_tag(endpoint, api_key, api_secret, tag_name):
#     url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
#     headers = {'Content-Type': 'application/json'}
#     payload = {
#         "category": "TAG",
#         "name": tag_name,
#         "description": f"Auto-generated tag: {tag_name}"
#     }
#     try:
#         response = requests.post(url, headers=headers, auth=(api_key, api_secret), json=payload, timeout=10)
#         response.raise_for_status()
#         logging.info(f"✅ Tag créé: {tag_name}")
#         return True
#     except requests.exceptions.HTTPError as e:
#         logging.error(f"Erreur HTTP pour le tag '{tag_name}': {e} - {response.text}")
#     except Exception as e:
#         logging.error(f"Erreur lors de la création du tag '{tag_name}': {e}")
#     return False

# # --- Main Logic ---

# def main():
#     config = load_yaml_config(args.config)
#     tags_to_create = build_tags_from_config(config)
#     logging.info(f"Tags générés depuis le YAML: {tags_to_create}")

#     existing_tags = fetch_existing_tag_names(args.endpoint, args.key, args.secret)
#     logging.info(f"Tags déjà existants: {existing_tags}")

#     missing_tags = [tag for tag in tags_to_create if tag not in existing_tags]
#     logging.info(f"Tags à créer: {missing_tags}")

#     for tag in missing_tags:
#         create_tag(args.endpoint, args.key, args.secret, tag)

# if __name__ == "__main__":
#     main()
#!/usr/bin/env python3

import sys
import os
import json
import yaml
import argparse
import requests
import logging

# logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s', stream=sys.stderr)

# # --- Arguments ---
# parser = argparse.ArgumentParser(description="Génère les tags depuis un YAML et les crée dans Confluent s'ils n'existent pas.")
# parser.add_argument('--config', required=True, help="Chemin vers le fichier config.yaml")
# parser.add_argument('--endpoint', required=True, help="Endpoint du Schema Registry (ex: https://...confluent.cloud:443)")
# parser.add_argument('--key', required=True, help="Clé API")
# parser.add_argument('--secret', required=True, help="Secret API")
# args = parser.parse_args()

# # --- Fonctions ---

# def load_yaml_config(config_path):
#     with open(config_path, 'r') as file:
#         return yaml.safe_load(file)

# def build_tags_from_config(config):
#     """Construit une liste de tags à partir du fichier YAML sous forme [{'name': ..., 'description': ...}]"""
#     keys_of_interest = ["environment", "team", "cost_center", "domain", "owner"]
#     project_info = config.get("project", {})
#     tags = []

#     for key in keys_of_interest:
#         value = project_info.get(key)
#         if value:
#             if key == "environment":
#                 value = value.split("-")[-1]
#             tag_name = f"{value}_{key}"
#             tags.append({"name": tag_name, "description": key})
#     return tags

# def fetch_existing_tag_names(endpoint, api_key, api_secret):
#     """Retourne un set des noms de tags déjà existants dans Confluent"""
#     headers = {'Accept': 'application/json'}
#     url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
#     try:
#         response = requests.get(url, headers=headers, auth=(api_key, api_secret), timeout=10)
#         response.raise_for_status()
#         tags_data = response.json()
#         return set(tag.get('name') for tag in tags_data if tag.get('name'))
#     except Exception as e:
#         logging.error(f"Erreur lors de la récupération des tags existants: {e}")
#         return set()

# def create_tags(endpoint, api_key, api_secret, tags):
#     """Crée une liste de tags dans Confluent Catalog (sans 'category')."""
#     if not tags:
#         logging.info("✅ Aucun tag à créer.")
#         return True

#     url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
#     headers = {'Content-Type': 'application/json'}
#     payload = [
#         {
#             "name": tag["name"],
#             "description": tag["description"] 
#         }
#         for tag in tags
#     ]
#     try:
#         response = requests.post(url, headers=headers, auth=(api_key, api_secret), json=payload, timeout=10)
#         response.raise_for_status()
#         logging.info(f"✅ Tags créés : {[tag['name'] for tag in tags]}")
#         return True
#     except requests.exceptions.HTTPError as e:
#         logging.error(f"❌ Erreur HTTP : {e} - {response.text}")
#     except Exception as e:
#         logging.error(f"❌ Erreur inattendue : {e}")
#     return False

# # --- Main ---

# def main():
#     config = load_yaml_config(args.config)
#     tags_from_yaml = build_tags_from_config(config)
#     logging.info(f"Tags générés depuis le YAML: {[tag['name'] for tag in tags_from_yaml]}")

#     existing_tags = fetch_existing_tag_names(args.endpoint, args.key, args.secret)
#     logging.info(f"Tags déjà existants: {existing_tags}")

#     tags_to_create = [tag for tag in tags_from_yaml if tag["name"] not in existing_tags]
#     logging.info(f"Tags à créer: {[tag['name'] for tag in tags_to_create]}")

#     create_tags(args.endpoint, args.key, args.secret, tags_to_create)

# if __name__ == "__main__":
#     main()

logging.basicConfig(level=logging.INFO, format='%(levelname)s: %(message)s', stream=sys.stderr)

# --- Fonctions ---
def load_yaml_config(config_path):
    try:
        with open(config_path, 'r') as file:
            return yaml.safe_load(file)
    except Exception as e:
        logging.error(f"❌ Impossible de lire le fichier YAML : {e}")
        sys.exit(1)

def get_env_suffix(config):
    env = config.get("project", {}).get("environment", "")
    if not env:
        logging.error("❌ Clé 'environment' manquante dans le fichier YAML.")
        sys.exit(1)
    return env.split("-")[-1]

def get_confluent_credentials(suffix):
    sr_key = os.getenv(f"TF_VAR_kafka_schema_registry_api_key_{suffix}")
    sr_secret = os.getenv(f"TF_VAR_kafka_schema_registry_api_secret_{suffix}")
    sr_endpoint = os.getenv(f"TF_VAR_schema_registry_rest_endpoint_{suffix}")

    if not all([sr_key, sr_secret, sr_endpoint]):
        logging.error(f"❌ Variables manquantes pour le suffixe : {suffix}")
        sys.exit(1)

    return sr_endpoint, sr_key, sr_secret

def build_tags_from_config(config):
    keys_of_interest = ["environment", "team", "cost_center", "domain", "owner"]
    project_info = config.get("project", {})
    tags = []

    for key in keys_of_interest:
        value = project_info.get(key)
        if value:
            if key == "environment":
                value = value.split("-")[-1]
            tag_name = f"{value}_{key}"
            tags.append({"name": tag_name, "description": key})
    return tags

def fetch_existing_tag_names(endpoint, api_key, api_secret):
    headers = {'Accept': 'application/json'}
    url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
    try:
        response = requests.get(url, headers=headers, auth=(api_key, api_secret), timeout=10)
        response.raise_for_status()
        tags_data = response.json()
        return set(tag.get('name') for tag in tags_data if tag.get('name'))
    except Exception as e:
        logging.error(f"Erreur lors de la récupération des tags existants: {e}")
        return set()

def create_tags(endpoint, api_key, api_secret, tags):
    if not tags:
        logging.info("✅ Aucun tag à créer.")
        return True

    url = f"{endpoint.rstrip('/')}/catalog/v1/types/tagdefs"
    headers = {'Content-Type': 'application/json'}
    payload = [{"name": tag["name"], "description": tag["description"]} for tag in tags]

    try:
        response = requests.post(url, headers=headers, auth=(api_key, api_secret), json=payload, timeout=10)
        response.raise_for_status()
        logging.info(f"✅ Tags créés : {[tag['name'] for tag in tags]}")
        return True
    except requests.exceptions.HTTPError as e:
        logging.error(f"❌ Erreur HTTP : {e} - {response.text}")
    except Exception as e:
        logging.error(f"❌ Erreur inattendue : {e}")
    return False

# --- Main ---
def main():
    config_path = os.getenv("CONFIG_PATH")
    if not config_path:
        logging.error("❌ Variable d'environnement CONFIG_PATH manquante.")
        sys.exit(1)

    config = load_yaml_config(config_path)
    suffix = get_env_suffix(config)
    logging.info(f"Environnement suffix: {suffix}")

    endpoint, key, secret = get_confluent_credentials(suffix)

    tags_from_yaml = build_tags_from_config(config)
    logging.info(f"Tags générés depuis le YAML: {[tag['name'] for tag in tags_from_yaml]}")

    existing_tags = fetch_existing_tag_names(endpoint, key, secret)
    logging.info(f"Tags déjà existants: {existing_tags}")

    tags_to_create = [tag for tag in tags_from_yaml if tag["name"] not in existing_tags]
    logging.info(f"Tags à créer: {[tag['name'] for tag in tags_to_create]}")

    create_tags(endpoint, key, secret, tags_to_create)

if __name__ == "__main__":
    main()