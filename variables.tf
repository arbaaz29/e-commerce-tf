variable "vpc_cidr" {
  description = "CIDR block for vpc"
  #   default = "10.1.0.0/16"
  type = string
}

variable "tag_name" {
  description = "tag name"
  default     = "arbaaz"
  type        = string
}

variable "transit_gateway_id" {
  description = "Id of pre existing transit gateway"
  default     = ""
  type        = string
}

variable "basename" {
  description = "prefix used for resources"
  default     = "arb-vpc"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Enter the public subnets you want to create in the specified azs"
  type        = map(any)
  default = {
    subnet-az1 = {
      az   = "use1-az1" //dynamic label to identify us-east-az1
      cidr = "10.0.1.0/24"
      idx  = 1
    }
    subnet-az2 = {
      az   = "use1-az2" //dynamic label to identify us-east-az2
      cidr = "10.0.6.0/24"
      idx  = 2
    }
    subnet-az3 = {
      az   = "use1-az3" //dynamic label to identify us-east-az3
      cidr = "10.0.12.0/24"
      idx  = 3
    }
    subnet-az4 = {
      az   = "use1-az4" //dynamic label to identify us-east-az4
      cidr = "10.0.18.0/24"
      idx  = 4
    }
  }
}

variable "private_subnet_cidrs" {
  description = "Enter the private subnets you want to create in the specified azs"
  type        = map(any)
  default = {
    subnet-az1 = {
      az   = "use1-az1" //dynamic label to identify us-east-az1
      cidr = "10.0.60.0/24"
      idx  = 1
    }
    subnet-az2 = {
      az   = "use1-az2" //dynamic label to identify us-east-az2
      cidr = "10.0.120.0/24"
      idx  = 2
    }
  }
}

variable "private_subnet_cidrs_rds" {
  description = "Enter the private subnet for rds this will not have a nat gateway attached to it"
  type        = map(any)
  default = {
    subnet-az1 = {
      az   = "use1-az1" //dynamic label to identify us-east-az1
      cidr = "10.0.180.0/24"
      idx  = 1
    }
    subnet-az2 = {
      az   = "use1-az2" //dynamic label to identify us-east-az2
      cidr = "10.0.240.0/24"
      idx  = 2
    }
  }
}

variable "instance_type_value" {
  description = "type of instance you want"
  default     = "t2.micro"
  type        = string
}

variable "rds_instance_type" {
  description = "Type of rds instance"
  type = string
  default = "db.t4g.micro"
  }

# variable "private_subnet_az" {
#   description = "Default az"
#   type = map(any)
#   default = {
#     subnet-az1 = {
#       az = "us-east-1a"
#     }
#     subnet-az2 = {
#       az = "us-east-1b"
#     }
#   }
# }























# variable "admin_role" {
#   description = "policy for admin this is a object type"
#   type = object({})
# }


variable "certificate_arn" {
  description = "SSL/TLS certificate arn for loadbalancer and cloudfront"
  type = string
}
