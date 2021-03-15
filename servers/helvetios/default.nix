{ config, modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.ec2

    ./backups.nix
    ./website.nix
  ];

  networking.hostName = "helvetios";
}
