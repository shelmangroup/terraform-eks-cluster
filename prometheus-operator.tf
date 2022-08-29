resource "helm_release" "prometheus_operator" {
  namespace = "monitoring"
  create_namespace = true
  name       = "prometheus-operator"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "39.7.0"

  set {
    name  = "kubeStateMetrics.enabled"
    value = false
  }

  set {
    name  = "nodeExporter.enabled"
    value = false
  }

  set {
    name  = "grafana.enabled"
    value = false
  }

  set {
    name  = "alertmanager.enabled"
    value = false
  }

}
