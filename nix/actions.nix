{ inputs, ... }:
let
  inherit (inputs.nix-actions.lib) steps;
in
{
  imports = [ inputs.actions-nix.flakeModules.default ];
  flake.actions-nix = {
    pre-commit.enable = true;
    defaultValues = {
      jobs = {
        runs-on = "ubuntu-latest";
      };
    };
    workflows = {
      ".github/workflows/docker-publish.yaml" = inputs.nix-actions.lib.mkDocker { name = "ociImage"; };
      ".github/workflows/helm-publish.yaml" = {
        on.push.tags = [ "v*" ];
        jobs.helm = {
          steps = [
            steps.checkout
            steps.dockerLogin
            {
              name = "Package and push Helm Chart";
              "if" = "github.event_name != 'pull_request'";
              run = ''
                cd chart
                CHART_VERSION="''${GITHUB_REF_NAME#"v"}" # remove the leading "v"
                sed -i "s|0.0.0-template|$CHART_VERSION|" Chart.yaml
                REPO_OWNER=`echo "''${{ github.repository_owner }}" | tr '[:upper:]' '[:lower:]'`
                # print helm version
                helm version
                # create chart package
                helm package .
                # Get packed chart file name
                PKG_NAME=`ls *.tgz`
                # push to GHCR
                helm push ''${PKG_NAME} oci://ghcr.io/''${REPO_OWNER}/charts
              '';
            }
          ];
        };
      };
    };
  };
}
