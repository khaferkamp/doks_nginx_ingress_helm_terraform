resource "digitalocean_project" "project" {
  name        = var.project
  description = "Demo application provisioned with terraform"
  purpose     = "Education"
  resources = [
    digitalocean_domain.default.urn,
    digitalocean_kubernetes_cluster.dok.urn
  ]
}