# modules/cert-manager/main.tf

# Create namespace for cert-manager
resource "kubernetes_namespace" "cert_manager" {
  metadata {
    name = "cert-manager"
    labels = {
      "cert-manager.io/disable-validation" = "true"
    }
  }
}

# Install cert-manager with CRDs
resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = kubernetes_namespace.cert_manager.metadata[0].name
  version          = "v1.10.1"
  create_namespace = false

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "startupapicheck.enabled"
    value = "false"
  }
}

# Wait for cert-manager to be ready
resource "time_sleep" "wait_for_crds" {
  depends_on = [helm_release.cert_manager]
  create_duration = "90s"
}

# Apply the ClusterIssuer using local-exec as fallback
resource "null_resource" "cluster_issuer" {
  triggers = {
    cert_manager_ready = time_sleep.wait_for_crds.id
  }

  provisioner "local-exec" {
    command = <<EOF
cat <<EOT | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: letsencrypt-prod
spec:
  acme:
    server: https://acme-v02.api.letsencrypt.org/directory
    email: ${var.email}
    privateKeySecretRef:
      name: letsencrypt-prod
    solvers:
    - http01:
        ingress:
          class: nginx
EOT
EOF
  }

  depends_on = [time_sleep.wait_for_crds]
}

