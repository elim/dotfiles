{ pkgs, pkgs-stable, ... }:

{
  home.packages =
    with pkgs;
    [
      albert
      avidemux
      brave
      firefox
      handbrake
      libreoffice
      slack
      thunderbird
      xorg.xhost
      zenity
      zoom-us
    ]
    ++ (with gnomeExtensions; [
      appindicator
      kimpanel
      xremap
    ])
    ++ (
      with skkDictionaries;
      map (pkg: pkg.override { useUtf8 = true; }) [
        l
        jinmei
        fullname
        geo
        okinawa
        china_taiwan
        station
        propernoun
        itaiji
        zipcode
      ]
    )
    ++ (with pkgs-stable; [ ]);
}
