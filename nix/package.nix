{ self, ... }:
{
  perSystem =
    {
      pkgs,
      ...
    }:
    {
      packages = rec {
        default = desec-http;
        desec-http = pkgs.buildGoModule {
          name = "cert-manager-webhook-desec-http";
          src = self;
          vendorHash = "sha256-Rpm4nCur2d2EPxwM/TIjb5UExxlxGdu08MK7x5L08EQ=";
          doCheck = false;
          ldflags = [
            "-s -w"
          ];
        };
      };
    };
}
