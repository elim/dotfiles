{
  lib,
  fetchFromGitHub,
  swift,
  swiftPackages,
  swiftpm,
}:

swiftPackages.stdenv.mkDerivation rec {
  pname = "macos-trash";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "sindresorhus";
    repo = "macos-trash";
    rev = "v${version}";
    hash = "sha256-4iIERz1eY9tEA3mH1pjcasn02JCzbID81qGa6p6HEzE=";
  };

  postPatch = ''
    substituteInPlace Package.swift \
      --replace-fail "swift-tools-version:5.11" "swift-tools-version:5.10"
    substituteInPlace Sources/trash/Utilities.swift \
      --replace-fail "extension FileHandle: @retroactive TextOutputStream" "extension FileHandle: TextOutputStream"
  '';

  nativeBuildInputs = [
    swift
    swiftpm
  ];

  installPhase = ''
    runHook preInstall
    install -Dm755 "$(swiftpmBinPath)/trash" "$out/bin/trash"
    runHook postInstall
  '';

  meta = {
    description = "Move files and folders to the trash on macOS";
    homepage = "https://github.com/sindresorhus/macos-trash";
    license = lib.licenses.mit;
    mainProgram = "trash";
    platforms = lib.platforms.darwin;
  };
}
