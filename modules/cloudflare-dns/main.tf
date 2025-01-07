# resource "cloudflare_record" "maged_dns_record" {
#   zone_id = var.cloudflare_zone_id
#   name    = var.record_name
#   value   = var.record_value
#   type    = "CNAME"
#   proxied = false
# }
