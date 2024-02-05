{
  description = "NixOS configuration of Mark Hall";
  
inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-citizen.url = "github:LovingMelody/nix-citizen";

        # Optional - updates underlying without waiting for nix-citizen to update
        nix-gaming.url = "github:fufexan/nix-gaming";
	nix-citizen.inputs.nix-gaming.follows = "nix-gaming";
	
  };  

   outputs = {self,nixpkgs,home-manager,... }@inputs: {
     nixosConfigurations = {
     nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        #specialArgs = inputs;
       specialArgs = {inherit inputs;};

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
