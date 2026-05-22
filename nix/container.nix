_: {
  perSystem =
    {
      pkgs,
      inputs',
      self',
      ...
    }:
    let
      nix2containerPkgs = inputs'.nix2container.packages;
      package = self'.packages.desec-http;
      inherit (package) name;
    in
    {
      packages = {
        ociImage = nix2containerPkgs.nix2container.buildImage {
          name = self'.packages.default.name;
          tag = "latest";

          copyToRoot = pkgs.buildEnv {
            name = "certs";
            paths = [ pkgs.cacert ];
            pathsToLink = [ "/etc/ssl" ];
          };

          config = {
            Entrypoint = [
              "${package}/bin/${name}"
              "--secure-port=8443"
            ];
          };
        };
      };
    };
}
