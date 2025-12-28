{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "github:NixOS/nixpkgs/cf3f5c4def3c7b5f1fc012b3d839575dbe552d43";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nicpkgs, nix-index-database, ... }: {
    nixosConfigurations.nixos-desktop = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
        # lanzaboote.nixosModules.lanzaboote
        nicpkgs.nixosModules.default
        nix-index-database.nixosModules.nix-index
      ];
    };
  };
}
