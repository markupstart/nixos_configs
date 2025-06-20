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
 #boot.kernelPackages = pkgs.linuxPackages_zen;

  #AMDGPU
  boot.initrd.kernelModules = [ "amdgpu" ];

  #Gaming Star Citizen
  boot.kernel.sysctl = {
  "vm.max_map_count" = 16777216;
  "fs.file-max" = 524288;
};  
  
  #network host name
  networking.hostName = "nixos"; 

  virtualisation.containers.enable = true;

 services.udev.extraRules = ''
    KERNEL=="hidraw*", ATTRS{idVendor}=="231d", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"
  '';

 #Enable xserver
 services.xserver  = {
   enable = true;
   videoDrivers = [ "amdgpu" ];   
 };

programs.nix-ld.enable = true;

  #Enable networking

  networking.networkmanager.enable = true;

  #time zone
  time.timeZone = "America/New_York";

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

  #Enable Niri
 programs.niri.enable = true;

  #XDG Portals enable with gtk and niri 
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config.common.default = "*";
  };

  #Enable SDDM
   services.xserver.displayManager.gdm.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {  
    layout = "us";
    variant = "";
  };

  #POLKIT Authentication
  security.polkit.enable = true; 

  #Enable CUPS to print documents.
  services.printing.enable = true;

  #Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
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
  hardware.graphics.extraPackages = with pkgs; [
  rocmPackages.clr.icd
  mesa.opencl   
];

    hardware.graphics.enable32Bit = true; # For 32 bit applications

   #HIP corrections
   systemd.tmpfiles.rules = [
       "L+    /opt/rocm/hip   -    -    -     -    ${pkgs.rocmPackages.clr}"
    ];

    nix.settings = {
    substituters = ["https://nix-gaming.cachix.org"];
    trusted-public-keys = ["nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="];
  };
  
    #Auto upgrades
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

    #NIXOS Version Number
    system.stateVersion = "25.05";
 }
