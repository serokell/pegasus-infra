resource "hcloud_server" "markab" {
  name = "markab"
  image = "ubuntu-20.04"
  server_type = "cpx21"
  ssh_keys = [ hcloud_ssh_key.zhenya.id ]
  # Install NixOS 20.03
  user_data = <<EOF
    #cloud-config

    runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-20.03 bash 2>&1 | tee /tmp/infect.log
EOF
}

resource "aws_route53_record" "markab_pegasus_serokell_team_ipv4" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "markab.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "A"
  ttl     = "60"
  records = [hcloud_server.markab.ipv4_address]
}

resource "aws_route53_record" "markab_pegasus_serokell_team_ipv6" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "markab.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "AAAA"
  ttl     = "60"
  records = [hcloud_server.markab.ipv6_address]
}

resource "aws_route53_record" "issues_serokell_io" {
  zone_id = data.aws_route53_zone.serokell_io.zone_id
  name    = "issues.serokell.io"
  type    = "CNAME"
  ttl     = "60"
  records = ["markab.${aws_route53_zone.pegasus_serokell_team.name}"]
}
