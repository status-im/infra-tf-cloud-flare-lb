# Description

This defines a [Terraform](https://www.terraform.io/) module that configures a [Cloud Flare Load Balancer](https://developers.cloudflare.com/load-balancing/).

# Usage

```tf
module "my_lb" {
  source     = "github.com/status-im/infra-tf-cloud-flare-lb"
  
  name   = "blog"
  domain = "example.org"
  hosts  = module.my_blog_hosts.hosts_by_dc

  /* Required to map our DCs to pool regions. */
  region_map = tomap({
    "gc-us-central1-a" = "ENAM" /* Eastern North America */
    "ac-cn-hongkong-c" = "SEAS" /* Southeast Asia */
    "do-eu-amsterdam3" = "EEU" /* Eastern Europe */
  })

  account_id = data.pass_password.cloudflare_account.password
}
```

# Variables

Here are the variables available in the module:

* __General__
    - `name` - Name of load balancer.
    - `domain` - Name of domain to use.
* __Hosts__
    - `hosts` - Map of DCs with map of hostnames and their IPs.
    - `region_map` - Map of pool DCs to regions.
* __Check__
    - `check_method` - Method for endpoint healthcheck. (default: `GET`)
    - `check_type` - Type of endpoint healthcheck. (default: `https`)
    - `check_path` - Path for endpoint healthcheck. (default: `/health`)
    - `check_expected_codes` - Response code for healthcheck. (default: `2xx`)
    - `check_expected_body` - Response body for healthcheck. (default: `OK`)
* __Plumbing__
    - `account_id` - ID of CloudFlare organization or account.
    - `zone_id` - ID of CloudFlare zone for host record.
