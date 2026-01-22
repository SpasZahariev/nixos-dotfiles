{
  description = "A very basic flake that adds packages to my configuration.nix";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    nixpkgs-unstable.url =
      "github:nixos/nixpkgs/nixos-unstable"; # I like to live dangerously
    swww.url = "github:LGFae/swww";
    spicetify-nix.url = "github:Gerg-L/spicetify-nix";
    hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
    # catppuccin.url = "github:catppuccin/nix";
  };

  outputs = { nixpkgs, nixpkgs-unstable, ... }@inputs:
    let
      system = "x86_64-linux";
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      nixosConfigurations = {
        # i originally set the hostname to be spas-nixos but i put it back to the default 'nixos'
        nixos = nixpkgs.lib.nixosSystem {
          # allows me to pass extra arguments to every single module
          specialArgs = {
            inherit system;
            inherit unstablePkgs;
            inherit inputs; # i'll be able to acceess all inputs in all modules
          };
          modules = [
            ./configuration.nix
            # ./nixosModules/programs/tmux.nix
          ];
        };
      };
    };
}
