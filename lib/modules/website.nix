{ config, lib, pkgs, inputs, ...}:
with lib;
let
  vs = config.vault-secrets.secrets;
  name = "www";
  port = 8080;
  profile = "/nix/var/nix/profiles/per-user/${name}/www";
in {
  imports = [
    inputs.serokell-nix.nixosModules.oauth2_proxy
    inputs.serokell-nix.nixosModules.oauth2_proxy_nginx
  ];

  users.users.${name} = {
    createHome = true;
    home = "/var/lib/${name}";

    # Deployment from CI
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIN0vAoNOnqvwI51ypKPVGwVNf2+LB0g8/XFSWazXcq/J" ];
  };

  # Allow the user to restart the backend service for CD
  security.sudo.extraRules = [
    {
      users = [ name ];
      commands = [{
        command = "/run/current-system/sw/bin/systemctl restart ${name}";
        options = [ "NOPASSWD" ];
      }];
    }
  ];

  vault-secrets.secrets.oauth2_proxy.environmentPrefix = "oauth2_proxy";
  services.oauth2_proxy = let
    inherit (config.networking) domain hostName;
  in {
    enable = true;
    email.domains = [ "serokell.io" ];
    keyFile = "${vs.oauth2_proxy}/environment";
    setXauthrequest = true;
    requestLogging = false;

    # Allow to redirect anywhere in the same domain after authentication
    extraConfig.whitelist-domain = [ "serokell.io" ".serokell.io" ];
    cookie.domain = "serokell.io";
  };

  services.nginx = {
    enable = true;
    openFirewall = true;

    # Breaks oauth2_proxy when enabled
    #   Error 400: Too many Host headers
    recommendedProxySettings = lib.mkForce false;

    virtualHosts.www = {
      default = true;
      serverName = "${config.networking.hostName}.${config.networking.domain}";

      # TODO: OPS-1120 Centralized ACME certs with Vault
      enableACME = true;
      forceSSL = true;

      root = "${profile}/out/website";
      extraConfig = ''
        if_modified_since off;
        gzip on;
        rewrite ^/(.*)/index.html$ /$1 permanent;
        rewrite ^/team.html$ /team permanent;
        gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript image/svg+xml;
        brotli_static on;
      '';

      locations = {
        "/static".extraConfig = "expires 7d;";
        "/client".extraConfig = "expires 7d;";
        "/content".extraConfig = "expires 7d;";

        "/files" = {
          root = "/var/lib/${name}";
          extraConfig = "expires 7d;";
        };

        "/" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            proxy_set_header X-User  $user;
            error_page 404 = /404;
          '';
        };

        "/api" = {
          proxyPass = "http://127.0.0.1:${toString port}";
          extraConfig = ''
            proxy_intercept_errors off;
            expires -1;
            error_page 404 = /404;

            auth_request /oauth2/auth;
            error_page 401 = /oauth2/sign_in;

            # pass information via X-User and X-Email headers to backend,
            # requires running with --set-xauthrequest flag
            auth_request_set $user   $upstream_http_x_auth_request_user;
            auth_request_set $email  $upstream_http_x_auth_request_email;
            proxy_set_header X-User  $user;
            proxy_set_header X-Email $email;

            # if you enabled --cookie-refresh, this is needed for it to work with auth_request
            auth_request_set $auth_cookie $upstream_http_set_cookie;
            add_header Set-Cookie $auth_cookie;
          '';
        };

      };
    };
  };

  vault-secrets.secrets.${name}.user = name;
  systemd.services."${name}" = rec {
    wantedBy = [ "multi-user.target" ];
    path = with pkgs; [ bash graphicsmagick ];

    # Do not attempt to start this unit unless the app profile path exists
    unitConfig.ConditionPathExists = [ profile ];

    environment = {
      HOME = "/var/lib/${name}";

      # PGUSER and PGDATABASE set at server level
      PGHOST = "matar";
    };

    serviceConfig = {
      Restart = "on-failure";
      RestartSec = 1;
      User = name;

      # Contains app secrets
      EnvironmentFile = "${vs.${name}}/environment";
    };

    # Ensure upload folder exists and permissions are correct
    preStart = ''
      mkdir -p $HOME/files
      chmod 0755 $HOME/files
      chown -R "$USER" $HOME
    '';

    script = ''
      # Fail on unset variables to ensure PG* are all defined
      set -u

      # PG is read by the app and passed to `pg` as `connectionString`
      export PG="postgresql://$PGUSER:$(cat ${vs.${name}}/pg_password)@$PGHOST/$PGDATABASE"

      exec ${profile}/bin/npm start \
        --scripts-prepend-node-path=true \
        --serokell-website:port=${toString port} \
        --serokell-website:uploadpath=$HOME/files
    '';
  };

}
