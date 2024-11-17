{
  config,
  pkgs,
  pinned-pkgs,
  ...
}:
{
  home = rec {
    stateVersion = "24.11";

    username = "takeru";
    homeDirectory = "/home/${username}";
  };

  imports = [
    ./modules
  ];

  services.dropbox = {
    enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "Nord";
    };
  };

  programs.direnv = {
    enable = true;
    nix-direnv = {
      enable = true;
    };
  };

  programs.home-manager.enable = true;

  programs.mpv = {
    enable = true;
    config = {
      save-position-on-quit = true;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      git_commit = {
        tag_disabled = false;
      };

      time = {
        disabled = false;
      };
    };
  };
}
