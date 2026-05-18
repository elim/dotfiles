{ pkgs, ... }:

{
  services.ollama = {
    enable = true;
    package = pkgs.ollama;
    host = "127.0.0.1";
    port = 11434;
  };
}
