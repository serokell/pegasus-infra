resource "aws_instance" "enif" {
  key_name = "Chris" # eu-west-2

  # Networking
  availability_zone           = module.vpc.azs[1]
  subnet_id                   = module.vpc.public_subnets[1]
  associate_public_ip_address = true

  vpc_security_group_ids = [
    aws_security_group.cluster_default_sg.id,
    aws_security_group.cluster_http_sg.id
  ]

  # Instance parameters
  instance_type = "t3a.nano"
  monitoring    = true

  # Disk type, size, and contents
  lifecycle { ignore_changes = [ami] }
  ami = data.aws_ami.nixos.id
  root_block_device {
    volume_type = "gp2"
    volume_size = "30"
  }
}

# Public DNS
resource "aws_eip" "enif" {
  instance = aws_instance.enif.id
  vpc      = true
}

resource "aws_route53_record" "enif_pegasus_serokell_team_ipv4" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "enif.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "A"
  ttl     = "60"
  records = [aws_eip.enif.public_ip]
}

resource "aws_route53_record" "enif_pegasus_serokell_team_ipv6" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "enif.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "AAAA"
  ttl     = "60"
  records = [aws_instance.enif.ipv6_addresses[0]]
}

# Private DNS
resource "aws_route53_record" "enif_private_ipv4" {
  zone_id = aws_route53_zone.pegasus_private.zone_id
  name    = "enif.${aws_route53_zone.pegasus_private.name}"
  type    = "A"
  ttl     = "60"
  records = [aws_instance.enif.private_ip]
}
