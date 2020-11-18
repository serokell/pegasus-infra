{ pkgs, lib, ... }:
{
  networking.firewall.allowedTCPPorts = [ 5432 ];
  services.postgresql = rec {
    enable = true;

    # By default only listens on UNIX socket
    enableTCPIP = true;

    # Defaults to md5, resulting in users not having a valid scram-sha-256
    # password and being unabe to log in.
    settings.password_encryption = "scram-sha-256";

    # Each database has a corresponding role with the same name and full access
    # Users will need to be members of the corresponding role for database access
    ensureDatabases = [ "www" "www-staging" ];
    ensureUsers =
      map (db: {
        name = db;
        ensurePermissions = {
          "DATABASE \"${db}\"" = "ALL";
        };
      }) ensureDatabases;

    authentication = ''
      ## Allow login over TCP:
      # To users that are a member of a role with the same name as the target database
      # Only from private VPC network
      # Providing a valid password
      host samerole all 10.0.0.0/16 scram-sha-256
    '';
  };
}
