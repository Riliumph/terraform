variable "project" {}

variable "owner" {
    type = string
    default = "terraformer"
}

variable "region" {
    type = string
    default = "ap-northeast-1"
}

# VPC
variable "vpc_cidr" {
    type = string
    default = "10.10.0.0/16"
}

variable "subnet_azs"{
    type = set(string)
    default = ["a", "c"]
}

variable "subnet_cidr" {
    type = list(string)
    default = ["10.10.10.0/24","10.10.20.0/24"]
}
