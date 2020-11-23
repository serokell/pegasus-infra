resource "hcloud_server" "sadalbari" {
  name = "sadalbari"
  image = "ubuntu-20.04"
  server_type = "cx31"
  ssh_keys = [ hcloud_ssh_key.mkaito.id ]
  # Install NixOS 20.03
  user_data = <<EOF
    #cloud-config

    runcmd:
      - curl https://raw.githubusercontent.com/elitak/nixos-infect/master/nixos-infect | NIX_CHANNEL=nixos-20.03 bash 2>&1 | tee /tmp/infect.log
EOF
}

# Public DNS
resource "aws_route53_record" "sadalbari_pegasus_serokell_team_ipv4" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "sadalbari.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "A"
  ttl     = "60"
  records = [hcloud_server.sadalbari.ipv4_address]
}

resource "aws_route53_record" "sadalbari_pegasus_serokell_team_ipv6" {
  zone_id = aws_route53_zone.pegasus_serokell_team.zone_id
  name    = "sadalbari.${aws_route53_zone.pegasus_serokell_team.name}"
  type    = "AAAA"
  ttl     = "60"
  records = [hcloud_server.sadalbari.ipv6_address]
}
