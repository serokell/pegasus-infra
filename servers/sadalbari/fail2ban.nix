{
  # Disable access log to avoid flooding
  services.nginx.commonHttpConfig = ''
    access_log off;
  '';

  services.fail2ban = {
    enable = true;

    # Ban clients abusing old SSL
    jails.nginx-old-ssl = ''
      enabled = true
      filter = nginx-old-ssl
      maxretry = 2
      bantime = 432000 ; 5 days
      findtime = 600 ; 10 minutes
    '';
  };

  environment.etc."fail2ban/filter.d/nginx-old-ssl.conf" = {
    enable = true;
    text = ''
      [Definition]
      failregex = ^.* error:1408F0C6:SSL .* client: <HOST>, .*$
      port = http,https
      backend = systemd
      journalmatch = SYSLOG_IDENTIFIER=nginx
      banaction = iptables-allports[name="nginx-old-ssl"]
    '';
  };

}
