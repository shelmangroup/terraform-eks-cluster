resource "helm_release" "external_dns" {
  namespace  = "kube-system"
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  version    = "1.11.0"
}
