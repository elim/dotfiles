{ pkgs, ... }:

let
  set-docker-detach-keys = pkgs.callPackage ../../../../pkgs/set-docker-detach-keys { inherit pkgs; };
in
{
  home.packages = [ set-docker-detach-keys ];

  home.activation = {
    setDockerDetachKeys = ''
      ${set-docker-detach-keys}/bin/set-docker-detach-keys
    '';
  };
}
