{ pkgs, inputs, ... }:

let
  rsiLauncherPkg = inputs.nix-citizen.packages.${pkgs.system}.rsi-launcher;
  rsiLauncherNiri = pkgs.writeShellScriptBin "rsi-launcher-niri" ''
    export MESA_VK_WSI_PRESENT_MODE=mailbox
    export MANGOHUD=1
    export MANGOHUD_DLSYM=1
    exec ${rsiLauncherPkg}/bin/rsi-launcher "$@"
  '';

  archiveAndMediaPackages = with pkgs; [
    alacritty
    audacious
    audacity
    bazecor
    cabextract
    catimg
    cava
    chafa
    davinci-resolve-studio
    dconf-editor
    glib
    gnome-boxes
    handbrake
    inotify-tools
    kitty
    libnotify
    micro
    mpd
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
    fd
    ripgrep
    dnsmasq
    ipcalc
    nmap
    curl
    exiftool
    file
    gawk
    jq
    mission-center
    socat
    tree
    which
    zstd
  ];

  nixPackages = with pkgs; [
    inxi
    nixd
    nixfmt
    nitch
    nix-output-monitor
  ];

  productivityPackages = with pkgs; [
    bottom
    btop
    clapper
    glow
    iftop
    owncloud-client
  ];

  monitoringPackages = with pkgs; [
    lsof
    ltrace
    strace
  ];

  systemPackages = with pkgs; [
    bash-completion
    docker-compose
    ethtool
    killall
    (lib.lowPrio mesa-demos)
    nixos-generators
    pciutils
    sysstat
    usbutils
  ];

  desktopAppPackages = with pkgs; [
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6
    bibata-cursors
    blender
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
    vlc
    vulkan-tools
    winetricks
    xwayland-satellite
  ];

  launcherPackages = [
    rsiLauncherPkg
    rsiLauncherNiri
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
    ++ launcherPackages;

  xdg.desktopEntries.rsi-launcher-niri = {
    name = "RSI Launcher (Niri)";
    genericName = "Star Citizen Launcher";
    comment = "Launch RSI Launcher with Niri-specific Vulkan present mode";
    exec = "rsi-launcher-niri %U";
    terminal = false;
    categories = [ "Game" ];
    icon = "rsi-launcher";
  };

  # Hide upstream launcher entry so only the Niri wrapper appears in app launchers.
  xdg.desktopEntries.rsi-launcher = {
    name = "RSI Launcher";
    noDisplay = true;
  };

  home.sessionVariables = {
    # Prefer native Wayland backend for Electron apps like VS Code.
    NIXOS_OZONE_WL = "1";
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

  # Zsh configuration managed by Home Manager
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autocd = true;

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
    '';

    shellAliases = {
      ll = "eza --icons -F -H -a --group-directories-first --git -1";
      la = "eza -la --icons --group-directories-first";
      ls = "eza --icons -F -H --group-directories-first --git -1";
      rsi = "rsi-launcher-niri";
      grep = "grep --color=auto";
      clr = "clear && fastfetch";
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
