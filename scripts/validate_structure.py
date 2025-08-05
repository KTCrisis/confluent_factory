import sys
import yaml

REQUIRED_STRUCTURE = {
    'project': {
        'name': str,
        'environment': str,
        'cluster': str,
        'team': str,
        'domain': str,
        'cost_center': str,
        'owner': str
    },
    'resources': {
        'topics': list,
        'schema_registry': list,
        'connectors': {
            'source': list,
            'sink': list
        },  
        'acl': {
            'acl_to_produce': {
                'topic': list
            },
            'acl_to_consume': {
                'topic': list
            }
        }
    }
}

def validate_structure(data, expected, path="", errors=None):
    if errors is None:
        errors = set()
    if not isinstance(data, dict):
        errors.add(f"Error:{path} should be a dictionary")
        return errors
    for key, value in expected.items():
        current_path = f"{path}.{key}" if path else key
        if key not in data:
            errors.add(f"Error:Missing required key '{current_path}'")
        else:
            if isinstance(value, dict):
                errors.update(validate_structure(data[key], value, current_path, errors))
            elif value == dict:
                if not isinstance(data[key], dict):
                    errors.add(f"Error:{current_path} should be a dictionary")
            elif not isinstance(data[key], value):
                errors.add(f"Error:{current_path} should be of type {value.__name__}")
    return errors

try:
    with open('config.yml', 'r') as f:
        data = yaml.safe_load(f)

    errors = validate_structure(data, REQUIRED_STRUCTURE)

    if errors:
        for error in errors:
            print(error)
        sys.exit(1)
    else:
        print("Structure validation passed!")
        sys.exit(0)

except Exception as e:
    print(f"Error:{str(e)}")
    sys.exit(1)

# import sys
# import yaml

# # Définition de la structure attendue
# REQUIRED_STRUCTURE = {
#     'project': {
#         'name': str,
#         'environment': str,
#         'cluster': str,
#         'team': str,
#         'domain': str,
#         'cost_center': str,
#         'owner': str
#     },
#     'resources': {
#         'topics': [
#             {
#                 'name': str,
#                 'partitions': int,
#                 'retention_ms': int
#             }
#         ],
#         'schema_registry': list,
#         'connectors': {
#             'source': list,
#             'sink': list
#         },
#         'acl': {
#             'acl_to_produce': {
#                 'topic': list
#             },
#             'acl_to_consume': {
#                 'topic': list
#             }
#         }
#     }
# }

# def validate_structure(data, expected, path="", errors=None):
#     if errors is None:
#         errors = set()

#     # Vérification si la donnée est un dictionnaire
#     if not isinstance(data, dict):
#         errors.add(f"Error: {path} should be a dictionary")
#         return errors

#     for key, value in expected.items():
#         current_path = f"{path}.{key}" if path else key
        
#         # Si la clé est absente, on ajoute une erreur
#         if key not in data:
#             errors.add(f"Error: Missing required key '{current_path}'")
#         else:
#             # Si la valeur attendue est un dictionnaire, on valide récursivement
#             if isinstance(value, dict):
#                 errors.update(validate_structure(data[key], value, current_path, errors))
            
#             # Si la valeur attendue est une liste d'objets, on vérifie chaque élément
#             elif isinstance(value, list):
#                 # On vérifie les éléments de la liste, s'il y a des objets à valider
#                 if len(value) > 0 and isinstance(value[0], dict):
#                     for i, item in enumerate(data[key]):
#                         errors.update(validate_structure(item, value[0], f"{current_path}[{i}]", errors))
#                 else:
#                     if not isinstance(data[key], list):
#                         errors.add(f"Error: {current_path} should be a list")
            
#             # Si la valeur attendue est d'un type particulier (str, int, etc.), on vérifie le type
#             elif not isinstance(data[key], value):
#                 errors.add(f"Error: {current_path} should be of type {value.__name__}")

#     return errors

# try:
#     with open('config.yml', 'r') as f:
#         data = yaml.safe_load(f)

#     # Valider la structure
#     errors = validate_structure(data, REQUIRED_STRUCTURE)

#     # Si des erreurs sont présentes, les afficher
#     if errors:
#         for error in errors:
#             print(error)
#         sys.exit(1)
#     else:
#         print("Structure validation passed!")
#         sys.exit(0)

# except Exception as e:
#     print(f"Error: {str(e)}")
#     sys.exit(1)
