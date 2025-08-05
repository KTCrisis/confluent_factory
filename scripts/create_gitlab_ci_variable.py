import os
import json
import requests
import yaml
import sys
import urllib3

urllib3.disable_warnings(urllib3.exceptions.InsecureRequestWarning)

file_name = os.getenv("FILE_NAME")
gitlab_token = os.getenv("CI_VARIABLES_TOKEN")  
project_id = os.getenv("CI_PROJECT_ID")
ci_api_url = os.getenv("CI_API_V4_URL")

if not all([file_name, gitlab_token, project_id, ci_api_url]):
    print(" Erreur : Les variables d'environnement FILE_NAME, CI_VARIABLES_TOKEN, CI_PROJECT_ID ou CI_API_V4_URL sont manquantes.")
    sys.exit(1)

with open(file_name, "r") as f:
    environments = yaml.safe_load(f)

env = environments["environment"][0]
environment_name = env['name']
cluster_name = env['cluster']['name']
environment_suffix = environment_name.split("-")[-1]

sa_cluster_admin_name = f"SA-{environment_name}-{cluster_name}-cluster_admin-api-key"
sa_schema_registry_manager_name = f"SA-{environment_name}-schema_registry_admin-api-key"

with open("tf_output_credentials.json", "r") as f:
    output_json = json.load(f)

sa_cluster_admin_key = output_json[sa_cluster_admin_name]["Kafka_Cluster_scope"]["credentials"]["key"]
sa_cluster_admin_secret = output_json[sa_cluster_admin_name]["Kafka_Cluster_scope"]["credentials"]["secret"]

sa_schema_registry_manager_key = output_json[sa_schema_registry_manager_name]["Schema_Registry_scope"]["credentials"]["key"]
sa_schema_registry_manager_secret = output_json[sa_schema_registry_manager_name]["Schema_Registry_scope"]["credentials"]["secret"]

schema_registry_rest_endpoint = output_json[sa_schema_registry_manager_name]["Schema_registry_rest_endpoint"]

gitlab_api_url = f"{ci_api_url}/projects/{project_id}/variables"
headers = {
    "PRIVATE-TOKEN": gitlab_token,
    "Content-Type": "application/json"
}

def create_variable(name, value):
    payload = {
        "value": value,
        "masked": False,
        "protected": False
    }
    try:
        get_url = f"{gitlab_api_url}/{name}"
        get_response = requests.get(get_url, headers=headers, verify=False)

        if get_response.status_code == 200:
            put_response = requests.put(get_url, headers=headers, json=payload, verify=False)
            if put_response.status_code == 200:
                print(f"Variable '{name}' mise à jour avec succès.")
            else:
                print(f"Erreur lors de la mise à jour de '{name}' ({put_response.status_code}) : {put_response.text}")
        else:
            payload["key"] = name
            post_response = requests.post(gitlab_api_url, headers=headers, json=payload, verify=False)
            if post_response.status_code == 201:
                print(f"Variable '{name}' créée avec succès.")
            else:
                print(f"Erreur lors de la création de '{name}' ({post_response.status_code}) : {post_response.text}")

    except requests.exceptions.SSLError as ssl_err:
        print(f"Erreur SSL : {ssl_err}")
    except Exception as e:
        print(f"Exception lors de l'appel API : {e}")


create_variable(f"TF_VAR_kafka_cluster_api_key_{environment_suffix}", sa_cluster_admin_key)
create_variable(f"TF_VAR_kafka_cluster_api_secret_{environment_suffix}", sa_cluster_admin_secret)

create_variable(f"TF_VAR_kafka_schema_registry_api_key_{environment_suffix}", sa_schema_registry_manager_key)
create_variable(f"TF_VAR_kafka_schema_registry_api_secret_{environment_suffix}", sa_schema_registry_manager_secret)

create_variable(f"TF_VAR_schema_registry_rest_endpoint_{environment_suffix}", schema_registry_rest_endpoint)

