module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  version = "6.4.1"

  name = "my-project-ec2"

  instance_type = "t3.micro"
  key_name      = "mykey-1"
  monitoring    = true
  subnet_id     = "subnet-097879cf09f59d553"

  create_security_group  = false
  vpc_security_group_ids = [module.security_group.id]

  create_iam_instance_profile = true

  iam_role_name = "my-project-ec2-ecr-role"

  iam_role_policies = {
    AmazonEC2ContainerRegistryReadOnly = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "My-project"
  }
}

module "ecr" {
  source  = "terraform-aws-modules/ecr/aws"
  version = "3.2.0"

  repository_name = "my-project-app"

  repository_lifecycle_policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 30 images"

        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 30
        }

        action = {
          type = "expire"
        }
      }
    ]
  })

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "My-project"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "6.0.0"

  name        = "my-project-ec2-sg"
  description = "Security group for My-project EC2"
  vpc_id      = "vpc-00eaf0a68030facee"

  ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "SSH access from my IP"
    }

    frontend = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
      description = "Frontend Nginx"

    }
  }

  egress_rules = {
    all = {
      ip_protocol = "-1"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }

  tags = {
    Terraform   = "true"
    Environment = "dev"
    Project     = "My-project"
  }
}
