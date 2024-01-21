# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs,... }:


{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  #enable Flakes and the new command line tool
  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };

  #Bootloader.
    boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    loader = {
       timeout = 2;
       systemd-boot.enable = true;
       efi.canTouchEfiVariables = true;
      };
    };

  #Kernel to Boot  
  boot.kernelPackages = pkgs.linuxPackages_latest;

  #AMDGPU
  boot.initrd.kernelModules = [ "amdgpu" ];

  #Gaming Star Citizen
  boot.kernel.sysctl = {
  "vm.max_map_count" = 16777216;
  "fs.file-max" = 524288;
};  
  
  #network host name
  networking.hostName = "nixos"; 

 #Enable xserver
 services.xserver  = {
   enable = true;
   videoDrivers = [ "amdgpu" ];
   libinput = {
     enable = false;
   };
   synaptics = {
     enable = true; 
  };
 };

  #Enable networking
  networking.networkmanager.enable = true;

  #time zone
  time.timeZone = "America/Indiana/Indianapolis";

  # internationalisation
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
    LANG="en_US.UTF-8";
};

  #DBUS
  services.dbus.enable = true;

  #Enable Hyprland
  programs.hyprland.enable = true;

#  XFCE4 enable
#  services.xserver.desktopManager.xfce.enable = true;

  #XDG Portals enable with gtk and hyprland 
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-hyprland
    ];
    config.common.default = "*";
  };

  #Enable SDDM
   services.xserver.displayManager.sddm.enable = true;

  # Configure keymap in X11
  services.xserver = {  
    layout = "us";
    xkbVariant = "";
  };

  #POLKIT Authentication
  security.polkit.enable = true; 

  #Enable CUPS to print documents.
  services.printing.enable = true;

  #Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    };

  #user account
  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "disk" "libvirtd" ];
  };

  #thunar with plugins
  programs.xfconf.enable = true;
  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
  thunar-archive-plugin
  thunar-volman
];
  services.gvfs.enable = true; # Mount, trash, and other functionalities
  services.tumbler.enable = true; # Thumbnail support for images 
  
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  #openrazer enable and configs
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "mark" ];
  
  #star citizen easy install
  environment.systemPackages = with pkgs; [  
    inputs.nix-gaming.packages.${system}.star-citizen 
  ];
  
  #DWM - Personal Config and setup
 # nixpkgs.overlays = [
 #	(final: prev: {
 #		dwm = prev.dwm.overrideAttrs (old: { src = /home/mark/dwm-6.4 ;});
 #	})
 # ];
 
  #Enable Virt-Manager 
  virtualisation.libvirtd.enable = true;
  programs.virt-manager.enable = true;
  
  #steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};
  
  #Enable OpenGL
  hardware.opengl.extraPackages = with pkgs; [
  rocmPackages.clr.icd
  #mesa.opencl   
];

   hardware.opengl.driSupport = true; # This is already enabled by default
   hardware.opengl.driSupport32Bit = true; # For 32 bit applications

   #HIP corrections
   systemd.tmpfiles.rules = [
       "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];
   
    #Auto upgrades
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

    #NIXOS Version Number
    system.stateVersion = "22.11";
 }
