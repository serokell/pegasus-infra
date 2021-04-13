{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.ec2

    ./backups.nix
    ./postgresql.nix
  ];

  networking.hostName = "matar";
  wireguard-ip-address = "172.21.0.7";
}
