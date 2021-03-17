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
      myRootPath = path: ./. + "/root${path}";
      pathOr = path: default:
        if (builtins.pathExists path) then path else default;
      getHostPreference = hostname:
        (import /etc/nixos/pref.nix) { inherit hostname; };
      generateHostConfigurations = hostname:
        let prefs = getHostPreference hostname;
        in {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            system = prefs.nixosSystem or "x86_64-linux";

            modules = [
              ({ config, pkgs, ... }:
                if hostname == "ssg" then {
                  boot.loader.grub.devices = [ "/dev/nvme0n1" ];
                  services.xserver.videoDrivers = [ "amdgpu" ];
                  hardware.cpu.amd.updateMicrocode = true;
                } else if hostname == "jxt" then
                  { }
                else {
                  boot.loader.grub.devices = [ "/dev/nvme0n1" ];
                })

              (import (pathOr
                (myRootPath "/etc/nixos/${hostname}-hardware-configuration.nix")
                /etc/nixos/hardware-configuration.nix))

              (import (myRootPath "/etc/nixos/common.nix"))

              inputs.nixpkgs.nixosModules.notDetected

              # inputs.sops-nix.nixosModules.sops
              inputs.home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
              }
            ];

            specialArgs = { inherit inputs prefs hostname; };
          };
        };
      allConfigurations = builtins.foldl'
        (acc: current: acc // generateHostConfigurations current)
        { } [ "default" "ssg" "jxt" "shl" ];
    in {
      nixosConfigurations = builtins.trace allConfigurations allConfigurations;
    };
}
