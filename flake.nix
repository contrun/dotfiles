{
  description = "Nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
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
        (import (myRootPath "/etc/nixos/pref.nix")) { inherit hostname; };
      generateHostConfigurations = hostname:
        let
          prefs = getHostPreference hostname;
          system = prefs.nixosSystem or "x86_64-linux";
        in {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [
              ({ config, pkgs, system, inputs, ... }: {
                nixpkgs.overlays = [
                  (self: super: {
                    unstable = import inputs.nixpkgs-unstable {
                      inherit system;
                      config = super.config;
                    };
                    stable = import inputs.nixpkgs-stable {
                      inherit system;
                      config = super.config;
                    };
                  })
                ];
              })

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
                (myRootPath "/etc/nixos/hardware-configuration-${hostname}.nix")
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

            specialArgs = { inherit inputs system prefs hostname; };
          };
        };
      allConfigurations = builtins.foldl'
        (acc: current: acc // generateHostConfigurations current)
        { } [ "default" "ssg" "jxt" "shl" ];
    in {
      nixosConfigurations = builtins.trace allConfigurations allConfigurations;
    };
}
