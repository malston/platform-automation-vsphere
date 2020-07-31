resource "nsxt_nat_rule" "SNAT traffic for TAS" {
  logical_router_id         = "${data.nsxt_logical_tier0_router.rtr0.id}"
  description               = "SNAT traffic for TAS rule provisioned by Terraform"
  display_name              = "SNAT traffic for TAS"
  action                    = "SNAT"
  enabled                   = true
  translated_network        = "${var.snat_public_ip}"
  match_source_network      = "${var.snat_cidr}"
}
