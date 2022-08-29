variable "cluster_name" {
  type        = string
  description = "The name of the cluster"
}

variable "cluster_version" {
  type        = string
  description = "The version of the cluster"
}

variable "public_endpoint" {
  type        = bool
  description = "Whether to enable public endpoint"
  default     = true
}

variable "vpc_id" {
  type        = string
  description = "The VPC ID"
}

variable "subnet_ids" {
  type        = list(string)
  description = "The subnet IDs"
}

variable "environment" {
  type        = string
  description = "The environment of the cluster"
}

variable "aws_auth_roles" {
  type        = list(any)
  description = "The AWS auth roles"
}

variable "initial_node_group_instance_types" {
  type        = list(string)
  description = "The initial node group instance types"
  default = ["m6g.large"]
}

variable "initial_node_group_ami_type" {
  type        = string
  description = "The initial node group AMI type"
  default = "BOTTLEROCKET_ARM_64"
}

variable "tags" {
  type        = map(string)
  description = "The tags to apply to the cluster. ClusterName and Environment are always added."
  default = {}
}
