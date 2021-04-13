{ config, inputs, ... }:
let
  constellation = "pegasus";
in {
  imports = [
    inputs.serokell-nix.nixosModules.common
    inputs.serokell-nix.nixosModules.serokell-users
    inputs.serokell-nix.nixosModules.wireguard-monitoring
    inputs.vault-secrets.nixosModules.vault-secrets
  ];

  networking.domain = "${constellation}.serokell.team";

  vault-secrets = {
    vaultPrefix = "kv/sys/${constellation}/${config.networking.hostName}";
    vaultAddress = "https://vault.serokell.org:8200";
    approlePrefix = "${constellation}-${config.networking.hostName}";
  };
}
