resource "helm_release" "node_exporter" {
  depends_on = [helm_release.prometheus_operator]
  namespace  = "monitoring"

  name       = "prometheus-node-exporter"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "prometheus-node-exporter"
  version    = "3.4.0"
}
