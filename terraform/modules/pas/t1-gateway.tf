resource "nsxt_logical_switch" "pas" {
  admin_state       = "UP"
  description       = "LS created by Terraform"
  display_name      = "${var.pas_ls}"
  transport_zone_id = "${data.nsxt_transport_zone.overlay_tz.id}"
  replication_mode  = "MTEP"
}

resource "nsxt_logical_tier1_router" "pas_t1" {
  description                 = "Tier1 router provisioned by Terraform"
  display_name                = "${var.pas_ls}-T1"
  failover_mode               = "PREEMPTIVE"
  edge_cluster_id             = "${data.nsxt_edge_cluster.edge_cluster.id}"
  enable_router_advertisement = true
  advertise_connected_routes  = true
  advertise_static_routes     = false
  advertise_nat_routes        = false
  advertise_lb_vip_routes     = true
}

resource "nsxt_logical_router_link_port_on_tier0" "link_port_tier0_pas" {
  description       = "TIER0_PORT1 provisioned by Terraform"
  display_name      = "${var.nsxt_t0_router}-TO-${var.pas_ls}-T1-t0_lrp"
  logical_router_id = "${data.nsxt_logical_tier0_router.rtr0.id}"
}

resource "nsxt_logical_router_link_port_on_tier1" "link_port_tier1_pas" {
  description                   = "TIER1_PORT1 provisioned by Terraform"
  display_name                  = "${var.nsxt_t0_router}-TO-${var.pas_ls}-T1-t1_lrp"
  logical_router_id             = "${nsxt_logical_tier1_router.pas_t1.id}"
  linked_logical_router_port_id = "${nsxt_logical_router_link_port_on_tier0.link_port_tier0_pas.id}"
}

resource "nsxt_logical_port" "logical_port1_pas" {
  admin_state       = "UP"
  description       = "LP-PAS provisioned by Terraform"
  display_name      = "LP-PAS"
  logical_switch_id = "${nsxt_logical_switch.pas.id}"
}

resource "nsxt_logical_router_downlink_port" "downlink_port_pas" {
  description                   = "DP1 provisioned by Terraform"
  display_name                  = "PAS"
  logical_router_id             = "${nsxt_logical_tier1_router.pas_t1.id}"
  linked_logical_switch_port_id = "${nsxt_logical_port.logical_port1_pas.id}"
  ip_address                    = "${var.pas_subnet_cidr}"
}

resource "nsxt_spoofguard_switching_profile" "ncp_ha_profile" {
  description                       = "ncp-ha provisioned by Terraform"
  display_name                      = "ncp-ha"
  address_binding_whitelist_enabled = "true"
}
