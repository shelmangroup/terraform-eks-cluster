module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 18"

  cluster_name                    = var.cluster_name
  cluster_version                 = var.cluster_version
  cluster_endpoint_private_access = true
  cluster_endpoint_public_access  = var.public_endpoint

  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  enable_irsa               = true
  manage_aws_auth_configmap = true

  aws_auth_roles = var.aws_auth_roles

  cluster_addons = {
    aws-ebs-csi-driver = {
      resolve_conflicts = "OVERWRITE"
    }
    coredns = {
      resolve_conflicts = "OVERWRITE"
    }
  }

  node_security_group_additional_rules = {
    ingress_nodes_karpenter_port = {
      description                   = "Cluster API to Node group for Karpenter webhook"
      protocol                      = "tcp"
      from_port                     = 8443
      to_port                       = 8443
      type                          = "ingress"
      source_cluster_security_group = true
    }
  }

  node_security_group_tags = {
    "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name
  }

  eks_managed_node_groups = {
    initial = {
      ami_type              = var.initial_node_group_ami_type
      instance_types        = var.initial_node_group_instance_types
      create_security_group = false
      min_size              = 1
      max_size              = 2
      desired_size          = 1
      iam_role_additional_policies = [
        "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
      ]

      tags = {
        "karpenter.sh/discovery/${var.cluster_name}" = var.cluster_name
      }
    }
  }

  tags = merge({
    ClusterName = var.cluster_name
    Environment = var.environment
  }, var.tags)
}


data "aws_eks_cluster" "cluster" {
  name = module.eks.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = module.eks.cluster_id
}
