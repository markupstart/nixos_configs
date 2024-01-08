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

  #Gaming Star Citizen
  boot.kernel.sysctl = {
  "vm.max_map_count" = 16777216;
  "fs.file-max" = 524288;
};  
  
  networking.hostName = "nixos"; 
 
 services.xserver  = {
    enable = true;
  libinput = {
    enable = true;
  mouse = {
    accelProfile = "flat";
   };
  };
 };

  #Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "America/Indiana/Indianapolis";

  # Select internationalisation properties.
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

  #XDG Portal 
  xdg.portal = {
    enable = true;
    extraPortals = [pkgs.xdg-desktop-portal-gtk];
    config.common.default = "*";
   
  };

  #Enable SDDM
   services.xserver.displayManager.sddm.enable = true;

  #dwm
  services.xserver.windowManager.dwm.enable = true;
  
  #leftwm
  #services.xserver.windowManager.leftwm.enable = true;
 
  #xfce4
  #services.xserver.desktopManager.xfce.enable = true;

 # modify config.def.h with my customizations 
 # Apply patches to DWM
 # Apply patches to DWM
 #nixpkgs.overlays = [  
  # (self: super: {    
  # dwm = super.dwm.overrideAttrs (oldAttrs: rec {
  #  patches = [
  #   (super.fetchpatch {
  #    url = "https://dwm.suckless.org/patches/alpha/dwm-alpha-6.4.diff";
  #    sha256 = "06bfx6dwrknk1dchqv920d3m6cn06lgf8i5pzxdmy2kfwf6ci8bi";
  #      })  
  #    (super.fetchpatch {
  #    url = "https://dwm.suckless.org/patches/centeredmaster/dwm-centeredmaster-6.1.diff";
  #    sha256 = "1c2gl2xxck78hwh3ffdzygpx2rd4mn2d9ppzw4s6rviswdm0h529";
  #      })

  #     ];

  #    configFile = super.writeText "config.h" (builtins.readFile /home/mark/config.def.h);
  #   postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} #config.def.h";
 # });
 # })	 	

 #   ]; 

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
    #media-session.enable = true;
  };

  #Enable touchpad support (enabled default in most desktopManager).
  #services.xserver.libinput.enable = true;

  #Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    extraGroups = [ "networkmanager" "wheel" "audio" "video" "disk" "libvirtd" ];
  };

  programs.thunar.enable = true;
  programs.thunar.plugins = with pkgs.xfce; [
     thunar-archive-plugin
     thunar-volman
];

   services.gvfs.enable = true; # Mount, trash, and other functionalities
   services.tumbler.enable = true; # Thumbnail support for images

   #Wayland finicky mouse cursor issues (uncomment if using wayland and having issues)
   #   environment.sessionVariables = {
   #      WLR_NO_HARDWARE_CURSORS = "1";
   #   };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  hardware.openrazer.enable = true;
  hardware.openrazer.users = [ "mark" ];
  
  #List packages installed in system profile. To search, run:
  environment.systemPackages = with pkgs; [
  firefox
  lutris
  gimp-with-plugins 
  dmenu
  xfce.thunar
  xfce.thunar-volman
  xfce.thunar-archive-plugin
  polkit
  lxde.lxsession
  neofetch
  gnome.adwaita-icon-theme
  feh
  xfce.thunar-archive-plugin
  wineWowPackages.full
  winetricks
  gamescope
  mangohud
  gamemode
  pulsemixer
  discord
  obs-studio
  htop
  btop
  picom
  rofi
  xfce.mousepad
  xfce.thunar-archive-plugin
  xarchiver
  gparted
  darktable
  xorg.xhost
  gnumake
  gcc12
  cargo
  pkg-config
  openssl
  slock
  xorg.libX11
  xorg.libX11.dev
  xorg.libxcb
  xorg.libXft
  xorg.libXinerama
  xorg.xinit
  xorg.xinput
  kind
  execline
  gnome.adwaita-icon-theme
  font-awesome
  grc
  lxqt.lxqt-sudo
  libreoffice-fresh  
  flameshot
  razergenie
  alacritty
  cups-brother-hll2340dw  
  virt-manager

  (lutris.override {
         extraPkgs = pkgs: [
 	  #List package dependencies here
	   wineWowPackages.stable
	   winetricks
	   ];
        })
  ];
  
  #DWM - Personal Config and setup
  nixpkgs.overlays = [
	(final: prev: {
		dwm = prev.dwm.overrideAttrs (old: { src = /home/mark/dwm-6.4 ;});
	})
  ];
 
  #Enable Virt-Manager 
  virtualisation.libvirtd.enable = true;
  #programs.virt-manager.enable = true;
  
  #Kernel to Boot
  boot.kernelPackages = pkgs.linuxPackages_xanmod_latest;

  #steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};
  
  #Enable OpenGL
  hardware.opengl = {
    enable = true;
    driSupport = true;
    driSupport32Bit = true;
  };

  #Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];
  hardware.nvidia = {
    #Modesetting is required.
    modesetting.enable = true;
    #Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    #Fine-grained power management. Turns off GPU when not in use.
    #Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    #Use the NVidia open source kernel module (not to be confused with the
    #independent third-party "nouveau" open source driver).
    #Support is limited to the Turing and later architectures. Full list of 
    #supported GPUs is at: 
    #https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    #Only available from driver 515.43.04+
    #Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = false;
    #Enable the Nvidia settings menu,
    #accessible via `nvidia-settings`.
    nvidiaSettings = true;

    #Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.production;
  };

    #Auto upgrades
    system.autoUpgrade.enable = true;
    system.autoUpgrade.allowReboot = true;

    #NIXOS Version Number
    system.stateVersion = "23.11";
 }
