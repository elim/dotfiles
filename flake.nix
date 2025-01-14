{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    ffmpeg-nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=ea1799ea8c3bb5bcbdc016986288836a04fc6294";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      ffmpeg-nixpkgs,
      treefmt-nix,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";
      eachSystem = f: nixpkgs.lib.genAttrs (import systems) (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };

      pinned-pkgs = {
        ffmpeg = import ffmpeg-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
      formatter = eachSystem (pkgs: treefmtEval.${pkgs.system}.config.build.wrapper);

      checks = eachSystem (pkgs: {
        formatting = treefmtEval.${pkgs.system}.config.build.check self;
      });

      homeConfigurations = {
        myHome = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            ./home.nix
          ];
          extraSpecialArgs = {
            inherit pinned-pkgs;
          };
        };
      };
    };
}
