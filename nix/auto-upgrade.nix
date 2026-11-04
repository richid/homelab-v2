{ config, pkgs, ... }:
let
  flakeRepo = "github:richid/homelab-v2";

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
    onFailure = [ "notify-gotify@%n.service" ];
    serviceConfig.ExecCondition = pkgs.writeShellScript "nixos-upgrade-changed" ''
      remote=$(${config.nix.package}/bin/nix --extra-experimental-features 'nix-command flakes' flake metadata --refresh --json ${flakeRepo} | ${pkgs.jq}/bin/jq -r .revision)
      current=$(/run/current-system/sw/bin/nixos-version --configuration-revision)
      [ -z "$remote" ] || [ "$remote" != "$current" ]
    '';
  };
}
