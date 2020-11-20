{ localModulesPath, ... }:
{
  imports = [
    "${localModulesPath}/backups.nix"
  ];

  services.borgbackup.jobs.backup = {
    # https://www.notion.so/serokell/Rsync-net-797d5fdca3744aed8e17db741b7fce5a
    repo = "12482@ch-s012.rsync.net:www";
    paths = [ "/var/lib/www/files" ];
    startAt = "hourly";
  };
}
