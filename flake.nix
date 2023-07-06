{
  description = "NixOS configuration of Mark Hall";
  
inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-23.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

##Hyprland
#   hyprland.url = "github:hyprwm/Hyprland";
##Hyprland

  };

  

   outputs = inputs@{ nixpkgs,home-manager,... }: {
    nixosConfigurations = {
    nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        #specialArgs = inputs;
        specialArgs = {inherit inputs;}; # this is the important part for hyprland


         modules = [

###Hyprland
#         hyprland.nixosModules.default
#        {programs.hyprland = {
#
#        enable = true;
#        xwayland.enable=true;
#        nvidiaPatches = true;
#};
#}
###
         
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
