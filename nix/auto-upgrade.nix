{ config, pkgs, ... }:
let
  flakeRepo    = "github:richid/homelab-v2";
  upgradeState = "/var/lib/nixos-upgrade";

  watver = pkgs.writeShellApplication {
    name          = "watver";
    runtimeInputs = [ pkgs.curl pkgs.jq ];
    text          = ''
      rev=$(/run/current-system/sw/bin/nixos-version --configuration-revision)
      curl -fsS "https://api.github.com/repos/richid/homelab-v2/commits/$rev" | jq -r '"\(.sha[0:7]) \(.commit.committer.date) \(.commit.message | split("\n")[0])"'
    '';
  };
in
{
  environment.systemPackages = [ watver ];

  system.autoUpgrade = {
    enable      = true;
    flake       = "${flakeRepo}#gibson";
    dates       = "*:0/5";
    flags       = [ "--refresh" ];
    operation   = "switch";
    upgrade     = false;
    allowReboot = false;
  };

  systemd.services.nixos-upgrade = {
    onFailure     = [ "notify-gotify@%n.service" ];
    serviceConfig = {
      ExecCondition = pkgs.writeShellScript "nixos-upgrade-changed" ''
        ${pkgs.coreutils}/bin/mkdir -p ${upgradeState}
        ${pkgs.coreutils}/bin/rm -f ${upgradeState}/candidate
        remote=$(${config.nix.package}/bin/nix --extra-experimental-features 'nix-command flakes' flake metadata --refresh --json ${flakeRepo} | ${pkgs.jq}/bin/jq -r .revision)
        current=$(/run/current-system/sw/bin/nixos-version --configuration-revision)
        [ -n "$remote" ] || exit 0
        [ "$remote" != "$current" ] || exit 1
        [ "$remote" != "$(${pkgs.coreutils}/bin/cat ${upgradeState}/failed-rev 2>/dev/null)" ] || exit 1
        printf '%s\n' "$remote" > ${upgradeState}/candidate
      '';
      ExecStopPost  = pkgs.writeShellScript "nixos-upgrade-record" ''
        case "$SERVICE_RESULT" in
          success) ${pkgs.coreutils}/bin/rm -f ${upgradeState}/failed-rev ;;
          exec-condition) ;;
          *) [ ! -f ${upgradeState}/candidate ] || ${pkgs.coreutils}/bin/cp ${upgradeState}/candidate ${upgradeState}/failed-rev ;;
        esac
      '';
    };
  };
}
