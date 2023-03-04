{
  inputs = {
    nicpkgs = {
      url = "github:nicball/nicpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
  };
  outputs = { self, nixpkgs, nicpkgs, emacs-overlay, ... }: {
    nixosConfigurations.nicball-nixos = nixpkgs.lib.nixosSystem rec {
      system = "x86_64-linux";
      modules = [ ./configuration.nix ];
      specialArgs = {
        inherit emacs-overlay;
        nlib = nicpkgs.lib.${system};
        npkgs = nicpkgs.packages.${system};
      };
    };
  };
}
