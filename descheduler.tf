resource "helm_release" "descheduler" {
  namespace  = "kube-system"
  name       = "descheduler"
  repository = "https://kubernetes-sigs.github.io/descheduler/"
  chart      = "descheduler"
  version    = "0.24.1"
}
