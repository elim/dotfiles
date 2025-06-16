{
  pkgs,
  ...
}:
let
  system = pkgs.stdenv.hostPlatform.parsed.kernel.name;

  variants = {
    emacs = {
      linux = "GTK_IM_MODULE=gtk-im-context-simple XMODIFIERS='@im=none' emacs";
      darwin = "Emacs";
    };

    ls = {
      linux = "ls -F --color=auto";
      darwin = "ls -wGF";
    };
  };
in
{
  # ls
  ls = variants.ls."${system}";
  la = "ls -AFH";
  ll = "la -l";

  cat = "bat";
  less = "bat";

  diff = "colordiff";

  emacs = variants.emacs."${system}";
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

  # other shorthand
  b = "bundle";
  be = "bundle exec";
  d = "docker";
  dc = "docker compose";
  l = "less";
  v = "vagrant";
}
