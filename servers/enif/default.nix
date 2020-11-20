{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ./backups.nix
    ./website.nix
  ];

  networking.hostName = "enif";
}
