{
  description = "NixOS configuration of Mark Hall";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-citizen.url = "github:LovingMelody/nix-citizen";

  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      overlays = [
        (final: prev: {
          obsbot-camera-control = final.callPackage ./pkgs/obsbot-camera-control.nix { };
        })
      ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      # Expose the package for direct building:  nix build .#obsbot-camera-control
      packages.${system}.obsbot-camera-control = pkgs.obsbot-camera-control;

      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          inherit system;

          #specialArgs = inputs;
          specialArgs = { inherit inputs; };

          modules = [
            ./configuration.nix

            # Register the overlay so the custom package is available system-wide
            { nixpkgs.overlays = overlays; }

            # make home-manager as a module of nixos
            # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
            home-manager.nixosModules.home-manager

            {
              home-manager.backupFileExtension = "hm-bak";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.extraSpecialArgs = { inherit inputs; };
              home-manager.users.mark = import ./home.nix;
            }
          ];
        };
      };
    };
}
