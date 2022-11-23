terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.16.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
    time = {
      source = "hashicorp/time"
      version = ">= 0.9.1"
    }
  }
}

variable "do_token" {}
variable "pvt_key" {}

provider "digitalocean" {
  token = var.do_token
}

provider "helm" {
  kubernetes {
    host                   = digitalocean_kubernetes_cluster.dok.endpoint
    token                  = digitalocean_kubernetes_cluster.dok.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dok.kube_config[0].cluster_ca_certificate)
  }
}
provider "kubernetes" {
  host                   = digitalocean_kubernetes_cluster.dok.endpoint
  token                  = digitalocean_kubernetes_cluster.dok.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.dok.kube_config[0].cluster_ca_certificate)
}