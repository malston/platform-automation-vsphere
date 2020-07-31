
output "foundation_name" {
  value = "${var.env_name}"
}

output "overlay_transport_zone_name" {
  value = "${var.transport_zone_overlay_name}"
}

output "router_t0_name" {
  value = "${var.router_t0}"
}

output "pas_ip_block_name" {
  value = "${var.pcf_ip_block_name}"
}

output "pas_ip_block_cidr" {
  value = "${var.pcf_ip_block_cidr}"
}

output "pas_floating_ip_pool_name" {
  value = "${var.pas_snat_ip_pool_name}"
}
