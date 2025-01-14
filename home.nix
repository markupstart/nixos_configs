{ config, pkgs, inputs,... }:
{
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  #set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 110;
  };

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
    zip
    xz
    unzip
    p7zip

    #utils
    ripgrep # recursively searches directories for a regex pattern
    fzf # A command-line fuzzy finder

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
    
    # nix related
    nix-output-monitor
    nitch
    inxi
    
    #productivity
    glow # markdown previewer in terminal
    btop
    iftop # network monitoring
    
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
    cinnamon.mint-y-icons
    cinnamon.mint-themes
    numix-cursor-theme
    distrobox
    dconf
    firefox
    lutris
    gimp-with-plugins 
    polkit
    lxde.lxsession
    fastfetch
    gnome.adwaita-icon-theme
    xfce.thunar-archive-plugin
    wine
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
    fuzzel
    nwg-look
    xfce.mousepad
    xfce.thunar-archive-plugin
    darktable
    gnome.adwaita-icon-theme
    font-awesome
    grc
    lxqt.lxqt-sudo
    libreoffice-fresh  
    ghostty
    polychromatic
    libsForQt5.kdenlive
    glaxnimate
    pw-volume
    copyq
    waybar
    swaybg
    swayidle
    swaylock
    swayosd
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
    transmission-gtk
    cups-filters
    brlaser
    ];

  #enable eza
  programs.eza.enable = true;

  #starship - an customizable prompt for any shell
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      aws.disabled = true;
      gcloud.disabled = true;
      line_break.disabled = true;
    };
  };

   programs.bash = {
    enable = true;
    enableCompletion = true;
    shellAliases = {
    "ls" = "eza --icons -F -H --group-directories-first --git -1";
    "la" = "eza --icons -F -H -a --group-directories-first --git -1";
    "ll" = "eza --icons -F -H -a -l --group-directories-first --git";
};
    bashrcExtra = ''
      export LOCALE_ARCHIVE="/run/current-system/sw/lib/locale/locale-archive"
      export LC_All=All
      export locale=en_US.UTF-8
      export PATH="/home/mark/.nix-profile/bin:$PATH"
      export PATH="/home/mark/.local/bin:$PATH"
      export PATH="/home/mark/.local/share/applications:$PATH"
      export PATH="/home/mark/.local/discord:$PATH"
      export TERMINAL=alacritty
    ''; 
};
 
    #gtk fonts and themes
    gtk = {
    enable = true;
    iconTheme = {
    name = "Mint-Y-Orange";
    package = pkgs.mate.mate-icon-theme;
    };

    theme = {
    name = "Mint-Y-Dark-Orange";
    package = pkgs.mate.mate-themes;
    };
       font.name = "Roboto-Black 10";
    cursorTheme = {
       name = "Bibata-Modern-Amber";
       package = pkgs.bibata-cursors;
         };
    gtk3.extraConfig = {
      gtk-xft-antialias = 1;
      gtk-xft-hinting = 1;
      gtk-xft-hintstyle = "hintfull";
      gtk-xft-rgba = "rgb";
      gtk-cursor-theme-name = "Bibata-Modern-Amber";
        };
       };

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
  home.stateVersion = "24.11";
}
