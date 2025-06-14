# Hostname for the setup
# Will create us.hostname eu.hostname and lb.hostname
variable "global_host" {
  type = string
  default = "localhost"
}

variable "host" {
  type = string
}