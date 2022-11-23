resource "digitalocean_kubernetes_cluster" "dok" {
  name    = var.dok_cluster_name
  region  = var.region
  version = var.dok_version

  node_pool {
    name       = "worker-pool"
    size       = "s-2vcpu-2gb"
    auto_scale = true
    min_nodes  = 1
    max_nodes  = 3
  }
}

resource "kubernetes_service_v1" "hello-kubernetes-first" {
  metadata {
    name = local.hw1_name
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 8080
    }
    selector = {
      app = local.hw1_name
    }
  }
}

resource "kubernetes_deployment_v1" "hello-kubernetes-first" {
  metadata {
    name = local.hw1_name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.hw1_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.hw1_name
        }
      }

      spec {
        container {
          image = "paulbouwer/hello-kubernetes:1.8"
          name  = "hello-kubernetes"
          port {
            container_port = 8080
          }
          env {
            name  = "MESSAGE"
            value = "Hello from the first deployment!"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "hello-kubernetes-second" {
  metadata {
    name = local.hw2_name
  }
  spec {
    type = "ClusterIP"
    port {
      port        = 80
      target_port = 8080
    }
    selector = {
      app = local.hw2_name
    }
  }
}

resource "kubernetes_deployment_v1" "hello-kubernetes-second" {
  metadata {
    name = local.hw2_name
  }

  spec {
    replicas = 3

    selector {
      match_labels = {
        app = local.hw2_name
      }
    }

    template {
      metadata {
        labels = {
          app = local.hw2_name
        }
      }

      spec {
        container {
          image = "paulbouwer/hello-kubernetes:1.8"
          name  = "hello-kubernetes"
          port {
            container_port = 8080
          }
          env {
            name  = "MESSAGE"
            value = "Hello from the second deployment!"
          }
        }
      }
    }
  }
}

resource "helm_release" "ingress-nginx" {
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  set {
    name  = "controller.publishService.enabled"
    value = true
  }
}

resource "kubernetes_ingress_v1" "hello-kubernetes-ingress" {
  wait_for_load_balancer = true
  metadata {
    name = "hello-kubernetes-ingress"
    annotations = {
      #"kubernetes.io/ingress.class" = "nginx"
      "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
    }
  }

  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.hw1_domain
      http {
        path {
          path_type = "Prefix"
          backend {
            service {
              name = local.hw1_name
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }
    rule {
      host = local.hw2_domain
      http {
        path {
          path_type = "Prefix"
          backend {
            service {
              name = local.hw2_name
              port {
                number = 80
              }
            }
          }
          path = "/"
        }
      }
    }


    tls {
      hosts       = [local.hw1_domain, local.hw2_domain]
      secret_name = "hello-kubernetes-tls"
    }
  }
}


resource "helm_release" "cert-manager" {
  name             = "cert-manager"
  version          = "1.2.0"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}

# would be the best solution but CRDs are validated and thus we need a custom helm chart...
# resource "kubernetes_manifest" "cluster-issuer" {
#   manifest = {
#     apiVersion = "cert-manager.io/v1"
#     kind       = "ClusterIssuer"
#     metadata = {
#       name = "letsencrypt-prod"
#     }
#     spec = {
#       acme = {
#         email  = var.letsencrypt_email
#         server = "https://acme-v02.api.letsencrypt.org/directory"
#         privateKeySecretRef = {
#           name = "letsencrypt-prod-private-key"
#         }
#         solvers = {
#           http01 = {
#             ingress = {
#               class = "nginx"
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [
#     helm_release.cert-manager
#   ]
# }

# workaround until the manifests can be applied
resource "helm_release" "cluster-issuer" {
  name      = "cluster-issuer"
  chart     = "./helm_charts/cluster-issuer"
  namespace = "kube-system"
  depends_on = [
    helm_release.cert-manager
  ]
  set {
    name  = "letsencrypt_email"
    value = var.letsencrypt_email
  }
}
