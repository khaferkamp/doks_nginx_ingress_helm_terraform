resource "digitalocean_domain" "default" {
  name = "demo2.${var.domain}"
}

resource "digitalocean_record" "hw1_record" {
  domain = digitalocean_domain.default.name
  type   = "A"
  ttl    = 1800
  name   = "hw1"
  value  = kubernetes_ingress_v1.hello-kubernetes-ingress.status.0.load_balancer.0.ingress.0.ip
  depends_on = [
    digitalocean_domain.default,
    kubernetes_ingress_v1.hello-kubernetes-ingress
  ]
}

resource "digitalocean_record" "hw2_record" {
  domain = digitalocean_domain.default.name
  type   = "A"
  ttl    = 1800
  name   = "hw2"
  value  = kubernetes_ingress_v1.hello-kubernetes-ingress.status.0.load_balancer.0.ingress.0.ip
  depends_on = [
    digitalocean_domain.default,
    kubernetes_ingress_v1.hello-kubernetes-ingress
  ]
}