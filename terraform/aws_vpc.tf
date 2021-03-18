module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "= v2.46"

  name = "serokell-cluster-vpc"
  cidr = "10.0.0.0/16"

  azs                         = ["eu-west-2a", "eu-west-2b", "eu-west-2c"]
  public_subnets              = ["10.0.11.0/24", "10.0.12.0/24", "10.0.13.0/24"]
  public_subnet_ipv6_prefixes = [0, 1, 2]

  enable_ipv6                     = true
  assign_ipv6_address_on_creation = true

  enable_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  enable_dhcp_options      = true
  dhcp_options_domain_name = "pegasus.serokell.team"
}

resource "aws_security_group" "cluster_default_sg" {
  name        = "cluster-default-sg"
  description = "Security group applied to all nodes in the cluster"
  vpc_id      = module.vpc.vpc_id

  # allow all egress traffic
  egress {
    protocol         = "-1"
    from_port        = 0
    to_port          = 0
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # icmp
  ingress {
    protocol         = "icmp"
    from_port        = -1
    to_port          = -1
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # ssh
  ingress {
    protocol         = "tcp"
    from_port        = 22
    to_port          = 22
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  ingress {
    protocol         = "tcp"
    from_port        = 17788
    to_port          = 17788
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cluster_http_sg" {
  name        = "cluster-http-sg"
  description = "Allow HTTP(S) ingress"
  vpc_id      = module.vpc.vpc_id

  # no egress rules
  egress = []

  # HTTP
  ingress {
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  # HTTPS
  ingress {
    protocol         = "tcp"
    from_port        = 443
    to_port          = 443
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
}

resource "aws_security_group" "cluster_pg_sg" {
  name        = "cluster-pg-sg"
  description = "Allow Postgres ingress over private network"
  vpc_id      = module.vpc.vpc_id

  # no egress rules
  egress = []

  # PostgreSQL
  ingress {
    protocol    = "tcp"
    from_port   = 5432
    to_port     = 5432
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }
}
