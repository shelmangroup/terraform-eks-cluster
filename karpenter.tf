resource "aws_iam_instance_profile" "karpenter" {
  name = "KarpenterNodeInstanceProfile-${module.eks.cluster_id}"
  role = module.eks.eks_managed_node_groups["initial"].iam_role_name
}

module "karpenter_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "5.3.0"

  role_name                          = "karpenter-controller-${module.eks.cluster_id}"
  attach_karpenter_controller_policy = true

  karpenter_tag_key               = "karpenter.sh/discovery/${module.eks.cluster_id}"
  karpenter_controller_cluster_id = module.eks.cluster_id
  karpenter_controller_node_iam_role_arns = [
    module.eks.eks_managed_node_groups["initial"].iam_role_arn
  ]

  oidc_providers = {
    ex = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["karpenter:karpenter"]
    }
  }
}

resource "helm_release" "karpenter" {
  namespace        = "karpenter"
  create_namespace = true

  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = "v0.14.0"

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = module.karpenter_irsa.iam_role_arn
  }

  set {
    name  = "clusterName"
    value = module.eks.cluster_id
  }

  set {
    name  = "clusterEndpoint"
    value = module.eks.cluster_endpoint
  }

  set {
    name  = "aws.defaultInstanceProfile"
    value = aws_iam_instance_profile.karpenter.name
  }
}

resource "kubectl_manifest" "karpenter_provisioner" {
  depends_on = [helm_release.karpenter]
  yaml_body  = <<-YAML
    apiVersion: karpenter.sh/v1alpha5
    kind: Provisioner
    metadata:
      name: default
    spec:
      requirements:
      - key: "karpenter.sh/capacity-type"
        operator: "In"
        values: ["spot"]
      - key: "kubernetes.io/arch"
        operator: "In"
        values: ["arm64"]
      limits:
        resources:
          cpu: "1k"
      provider:
        amiFamily: Bottlerocket
        subnetSelector:
          Name: "*-priv-*"
        securityGroupSelector:
          "karpenter.sh/discovery/${module.eks.cluster_id}": "${module.eks.cluster_id}"
        tags:
          "karpenter.sh/discovery/${module.eks.cluster_id}": "${module.eks.cluster_id}"

      ttlSecondsAfterEmpty: 30
  YAML
}
