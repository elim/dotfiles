{
  config,
  lib,
  pkgs,
  ...
}:
let
  # Commands with Linux or Darwin variants
  commandVariants = {
    emacs = {
      linux = "GTK_IM_MODULE=gtk-im-context-simple XMODIFIERS='@im=none' emacs";
      darwin = "Emacs";
      default = "emacs";
    };

    ls = {
      linux = "ls -F --color=auto";
      darwin = "ls -wGF";
      default = "ls";
    };
  };

  # Get command variant based on the system
  getCommandVariant =
    cmdName:
    if pkgs.stdenv.isLinux then
      commandVariants.${cmdName}.linux
    else if pkgs.stdenv.isDarwin then
      commandVariants.${cmdName}.darwin
    else
      commandVariants.${cmdName}.default;

  # Create an enhanced alias based on package presence or command variants
  makeEnhancedAlias =
    {
      cmd, # Base command
      pkg, # Optional enhancement package
      enhanced, # Enhanced command when package is present
      hasVariants ? false, # Whether command has Linux or Darwin variants
    }:
    let
      hasPackage = pkg != null && (lib.any (p: p == pkg) config.home.packages);
      finalCmd = if hasVariants then getCommandVariant cmd else enhanced;
    in
    if (hasPackage && enhanced != cmd) || hasVariants then { ${cmd} = finalCmd; } else { };

  baseAliases = {
    # ls
    la = "ls -AFH";
    ll = "la -l";

    # grep
    grep = "grep --color=always";

    # git
    g = "git";
    gb = "g browse";
    gbr = "g br";
    gbrs = "g brs";
    gbrsr = "g brsr";
    gco = "g co";
    gf = "g fetch";
    gdi = "g di";
    gg = "g grep";
    gl = "g log --stat --show-signature";
    glp = "gl -p";
    gop = "g open";
    gpl = "g pull";
    gp = "g p";
    gps = "g push";
    gr = "cd-gitroot";
    grb = "g rb";
    gref = "g ref";
    gst = "g st";

    # other shorthand
    b = "bundle";
    be = "bundle exec";
    d = "docker";
    dc = "docker compose";
    l = "less";
    v = "vagrant";
  };

  # Enhanced aliases with package dependencies or variants
  enhancedAliases = lib.mkMerge [
    (makeEnhancedAlias {
      cmd = "ls";
      pkg = null;
      enhanced = null;
      hasVariants = true;
    })
    (makeEnhancedAlias {
      cmd = "emacs";
      pkg = null;
      enhanced = null;
      hasVariants = true;
    })
    (makeEnhancedAlias {
      cmd = "cat";
      pkg = pkgs.bat;
      enhanced = "bat";
    })
    (makeEnhancedAlias {
      cmd = "less";
      pkg = pkgs.bat;
      enhanced = "bat";
    })
    (makeEnhancedAlias {
      cmd = "diff";
      pkg = pkgs.colordiff;
      enhanced = "colordiff";
    })
    (makeEnhancedAlias {
      cmd = "vi";
      pkg = pkgs.vim;
      enhanced = "vim";
    })
  ];
in
lib.mkMerge [baseAliases enhancedAliases]
