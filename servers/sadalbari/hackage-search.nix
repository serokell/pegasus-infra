{ config, ... }:

let profile = "/nix/var/nix/profiles/per-user/deploy/hackage-search";
in {
  services.hackage-search = {
    enable = true;
    package = profile;
  };

  services.nginx = {
    enable = true;
    openFirewall = true;
    virtualHosts.hackage-search = {
      serverName = with config.networking; "${hostName}.${domain}";
      serverAliases = [ "hackage-search.serokell.io" ];
      default = true;
      enableACME = true;
      forceSSL = true;
    };
  };

  # Deployment from CI
  users.users.deploy = {
    useDefaultShell = true;
    isSystemUser = true;
    # Pipeline: serokell/hackage-search
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKqZIf4rw89vg/EpDaYkSm3i5y8WkQv7ByI8yy9elqcl" ];
  };

  # Allow the user to restart the backend service for CD
  security.sudo.extraRules =
    [ {
      users = [ "deploy" ];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl restart hackage-search";
        options = [ "NOPASSWD" ];
      }];
    } ];

  serokell-users.regularUsers = [ "int-index" ];
}
