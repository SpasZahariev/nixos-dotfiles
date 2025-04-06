# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix.settings.experimental-features = [ "flakes" "nix-command"];
 # Bootloader
 # boot.loader.grub.device = "/dev/nvme1n1p5";
  #boot.loader.efi.efiSysMountPoint = "/mnt/boot"
  #boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 20; #wait for 20 secs before going to default option
  boot.loader.grub = {
    enable = true;
    devices = ["nodev"];
    useOSProber = true;
    efiSupport = true;
    # theme = ./nixosModules/programs/grub-themes/CyberRe;
    theme = ./nixosModules/programs/grub-themes/CyberGRUB-2077;
    # theme = ./nixosModules/programs/grub-themes/virtuaverse;
    default = "2";
    # default = "Windows Boot Manager";

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
  console = {
    font = "Lat2-Terminus16";
  #    keyMap = "us";
    useXkbConfig = true; # use xkb.options in tty.
  };

  # Enable Wayland and Hyprland (ignore the xserver part - that is bad naming)
  services.xserver.enable = true;
  programs.hyprland.enable = true;
  
  # Enable seatd for better input handling in wayland with keyboard and mouse of non-root users
  services.seatd.enable = true;

  # OpenGl (for hardware acceleration)
  hardware.graphics.enable = true;


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
    pulse.enable = true;
    audio.enable = true;
    jack.enable = true;
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
  
  nixpkgs.config.allowUnfree = true; # FU Spotify
  
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
     git
     stow 
     tree
     wofi
     kdePackages.dolphin
     waybar
     cava
     python3
     rustup
     xdg-desktop-portal-hyprland
     grim
     slurp
     starship
     bat
     btop-rocm
     dunst
     gcc
     # copyq
     wl-clipboard
     zoxide
     fastfetch # like neofetch but faster and actively maintained
     mpd # music player client
     wireplumber # manages where the pipewire sound is going (headphones, speakers - etc)
     spotify
     spicetify-cli
     inputs.swww.packages.${pkgs.system}.swww # daemon for changing wallpapers
     hyprpaper
     nodejs
     ripgrep
     unzip
     yazi
     ffmpeg
  ];

  # Env session variables for better wayland support
  environment.sessionVariables = {
    XDG_SESSION_TYPE = "wayland";
    XDG_CURRENT_DESKTOP = "Hyprland";
    QT_QPA_PLATFORM = "wayland"; # Force Wayland for Qt apps like VLC
    SDL_VIDEODRIVER = "wayland";
  };
  environment.variables = {
    EDITOR = "nvim";
    TERMINAL = "ghostty";
    HOME = "/home/spas";
  };
  
  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "JetBrainsMono" ]; })
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
  system.stateVersion = "24.11"; # Did you read the comment?

}

