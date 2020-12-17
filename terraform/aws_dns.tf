# Public DNS
resource "aws_route53_zone" "pegasus_serokell_team" {
  name = "pegasus.serokell.team"
}

data "aws_route53_zone" "serokell_team" {
  name = "serokell.team"
}

data "aws_route53_zone" "serokell_io" {
  name = "serokell.io"
}

resource "aws_route53_record" "pegasus_serokell_team" {
  zone_id = data.aws_route53_zone.serokell_team.zone_id
  name    = "pegasus.serokell.team"
  type    = "NS"
  ttl     = "60"
  records = aws_route53_zone.pegasus_serokell_team.name_servers
}

# Private DNS
resource "aws_route53_zone" "pegasus_private" {
  name = "pegasus.serokell.team"
  vpc {
    vpc_id = module.vpc.vpc_id
  }
}
