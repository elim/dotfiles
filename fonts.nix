{ pkgs, ... }:

{
  # https://nixos.wiki/wiki/Fonts
  fonts = {
    enableDefaultFonts = true;
    fonts = with pkgs; [
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
          "BIZ UDGothic"
          "Noto Sans"
          "Noto Sans CJK JP"
        ];
        monospace = [
          "Noto Sans Mono"
          "Noto Sans Mono CJK JP"
        ];
      };
    };
  };
}
