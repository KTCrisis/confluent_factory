output "tags_map" {
  description = "Map des tags créés (clé = description, valeur = nom du tag)"
  value = {
    for k, tag in confluent_tag.tags : k => tag.name
  }
}