provider  "aws" {
  version = "~> 3.20"
  region = "eu-west-2"
}

# Grab the latest NixOS AMI built by Serokell
data "aws_ami" "nixos" {
  most_recent = true

  filter {
    name = "name"
    values = ["NixOS-*"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["920152662742"] # Serokell
}
