{ pkgs, inputs, ... }:

let
  rsiLauncherPkg =
    inputs.nix-citizen.packages.${pkgs.stdenv.hostPlatform.system}.rsi-launcher.override
      {
        includeMangoHud = true;
        extraEnvVars = {
          MESA_VK_WSI_PRESENT_MODE = "mailbox";
        };
      };

  sysStatus = pkgs.writeShellScriptBin "sys-status" ''
    #!/usr/bin/env bash
    set -euo pipefail

    echo "== System Status =="
    echo "Time: $(date '+%Y-%m-%d %H:%M:%S')"
    echo

    echo "[Temperatures]"
    if command -v sensors >/dev/null 2>&1; then
      sensors 2>/dev/null | awk '/°C/ {print "  " $0; count++; if (count >= 6) exit}' || true
    else
      echo "  sensors not found (install lm_sensors support)"
    fi
    echo

    echo "[GPU]"
    if command -v nvidia-smi >/dev/null 2>&1; then
      nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader,nounits \
        | awk -F', *' '{printf "  %s | Temp: %sC | Util: %s%% | VRAM: %s/%s MiB\n", $1, $2, $3, $4, $5}'
    elif ls /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input >/dev/null 2>&1; then
      for t in /sys/class/drm/card*/device/hwmon/hwmon*/temp1_input; do
        temp_c=$(( $(cat "$t") / 1000 ))
        echo "  $(dirname "$t" | sed 's#^/sys/class/drm/##') | Temp: ''${temp_c}C"
      done
    else
      echo "  GPU telemetry not available"
    fi
    echo

    echo "[Network]"
    ip -brief address | awk '{print "  " $1 " " $3}'
    default_if=$(ip route show default 2>/dev/null | awk '/default/ {print $5; exit}')
    if [[ -n "''${default_if:-}" ]]; then
      echo "  Default route: $default_if"
    fi
  '';

  gimpWithPlugins = pkgs.gimp-with-plugins.override {
    plugins = with pkgs.gimpPlugins; [
      gmic
      resynthesizer
    ];
  };

  davinciWithPlugins = pkgs.davinci-resolve-studio.overrideAttrs (
    old:
    let
      baseBwrapArgs = old.extraBwrapArgs or [ ];
      extrasBind =
        if builtins.length baseBwrapArgs > 1 then
          builtins.elemAt baseBwrapArgs 1
        else
          ''--bind "$HOME"/.local/share/DaVinciResolve/Extras /opt/resolve/Extras'';
      extrasDest = builtins.elemAt (pkgs.lib.splitString " " extrasBind) 2;
      ioPluginsDest = pkgs.lib.replaceStrings [ "/Extras" ] [ "/IOPlugins" ] extrasDest;
    in
    {
      extraPreBwrapCmds = (old.extraPreBwrapCmds or "") + ''
        mkdir -p "$HOME/Downloads/IOPlugins" || true
      '';

      extraBwrapArgs = baseBwrapArgs ++ [
        ''--bind "$HOME"/Downloads/IOPlugins ${ioPluginsDest}''
      ];
    }
  );

  blenderHip = pkgs.blender.override {
    rocmSupport = true;
  };

  archiveAndMediaPackages = with pkgs; [
    alacritty
    audacious
    audacity
    bazecor
    cabextract
    catimg
    cava
    chafa
    dconf-editor
    glib
    gnome-boxes
    handbrake
    inotify-tools
    kitty
    libnotify
    micro
    mpd
    mpv
    ollama-rocm
    p7zip
    pamixer
    pavucontrol
    ripdrag
    rmpc
    rssguard
    swayimg
    trash-cli
    unzip
    v4l-utils
    xz
    yazi
    zenity
    zip
    dgop
    fprintd
  ];

  utilityPackages = with pkgs; [
    bat
    delta
    fd
    dust
    cargo
    cliphist
    ripgrep
    dnsmasq
    direnv
    ipcalc
    nmap
    curl
    exiftool
    file
    gawk
    gh
    go
    jq
    imagemagick
    localsend
    mission-center
    mermaid-cli
    neovim
    nodejs
    socat
    tectonic
    tree
    which
    zstd
  ];

  nixPackages = with pkgs; [
    comma
    deadnix
    inxi
    nh
    nix-tree
    nixd
    nix-direnv
    nixfmt
    nvd
    nitch
    nix-output-monitor
    statix
  ];

  productivityPackages = with pkgs; [
    bottom
    btop
    glow
    iftop
    owncloud-client
  ];

  monitoringPackages = with pkgs; [
    iotop
    lsof
    ltrace
    strace
  ];

  systemPackages = with pkgs; [
    bash-completion
    docker-compose
    ethtool
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
    killall
    libva-utils
    lm_sensors
    (lib.lowPrio mesa-demos)
    nixos-generators
    pciutils
    smartmontools
    sysstat
    usbutils
    wl-clipboard
  ];

  desktopAppPackages = with pkgs; [
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6
    bibata-cursors
    blenderHip
    boxbuddy
    cups-filters
    darktable
    dconf
    discord
    distrobox
    element-desktop
    engrampa
    extremetuxracer
    fastfetch
    ffmpeg
    firefox
    fish
    font-awesome
    foomatic-db
    foot
    gimpWithPlugins
    gamescope
    ghostty
    glaxnimate
    gnome-keyring
    grc
    gpu-screen-recorder-gtk
    htop
    inkscape
    kdePackages.kdenlive
    libreoffice-fresh
    lutris
    makemkv
    mako
    mangohud
    mate-icon-theme
    mate-themes
    matugen
    mint-themes
    mint-y-icons
    mousepad
    nautilus
    nordzy-cursor-theme
    numix-cursor-theme
    nwg-look
    obs-studio
    obs-studio-plugins.obs-gstreamer
    obs-studio-plugins.obs-pipewire-audio-capture
    obs-studio-plugins.obs-vaapi
    obs-studio-plugins.obs-vkcapture
    obs-studio-plugins.wlrobs
    papers
    power-profiles-daemon
    pulsemixer
    pw-volume
    qalculate-gtk
    roboto
    scribus
    supertux
    supertuxkart
    system-config-printer
    terminus_font
    thunderbird
    transmission_4-gtk
    vulkan-tools
    winetricks
    xwayland-satellite
  ];

  launcherPackages = [
    rsiLauncherPkg
  ];

  scriptPackages = [
    sysStatus
    davinciWithPlugins
  ];
