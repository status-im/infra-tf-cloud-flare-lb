variable "account_id" {
  description = "ID of CloudFlare organization or account."
}

variable "zone_id" {
  description = "ID of CloudFlare zone for host record."
  /* We default to: status.net */
  default     = "fd48f427e99bbe1b52105351260690d1"
}

variable "name" {
  description = "Name of load balancer"
  type        = string
}

variable "domain" {
  description = "Name of domain to use"
  type        = string
}

variable "notify_email" {
  description = "Name of domain to use"
  type        = string
  default     = "devops@status.im"
}

variable "check_method" {
  description = "Method for endpoint healthcheck"
  type        = string
  default     = "GET"
}

variable "check_type" {
  description = "Type of endpoint healthcheck"
  type        = string
  default     = "https"
}

variable "check_path" {
  description = "Path for endpoint healthcheck"
  type        = string
  default     = "/health"
}

variable "check_expected_codes" {
  description = "Response code for healthcheck"
  type        = string
  default     = "2xx"
}

variable "check_expected_body" {
  description = "Response body for healthcheck"
  type        = string
  default     = "OK"
}

variable "hosts" {
  description = "Map of DCs with map of hostnames and their IPs."
  type        = map(map(string))
}

/* FIXME: This is not pretty, but it works. */
variable "region_map" {
  description = "Map of pool DCs to regions."
  type        = map(string)
}
