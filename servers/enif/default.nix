{ modulesPath, ... }:
{
  imports = [
    "${modulesPath}/virtualisation/amazon-image.nix"
    ./ariadne-landing.nix
    ./backups.nix
    ./website.nix
  ];

  networking.hostName = "enif";
}
