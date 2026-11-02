{ lib, ... }:
let
  vars     = import ./variables.nix;
  withIp   = lib.filterAttrs (_: svc: builtins.isAttrs svc && svc ? ip) vars.services;
  byIp     = lib.groupBy (name: withIp.${name}.ip) (builtins.attrNames withIp);
  dupes    = lib.filterAttrs (_: names: builtins.length names > 1) byIp;
  dupeList = lib.mapAttrsToList (ip: names: "${ip} (${lib.concatStringsSep ", " names})") dupes;
in
{
  assertions = [
    {
      assertion = dupes == { };
      message   = "Duplicate service IPs in variables.nix: ${lib.concatStringsSep "; " dupeList}";
    }
  ];
}
