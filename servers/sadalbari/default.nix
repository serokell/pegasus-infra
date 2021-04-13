{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    inputs.hackage-search.module
    ./hackage-search.nix
    ./fail2ban.nix
  ];

  networking.hostName = "sadalbari";
  wireguard-ip-address = "172.21.0.8";

  hetzner.ipv6Address = "2a01:4f8:1c1c:335e::1";
}
