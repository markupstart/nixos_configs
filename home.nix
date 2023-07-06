{ config, pkgs, ... }:

{
  home.username = "mark";
  home.homeDirectory = "/home/mark";

  # link the configuration file in current directory to the specified location in home directory
  # home.file.".config/i3/wallpaper.jpg".source = ./wallpaper.jpg;

  # link all files in `./scripts` to `~/.config/i3/scripts`
  # home.file.".config/i3/scripts" = {
  #   source = ./scripts;
  #   recursive = true;   # link recursively
  #   executable = true;  # make all files executable
  # };

  # encode the file content in nix configuration file directly
  # home.file.".xxx".text = ''
  #     xxx
  # '';

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    "Xcursor.size" = 16;
    "Xft.dpi" = 192;
  };

  # basic configuration of git, please change to your own
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




  # Packages that should be installed to the user profile.

    home.packages = with pkgs; [

    # archives
    zip
    xz
    unzip
    p7zip

    # utils
    ripgrep # recursively searches directories for a regex pattern
    fzf # A command-line fuzzy finder

    # networking tools
    nmap # A utility for network discovery and security auditing
    ipcalc  # it is a calculator for the IPv4/v6 addresses

    # misc
    file
    which
    tree
    gawk
    zstd
    gnupg
    jq
    socat
    # nix related
    #
    # it provides the command `nom` works just like `nix
    # with more details log output
    nix-output-monitor

    # productivity
    glow # markdown previewer in terminal

    btop  # replacement of htop/nmon
    iftop # network monitoring
    #lxappearance

    # system call monitoring
    strace # system call monitoring
    ltrace # library call monitoring
    lsof # list open files

    # system tools
    sysstat
    lm_sensors # for `sensors` command
    ethtool
    pciutils # lspci
    usbutils # lsusb
    nixos-generators
    killall
    conky
   # openbox-menu
   # obconf
   # tint2
    roboto
    exa
    mate.mate-themes
    mate.mate-icon-theme
    terminus_font
    vlc
#    wdisplays
#    wlr-randr
#    eww-wayland
    neovim
    pinentry   

  ];

  # starship - an customizable prompt for any shell
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
    "ls" = "exa --icons -F -H --group-directories-first --git -1";
};
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
    '';
    
};
 
  ###Alacritty
#    {
   programs.alacritty = {
     enable = true;
     settings = {
       font.size = 9;
       font.theme = pkgs.terminus_font;

#      shell.program = "/usr/local/bin/fish";
    };
  };
#}
###
    programs.waybar = {
	enable = true;
	   
};

     # gtk fonts and themes
     gtk = {
      enable = true;
      iconTheme = {
      name = "menta";
      package = pkgs.mate.mate-icon-theme;
    };

    theme = {
      name = "BlackMATE";
      package = pkgs.mate.mate-themes;
    };

      font.name = "Roboto-Black 9";

      };
  #
  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
