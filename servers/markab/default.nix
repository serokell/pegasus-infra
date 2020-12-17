{ inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.hetzner-cloud
    ./backups.nix
    ./youtrack.nix
  ];

  networking.hostName = "markab";
}
