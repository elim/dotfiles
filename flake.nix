{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-25.05";

    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

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
      emacs-overlay,
      xremap-flake,
      treefmt-nix,
      home-manager,
      ...
    }:

    let
      system = "x86_64-linux";
      supportedSystems = nixpkgs.lib.systems.flakeExposed;
      eachSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f nixpkgs.legacyPackages.${system});
      treefmtEval = eachSystem (pkgs: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
        overlays = [
          emacs-overlay.overlay
          (import ./overlays/emacs.nix { inherit self; })
        ];
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

      nixosConfigurations = {
        obsidian = nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              nixpkgs = {
                config = {
                  allowUnfree = true;
                  cudaSupport = true;
                };
                overlays = [ ];
              };
            }
            ./hosts/obsidian
          ];

          specialArgs = {
            inherit inputs;
          };
        };
      };

      homeConfigurations = {
        "takeru@obsidian" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [
            xremap-flake.homeManagerModules.default
            ./home/takeru/obsidian.nix
          ];
          extraSpecialArgs = {
            inherit pkgs-stable;
          };
        };
      };
    };
}
