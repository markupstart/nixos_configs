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
    supportedFilesystems = [
      "ntfs"
      "btrfs"
    ];
    loader = {
      systemd-boot.configurationLimit = 10;
      timeout = 2;
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  #yubikey
   services.pcscd.enable = true;

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

  # Personal data drive mounted separately from the system disk.
  fileSystems."/home/mark/docs" = {
    device = "/dev/disk/by-uuid/f9e3bf3d-6c7a-4bd8-8734-5ced340a6161";
    fsType = "btrfs";
    options = [
      "nofail"
      "compress=zstd:3"
      "x-systemd.automount"
      "x-systemd.device-timeout=10s"
    ];
  };

  virtualisation.containers.enable = true;

  services.udev.packages = [
    (pkgs.writeTextFile {
      name = "40-starcitizen-joystick-uaccess.rules";
      destination = "/lib/udev/rules.d/40-starcitizen-joystick-uaccess.rules";
      text = ''
        KERNEL=="hidraw*", ATTRS{idVendor}=="231d|3344|044f", ATTRS{idProduct}=="*", MODE="0660", TAG+="uaccess"
      '';
    })
  ];

  services.udev.enable = true;
  services.flatpak.enable = true;
  services.navidrome = {
    enable = true;
    settings.MusicFolder = "/mnt/audio/music";
    settings.PlaylistsPath = "/mnt/audio/music/playlists";
    settings.EnableSharing = true;
};

  services.searx = {
    enable = true;
    package = pkgs.searxng;
    openFirewall = true;
    redisCreateLocally = true;
    environmentFile = "/var/lib/searx/searxng.env";

    settings = {
      general = {
        debug = false;
        instance_name = "Mark SearXNG";
      };

      server = {
        bind_address = "0.0.0.0";
        port = 8888;
        secret_key = "$SEARXNG_SECRET";
        limiter = false;
        public_instance = false;
        image_proxy = true;
        method = "GET";
      };
    };

    # Keep bot protection on, but whitelist local ranges to avoid home/LAN lockouts.
    limiterSettings = {
      botdetection = {
        ipv4_prefix = 32;
        ipv6_prefix = 56;
        trusted_proxies = [
          "127.0.0.0/8"
          "::1"
        ];

        ip_limit = {
          filter_link_local = false;
          link_token = false;
        };

        ip_lists = {
          block_ip = [ ];
          pass_ip = [
            "127.0.0.0/8"
            "10.0.0.0/8"
            "172.16.0.0/12"
            "192.168.0.0/16"
            "100.64.0.0/10"
            "::1"
            "fd00::/8"
            "fe80::/10"
          ];
          pass_searxng_org = true;
        };
      };
    };
  };

  services.ocis = {
    enable = true;
    address = "0.0.0.0";
    port = 9200;
    url = "https://nixos:9200";
    configDir = "/var/lib/ocis/config";

    environment = {
      OCIS_INSECURE = "true";
      OCIS_LOG_LEVEL = "info";
    };
  };

  services.ollama = {
    enable = true;
    package = pkgs.ollama-rocm;
    host = "0.0.0.0";
    port = 11434;
  };

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
      9200
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
  system.activationScripts.searxng-secret = ''
    secret_file="/var/lib/searx/searxng.env"

    if [ ! -s "$secret_file" ] || ! ${pkgs.gnugrep}/bin/grep -q '^SEARXNG_SECRET=' "$secret_file"; then
      ${pkgs.coreutils}/bin/install -d -m 0700 /var/lib/searx
      secret="$(${pkgs.openssl}/bin/openssl rand -hex 32)"
      tmp_file="$(${pkgs.coreutils}/bin/mktemp)"
      ${pkgs.coreutils}/bin/printf 'SEARXNG_SECRET=%s\n' "$secret" > "$tmp_file"
      ${pkgs.coreutils}/bin/install -m 0600 "$tmp_file" "$secret_file"
      ${pkgs.coreutils}/bin/rm -f "$tmp_file"
    fi
  '';

  system.activationScripts.ocis-bootstrap = ''
    state_dir="/var/lib/ocis"
    config_dir="$state_dir/config"
    config_file="$config_dir/ocis.yaml"
    admin_pw_file="$state_dir/admin-password"

    ${pkgs.coreutils}/bin/install -d -m 0750 -o ocis -g ocis "$state_dir"
    ${pkgs.coreutils}/bin/install -d -m 0750 -o ocis -g ocis "$config_dir"

    # Clean up broken state from previous runs where --config-path was given a
    # file path; ocis init treats it as a directory and creates ocis.yaml/ocis.yaml.
    if [ -d "$config_file" ]; then
      ${pkgs.coreutils}/bin/rm -rf "$config_file"
    fi

    if [ ! -s "$admin_pw_file" ]; then
      admin_pw="$(${pkgs.openssl}/bin/openssl rand -base64 24 | ${pkgs.coreutils}/bin/tr -dc 'A-Za-z0-9' | ${pkgs.coreutils}/bin/head -c 20)"
      ${pkgs.coreutils}/bin/printf '%s\n' "$admin_pw" > "$admin_pw_file"
      ${pkgs.coreutils}/bin/chown ocis:ocis "$admin_pw_file"
      ${pkgs.coreutils}/bin/chmod 0600 "$admin_pw_file"
    fi

    if [ ! -s "$config_file" ]; then
      admin_pw="$(${pkgs.coreutils}/bin/cat "$admin_pw_file")"
      # --config-path takes a directory; ocis init writes ocis.yaml inside it.
      ${pkgs.util-linux}/bin/runuser -u ocis -- \
        ${config.services.ocis.package}/bin/ocis init \
          --insecure true \
          --config-path "$config_dir" \
          --admin-password "$admin_pw"
    fi
  '';

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
