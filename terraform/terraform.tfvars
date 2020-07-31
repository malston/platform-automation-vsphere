nsx_hostname                    = "nsxmgr-01.haas-439.pez.vmware.com"
nsx_user                        = "admin"
nsx_password                    = "gbCLia8hP8SKKjiinT!"

pas_snat_ip_pool_name           = "pcf-floating-ip-pool"
pas_snat_ip_pool_range          = "10.213.147.35-10.213.147.45"
pas_snat_ip_pool_cidr           = "10.213.147.0/24"

nsxt_t0_router                  = "T0-Router"
pas_ls                          = "TAS-Deployment"

uplink_router_ip                = "10.213.147.1/24"
static_route_next_hop_ip        = "10.213.147.1"
pas_subnet_cidr                 = "172.16.3.1/24"

edge_cluster_name               = "edge-cluster-1"
transport_zone_vlan_name        = "vlan-tz"
transport_zone_overlay_name     = "overlay-tz"

loadbalancer_type               = "SMALL" # SMALL | MEDIUM | LARGE

router_server_pool_name         = "RouterServerPool"
diego_brain_server_pool_name    = "DiegoBrainServerPool"
istio_server_pool_name          = "IstioServerPool"

pas_routers_public_ip           = "10.213.147.31"
pas_diego_brains_public_ip      = "10.213.147.31"
pas_istio_public_ip             = "10.213.147.32"

snat_public_ip                  = "10.213.147.251"
snat_cidr                       = "172.16.3.0/24"
