{ config, pkgs, lib, ... }:
let
  vs = config.vault-secrets.secrets;
in {
  vault-secrets.secrets.borgbackup = {
    secretsAreBase64 = true;
    services = [ "borgbackup-job-backup" ];
  };

  # We define a known job name in order to set default values for it
  # Our servers only run one backup job each, so this is not a problem
  # TODO: Upstream a `defaults` attribute to the borgbackup NixOS module
  services.borgbackup.jobs.backup = {
    encryption = {
      # Keep the encryption key in the repo itself
      mode = "repokey-blake2";

      # Password is used to decrypt the encryption key from the repo
      passCommand = "cat ${vs.borgbackup}/repo_password";
    };

    environment = {
      # Make sure we're using Borg >= 1.0
      BORG_REMOTE_PATH = "borg1";

      # SSH key is specific to the subaccount, and is pulled from Vault
      BORG_RSH = "ssh -i ${vs.borgbackup}/ssh_private_key";
    };

    # Make sure we don't accidentally a bunch of crap
    exclude = [
      "**/.cabal"
      "**/.stack-work"
      "**/.stack"
      "**/.cache"
    ];

    prune.keep = {
      # hourly backups for the past week
      within = "7d";

      # daily backups for two weeks before that
      daily = 14;

      # weekly backups for a month before that
      weekly = 4;

      # monthly backups for 6 months before that
      monthly = 6;
    };
  };

  # Ensure the unit doesn't go crazy trying to restart when something goes wrong.
  # TODO: Upstream defaults to nixpkgs
  systemd.services."borgbackup-job-backup" = {
      unitConfig = {
        StartLimitInterval = 300;
        StartLimitBurst = 3;
      };

      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 10;
      };
    };
}
