{
  programs.starship = {
    enable = true;
    enableZshIntegration = false;

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
