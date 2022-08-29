module "aws_otel_role" {
  depends_on = [module.eks]
  source  = "terraform-aws-modules/iam/aws//modules/iam-eks-role"
  version = "5.3.0"

  role_name = "aws-otel"

  cluster_service_accounts = {
    "${var.cluster_name}" = ["aws-otel-eks:aws-otel-sa"]
  }

  tags = {
    Name = "eks-role"
  }

  role_policy_arns = {
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy",
  }
}


data "kubectl_file_documents" "otel_container_insights" {
  content = file("${path.module}/otel-container-insights-infra.yaml")
}

resource "kubectl_manifest" "aws_otel_namespace" {
  depends_on = [module.eks]
  yaml_body = <<-YAML
    apiVersion: v1
    kind: Namespace
    metadata:
      name: aws-otel-eks
      labels:
        name: aws-otel-eks
  YAML
}

resource "kubectl_manifest" "aws_otel_serviceaccount" {
  depends_on = [kubectl_manifest.aws_otel_namespace]
  yaml_body = <<-YAML
    apiVersion: v1
    kind: ServiceAccount
    metadata:
      name: aws-otel-sa
      namespace: aws-otel-eks
      annotations:
        "eks.amazonaws.com/role-arn": "${module.aws_otel_role.iam_role_arn}"
  YAML
}

resource "kubectl_manifest" "otel_container_insights" {
  depends_on = [kubectl_manifest.aws_otel_serviceaccount]
  for_each   = data.kubectl_file_documents.otel_container_insights.manifests
  yaml_body  = each.value
}
