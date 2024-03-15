/* https://support.cloudflare.com/hc/en-us/requests/1543877 */
resource "cloudflare_load_balancer_monitor" "health" {
  account_id = var.account_id

  description    = "${var.check_path} check"
  method         = var.check_method
  type           = var.check_type
  path           = var.check_path
  expected_codes = var.check_expected_codes
  expected_body  = var.check_expected_body
  interval       = 60
  retries        = 5
  timeout        = 7

  /* disables SSl cert check, this way we can use origin */
  allow_insecure = true
}

/* https://github.com/terraform-providers/terraform-provider-cloudflare/issues/54 */
resource "cloudflare_load_balancer_pool" "main" {
  account_id = var.account_id

  for_each = var.hosts

  name        = "${each.key}.${var.name}.${var.domain}"
  description = "${each.key}"

  monitor = cloudflare_load_balancer_monitor.health.id
  enabled = true

  minimum_origins = 1

  dynamic "origins" {
    iterator = host
    for_each = each.value
    content {
      name    = host.key
      address = host.value
    }
  }
}

locals {
  pool_ids = [ for pool in cloudflare_load_balancer_pool.main : pool.id ]
}

resource "cloudflare_notification_policy" "main" {
  account_id = var.account_id

  name        = "${var.name}.${var.domain}"
  description = "Notification policy for ${var.domain}"
  enabled     = true
  alert_type  = "load_balancing_health_alert"

  email_integration {
    id = var.notify_email
  }

  filters {
    #status  = ["Unhealthy", "Healthy"]
    event_source = [ "origin", "pool" ]
    new_health   = [ "Healthy", "Unhealthy" ]
    pool_id = local.pool_ids
  }
}

resource "cloudflare_load_balancer" "main" {
  description      = "LB for ${var.name}.${var.domain} service."

  zone_id = var.zone_id
  name    = "${var.name}.${var.domain}"
  proxied = true

  default_pool_ids = local.pool_ids
  fallback_pool_id = local.pool_ids[0]

  /**
   * This is Geo-Steering, for more details read:
   * https://support.cloudflare.com/hc/en-us/articles/115000540888-Load-Balancing-Geographic-Regions
   **/
  dynamic "region_pools" {
    iterator = pool
    for_each = cloudflare_load_balancer_pool.main
    content {
      region   = var.region_map[pool.value.description]
      pool_ids = [pool.value.id]
    }
  }
}

