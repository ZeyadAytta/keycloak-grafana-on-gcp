# modules/argocd/main.tf

resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
  }
}

# Create Certificate for ArgoCD
resource "null_resource" "argocd_certificate" {
  provisioner "local-exec" {
    command = <<EOF
cat <<EOT | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: argocd-cert
  namespace: argocd
spec:
  secretName: argocd-server-tls
  dnsNames:
    - ${var.argocd_hostname}
  issuerRef:
    name: letsencrypt-prod
    kind: ClusterIssuer
EOT
EOF
  }
  depends_on = [kubernetes_namespace.argocd]
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false

  values = [
    <<-EOT
    server:
      extraArgs:
        - --insecure
      certificate:
        enabled: false
      ingress:
        enabled: false
    configs:
      tls:
        enabled: false
    EOT
  ]

  depends_on = [null_resource.argocd_certificate]
}

resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name      = "argocd-ingress"
    namespace = kubernetes_namespace.argocd.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class"                    = "nginx"
      "cert-manager.io/cluster-issuer"                 = "letsencrypt-prod"
      "nginx.ingress.kubernetes.io/ssl-passthrough"    = "false"
      "nginx.ingress.kubernetes.io/backend-protocol"   = "HTTP"
      "nginx.ingress.kubernetes.io/ssl-redirect"       = "true"
    }
  }

  spec {
    tls {
      hosts       = [var.argocd_hostname]
      secret_name = "argocd-server-tls"
    }

    rule {
      host = var.argocd_hostname
      http {
        path {
          path = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

