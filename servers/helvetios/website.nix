{ pkgs, localModulesPath, ... }:
let
  robots-deny = pkgs.writeText "robots.txt" ''
    User-agent: *
    Disallow: /
  '';
in {
  imports = [
    "${localModulesPath}/website.nix"
  ];

  # Configure server-local database credentials
  # PGPASSWORD is fetched from Vault
  systemd.services.www.environment = {
    PGUSER = "www-staging-user";
    PGDATABASE = "www-staging";
  };

  services.oauth2_proxy = {
    # Make sure the exact callback URL is registered with Google
    redirectURL = "https://staging.serokell.io/oauth2/callback";

    # Do not intercept 401 errors from auth backend
    nginx.virtualHosts.www.applicationChecksAuth = false;
  };

  services.nginx.virtualHosts.www = {
    # Disable all web crawling
    locations."= /robots.txt".alias = robots-deny;

    # Aliases for CNAME and ACME
    serverAliases = [ "staging.serokell.io" ];
  };
}
