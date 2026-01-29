{ pkgs }:

{
  slackdump-auth = import ./slackdump-auth.nix { inherit pkgs; };
}
