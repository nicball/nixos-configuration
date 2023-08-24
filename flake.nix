{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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
