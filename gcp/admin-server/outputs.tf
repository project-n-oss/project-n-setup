output "admin_id" {
  value = google_compute_instance.admin.instance_id
}

output "admin_name_suffix" {
  value = random_id.admin_name_suffix.hex
}
