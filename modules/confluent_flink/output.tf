output "flink_compute_pool_id" {
  value       = confluent_flink_compute_pool.flink_pool.id
  description = "The ID of the Flink compute pool"
}
