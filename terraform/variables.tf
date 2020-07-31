variable "nsx_hostname" {}
variable "nsx_user" {}
variable "nsx_password" {}

variable "edge_cluster_name" {}
variable "transport_zone_vlan_name" {}
variable "transport_zone_overlay_name" {}

variable "pas_snat_ip_pool_name" {}
variable "pas_snat_ip_pool_range" {}
variable "pas_snat_ip_pool_cidr" {}

variable "pas_ls" {}

variable "pas_subnet_cidr" {}

variable "nsxt_t0_router" {}
variable "uplink_router_ip" {}
variable "static_route_next_hop_ip" {}

variable "loadbalancer_type" {}

variable "router_server_pool_name" {}
variable "diego_brain_server_pool_name" {}
variable "istio_server_pool_name" {}

variable "pas_routers_public_ip" {}
variable "pas_diego_brains_public_ip" {}
variable "pas_istio_public_ip" {}

variable "snat_public_ip" {}
variable "snat_cidr" {}