in
{
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  programs.git = {
    enable = true;
    settings = {
      user.name = "markupstart";
      user.email = "mark@upstarters.com";
      credential.helper = "${pkgs.git.override { withLibsecret = true; }}/bin/git-credential-libsecret";
    };
  };

  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      line-numbers = true;
      navigate = true;
      side-by-side = true;
    };
  };

  #Virt-Manager setup
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };
  };

  # Packages that should be installed to the user profile.
  home.packages =
    archiveAndMediaPackages
    ++ utilityPackages
    ++ nixPackages
    ++ productivityPackages
    ++ monitoringPackages
    ++ systemPackages
    ++ desktopAppPackages
    ++ launcherPackages
    ++ scriptPackages;

  home.sessionVariables = {
    # Prefer native Wayland backend for Electron apps like VS Code.
    NIXOS_OZONE_WL = "1";
    # Required for Blender HIP rendering on Navi 31 (RX 7900 XTX = gfx1100)
    HSA_OVERRIDE_GFX_VERSION = "11.0.0";
    ROC_ENABLE_PRE_VEGA = "1";
  };

  programs.vscode = {
    enable = true;
    # FHS mode improves compatibility for extensions shipping prebuilt binaries.
    package = pkgs.vscode.fhs;

    profiles.default = {
      extensions = with pkgs.vscode-extensions; [
        jnoortheen.nix-ide
        ms-python.python
        ms-vscode-remote.remote-ssh
      ];

      userSettings = {
        "editor.formatOnSave" = true;
        "files.autoSave" = "afterDelay";

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nixd";
        "nix.formatterPath" = "nixfmt";

        "[nix]" = {
          "editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
      };
    };
  };

  #enable eza
  programs.eza.enable = true;

  # Shell integrations (better than package-only installs)
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.bat = {
    enable = true;
    config = {
      pager = "less -FR";
      style = "numbers,changes,header";
      theme = "TwoDark";
    };
  };

  programs.pay-respects = {
    enable = true;
    enableZshIntegration = true;
  };

  # Zsh configuration managed by Home Manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

    plugins = [
      {
        name = "zsh-autopair";
        src = pkgs.zsh-autopair;
        file = "share/zsh/zsh-autopair/autopair.zsh";
      }
    ];

    completionInit = "autoload -U compinit && compinit -d ~/.cache/zsh/zcompdump-$ZSH_VERSION";

    setOptions = [
      "INTERACTIVE_COMMENTS"
      "EXTENDED_HISTORY"
    ];

    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    historySubstringSearch.enable = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      share = true;
    };

    oh-my-zsh = {
      enable = true;
      theme = "intheloop";
      plugins = [
        "colored-man-pages"
        "command-not-found"
        "fzf"
        "git"
        "sudo"
      ];
    };

    initContent = ''
      # History substring search with arrow keys
      bindkey "^[[A" history-substring-search-up
      bindkey "^[[B" history-substring-search-down

      # Better completion menu behavior
      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

      # fzf-tab plugin for fuzzy completion menus.
      if [[ -f ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh ]]; then
        source ${pkgs.zsh-fzf-tab}/share/fzf-tab/fzf-tab.plugin.zsh
      fi

      # Quick git commit+push: gacp "message"
      gacp() { git add . && git commit -m "$*" && git push }
    '';

    shellAliases = {
      ll = "eza --icons -F -H -a --group-directories-first --git -1";
      la = "eza -la --icons --group-directories-first";
      ls = "eza --icons -F -H --group-directories-first --git -1";
      myip = "ip -brief address | awk '{print \$1 \" \" \$3}' && echo -n 'External: ' && curl -s ifconfig.me && echo";
      ports = "ss -tulanp";
      listening = "ss -tulnp";
      nsw = "sudo nixos-rebuild switch --flake ~/nixos_configs#nixos";
      ntest = "sudo nixos-rebuild test --flake ~/nixos_configs#nixos";
      nup = "nix flake update --flake ~/nixos_configs && sudo nixos-rebuild switch --flake ~/nixos_configs#nixos";
      ngc = "nix-collect-garbage -d && sudo nix-collect-garbage -d";
      ncheck = "sudo nixos-rebuild dry-build --flake ~/nixos_configs#nixos";
      stat = "sys-status";
      rsi = "rsi-launcher";
      grep = "grep --color=auto";
      clr = "clear && fastfetch";
      trashl = "trash-list";
      rm = "trash-put";
      restore = "trash-restore";

    };
  };

  # Use Home Manager for per-user config files under ~/.config
  xdg.configFile."niri/config.kdl".source = ./dotfiles/niri/config.kdl;
  xdg.configFile."niri/dms/binds.kdl".source = ./dotfiles/niri/dms/binds.kdl;

  # Examples:
  # xdg.configFile."waybar/config".source = ./dotfiles/waybar/config;
  # xdg.configFile."mako/config".source = ./dotfiles/mako/config;

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "26.05";
}
