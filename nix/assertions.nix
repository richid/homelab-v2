{ config, lib, ... }:
let
  dupesOf = field:
    let
      having = lib.filterAttrs (_: svc: svc.${field} != null) config.homelab.services;
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
      message   = "Duplicate homelab.services IPs: ${lib.concatStringsSep "; " ipDupes}";
    }
    {
      assertion = uidDupes == [ ];
      message   = "Duplicate homelab.services UIDs: ${lib.concatStringsSep "; " uidDupes}";
    }
  ];
}
