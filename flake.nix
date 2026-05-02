{
  inputs = {
    nicpkgs.url = "github:nicball/nicpkgs";
    # lanzaboote = {
    #   url = "github:nix-community/lanzaboote";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    nixpkgs.url = "github:NixOS/nixpkgs/15f4ee454b1dce334612fa6843b3e05cf546efab";
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
