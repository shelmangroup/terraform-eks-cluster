resource "helm_release" "cert_manager" {
  namespace        = "cert-manager"
  create_namespace = true

  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.9.1"

  set {
    name  = "installCRDs"
    value = true
  }
}
