resource "kubernetes_namespace" "keycloak" {
  metadata {
    name = "keycloak"
  }
}
resource "kubernetes_deployment" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "keycloak"
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
          image = "vassio/keycloak-radius-plugin:latest-multiarch"
          name  = "keycloak"
          
          # Direct environment variables
          env {
            name  = "KEYCLOAK_ADMIN"
            value = var.keycloak_admin_user
          }
          
          env {
            name  = "KEYCLOAK_ADMIN_PASSWORD"
            value = var.keycloak_admin_password
          }
          
          env {
            name  = "RADIUS_SHARED_SECRET"
            value = var.radius_shared_secret
          }
          
          env {
            name  = "RADIUS_UDP"
            value = "true"
          }
          
          env {
            name  = "RADIUS_UDP_AUTH_PORT"
            value = tostring(var.radius_auth_port)
          }
          
          env {
            name  = "RADIUS_UDP_ACCOUNT_PORT"
            value = tostring(var.radius_accounting_port)
          }
          
          env {
            name  = "RADIUS_RADSEC"
            value = "false"
          }
          
          # Hostname and proxy settings
          env {
            name  = "KC_HOSTNAME"
            value = var.keycloak_hostname
          }
          
          env {
            name  = "KC_HOSTNAME_STRICT"
            value = "false"
          }
          
          env {
            name  = "KC_HTTP_RELATIVE_PATH"
            value = "/"
          }
          
          env {
            name  = "KC_PROXY"
            value = "edge"
          }

          args = ["start-dev"]

          port {
            container_port = 8080
            name           = "http"
          }
          
          port {
            container_port = 1812
            protocol       = "UDP"
            name           = "radius-auth"
          }
          
          port {
            container_port = 1813
            protocol       = "UDP"
            name           = "radius-acct"
          }

          # Reduced resource requirements for free tier
          resources {
            limits = {
              cpu    = "500m"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "256Mi"
            }
          }
          
          # Add volume mount for the emptyDir to persist H2 database across restarts
          volume_mount {
            name       = "keycloak-data"
            mount_path = "/opt/keycloak/data"
          }
        }
        
        # Use emptyDir for some level of data persistence (within the node's lifecycle)
        volume {
          name = "keycloak-data"
          empty_dir {}
        }
      }
    }
  }
  
  depends_on = [
    kubernetes_namespace.keycloak
  ]
}

resource "kubernetes_service" "keycloak_http" {
  metadata {
    name      = "keycloak-http"
    namespace = "keycloak"
  }
  spec {
    selector = {
      app = kubernetes_deployment.keycloak.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 8080
      target_port = 8080
      name        = "http"
    }
    type = "ClusterIP"
  }
  
  depends_on = [
    kubernetes_namespace.keycloak
  ]
}

resource "kubernetes_service" "keycloak" {
  metadata {
    name      = "keycloak"
    namespace = "keycloak"
  }
  spec {
    selector = {
      app = kubernetes_deployment.keycloak.spec[0].template[0].metadata[0].labels.app
    }
    port {
      port        = 1812
      target_port = 1812
      protocol    = "UDP"
      name        = "radius-auth"
    }
    port {
      port        = 1813
      target_port = 1813
      protocol    = "UDP"
      name        = "radius-acct"
    }
    type                    = "LoadBalancer"
    external_traffic_policy = "Local"
  }
  
  depends_on = [
    kubernetes_namespace.keycloak
  ]
}

# Ingress for HTTP traffic
resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name      = "keycloak-ingress"
    namespace = "keycloak"
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "acme.cert-manager.io/http01-edit-in-place"      = "true"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "10m"
      "nginx.ingress.kubernetes.io/force-ssl-redirect" = "true"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "nginx.ingress.kubernetes.io/proxy-buffer-size"  = "128k"
      "nginx.ingress.kubernetes.io/proxy-buffers"      = "4 256k"
      "nginx.ingress.kubernetes.io/proxy-busy-buffers-size" = "256k"
    }
  }

  spec {
    rule {
      host = var.keycloak_hostname
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = kubernetes_service.keycloak_http.metadata[0].name
              port {
                number = 8080
              }
            }
          }
        }
      }
    }

    tls {
      hosts       = [var.keycloak_hostname]
      secret_name = "keycloak-tls-cert"
    }
  }
  
  depends_on = [
    kubernetes_namespace.keycloak,
    kubernetes_service.keycloak_http
  ]
}

# Explicit Certificate Resource - Only created if var.create_certificate is true
resource "kubernetes_manifest" "keycloak_certificate" {
  count = var.create_certificate ? 1 : 0
  
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "Certificate"
    metadata = {
      name      = "keycloak-tls-cert"
      namespace = "keycloak"
    }
    spec = {
      secretName = "keycloak-tls-cert"
      duration   = "2160h" # 90 days
      renewBefore = "360h" # 15 days
      subject = {
        organizations = [var.organization]
      }
      privateKey = {
        algorithm = "RSA"
        encoding  = "PKCS1"
        size      = 2048
      }
      dnsNames = [
        var.keycloak_hostname
      ]
      issuerRef = {
        name  = "letsencrypt-prod"
        kind  = "ClusterIssuer"
        group = "cert-manager.io"
      }
    }
  }

  depends_on = [
    kubernetes_namespace.keycloak
  ]
}
