{
  description = "gibson homelab";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, agenix, ... }: {
    nixosConfigurations.gibson = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./nix/configuration.nix
        agenix.nixosModules.default
        { system.configurationRevision = self.rev or self.dirtyRev or null; }
      ];
    };
  };
}
