{ pkgs }:

pkgs.buildGoModule rec {
  pname = "whichpr";
  version = "v1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "elim";
    repo = "whichpr";
    rev = "ca06bf59ec2a83113c17ce9a0c8c2940808e5efe";
    hash = "sha256-9lygIUitfP8itNEUyXhCaULPLExgmohEYnDSnoJugDQ=";
  };

  vendorHash = "sha256-zx2jVFP0MWCpymhktSTBKEAkOzuQzi12959RNQ7WknA=";

  buildInputs = [ pkgs.git ];

  preBuild = ''
    export HOME=$(mktemp -d)
    export PATH=${pkgs.git}/bin:$PATH
    git config --global user.name "Test User"
    git config --global user.email test.user@example.com
  '';

  buildPhase = ''
    go build
  '';

  installPhase = ''
    mkdir -p $out/bin
    cp whichpr $out/bin
  '';
}
