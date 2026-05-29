# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{
  inputs,
  config,
  pkgs,
  ...
}:

{
  imports = [
    # Include the results of the hardware scan.
    ./hardware-configuration.nix
  ];

  #enable Flakes and the new command line tool
  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    substituters = [
      "https://nix-gaming.cachix.org"
      "https://nix-citizen.cachix.org"
    ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
      "nix-citizen.cachix.org-1:lPMkWc2X8XD4/7YPEEwXKKBg+SVbYTVrAaLA2wQTKCo="
    ];
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  nix.optimise = {
    automatic = true;
    dates = [ "weekly" ];
  };

  #Bootloader.
  boot = {
    tmp.cleanOnBoot = true;
    supportedFilesystems = [ "ntfs" ];
    loader = {
      systemd-boot.configurationLimit = 10;
      timeout = 2;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  #Kernel to Boot
  boot.kernelPackages = pkgs.linuxPackages_latest;
  #boot.kernelPackages = pkgs.linuxPackages_zen;

  #AMDGPU
  boot.initrd.kernelModules = [
    "amdgpu"
    "v4l2loopback"
  ];
  boot.extraModulePackages = [ config.boot.kernelPackages.v4l2loopback ];

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

  services.udev.enable = true;
  services.flatpak.enable = true;
  virtualisation.docker.enable = true;
  virtualisation.oci-containers = {
    backend = "docker";
    containers.jellyfin = {
      image = "jellyfin/jellyfin:latest";
      autoStart = true;
      environment = {
        TZ = "America/New_York";
      };
      ports = [
        "8096:8096"
        "8920:8920"
        "7359:7359/udp"
        "1900:1900/udp"
      ];
      volumes = [
        "/opt/jellyfin/config:/config"
        "/opt/jellyfin/cache:/cache"
        "/home/mark/media:/media/movies:ro"
        "/home/mark/Music:/media/music:ro"
      ];
      extraOptions = [
        "--user=1000:1000"
        "--device=/dev/dri:/dev/dri"
      ];
    };
  };
  virtualisation.waydroid.enable = true;
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

  networking.firewall = {
    allowedTCPPorts = [
      8096
      8920
    ];
    allowedUDPPorts = [
      7359
      1900
    ];
  };

  programs.nix-ld.enable = true;
  programs.zsh.enable = true;

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
    LANG = "en_US.UTF-8";
  };

  #DBUS
  services.dbus.enable = true;

  #Enable Niri
  programs.niri.enable = true;

  # Enable DankMaterialShell (DMS)
  programs.dms-shell = {
    enable = true;
    systemd.enable = true;
    enableSystemMonitoring = true;
    enableDynamicTheming = true;
    enableClipboardPaste = true;
  };

  #XDG Portals enable with gtk and niri
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal-gtk
      pkgs.xdg-desktop-portal-gnome
    ];
    config = {
      # Define preferred portals for specific interfaces (optional)
      # gnome = {
      #   default = [ "gnome" "gtk" ]; # Example: Set the default for GNOME to use gnome and then gtk
      #   "org.freedesktop.impl.portal.Secret" = [ "gnome-keyring" ]; # Example: Use gnome-keyring for secret storage
      # };
      common = {
        default = [ "gnome" ]; # Example: Set a fallback default for all desktops
      };
    };
  };

  # Drop GDM, use Greetd to auto-login to Niri
  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.greetd}/bin/agreety --cmd niri-session";
      };
      initial_session = {
        command = "niri-session";
        user = "mark";
      };
    };
  };
  #POLKIT Authentication
  security.polkit.enable = true;

  #Enable CUPS to print documents.
  services.printing = {
    enable = true;
    drivers = with pkgs; [
      brlaser
      cups-brother-hl1210w
      cups-brother-hl2260d
      cups-brother-hll2340dw
      foomatic-db
    ];
  };
  #Enable sound with pipewire.
  services.pulseaudio.enable = false;
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
    shell = pkgs.zsh;
    extraGroups = [
      "networkmanager"
      "wheel"
      "audio"
      "video"
      "disk"
      "libvirtd"
      "docker"
      "dialout"
    ];
  };

  # thunar with plugins
  programs.xfconf.enable = true;
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin
      thunar-volman
    ];
  };

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
    "d /opt/jellyfin 0755 1000 1000 -"
    "d /opt/jellyfin/config 0755 1000 1000 -"
    "d /opt/jellyfin/cache 0755 1000 1000 -"
  ];

  nixpkgs.overlays = [
    (final: prev: {
      openldap = prev.openldap.overrideAttrs (oldAttrs: {
        doCheck = false;
      });
    })
  ];

  #Auto upgrades
  system.autoUpgrade = {
    enable = true;
    allowReboot = true;
    dates = "weekly";
    flake = "${inputs.self.outPath}#nixos";
  };

  #NIXOS Version Number
  system.stateVersion = "26.05";
}
