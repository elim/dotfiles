{
  inputs = {
    # Base nixpkgs (referenced by other inputs)
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs?ref=nixos-25.11";

    # All other inputs in alphabetical order
    emacs-overlay = {
      url = "github:nix-community/emacs-overlay";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-stable.follows = "nixpkgs-stable";
    };

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xremap-flake = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixpkgs-stable,

      emacs-overlay,
      git-hooks,
      home-manager,
      mcp-servers-nix,
      sops-nix,
      treefmt-nix,
      xremap-flake,
      ...
    }:

    let
      supportedSystems = nixpkgs.lib.systems.flakeExposed;

      config = {
        allowUnfree = true;
      };

      overlays = [
        emacs-overlay.overlay
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

      preCommitChecks = eachSystem (
        { system, pkgs, ... }:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            treefmt = {
              enable = true;
              package = treefmtEval.${system}.config.build.wrapper;
            };
          };
        }
      );
    in
    {
      # Development tools
      checks = eachSystem (
        { system, pkgs, ... }:
        {
          formatting = treefmtEval.${system}.config.build.check self;
          pre-commit-check = preCommitChecks.${system};
        }
      );

      devShells = eachSystem (
        { system, pkgs, ... }:
        {
          default = pkgs.mkShell {
            name = "dotfiles-dev-shell";
            shellHook = preCommitChecks.${system}.shellHook;
          };
          slackdump-auth = import ./devShells/slackdump-auth.nix { inherit pkgs; };
        }
      );

      formatter = eachSystem ({ system, pkgs, ... }: treefmtEval.${system}.config.build.wrapper);

      # System configurations
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
            inherit mcp-servers-nix;
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
            inherit mcp-servers-nix;
          };
        };
      };

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
    };
}
