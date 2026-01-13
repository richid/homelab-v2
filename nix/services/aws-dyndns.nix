{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
  secrets = import ../secrets.nix;
in
{
  virtualisation.oci-containers.containers = {
    aws-dyndns = {
      image = "sjmayotte/route53-dynamic-dns:v1.4.1";
      environment = {
        AWS_ACCESS_KEY_ID      = secrets.aws_dyndns.key;
        AWS_SECRET_ACCESS_KEY  = secrets.aws_dyndns.secret;
        AWS_REGION             = "us-east-1";
        IPCHECKER              = "ipify.org";
        LOG_TO_STDOUT          = "true";
        ROUTE53_HOSTED_ZONE_ID = secrets.aws_dyndns.zone_id;
        ROUTE53_DOMAIN         = "mc.fatsch.us";
        ROUTE53_TYPE           = "A";
        ROUTE53_TTL            = "300";
        UPDATE_FREQUENCY       = "3600000";
        TZ                     = "America/New_York";
      };
      extraOptions = [
        "--network=services"
      ];
    };
  };
}