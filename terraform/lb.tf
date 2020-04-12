# // instance group
# resource "google_compute_instance_group" "reddit-group" {
#   name      = "reddit-group"
#   zone      = var.zone
#   instances = google_compute_instance.app.*.self_link
#   named_port {
#     name = "puma"
#     port = "9292"
#   }
# }
# // health check
# resource "google_compute_health_check" "reddit-health-check" {
#   name = "reddit-health-check"
#   http_health_check {
#     port = 9292
#   }
# }
# // backend service
# resource "google_compute_backend_service" "reddit-backend-service" {
#   name          = "reddit-backend-service"
#   port_name     = "puma"
#   protocol      = "HTTP"
#   health_checks = [google_compute_health_check.reddit-health-check.self_link]
#   backend {
#     group = google_compute_instance_group.reddit-group.self_link
#   }
# }
# // target proxy
# resource "google_compute_target_http_proxy" "reddit-target-proxy" {
#   name    = "reddit-target-proxy"
#   url_map = google_compute_url_map.reddit-load-balancer.self_link
# }
# // URL map (aka load balancers)
# resource "google_compute_url_map" "reddit-load-balancer" {
#   name            = "reddit-load-balancer"
#   default_service = google_compute_backend_service.reddit-backend-service.self_link
# }
# // forwarding rule
# resource "google_compute_global_forwarding_rule" "reddit-forwarding-rule" {
#   name       = "reddit-forwarding-rule"
#   target     = google_compute_target_http_proxy.reddit-target-proxy.self_link
#   port_range = "80-80"
# }
