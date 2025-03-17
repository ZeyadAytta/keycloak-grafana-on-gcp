# modules/teleport/main.tf

resource "kubernetes_namespace" "teleport" {
  metadata {
    name = "teleport"
  }
}

# Single ingress for both ACME challenges and main traffic
resource "kubernetes_ingress_v1" "teleport_ingress" {
  metadata {
    name      = "teleport-ingress"
    namespace = kubernetes_namespace.teleport.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTPS"
      "nginx.ingress.kubernetes.io/proxy-body-size"    = "0"
    }
  }

  spec {
    tls {
      hosts = [
        var.auth_service_domain,
        var.proxy_service_domain
      ]
      secret_name = "teleport-tls"
    }

    rule {
      host = var.auth_service_domain
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "teleport"
              port {
                number = 3080
              }
            }
          }
        }
      }
    }

    rule {
      host = var.proxy_service_domain
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "teleport"
              port {
                number = 3080
              }
            }
          }
        }
      }
    }
  }
}

# Wait for certificate to be ready
resource "time_sleep" "wait_for_cert" {
  depends_on = [kubernetes_ingress_v1.teleport_ingress]
  create_duration = "60s"
}

# Install Teleport
resource "helm_release" "teleport" {
  name             = "teleport"
  repository       = "https://charts.releases.teleport.dev"
  chart            = "teleport-cluster"
  namespace        = kubernetes_namespace.teleport.metadata[0].name
  create_namespace = false

  values = [
    templatefile("${path.module}/values.yaml", {
      auth_service_domain  = var.auth_service_domain
      proxy_service_domain = var.proxy_service_domain
    })
  ]

  depends_on = [time_sleep.wait_for_cert]
}

