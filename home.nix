{ config, pkgs, ... }:
{
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  #basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    settings = {
      user.name = "markupstart";
      user.email = "mark@upstarters.com";
      credential.helper = "${
          pkgs.git.override { withLibsecret = true; }
        }/bin/git-credential-libsecret";
    };
  };

  #Virt-Manager setup
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
  };
};

  # Packages that should be installed to the user profile.
  home.packages = with pkgs; [
    #archives
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
    gnome-weather
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
    swappy
    trash-cli
    unzip
    v4l-utils
    xz
    yazi
    zenity
    zip

    #utils
    fd
    ripgrep # recursively searches directories for a regex pattern

    #networking tools
    dnsmasq
    ipcalc # it is a calculator for the IPv4/v6 addresses
    nmap # A utility for network discovery and security auditing

    #misc
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

    # nix related
    inxi
    nixd
    nixfmt
    nitch
    nix-output-monitor

    #productivity
    bottom
    btop
    clapper
    glow # markdown previewer in terminal
    iftop # network monitoring
    owncloud-client

    #system call monitoring
    lsof # list open files
    ltrace # library call monitoring
    strace # system call monitoring

    #system tools
    bash-completion
    docker-compose
    ethtool
    kdePackages.polkit-kde-agent-1
    killall
    (lib.lowPrio mesa-demos)
    nixos-generators
    pciutils # lspci
    sysstat
    usbutils # lsusb

    #my software for user
    adwaita-icon-theme
    adwaita-qt
    adwaita-qt6
    bibata-cursors
    blender
    boxbuddy
    brlaser
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
    gamemode
    gamescope
    ghostty
    glaxnimate
    gnome-keyring
    grc
    grim
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
      theme = "robbyrussell";
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
      ll = "eza -la";
      la = "eza -a";
      ls = "eza";
      grep = "grep --color=auto";
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
