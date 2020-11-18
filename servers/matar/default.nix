{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ./backups.nix
    ./postgresql.nix
  ];

  networking.hostName = "matar";
}
