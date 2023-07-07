# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ inputs, config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];




# enable Flakes and the new command line tool
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Bootloader.
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.grub.enable = true;
  # boot.loader.grub.version = 2;
  boot.loader.grub.device = "nodev";
  boot.loader.grub.efiSupport = true;
  boot.loader.grub.useOSProber = false;
  boot.kernel.sysctl."vm.max_map_count" = 16777216;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  networking.extraHosts =
  ''
    127.0.0.1 modules-cdn.eac-prod.on.epicgames.com
  '';

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
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
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable SDDM
  services.xserver.displayManager.sddm.enable = true;
  
  # dwm
  services.xserver.windowManager.dwm.enable = true;
  
  #openbox
  # services.xserver.windowManager.openbox.enable = true; 

  #herbstluftwm
  #services.xserver.windowManager.herbstluftwm.enable = true;


 #hyprland 

#   programs.hyprland.package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  # programs.hyprland.xwayland.hidpi = true;

#
  # hyperland
#      programs.hyprland = {
#      enable = true;
#      xwayland.enable = true;
#      nvidiaPatches = true;
# };
 #



 # modify config.def.h with my customizations 
 # Apply patches to DWM
 # Apply patches to DWM
 nixpkgs.overlays = [  
   (self: super: {    
    dwm = super.dwm.overrideAttrs (oldAttrs: rec {
     patches = [
      (super.fetchpatch {
       url = "https://dwm.suckless.org/patches/alpha/dwm-alpha-6.4.diff";
       sha256 = "06bfx6dwrknk1dchqv920d3m6cn06lgf8i5pzxdmy2kfwf6ci8bi";
         })  
       (super.fetchpatch {
       url = "https://dwm.suckless.org/patches/centeredmaster/dwm-centeredmaster-6.1.diff";
       sha256 = "1c2gl2xxck78hwh3ffdzygpx2rd4mn2d9ppzw4s6rviswdm0h529";
         })

         ];

       configFile = super.writeText "config.h" (builtins.readFile /home/mark/config.def.h);
       postPatch = oldAttrs.postPatch or "" + "\necho 'Using own config file...'\n cp ${configFile} config.def.h";
  });
   })
#waybar experimental patch
#	   (self: super: {
#	     waybar = super.waybar.overrideAttrs (oldAttrs: {
#  	       mesonFlags = oldAttrs.mesonFlags ++ [ "-Dexperimental=true" ];
#             });
#           })
#waybar patch
    ]; 

  # Configure keymap in X11
  services.xserver = {  
    layout = "us";
    xkbVariant = "";
  };

#POLKIT Authentication
 systemd = {
   user.services.polkit-gnome-authentication-agent-1 = {
     description = "polkit-gnome-authentication-agent-1";
     wantedBy = [ "graphical-session.target" ];
     wants = [ "graphical-session.target" ];
     after = [ "graphical-session.target" ];
     serviceConfig = {
         Type = "simple";
         ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
         Restart = "on-failure";
         RestartSec = 1;
         TimeoutStopSec = 10;
      };
  };
};

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mark = {
    isNormalUser = true;
    description = "mark";
    extraGroups = [ "networkmanager" "wheel" "vboxusers"];
    packages = with pkgs; [
      firefox
    #  thunderbird
    ];
  };



#Wayland finicky mouse cursor issues (uncomment if using wayland and having issues)
   environment.sessionVariables = {
     WLR_NO_HARDWARE_CURSORS = "1";
      #
   };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
  lutris
  gimp-with-plugins 
  dmenu
  xfce.thunar
  xfce.thunar-volman
  polkit
  lxde.lxsession
  neofetch
  virt-manager
  swtpm
  virt-viewer
  spice spice-gtk
  spice-protocol
  win-virtio
  win-spice
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
  picom
  kitty
  rofi
  xfce. mousepad
  xfce.thunar-archive-plugin
  xarchiver
  gparted
  darktable

#hyprland programs
#     xdg-desktop-portal-hyprland
#     dconf
#     kitty
#     hyprpaper #doesnt seem to work with my monitor or nvidia card
#     rofi
#     qt6.qtwayland
#     swaybg
#     waybar
#


  #  vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #  wget
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "unstable"; # Did you read the comment?

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.opengl.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;
  hardware.nvidia.modesetting.enable = true;
 
  boot.supportedFilesystems = [ "ntfs" ];
  


 # services.xserver.dpi = 192;


  # steam
  programs.steam = {
  enable = true;
  remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
  dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
};
  #Auto upgrades
  system.autoUpgrade.enable = true;
  system.autoUpgrade.allowReboot = true;
  
#enlightenment
#  services.xserver.desktopManager.enlightenment.enable = true; 


#e16
#  services.xserver.windowManager.e16.enable = true;


  #virt-manager config
  programs.dconf.enable = true;
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;

  }
  
  
  

