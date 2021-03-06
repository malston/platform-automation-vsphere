resource "nsxt_lb_tcp_monitor" "istio_tcp_monitor" {
  description  = "istio_tcp_monitor provisioned by Terraform"
  display_name = "istio_tcp_monitor"
  fall_count   = 3
  interval     = 5
  monitor_port = 8002
  rise_count   = 3
  timeout      = 15
}

resource "nsxt_lb_tcp_monitor" "pcf_tcp_monitor" {
  description  = "pcf_tcp_monitor provisioned by Terraform"
  display_name = "pcf_tcp_monitor"
  fall_count   = 3
  interval     = 5
  rise_count   = 3
  timeout      = 15
}

# Server Pools
resource "nsxt_lb_pool" "router_server_pool" {
  description              = "router_server_pool provisioned by Terraform"
  display_name             = "${var.router_server_pool_name}"
  algorithm                = "LEAST_CONNECTION"
  min_active_members       = 1
  tcp_multiplexing_enabled = false
  tcp_multiplexing_number  = 6
  active_monitor_id        = "${nsxt_lb_tcp_monitor.pcf_tcp_monitor.id}"
  snat_translation {
    type = "SNAT_AUTO_MAP"
  }
}

resource "nsxt_lb_pool" "diego_brain_server_pool" {
  description              = "diego_brain_server_pool provisioned by Terraform"
  display_name             = "${var.diego_brain_server_pool_name}"
  algorithm                = "LEAST_CONNECTION"
  min_active_members       = 1
  tcp_multiplexing_enabled = false
  tcp_multiplexing_number  = 6
  active_monitor_id        = "${nsxt_lb_tcp_monitor.pcf_tcp_monitor.id}"
  snat_translation {
    type = "SNAT_AUTO_MAP"
  }
}

resource "nsxt_lb_pool" "istio_server_pool" {
  description              = "istio_server_pool provisioned by Terraform"
  display_name             = "${var.istio_server_pool_name}"
  algorithm                = "WEIGHTED_ROUND_ROBIN"
  min_active_members       = 1
  tcp_multiplexing_enabled = false
  tcp_multiplexing_number  = 6
  active_monitor_id        = "${nsxt_lb_tcp_monitor.istio_tcp_monitor.id}"
  snat_translation {
    type = "SNAT_AUTO_MAP"
  }
}

# Virtual Servers
resource "nsxt_lb_fast_tcp_application_profile" "pcf_app_profile" {
  close_timeout = 60
  idle_timeout  = 1800
}

resource "nsxt_lb_tcp_virtual_server" "routers_virtual_server" {
  description                = "routers_virtual_server provisioned by terraform"
  display_name               = "${var.router_server_pool_name}-VS"
  application_profile_id     = "${nsxt_lb_fast_tcp_application_profile.pcf_app_profile.id}"
  enabled                    = true
  ip_address                 = "${var.pas_routers_public_ip}"
  ports                      = ["443"]
  pool_id                    = "${nsxt_lb_pool.router_server_pool.id}"
}

resource "nsxt_lb_tcp_virtual_server" "diego_brains_virtual_server" {
  description                = "diego_brains_virtual_server provisioned by terraform"
  display_name               = "${var.diego_brain_server_pool_name}-VS"
  application_profile_id     = "${nsxt_lb_fast_tcp_application_profile.pcf_app_profile.id}"
  enabled                    = true
  ip_address                 = "${var.pas_diego_brains_public_ip}"
  ports                      = ["2222"]
  pool_id                    = "${nsxt_lb_pool.diego_brain_server_pool.id}"
  depends_on        = [
    "nsxt_lb_tcp_virtual_server.routers_virtual_server"
  ]
}

resource "nsxt_lb_tcp_virtual_server" "istio_virtual_server" {
  description                = "istio_virtual_server provisioned by terraform"
  display_name               = "${var.istio_server_pool_name}-VS"
  application_profile_id     = "${nsxt_lb_fast_tcp_application_profile.pcf_app_profile.id}"
  enabled                    = true
  ip_address                 = "${var.pas_istio_public_ip}"
  ports                      = ["443"]
  pool_id                    = "${nsxt_lb_pool.istio_server_pool.id}"
  depends_on        = [
    "nsxt_lb_tcp_virtual_server.routers_virtual_server",
    "nsxt_lb_tcp_virtual_server.diego_brains_virtual_server"
  ]
}

resource "nsxt_lb_service" "pcf_lb" {
  description  = "pcf-lb provisioned by Terraform"
  display_name = "pcf-lb"

  enabled           = true
  logical_router_id = "${nsxt_logical_tier1_router.pas_t1.id}"
  error_log_level   = "INFO"
  size              = "${var.loadbalancer_type}"

  virtual_server_ids  = [
    "${nsxt_lb_tcp_virtual_server.routers_virtual_server.id}",
    "${nsxt_lb_tcp_virtual_server.diego_brains_virtual_server.id}",
    "${nsxt_lb_tcp_virtual_server.istio_virtual_server.id}"
  ]

  depends_on        = [
    "nsxt_logical_router_link_port_on_tier1.link_port_tier1_pas",
    "nsxt_lb_tcp_virtual_server.routers_virtual_server",
    "nsxt_lb_tcp_virtual_server.diego_brains_virtual_server",
    "nsxt_lb_tcp_virtual_server.istio_virtual_server",
  ]
}
