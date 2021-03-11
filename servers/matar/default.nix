{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.ec2

    ./backups.nix
    ./postgresql.nix
  ];

  networking.hostName = "matar";
}
