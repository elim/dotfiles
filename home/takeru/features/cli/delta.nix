{ pkgs, ... }:

{
  home.packages = [ pkgs.delta ];

  home.sessionVariables = {
    KUBECTL_EXTERNAL_DIFF = "${pkgs.delta}/bin/delta";
  };
}
