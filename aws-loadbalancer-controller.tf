resource "helm_release" "aws_loadbalancer_controller" {
  namespace = "kube-system"

  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = "1.4.4"

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "ingressClass"
    value = "alb"
  }
}
