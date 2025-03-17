# modules/keycloak/main.tf
resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}

# Create Certificate for Keycloak
resource "null_resource" "keycloak_certificate" {
  provisioner "local-exec" {
    command = <<EOF
cat <<EOT | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: keycloak-cert
  namespace: keycloak
spec:
  secretName: keycloak-server-tls
  dnsNames:
    - ${var.keycloak_hostname}
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOT
EOF
  }
  depends_on = [kubernetes_namespace.keycloak]
}

resource "kubernetes_persistent_volume_claim" "postgres_data" {
  count = var.use_external_database ? 0 : 1
  
  metadata {
    name      = "postgres-data"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "10Gi"
      }
    }
    storage_class_name = "standard"
  }
}

resource "kubernetes_deployment" "postgres" {
  count = var.use_external_database ? 0 : 1
  
  metadata {
    name      = "keycloak-postgres"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
    labels = {
      app = "keycloak-postgres"
    }
  }
  
  spec {
    replicas = 1
    
    selector {
      match_labels = {
        app = "keycloak-postgres"
      }
    }
    
    template {
      metadata {
        labels = {
          app = "keycloak-postgres"
        }
      }
      
      spec {
        container {
          name  = "postgres"
          image = "postgres:14"
          
          env {
            name  = "POSTGRES_USER"
            value = "keycloak"
          }
          
          env {
            name  = "POSTGRES_PASSWORD"
            value = var.postgres_password
          }
          
          env {
            name  = "POSTGRES_DB"
            value = "keycloak"
          }
          
          env {
            name  = "PGDATA"
            value = "/var/lib/postgresql/data/pgdata"
          }
          
          port {
            container_port = 5432
          }
          
          volume_mount {
            name       = "postgres-data"
            mount_path = "/var/lib/postgresql/data"
          }
          
          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }
          }
        }
        
        volume {
          name = "postgres-data"
          persistent_volume_claim {
            claim_name = kubernetes_persistent_volume_claim.postgres_data[0].metadata[0].name
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "postgres" {
  count = var.use_external_database ? 0 : 1
  
  metadata {
    name      = "keycloak-postgres"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  
  spec {
    selector = {
      app = "keycloak-postgres"
    }
    
    port {
      port        = 5432
      target_port = 5432
    }
  }
  
  depends_on = [kubernetes_deployment.postgres]
}

# Create ConfigMap for Keycloak configuration
resource "kubernetes_config_map" "keycloak_config" {
  metadata {
    name      = "keycloak-config"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "KC_DB"                      = "postgres"
    "KC_DB_URL"                  = "jdbc:postgresql://${var.use_external_database ? var.db_host : "keycloak-postgres"}:${var.use_external_database ? var.db_port : "5432"}/${var.use_external_database ? var.db_name : "keycloak"}"
    "KC_DB_USERNAME"             = var.use_external_database ? var.db_user : "keycloak"
    "KC_PROXY"                   = "edge"
    "KC_HTTP_RELATIVE_PATH"      = "/"
    "KC_HEALTH_ENABLED"          = "true"
    "KC_METRICS_ENABLED"         = "true"
    "KC_HOSTNAME"                = var.keycloak_hostname
    "KC_HOSTNAME_STRICT"         = "false"
    "KC_HOSTNAME_STRICT_HTTPS"   = "false"
    "QUARKUS_DATASOURCE_JDBC_DRIVER" = "org.postgresql.Driver"
    "QUARKUS_DATASOURCE_DB_KIND" = "postgresql"
  }
}

# Create Secret for database password
resource "kubernetes_secret" "keycloak_db_secret" {
  metadata {
    name      = "keycloak-db-secret"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "KC_DB_PASSWORD" = var.use_external_database ? var.db_password : var.postgres_password
  }
}

# Create Secret for admin password
resource "kubernetes_secret" "keycloak_admin_secret" {
  metadata {
    name      = "keycloak-admin-secret"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  data = {
    "KEYCLOAK_ADMIN"          = "admin"
    "KEYCLOAK_ADMIN_PASSWORD" = var.admin_password
  }
}

# Create Deployment for Keycloak
resource "kubernetes_deployment" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
    labels = {
      app = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        container {
          name  = "keycloak"
          image = "quay.io/keycloak/keycloak:22.0.3"

          args = ["start-dev"]

          resources {
            limits = {
              cpu    = "200m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "256Mi"
            }
          }

          port {
            name           = "http"
            container_port = 8080
          }

          env_from {
            config_map_ref {
              name = kubernetes_config_map.keycloak_config.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.keycloak_db_secret.metadata[0].name
            }
          }

          env_from {
            secret_ref {
              name = kubernetes_secret.keycloak_admin_secret.metadata[0].name
            }
          }

          readiness_probe {
            http_get {
              path = "/health/ready"
              port = 8080
            }
            initial_delay_seconds = 30
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }

          liveness_probe {
            http_get {
              path = "/health/live"
              port = 8080
            }
            initial_delay_seconds = 60
            period_seconds        = 10
            timeout_seconds       = 5
            failure_threshold     = 6
          }
        }
      }
    }
  }

  depends_on = [
    kubernetes_service.postgres
  ]
}

# Create Service for Keycloak
resource "kubernetes_service" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }

  spec {
    selector = {
      app = "keycloak"
    }

    port {
      name        = "http"
      port        = 80
      target_port = 8080
    }

    type = "ClusterIP"
  }
}

resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = "keycloak-ingress"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
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
      hosts       = [var.keycloak_hostname]
      secret_name = "keycloak-server-tls"
    }
    
    rule {
      host = var.keycloak_hostname
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.keycloak.metadata[0].name
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
  
  depends_on = [kubernetes_deployment.keycloak]
}
