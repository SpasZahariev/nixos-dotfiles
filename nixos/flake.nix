{
  description = "A very basic flake that adds packages to my configuration.nix";

  inputs = {
    # nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-25.11";
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

      # For importing packages, use 'system' (this is correct)
      unstablePkgs = import nixpkgs-unstable {
        inherit system;
        config = { allowUnfree = true; };
      };
    in {
      nixosConfigurations = {
        nixos = nixpkgs.lib.nixosSystem {
          specialArgs = {
            inherit unstablePkgs;
            inherit inputs;
          };
          modules = [
            # For nixosSystem, use nixpkgs.hostPlatform (new way)
            { nixpkgs.hostPlatform = system; }

            ./configuration.nix
          ];
        };
      };
    };
}
