{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    inputs.hackage-search.module
    ./hackage-search.nix
    ./fail2ban.nix
  ];

  networking.hostName = "sadalbari";

  hetzner.ipv6Address = "2a01:4f8:1c17:6a18::1";
}
