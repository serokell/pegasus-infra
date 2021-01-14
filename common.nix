{ config, inputs, ... }:
let
  constellation = "pegasus";
in {
  imports = [
    inputs.serokell-nix.nixosModules.common
    inputs.serokell-nix.nixosModules.serokell-users
    inputs.serokell-nix.nixosModules.vault-secrets
  ];

  networking.domain = "${constellation}.serokell.team";

  vault-secrets = {
    vaultPathPrefix = "kv/sys/${constellation}";
    vaultAddress = "https://vault.serokell.org:8200";
    namespace = config.networking.hostName;
    approlePrefix = "${constellation}-${config.networking.hostName}";
  };
}
