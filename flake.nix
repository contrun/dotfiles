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

          flakeSupport = { lib, pkgs, config, ... }: {
            nix.package = pkgs.nixFlakes;
            nix.extraOptions =
              pkgs.lib.optionalString (config.nix.package == pkgs.nixFlakes)
              "experimental-features = nix-command flakes ca-references";
            system.configurationRevision = lib.mkIf (self ? rev) self.rev;
          };
          nixpkgsOverlay = { config, pkgs, system, inputs, ... }: {
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
          };
          hostConfiguration = { config, pkgs, ... }:
            if hostname == "ssg" then {
              boot.loader.grub.devices = [ "/dev/nvme0n1" ];
              services.xserver.videoDrivers = [ "amdgpu" ];
              hardware.cpu.amd.updateMicrocode = true;
            } else if hostname == "jxt" then
              { }
            else {
              boot.loader.grub.devices = [ "/dev/nvme0n1" ];
            };
          hardwareConfiguration = import (pathOr
            (myRootPath "/etc/nixos/hardware-configuration-${hostname}.nix")
            /etc/nixos/hardware-configuration.nix);
          commonConfiguration = import (myRootPath "/etc/nixos/common.nix");
          overlaysConfiguration = let
            overlaysFile = ./. + "/dot_config/nixpkgs/overlays.nix";
            enableOverlays = builtins.pathExists overlaysFile;
          in if enableOverlays then {
            nixpkgs.overlays = [ import overlaysFile ];
          } else
            [ ];
          sopsConfiguration = let
            sopsSecretsFile = ./. + "/dot_config/nixpkgs/sops/secrets.yaml";
            enableSops = builtins.pathExists sopsSecretsFile;
          in if enableSops then {
            sops = {
              validateSopsFiles = false;
              defaultSopsFile = "${builtins.path {
                name = "sops-secrets";
                path = sopsSecretsFile;
              }}";
              secrets = {
                hello = {
                  mode = "0440";
                  owner = prefs.owner;
                  group = prefs.ownerGroup;
                };
                yandex-passwd = {
                  mode = "0400";
                  owner = prefs.owner;
                  group = prefs.ownerGroup;
                };
              };
            };
          } else
            { };
          homeManagerConfiguration = {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
          };
        in {
          "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
            inherit system;

            modules = [
              nixpkgsOverlay
              hostConfiguration
              hardwareConfiguration
              commonConfiguration
              inputs.nixpkgs.nixosModules.notDetected
              inputs.sops-nix.nixosModules.sops
              sopsConfiguration
              inputs.home-manager.nixosModules.home-manager
              homeManagerConfiguration
              # overlaysConfiguration
            ];

            specialArgs = { inherit inputs system prefs hostname; };
          };
        };
      allConfigurations = builtins.foldl'
        (acc: current: acc // generateHostConfigurations current)
        { } [ "default" "ssg" "jxt" "shl" ];
    in { nixosConfigurations = allConfigurations; };
}
