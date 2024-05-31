{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/ad57eef4ef0659193044870c731987a6df5cf56b";
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
        ({ ... }: {
          nixpkgs.overlays = [ nicpkgs.overlays.default ];
          nix.nixPath = [
            "nicpkgs=${nicpkgs}"
            "nixos-config=${./.}"
            "nixpkgs=flake:nixpkgs"
          ];
        })
      ];
    };
  };
}
