{ config, ... }:
{
  homelab.services.aws-dyndns = {
    image       = "sjmayotte/route53-dynamic-dns";
    version     = "v1.4.5";
    appPath     = null;
    environment = {
      AWS_REGION       = "us-east-1";
      IPCHECKER        = "ipify.org";
      LOG_TO_STDOUT    = "true";
      ROUTE53_DOMAIN   = "mc.fatsch.us";
      ROUTE53_TYPE     = "A";
      ROUTE53_TTL      = "300";
      UPDATE_FREQUENCY = "3600000";
      TZ               = "America/New_York";
    };
    environmentFiles = [ config.age.secrets.aws-dyndns.path ];
  };
}
