{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-25.11";

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
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
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
      sops-nix,
      ...
    }:

    let
      supportedSystems = nixpkgs.lib.systems.flakeExposed;

      config = {
        allowUnfree = true;
      };

      overlays = [
        emacs-overlay.overlay
        (import ./overlays/yt-dlp.nix)
      ];

      makePkgs =
        system:
        import nixpkgs {
          inherit system;
          inherit config;
          inherit overlays;
        };

      makeStablePkgs =
        system:
        import nixpkgs-stable {
          inherit system;
          inherit config;
        };

      eachSystem =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = makePkgs system;
            pkgs-stable = makeStablePkgs system;
          }
        );

      commonNixSettings = {
        nix = {
          channel.enable = false;
          settings = {
            auto-optimise-store = true;
            experimental-features = [
              "nix-command"
              "flakes"
            ];
          };
          gc = {
            automatic = true;
            dates = "weekly";
            options = "--delete-older-than 30d";
          };
        };
      };
      treefmtEval = eachSystem ({ system, pkgs, ... }: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);
    in
    {
      formatter = eachSystem ({ system, pkgs, ... }: treefmtEval.${system}.config.build.wrapper);

      checks = eachSystem (
        { system, pkgs, ... }:
        {
          formatting = treefmtEval.${system}.config.build.check self;
        }
      );

      devShells = eachSystem ({ system, pkgs, ... }: import ./devShells { inherit pkgs; });

      nixosConfigurations = {
        obsidian = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            commonNixSettings
            {
              nixpkgs = {
                inherit config;
                inherit overlays;
              };
            }
            sops-nix.nixosModules.sops
            ./hosts/obsidian
          ];
          specialArgs = { inherit inputs; };
        };
      };

      homeConfigurations = {
        "takeru@obsidian" = home-manager.lib.homeManagerConfiguration {
          pkgs = makePkgs "x86_64-linux";
          modules = [
            xremap-flake.homeManagerModules.default
            sops-nix.homeManagerModules.sops
            ./home/takeru/obsidian.nix
          ];
          extraSpecialArgs = {
            pkgs-stable = makeStablePkgs "x86_64-linux";
            dotfiles = self;
          };
        };

        "takeru.naito@emerald" = home-manager.lib.homeManagerConfiguration {
          pkgs = makePkgs "aarch64-darwin";
          modules = [
            sops-nix.homeManagerModules.sops
            ./home/takeru.naito/emerald.nix
          ];
          extraSpecialArgs = {
            pkgs-stable = makeStablePkgs "aarch64-darwin";
            dotfiles = self;
          };
        };
      };
    };
}
