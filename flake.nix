{
  description = "NixOS configuration of Mark Hall";
  
inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  

   outputs = inputs@{ nixpkgs,home-manager,... }: {
    nixosConfigurations = {
    nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        #specialArgs = inputs;
       specialArgs = {inherit inputs;}; # this is the important part for hyprland
 
          modules = [
               
         ./configuration.nix



        # make home-manager as a module of nixos
        # so that home-manager configuration will be deployed automatically when executing `nixos-rebuild switch`
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;

            home-manager.users.mark = import ./home.nix;


      }
        ];
      };
    };
  };
}
