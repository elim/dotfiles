final: prev: {
  yt-dlp = prev.yt-dlp.overrideAttrs (_: {
    version = "unstable-b2c01d0";
    src = prev.fetchFromGitHub {
      owner = "yt-dlp";
      repo = "yt-dlp";
      rev = "b2c01d0498653e0239c7226c5a7fcb614dd4dbc8";
      hash = "sha256-hN65CCfc45zbiQdT1WyXrJ0jAUZ8weMpW/NgLZbzW/M=";
    };
  });
}
