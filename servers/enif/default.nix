{ modulesPath, inputs, ... }:
{
  imports = [
    inputs.serokell-nix.nixosModules.ec2

    ./ariadne-landing.nix
    ./backups.nix
    ./website.nix
  ];

  networking.hostName = "enif";
  wireguard-ip-address = "172.21.0.4";
}
