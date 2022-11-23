variable "domain" {
  type        = string
  default     = ""
  description = "The name of the default domain"
}

variable "project" {
  type        = string
  default     = ""
  description = "The name of the DigitalOcean project"
}

variable "region" {
  type        = string
  default     = "fra1"
  description = "The region for the DigitalOcean resources"
}

variable "letsencrypt_email" {
  type = string
}

variable "dok_version" {
  type        = string
  default     = "1.24.4-do.0"
  description = "The vesion for the DigitalOcean Kubernetes cluster"
}

variable "dok_cluster_name" {
  type        = string
  default     = "dok-cluster"
  description = "The (base) name for the DigitalOcean Kubernetes cluster"
}