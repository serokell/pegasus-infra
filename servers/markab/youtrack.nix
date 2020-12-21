{ ... }:

{
  networking.firewall.allowedTCPPorts = [
    80 443 # nginx
  ];

  services.nginx = {
    enable = true;
    virtualHosts = {
      youtrack = {
        serverName = "issues.serokell.io";
        enableACME = true;
        forceSSL = true;
      };
    };
  };

  # youtrack requires 'allowUnfree'
  nixpkgs.config.allowUnfree = true;

  services.youtrack = {
    enable = true;
    virtualHost = "youtrack";
    maxMemory = "2g";
  };
}
