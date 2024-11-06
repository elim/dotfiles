{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs?ref=nixos-unstable";

    azure-cli-nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=92ceff55c9ebc5943853b83287f49fd73a909abd";
    };

    ffmpeg-nixpkgs = {
      url = "github:NixOS/nixpkgs?ref=ea1799ea8c3bb5bcbdc016986288836a04fc6294";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      systems,
      azure-cli-nixpkgs,
      ffmpeg-nixpkgs,
      home-manager,
      ...
    }:
    let
      system = "x86_64-linux";

      pkgs = import nixpkgs {
        system = system;
        config.allowUnfree = true;
      };

      pinned-pkgs = {
        azure-cli = import azure-cli-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };

        ffmpeg = import ffmpeg-nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      };
    in
    {
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
