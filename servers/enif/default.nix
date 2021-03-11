{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.ec2

    ./ariadne-landing.nix
    ./backups.nix
    ./website.nix
  ];

  networking.hostName = "enif";
}
