resource "helm_release" "kube_state_metrics" {
  namespace  = "kube-system"
  name       = "kube-state-metrics"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-state-metrics"
  version    = "4.16.0"
}
