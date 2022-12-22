{ pkgs, ... }:

let
  cica = pkgs.callPackage ./packages/cica.nix { };
in
{
  # https://nixos.wiki/wiki/Fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
      cica

      (google-fonts.override {
        fonts = [
          "BIZUDGothic"
          "BIZUDMincho"
        ];
      })

      noto-fonts
      noto-fonts-cjk-sans
      noto-fonts-cjk-serif
      noto-fonts-emoji
    ];

    fontconfig = {
      defaultFonts = {
        serif = [
          "BIZ UDMincho"
          "Noto Serif"
          "Noto Serif CJK JP"
        ];
        sansSerif = [
          "Cica"
          "BIZ UDGothic"
          "Noto Sans"
          "Noto Sans CJK JP"
        ];
        monospace = [
          "Cica"
          "Noto Sans Mono"
          "Noto Sans Mono CJK JP"
        ];
      };
    };
  };
}
