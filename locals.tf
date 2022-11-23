locals {
  hw1_name   = "hello-kubernetes-first"
  hw2_name   = "hello-kubernetes-second"
  hw1_domain = "hw1.${digitalocean_domain.default.name}"
  hw2_domain = "hw2.${digitalocean_domain.default.name}"
}