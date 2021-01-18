{ inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    ./backups.nix
    ./youtrack.nix
  ];

  networking.hostName = "markab";

  hetzner.ipv6Address = "2a01:4f9:c010:d32a::1";
}
