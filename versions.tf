terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.26.0"
    }

    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.14.0"
    }
  }
}
