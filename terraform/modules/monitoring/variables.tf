variable "hosted_prometheus_token" {
  description = "The token for hosted Prometheus"
  type        = string
  sensitive   = true
}

variable "hosted_prometheus_metrics_url" {
  description = "The URL for hosted Prometheus metrics endpoint"
  type        = string
}

variable "hosted_prometheus_username" {
  description = "The username for hosted Prometheus"
  type        = string
}