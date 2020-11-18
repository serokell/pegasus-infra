{ config, localModulesPath, ... }:
{
  imports = [
    "${localModulesPath}/backups.nix"
  ];

  # Ensure that we have a folder to dump PG backups into
  systemd.tmpfiles.rules = [
    # https://www.freedesktop.org/software/systemd/man/tmpfiles.d.html
    "d /var/lib/backup 0700 -"
  ];

  services.borgbackup.jobs.backup = {
    # https://www.notion.so/serokell/Rsync-net-797d5fdca3744aed8e17db741b7fce5a
    repo = "12482@ch-s012.rsync.net:postgres";
    startAt = "hourly";

    # Only back up the database dumps
    paths = [ "/var/lib/backup" ];

    # By default, Borg has read-only access to most of the system
    # We need write access to this folder to dump the databases into
    readWritePaths = [ "/var/lib/backup" ];

    # Dump all databases to a file
    preHook = ''
      /run/wrappers/bin/sudo -u postgres \
        ${config.services.postgresql.package}/bin/pg_dumpall \
        > /var/lib/backup/postgres_dump_$(date -uIm).psql
    '';

    # Delete database dumps after backing up
    postHook = ''
      find /var/lib/backup -iname '*.psql' -delete
    '';

  };
}
