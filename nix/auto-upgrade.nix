{ config, pkgs, ... }:
let
  flakeRepo = "github:richid/homelab-v2";
in
{
  age.secrets.gotify-gibson.file = ../secrets/gotify-gibson.env.age;

  system.autoUpgrade = {
    enable      = true;
    flake       = "${flakeRepo}#gibson";
    dates       = "*:0/5";
    flags       = [ "--refresh" ];
    operation   = "switch";
    allowReboot = false;
  };

  systemd.services.nixos-upgrade = {
    onFailure = [ "notify-gotify@%n.service" ];
    serviceConfig.ExecCondition = pkgs.writeShellScript "nixos-upgrade-changed" ''
      remote=$(${config.nix.package}/bin/nix --extra-experimental-features 'nix-command flakes' flake metadata --refresh --json ${flakeRepo} | ${pkgs.jq}/bin/jq -r .revision)
      current=$(/run/current-system/sw/bin/nixos-version --configuration-revision)
      [ -z "$remote" ] || [ "$remote" != "$current" ]
    '';
  };

  systemd.services."notify-gotify@" = {
    description = "Send a Gotify message when %i fails";
    serviceConfig = {
      Type            = "oneshot";
      EnvironmentFile = config.age.secrets.gotify-gibson.path;
    };
    scriptArgs = "%i";
    script = ''
      log=$(${config.systemd.package}/bin/journalctl -u "$1" -n 20 --no-pager -o cat)
      log=''${log:-No log lines for $1.}
      ${pkgs.curl}/bin/curl -fsS -X POST -H "X-Gotify-Key: $GOTIFY_TOKEN" --form-string "title=gibson: $1 failed" --form-string "message=$log" --form-string "priority=8" https://gotify.fatsch.us/message
    '';
  };
}
