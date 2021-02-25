{ localModulesPath, ... }:
{
  imports = [
    "${localModulesPath}/website.nix"
  ];

  # Configure server-local database credentials
  # PGPASSWORD is fetched from Vault
  systemd.services.www.environment = {
    PGUSER = "www-user";
    PGDATABASE = "www";
  };

  services.oauth2_proxy = {
    # Do not forward 401 errors from auth backend to the client
    nginx.virtualHosts.www.applicationChecksAuth = true;

    # Make sure the exact callback URL is registered with Google
    redirectURL = "https://serokell.io/oauth2/callback";
  };

  services.nginx.virtualHosts = {
    # Refuse any traffic that doesn't send X-From-CloudFront header
    # Or that is not for the ACME challenge
    www.extraConfig = ''
      if ($request_uri !~ "/\.well-known/acme-challenge/.*") {
        set $match 1;
      }
      if ($http_x_from_cloudfront = "") {
        set $match 1$match;
      }
      if ($match = 11) {
        return 404;
      }
    '';

    # redirect *.serokell.io to serokell.io
    "*.serokell.io".globalRedirect = "serokell.io";

    # redirect abf.serokell.io to serokell.io/abf
    "abf.serokell.io".globalRedirect = "serokell.io/abf";
  };

  # Set internal hostname to be the public DNS name rather than the internal name
  services.oauth2_proxy.nginx.virtualHosts.www.host = "serokell.io";
}
