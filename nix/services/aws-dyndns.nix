{ config, pkgs, lib, ... }:
let
  vars    = import ../variables.nix;
in
{
  virtualisation.oci-containers.containers = {
    aws-dyndns = {
      image = "${vars.services.aws-dyndns.image}:${vars.services.aws-dyndns.version}";
      environment = {
        AWS_REGION             = "us-east-1";
        IPCHECKER              = "ipify.org";
        LOG_TO_STDOUT          = "true";
        ROUTE53_DOMAIN         = "mc.fatsch.us";
        ROUTE53_TYPE           = "A";
        ROUTE53_TTL            = "300";
        UPDATE_FREQUENCY       = "3600000";
        TZ                     = "America/New_York";
      };
      environmentFiles = [ config.age.secrets.aws-dyndns.path ];
      extraOptions = [
        "--network=services"
      ];
    };
  };
}