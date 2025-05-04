{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,
      systems,

      xremap-flake,
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

      pkgs-stable = import nixpkgs-stable {
        inherit system;
        config.allowUnfree = true;
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
            xremap-flake.homeManagerModules.default
            ./home.nix
          ];
          extraSpecialArgs = {
            inherit pkgs-stable;
          };
        };
      };
    };
}
