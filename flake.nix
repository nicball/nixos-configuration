{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nicpkgs = {
      url = "github:nicball/nicpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote.url = "github:nix-community/lanzaboote";
  };
  outputs = { self, nixpkgs, nicpkgs, lanzaboote, ... }: {
    nixosConfigurations.nixos-laptop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        lanzaboote.nixosModules.lanzaboote
      ];
      specialArgs = {
        niclib = nicpkgs.niclib.${system};
        nicpkgs = nicpkgs.packages.${system};
      };
    };
  };
}
