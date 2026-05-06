{ pkgs, ... }:
{
  home.shellAliases = {
    # ls
    ls = "eza --classify --group-directories-first --icons";
    la = "eza --classify --group-directories-first --icons --almost-all";
    ll = "eza --classify --group-directories-first --icons --almost-all --long --git --header --time-style=relative";
    lt = "eza --tree --level=2 --icons";
    llt = "eza --tree --level=2 --long --git --icons";

    cat = "bat";
    less = "bat";

    diff = "colordiff";

    emacs =
      if pkgs.stdenv.isDarwin then
        "open -a Emacs"
      else
        "GTK_IM_MODULE=gtk-im-context-simple XMODIFIERS='@im=none' emacs";
    vi = "vim";

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

    # rm
    rm = "gomi";

    # jobcan
    jt = "jobcan-slack --jt";
    jw = "jobcan-slack --jw";

    # other shorthand
    b = "bundle";
    be = "bundle exec";
    d = "docker";
    dc = "docker compose";
    l = "less";
  };
}
