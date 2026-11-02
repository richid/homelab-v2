{ lib, ... }:
let
  vars = import ./variables.nix;

  dupesOf = field:
    let
      having = lib.filterAttrs (_: svc: builtins.isAttrs svc && svc ? ${field}) vars.services;
      byVal  = lib.groupBy (name: toString having.${name}.${field}) (builtins.attrNames having);
      dupes  = lib.filterAttrs (_: names: builtins.length names > 1) byVal;
    in
    lib.mapAttrsToList (val: names: "${val} (${lib.concatStringsSep ", " names})") dupes;

  ipDupes  = dupesOf "ip";
  uidDupes = dupesOf "uid";
in
{
  assertions = [
    {
      assertion = ipDupes == [ ];
      message   = "Duplicate service IPs in variables.nix: ${lib.concatStringsSep "; " ipDupes}";
    }
    {
      assertion = uidDupes == [ ];
      message   = "Duplicate service UIDs in variables.nix: ${lib.concatStringsSep "; " uidDupes}";
    }
  ];
}
