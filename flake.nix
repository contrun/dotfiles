{
  description = "Nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur-no-pkgs.url = "github:nix-community/NUR/master";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, ... }@inputs:
    let
      getHostPreference = hostname:
        (import /etc/nixos/pref.nix) { inherit hostname; };
      generateHostConfigurations = hostname:
        let prefs = getHostPreference hostname;
        in {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            system = prefs.currentSystem or "x86_64-linux";
            modules = [
              (import /etc/nixos/configuration.nix)
              # inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
              inputs.nixpkgs.nixosModules.notDetected
            ];
            specialArgs = { inherit inputs prefs; };
          };
        };
      allConfigurations = builtins.foldl'
        (acc: current: acc // generateHostConfigurations current) { }
        [ "default" ];
    in {
      nixosConfigurations = builtins.trace allConfigurations allConfigurations;
    };
}
