{
  description = "A very basic flake that adds packages to my configuration.nix";

  inputs = {
     nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
     swww.url = "github:LGFae/swww";
     spicetify-nix.url = "github:Gerg-L/spicetify-nix";
     hyprpanel.url = "github:Jas-SinghFSU/HyprPanel";
  };

  outputs = { nixpkgs, ... } @ inputs: 
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      # i originally set the hostname to be spas-nixos but i put it back to the default 'nixos'
      nixos = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit system;
          inherit inputs; # i'll be able to use all inputs in all modules
        }; 
        modules = [
          {nixpkgs.overlays = [inputs.hyprpanel.overlay];}
          ./configuration.nix
        ];
      };
    };
  };
}
