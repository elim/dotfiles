{ lib, fetchzip }:

let
  pname = "Cica";
  version = "5.0.3";
in
fetchzip {
  name = "${lib.toLower pname}-${version}";
  url = "https://github.com/miiton/${pname}/releases/download/v${version}/${pname}_v${version}.zip";
  sha256 = "sha256-C62wzXLDjC9sJ3et8UMWS6tld4YMek/tEeSpiwGeDwg=";

  stripRoot = false;

  postFetch = ''
    mkdir -p $out/share/fonts/truetype
    mv $out/*.ttf $out/share/fonts/truetype
  '';

  meta = with lib; {
    description = "Cica";
    longDescription = "A monospaced Japanese font for programming.";
    homepage = "https://github.com/miiton/Cica";
    license = licenses.ofl;
    platforms = platforms.all;
    maintainers = with maintainers; [ elim ];
  };
}
