{ config, pkgs, ... }:
let
  flakeRepo = "github:richid/homelab-v2";
in
{
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
}
