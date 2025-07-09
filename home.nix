{ config, pkgs, inputs,... }:
{
  home.username = "mark";
  home.homeDirectory = "/home/mark";
  home.enableNixpkgsReleaseCheck = false;

  #basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "markupstart";
    userEmail = "mark@upstarters.com";
     extraConfig = {
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
    pamixer
    pavucontrol
	gnome-weather
	bazecor
	davinci-resolve-studio
    zip
    audacity
    audacious
    handbrake
    gnome-boxes
    nautilus
    mpd
    rmpc
    cava
    dconf-editor
	trash-cli
    libnotify
    xz
    unzip
    p7zip
    cabextract
    zenity
    alacritty
    alpaca
    ollama-rocm
	glib
    starship
    flatpak
    rssguard
    micro
    kitty
    xdg-desktop-portal-gnome
    xdg-desktop-portal-gtk
    swww

    #utils
    ripgrep # recursively searches directories for a regex pattern
    fzf # A command-line fuzzy finder
    atuin
    zoxide

    #networking tools
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    #misc
    file
    which
    tree
    gawk
    zstd
    jq
    socat
    mission-center
    
    # nix related
    nix-output-monitor
    nitch
    inxi
    
    #productivity
    glow # markdown previewer in terminal
    btop
    iftop # network monitoring
    clapper
    spotify
    mission-center  
    nextcloud-client
    
    #system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    #system tools
    sysstat
    ethtool
    pciutils # lspci
    usbutils # lsusb
    nixos-generators
    killall
    glxinfo
    kdePackages.polkit-kde-agent-1

    #my software for user
    adwaita-qt
    adwaita-qt6
    roboto
    mate.mate-themes
    mate.mate-icon-theme
    terminus_font
    vlc
    font-awesome
    mate.engrampa
    qalculate-gtk
    fish
    thunderbird
    mint-y-icons
    mint-themes
    numix-cursor-theme
    distrobox
    podman
    boxbuddy
    vscode
    dconf
    firefox
    lutris
    polkit
    polkit_gnome
    lxde.lxsession
    fastfetch
    adwaita-icon-theme
    xfce.thunar-archive-plugin
    winetricks
    scribus
    inkscape
    extremetuxracer
    superTuxKart
    superTux
    makemkv
    gamescope
    mangohud
    gamemode
    pulsemixer
    discord
    obs-studio
    obs-studio-plugins.wlrobs
    obs-studio-plugins.obs-vaapi
    obs-studio-plugins.obs-vkcapture
    obs-studio-plugins.obs-gstreamer
    obs-studio-plugins.obs-pipewire-audio-capture
    htop
    btop
    wofi
    nwg-look
    power-profiles-daemon
    xfce.mousepad
    xfce.thunar-archive-plugin
    darktable
    adwaita-icon-theme
    font-awesome
    grc
    lxqt.lxqt-sudo
    libreoffice-fresh  
    ghostty
    foot
    libsForQt5.kdenlive
    glaxnimate
    pw-volume
    copyq
    waybar
    mate.mate-polkit
    nordzy-cursor-theme
    gnome-keyring
    swaybg
    swayidle
    swaylock
    swayosd
    wallust
    xwayland-satellite
    mako
    gpu-screen-recorder-gtk
    papers
    bibata-cursors
    grim
    vulkan-tools
    blender-hip
    virt-manager
    ffmpeg
    system-config-printer
    cups-brother-hll2340dw
    foomatic-db
    transmission_4-gtk
    cups-filters
    brlaser
    cups-brother-hl2260d
    cups-brother-hl1210w
    
    ];

  #enable eza
  programs.eza.enable = true;
 
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
  home.stateVersion = "25.05";
}
