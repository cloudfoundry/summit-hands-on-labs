resource "google_compute_firewall" "kube-master-tcp" {
  name    = "${var.env_id}-kube-master-tcp"
  network = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["8443"]
  }
  target_tags = ["${var.env_id}-kube-master-tcp"]
}

// Static IP address for forwarding rule
resource "google_compute_address" "kube-master-tcp" {
  name = "${var.env_id}-kube-master-tcp"
}

// TCP target pool
resource "google_compute_target_pool" "kube-master-tcp" {
  name = "${var.env_id}-kube-master-tcp"
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "kube-master-tcp" {
  name        = "${var.env_id}-kube-master-tcp"
  target      = "${google_compute_target_pool.kube-master-tcp.self_link}"
  port_range  = "1024-65535"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.kube-master-tcp.address}"
}
output "kube_master_tcp_lb_ip" {
  value = "${google_compute_address.kube-master-tcp.address}"
}
output "kube_master_tcp_target_pool_name" {
  value = "${google_compute_target_pool.kube-master-tcp.name}"
}

output "kube_master_tcp_target_pool_tags" {
  value = "${google_compute_firewall.kube-master-tcp.target_tags}"
}


resource "google_compute_firewall" "kube-worker-tcp" {
  name    = "${var.env_id}-kube-worker-tcp"
  network = "${google_compute_network.bbl-network.name}"

  allow {
    protocol = "tcp"
    ports    = ["1024-65535"]
  }
  target_tags = ["${var.env_id}-kube-worker-tcp"]
}

// Static IP address for forwarding rule
resource "google_compute_address" "kube-worker-tcp" {
  name = "${var.env_id}-kube-worker-tcp"
}

// TCP target pool
resource "google_compute_target_pool" "kube-worker-tcp" {
  name = "${var.env_id}-kube-worker-tcp"
}

// TCP forwarding rule
resource "google_compute_forwarding_rule" "kube-worker-tcp" {
  name        = "${var.env_id}-kube-worker-tcp"
  target      = "${google_compute_target_pool.kube-worker-tcp.self_link}"
  port_range  = "1024-65535"
  ip_protocol = "TCP"
  ip_address  = "${google_compute_address.kube-worker-tcp.address}"
}
output "kube_worker_tcp_lb_ip" {
  value = "${google_compute_address.kube-worker-tcp.address}"
}
output "kube_worker_tcp_target_pool_name" {
  value = "${google_compute_target_pool.kube-worker-tcp.name}"
}
output "kube_worker_tcp_target_pool_tags" {
  value = "${google_compute_firewall.kube-worker-tcp.target_tags}"
}
