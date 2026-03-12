{
  lib,
  pkgs,
  python3Packages,
}:

let
  giTypelibPath = lib.makeSearchPath "lib/girepository-1.0" [
    pkgs.libfprint
    pkgs.gusb.out
    pkgs.json-glib
  ];

  libraryPath = lib.makeLibraryPath [
    pkgs.libfprint
    pkgs.gusb.out
    pkgs.json-glib
  ];
in
python3Packages.buildPythonApplication {
  pname = "goodix-reset";
  version = "0.1.0";
  format = "other";
  src = ./.;

  propagatedBuildInputs = [
    python3Packages.pygobject3
  ];

  nativeBuildInputs = [
    pkgs.makeWrapper
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 goodix-reset.py $out/bin/goodix-reset
    runHook postInstall
  '';

  postFixup = ''
    wrapProgram "$out/bin/goodix-reset" \
      --suffix GI_TYPELIB_PATH : "${giTypelibPath}" \
      --suffix LD_LIBRARY_PATH : "${libraryPath}"
  '';

  meta = with lib; {
    description = "Reset Goodix fingerprint templates via libfprint";
    license = licenses.mit;
    mainProgram = "goodix-reset";
    platforms = platforms.linux;
  };
}
