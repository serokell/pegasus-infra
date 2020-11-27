{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    inputs.hackage-search.module
    ./hackage-search.nix
    ./fail2ban.nix
  ];

  networking.hostName = "sadalbari";
}
