# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, unstablePkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.spicetify-nix.nixosModules.default
      # inputs.home-manager.nixosModules.home-manager
    ];

  nix.settings.experimental-features = [ "flakes" "nix-command"];
  # GPU
  # make the kernel use the correct driver early
  boot.initrd.kernelModules = ["amdgpu"];
 # Bootloader
 # boot.loader.grub.device = "/dev/nvme1n1p5";
  #boot.loader.efi.efiSysMountPoint = "/mnt/boot"
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 20; #wait for 20 secs before going to default option
  boot.loader.grub = {
    enable = true;
    devices = ["nodev"];
    efiSupport = true;
    # theme = ./nixosModules/programs/grub-themes/CyberRe;
    # theme = ./nixosModules/programs/grub-themes/CyberGRUB-2077;
    theme = ./nixosModules/programs/grub-themes/virtuaverse;
    default = "2";
    # default = "Windows Boot Manager";

    # skip grub-install and grub-mkconfig for faster nixos rebuilds
    useOSProber = true; # if true will scan for windows boot config and add it to grub window!
    forceInstall = false; # nix rebuild switch will skip GRUB regeneration unless the bootloader config actually changed
  };


  networking.hostName = "nixos"; # Define your hostname.
  # Pick only one of the below networking options.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

  # Set your time zone.
  time.timeZone = "Europe/Zurich";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  # the basic console doesn't support nerdfonts
  console = {
    font = "Lat2-Terminus16";
  #    keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable Wayland and Hyprland (ignore the xserver part - that is bad naming)
  services.xserver = {
    enable = true;
    videoDrivers = [ "amdgpu" ];

    xkb.layout = "us,bg";
    xkb.variant = ",phonetic"; # Empty for "us", phonetic for "bg"
    # xkbOptions = "grp:alt_shift_toggle"; # Switch layout with Shift + Alt
    xkb.options = "grp:caps_toggle,grp_led:caps"; # Switch with caps and light says on for second layout
  };
  programs.hyprland.enable = true;
  # programs.hyprpanel.enable = true;
  
  # Enable seatd for better input handling in wayland with keyboard and mouse of non-root users
  services.seatd.enable = true;


  # bluetooth
  hardware.bluetooth.enable = true;

  # Start Hyprland on startup and use Greetd for a quick login
  # With the help of greetd enable autologin for my user
  services.greetd = {
     enable = true;
     settings = rec {
     	initial_session = {
           command = "Hyprland";
           user = "spas";
	};
        default_session = initial_session;
    };
  };


  # #home manager config
  # programs.home-manager.enable = true;
  # home-manager.users.spas = { pkgs, ... }: {
  #    home.packages = [
  #      pkgs.tmux
  #    ];
  # };
  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

  # Enable CUPS to print documents.
  # services.printing.enable = true;

  # Enable sound.
  # hardware.pulseaudio.enable = true;
  # OR
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    audio.enable = true;
    jack.enable = true;
    wireplumber.extraConfig.bluetoothEnhancements = {
      "monitor.bluez.properties" = {
      "bluez5.enable-sbc-xq" = true;
      "bluez5.enable-msbc" = true;
      "bluez5.enable-hw-volume" = true;
      "bluez5.roles" = [ "hsp_hs" "hsp_ag" "hfp_hf" "hfp_ag" ];
      };
    };
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.libinput.enable = true;
  users.defaultUserShell = pkgs.nushell;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.spas = {
    isNormalUser = true;
    extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  };

  security.sudo.extraConfig = ''
    Defaults        timestamp_timeout=-1
  '';
  # programs.firefox.enable = true;
  # programs.ghostty.enable = true;
  # nixpkgs.channel = "nixos-unstable";
  
  # Rust version of fuck aka pay-respects
  programs.pay-respects.enable = true;
  programs.pay-respects.alias = "fuck";

  # fallback dynamic linker for binaries that expect a traditional Linux environment
  programs.nix-ld.enable = true;

  # for using direnv .envrc files in my programming projects so ican use package managers like pip npm cargo
  programs.direnv.enable = true;
  programs.direnv.nix-direnv.enable = true;

  programs.tmux.enable = true;
  programs.git = {
    enable = true;
    config = {
        # Fuck 3 way conflict resolution
        mergetool = {
            hideResolved = true;
        };
        init = {
            defaultBranch = "main";
        };
    };
  };


  ### spotify customization
  programs.spicetify = 
  let
    spicePkgs = inputs.spicetify-nix.legacyPackages.${pkgs.system};
  in
  {
     enable = true;
     # theme = spicePkgs.themes.starryNight;
     theme = spicePkgs.themes.ziro;
     colorScheme = "rose-pine";
     enabledCustomApps = with spicePkgs.apps; [
       ncsVisualizer
     ];
     enabledSnippets = with spicePkgs.snippets; [
       rotatingCoverart
       pointer
     ];
  };

  nixpkgs.config.allowUnfree = true; # FU Spotify
  
  
  ####################

  # gtk thunar setup

  # bookmarks for the left side panel
  # gtk.gtk3.bookmarks = [
  #   "file:///home/spas/Downloads Downloads"
  #   "file:///home/spas/nextcloud Nextcloud"
  #   "file:///home/spas/dotfiles Dotfiles"
  #   "file:///home/spas/.config/nixos NixOS"
  #   "file:///home/spas/dev Development"
  # ];

  # setup steam and stuff
  # OpenGl (for hardware acceleration)
  hardware.graphics.enable = true;
  hardware.graphics.enable32Bit = true;
  programs.steam.enable = true;
  programs.steam.gamescopeSession.enable = true; # used to start game in an optimized microcompositor... can help if game has issues with upscaling or monitor resolutions
  programs.gamemode.enable = true; # daemon that will improve game performance on linux


  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
     vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
     wget
     ghostty
     neovim
     nushell
     hyprland
     seatd
     brave
     stow 
     tree
     wofi
     cava
     rustup
     xdg-desktop-portal-hyprland
     grim
     slurp
     starship
     bat
     btop-rocm
     gcc
     # copyq
     wl-clipboard
     zoxide
     fastfetch # like neofetch but faster and actively maintained
     mpd # music player client
     inputs.swww.packages.${pkgs.system}.swww # daemon for changing wallpapers
     hyprpaper
     nodejs
     yarn # or npm
     ripgrep
     unzip
     yazi
     ffmpeg-full
     widevine-cdm # DRM support (e.g., Netflix, Spotify, YouTube Music)
     mpv
     mesa # amd gpu drivers
     vesktop
     spotify
     jq # json query - useful in bash commands
     # Thunar file manager GTK stuff
     xfce.xfconf
     xfce.tumbler # nice thumbnails for files and pictures
     p7zip
     unrar
     xfce.thunar
     xfce.thunar-archive-plugin
     catppuccin-papirus-folders # nice folder icons for thunar
     nwg-look
     catppuccin-gtk # should turn thunar dark
     ###
     playerctl #control media with keyboard keys
     brightnessctl #change brightness with keyboard (didn't work but that's fine)
     # code-cursor
     qbittorrent
     fd
     fzf
     lazygit
     pay-respects # alternative to fuck cli
     gnumake # so I can use the "make command"
     go
     mangohud # hame overlay FPS counter
     protonup # for installing proton GE for playing games
     hyprpanel
     unstablePkgs.opencode # terminal ai agent from unstable channel
     hyprsunset # Blue light filtering during night
     rose-pine-hyprcursor # hyprcursor theme
     catppuccin-cursors.mochaMauve # i can see it in nwg but can't make it work right now soo rose pine it is
     hyprshot # screenshots
     lsof # "List open files" in unix everything is a file including sockets, network ports and directories
     unstablePkgs.gemini-cli # some ai terminal goodness
     python314Full
     carapace # cli command completions and suggestions
     rustc
     cargo
  ];

  # Env session variables for better wayland support
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland"; # Force Wayland for Qt apps like VLC
    SDL_VIDEODRIVER = "wayland";
    NO_UPDATE_NOTIFIER = "1"; # should Disable gemini-cli from autoupdating

    # VDPAU_DRIVER = "radeonsi"; # idk if this will fix my video playback problem, let's try
    # GTK_THEME = "Papirus-Dark";
    # XDG_ICON_DIR = "${pkgs.catppuccin-papirus-folders}/share/icons/Papirus-Dark";
    
    # Setup env vars for where steam should be installed
    STEAM_EXTRA_COMPAT_TOOLS_PATHS = "/home/user/.steam/root/compatibilitytools.d";
  };
  environment.variables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
    HOME = "/home/spas";
  };
  
  fonts.packages = with pkgs; [
    # (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) # for nix-os stable
    nerd-fonts.jetbrains-mono # new syntax in nios-unstable branch
    nerd-fonts.hack
  ];

  # browser video playback doesn't work and adding this didn't fix it
  nixpkgs.config = {
    brave = {
      enableWideVine = true;
    };
  };

  # Settings to remember mount points instead of editing etc/fstab (in this case for the shared drive with windows)
  fileSystems = {
	"/shared" = {
		device = "LABEL=Caring";
		fsType = "ntfs";
		options = [ "rw" "uid=1000" "gid=100" "unmask=0022" "nofail" ];
	};
  };

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?

}

