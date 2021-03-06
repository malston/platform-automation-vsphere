provider "nsxt" {
  host                     = "${var.nsx_hostname}"
  username                 = "${var.nsx_user}"
  password                 = "${var.nsx_password}"
  allow_unverified_ssl     = true
  max_retries              = 10
  retry_min_delay          = 500
  retry_max_delay          = 5000
  retry_on_status_codes    = [429]
}

module "pas" {
  source = "./modules/pas"

  edge_cluster_name             = "${var.edge_cluster_name}"
  transport_zone_vlan_name      = "${var.transport_zone_vlan_name}"
  transport_zone_overlay_name   = "${var.transport_zone_overlay_name}"

  pas_snat_ip_pool_name         = "${var.pas_snat_ip_pool_name}"
  pas_snat_ip_pool_range        = "${var.pas_snat_ip_pool_range}"
  pas_snat_ip_pool_cidr         = "${var.pas_snat_ip_pool_cidr}"

  pas_ls                        = "${var.pas_ls}"

  pas_subnet_cidr               = "${var.pas_subnet_cidr}"
  nsxt_t0_router                     = "${var.nsxt_t0_router}"
  uplink_router_ip              = "${var.uplink_router_ip}"
  static_route_next_hop_ip      = "${var.static_route_next_hop_ip}"

  loadbalancer_type             = "${var.loadbalancer_type}"

  router_server_pool_name       = "${var.router_server_pool_name}"
  diego_brain_server_pool_name  = "${var.diego_brain_server_pool_name}"
  istio_server_pool_name        = "${var.istio_server_pool_name}"

  pas_routers_public_ip         = "${var.pas_routers_public_ip}"
  pas_diego_brains_public_ip    = "${var.pas_diego_brains_public_ip}"
  pas_istio_public_ip           = "${var.pas_istio_public_ip}"

  snat_public_ip                = "${var.snat_public_ip}"
  snat_cidr                     = "${var.snat_cidr}"
}

