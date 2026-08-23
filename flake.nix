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

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mcp-servers-nix = {
      url = "github:natsukium/mcp-servers-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
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
      llm-agents,
      mcp-servers-nix,
      nix-darwin,
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

      treefmtEval = eachSystem ({ system, pkgs, ... }: treefmt-nix.lib.evalModule pkgs ./treefmt.nix);

      emacsMarkdownTest = eachSystem (
        { pkgs, ... }:
        let
          inherit (import ./home/takeru/features/emacs/package.nix { inherit pkgs; })
            emacs
            treeSitterGrammars
            ;
        in
        pkgs.writeShellApplication {
          name = "emacs-markdown-test";
          text = ''
            repository="''${1:-$PWD}"
            emacs_directory="$repository/home/takeru/features/emacs"
            test_emacs_directory="$(mktemp -d)"

            ln -s "$emacs_directory/config" "$test_emacs_directory/config"
            ln -s "$emacs_directory/lisp" "$test_emacs_directory/lisp"

            ${emacs}/bin/emacs --batch --quick \
              --eval "(setq user-emacs-directory (file-name-as-directory \"$test_emacs_directory\"))" \
              --eval "(advice-add 'display-warning :override (lambda (type message &rest _) (error \"%s: %s\" type message)))" \
              --load "$emacs_directory/init.el"

            exec ${emacs}/bin/emacs --batch --quick \
              --eval "(add-to-list 'treesit-extra-load-path \"${treeSitterGrammars}/lib\")" \
              --load "$emacs_directory/test/markdown-test.el" \
              --funcall ert-run-tests-batch-and-exit
          '';
        }
      );

      preCommitChecks = eachSystem (
        { system, pkgs, ... }:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            emacs-markdown = {
              enable = true;
              entry = "${emacsMarkdownTest.${system}}/bin/emacs-markdown-test";
              files = "^home/takeru/features/emacs/(config/.*\\.el|init\\.el|test/.*\\.el)$";
              pass_filenames = false;
            };
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
          emacs-markdown = pkgs.runCommand "emacs-markdown-test" { } ''
            ${emacsMarkdownTest.${system}}/bin/emacs-markdown-test ${self}
            touch $out
          '';
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
          karabiner-ts = import ./devShells/karabiner-ts.nix { inherit pkgs; };
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
            inherit llm-agents mcp-servers-nix;
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
            inherit llm-agents mcp-servers-nix;
          };
        };
      };

      nixosConfigurations = {
        obsidian = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
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

      darwinConfigurations = {
        emerald = nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          modules = [
            ./hosts/emerald
          ];
          specialArgs = { inherit inputs; };
        };
      };
    };
}
