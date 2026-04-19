{
  lib,
  rustPlatform,
  fetchFromGitHub,
}:

rustPlatform.buildRustPackage rec {
  pname = "zsh-history-utils";
  name = pname;

  src = fetchFromGitHub {
    owner = "watiko";
    repo = "zsh-history-utils";
    rev = "22175514372b352697adf669aa1dc691f75ba6ea";
    hash = "sha256-re4IV7nfRtD8w7BzOnHa0hXoZlQwfg9RmprFYdG8eXc=";
  };

  cargoHash = "sha256-gSpbRViETtf/T5+qkUjVo2G7ex2WO1MvuAqmkpKvdJU=";

  meta = with lib; {
    description = "Utility to decode, filter, and encode zsh history files";
    homepage = "https://github.com/watiko/zsh-history-utils";
    license = licenses.mit;
    maintainers = with maintainers; [ "elim" ];
    platforms = platforms.all;
  };
}
