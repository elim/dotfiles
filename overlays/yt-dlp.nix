final: prev: {
  yt-dlp = prev.yt-dlp.overrideAttrs (_: {
    version = "unstable-6d92f87d";
    src = prev.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "6d92f87ddc40a31959097622ff01d4a7ca833a13";
      hash = "sha256-EJUPoBbLkB6mrouR657Arwo8+l9yVUGNor9e06Zev2U=";
    };
  });
}
