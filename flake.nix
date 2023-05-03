{
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    nicpkgs = {
      url = "github:nicball/nicpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, nicpkgs, ... }: {
    nixosConfigurations.nicball-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {
        niclib = nicpkgs.niclib.${system};
        nicpkgs = nicpkgs.packages.${system};
      };
    };
  };
}
