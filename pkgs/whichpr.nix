{ pkgs }:

pkgs.buildGoModule rec {
  pname = "whichpr";
  version = "v1.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "pocke";
    repo = "whichpr";
    rev = "a62c1fcbbda163ee480efe3721faa5e9bce86b8c";
    hash = "sha256-fCgcOBe1UfcTOt0g9Se0EfkZ78dFNUXDIO+sX4ExRGk=";
  };

  vendorHash = "sha256-zx2jVFP0MWCpymhktSTBKEAkOzuQzi12959RNQ7WknA=";

  patches = [
    # Add go.mod and go.sum
    (pkgs.fetchpatch {
      url = "https://github.com/elim/whichpr/commit/3a65bdca318135896792c9c29a286fdb76fc0855.patch";
      hash = "sha256-A3ZLwOEX/xCJmrV9Is6WBVaLiYyWZ+a/dEaLDHGsTPc=";
    })
    # Use default branch in test case
    (pkgs.fetchpatch {
      url = "https://github.com/elim/whichpr/commit/ca06bf59ec2a83113c17ce9a0c8c2940808e5efe.patch";
      hash = "sha256-sy/I6TtlZpKMu+E3E2ijP8sd8tzbOqnxuhNY5be/mjQ=";
    })
  ];

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
