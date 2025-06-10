# Region of the cluster
variable "region" {
  type = string

  validation {
    condition     = var.region == "us" || var.region == "eu"
    error_message = "Region must be either 'us' or 'eu'."
  }
}
