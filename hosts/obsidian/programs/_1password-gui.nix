{ config, ... }:
{
  programs._1password-gui = {
    enable = true;

    polkitPolicyOwners = [ config.users.users.default.name ];
  };
}
