{ config, lib, pkgs, ... }:

let
  profile = "/nix/var/nix/profiles/per-user/www/ariadne-landing";
  port = 8120;

in {
  # used by buildkite for deploying updates from ariadne-landing CI
  users.users.bk-ariadne-landing = {
    isNormalUser = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMwZWnQ5Oqkjkfjw/dZsjP3jIL6f3xT73DOb5+L5mxpo" ];
  };

  systemd.services.ariadne-landing = {
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${profile}/bin/npm start --port=${toString port}";
      DynamicUser = true;
    };
  };

  # allow buildkite to restart the service for CD
  security.sudo.extraRules = [{
    users = [ "bk-ariadne-landing" ];
    commands = [{
      command = "/run/current-system/sw/bin/systemctl restart ariadne-landing";
      options = [ "NOPASSWD" ];
    }];
  }];

  services.nginx.virtualHosts.www = {
    # proxy serokell.io/ariadne to the ariadne-landing service
    locations."/ariadne".proxyPass = "http://127.0.0.1:${toString port}";
  };
}
