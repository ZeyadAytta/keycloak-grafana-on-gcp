# modules/grafana/main.tf
resource "kubernetes_namespace" "grafana" {
  metadata {
    name = "grafana"
  }
}

# Create Certificate for Grafana
resource "null_resource" "grafana_certificate" {
  provisioner "local-exec" {
    command = <<EOF
cat <<EOT | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: grafana-cert
  namespace: grafana
spec:
  secretName: grafana-server-tls
  dnsNames:
    - ${var.grafana_hostname}
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOT
EOF
  }
  depends_on = [kubernetes_namespace.grafana]
}

resource "kubernetes_persistent_volume_claim" "grafana_data" {
  metadata {
    name      = "grafana-data"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }

  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    storage_class_name = "standard"
  }
}

# Create ConfigMap for Grafana configuration
resource "kubernetes_config_map" "grafana_config" {
  metadata {
    name      = "grafana-config"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }

  data = {
    "grafana.ini" = <<-EOT
      [server]
      domain = ${var.grafana_hostname}
      root_url = https://${var.grafana_hostname}
      [analytics]
      reporting_enabled = false
      check_for_updates = false
      [security]
      admin_user = admin
    EOT
  }
}

# Create Secret for admin password
resource "kubernetes_secret" "grafana_admin_secret" {
  metadata {
    name      = "grafana-admin-secret"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }

  data = {
    "admin-password" = var.admin_password
  }
}

resource "kubernetes_deployment" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata[0].name
    labels = {
      app = "grafana"
    }
  }

  spec {
    replicas = var.grafana_replicas

    selector {
      match_labels = {
        app = "grafana"
      }
    }

    template {
      metadata {
        labels = {
          app = "grafana"
        }
      }

      spec {
        # Security context at the pod level - this is correct
        security_context {
          run_as_user  = 472
          run_as_group = 472
          fs_group     = 472
        }

        container {
          name  = "grafana"
          image = "grafana/grafana:${var.grafana_version}"

          # Note: security context should be at pod level, not here

          resources {
            limits = {
              cpu    = var.resource_limits_cpu
              memory = var.resource_limits_memory
            }
            requests = {
              cpu    = var.resource_requests_cpu
              memory = var.resource_requests_memory
            }
          }

          port {
            name           = "http"
            container_port = 3000
          }

          env {
            name  = "GF_SECURITY_ADMIN_PASSWORD"
            value_from {
              secret_key_ref {
                name = kubernetes_secret.grafana_admin_secret.metadata[0].name
                key  = "admin-password"
              }
            }
          }

          volume_mount {
            name       = "grafana-data"
            mount_path = "/var/lib/grafana"
          }

          volume_mount {
            name       = "grafana-config"
            mount_path = "/etc/grafana/grafana.ini"
            sub_path   = "grafana.ini"
          }

          readiness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          liveness_probe {
            http_get {
              path = "/api/health"
              port = 3000
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }

        volume {
          name = "grafana-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.grafana_data.metadata[0].name
          }
        }

        volume {
          name = "grafana-config"
          config_map {
            name = kubernetes_config_map.grafana_config.metadata[0].name
          }
        }
      }
    }
  }
}
# Create Service for Grafana
resource "kubernetes_service" "grafana" {
  metadata {
    name      = "grafana"
    namespace = kubernetes_namespace.grafana.metadata[0].name
  }

  spec {
    selector = {
      app = "grafana"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 3000
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name      = "grafana-ingress"
    namespace = kubernetes_namespace.grafana.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"  = "128k"
    }
  }

  spec {
    tls {
      hosts       = [var.grafana_hostname]
      secret_name = "grafana-server-tls"
    }

    rule {
      host = var.grafana_hostname
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.grafana.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubernetes_deployment.grafana]
}
