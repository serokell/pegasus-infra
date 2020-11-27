{ config, pkgs, lib, localModulesPath, ... }:

let
  borgCfg = config.services.borgbackup.jobs.backup;

in {
  imports = [
    "${localModulesPath}/backups.nix"
  ];

  systemd.tmpfiles.rules = [
    "d /var/lib/backup 0700 -"
  ];

  systemd.services.borgbackup-job-backup.enable = false;

  services.borgbackup.jobs.backup = {
    repo = "12482@ch-s012.rsync.net:youtrack";

    startAt = "hourly";

    paths = [ "/var/lib/backup" ];

    readWritePaths = [ "/var/lib/youtrack/.youtrack/backups" "/var/lib/backup" ];

    preHook = ''
      set -uo pipefail
      shopt -s nullglob

      YOUTRACK_BACKUP_DIR=/var/lib/youtrack/.youtrack/backups
      if [[ -z $(ls -A "$YOUTRACK_BACKUP_DIR") ]]; then
        echo "$YOUTRACK_BACKUP_DIR is empty, skipping upload" >&2
        exit 0
      fi

      for BACKUP in "$YOUTRACK_BACKUP_DIR"/*.tar.gz; do
        # decompress tar file to enable deduplication
        ${pkgs.gzip}/bin/gzip --decompress --to-stdout "$BACKUP" > /var/lib/backup/youtrack_$(basename "$BACKUP" .gz)
        rm "$BACKUP"
      done
    '';

    postHook = ''
      for BACKUP in /var/lib/backup/youtrack_*.tar; do
        rm "$BACKUP"
      done
    '';
  };

  # Oneshot systemd service to extract latest youtrack backup into /tmp/youtrack-dump.
  # Intended to be run manually
  systemd.services.extract-youtrack-backup = {
    path = with pkgs; [ borgbackup openssh gzip ];

    script = ''
      set -uo pipefail

      # get latest archive name
      LATEST_ARCHIVE=$(borg list --short | tail -n1)

      # extract latest archive to /tmp/youtrack-dump
      mkdir -p /tmp/youtrack-dump
      cd /tmp/youtrack-dump
      borg extract "::$LATEST_ARCHIVE"

      # run gzip on the latest backup from the archive
      cd var/lib/backup
      LATEST_BACKUP=$(ls | tail -n1)
      gzip "$LATEST_BACKUP"

      # make backup readable by youtrack
      chown -R youtrack:youtrack /tmp/youtrack-dump
    '';

    environment = {
      BORG_REPO = borgCfg.repo;
      BORG_PASSCOMMAND = borgCfg.encryption.passCommand;
    } // borgCfg.environment;

    serviceConfig = {
      Type = "oneshot";
    };
  };
}
