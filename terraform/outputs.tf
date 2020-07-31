output "overlay_transport_zone_name" {
  value = "${var.transport_zone_overlay_name}"
}

output "nsxt_t0_router" {
  value = "${var.nsxt_t0_router}"
}

output "pas_floating_ip_pool_name" {
  value = "${var.pas_snat_ip_pool_name}"
}
