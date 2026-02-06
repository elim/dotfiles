{ dotfiles, ... }:

let
  sopsFile = "${dotfiles}/secrets/esa.yaml";
in
{
  "esa/access_token" = {
    inherit sopsFile;
    key = "access_token";
  };
}
