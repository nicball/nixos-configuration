{
  inputs = {
    # nixpkgs.url = "nixpkgs/nixos-22.11";
    nicpkgs = {
      url = "github:nicball/nicpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.nixpkgs-latest.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nicpkgs, ... }: {
    nixosConfigurations.nicball-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {
        niclib = nicpkgs.lib.${system};
        nicpkgs = nicpkgs.packages.${system};
      };
    };
  };
}
