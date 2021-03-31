let
  pathOr = path: default: if (builtins.pathExists path) then path else default;
in { prefs, inputs }:
let
  inherit (prefs) hostname isMinimalSystem system getDotfile getNixConfig;

  moduleArgs = { inherit inputs hostname prefs isMinimalSystem system; };

  systemInfo = { lib, pkgs, config, ... }: {
    system.configurationRevision = lib.mkIf (inputs.self ? rev) inputs.self.rev;
    system.nixos.label = lib.mkIf (inputs.self.sourceInfo ? lastModifiedDate
      && inputs.self.sourceInfo ? shortRev) "flake.${
        builtins.substring 0 8 inputs.self.sourceInfo.lastModifiedDate
      }.${inputs.self.sourceInfo.shortRev}";
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
    {
      system.stateVersion = "20.09";
    } // (if hostname == "ssg" then {
      boot.loader.grub.devices = [ "/dev/nvme0n1" ];
      services.xserver.videoDrivers = [ "amdgpu" ];
      hardware.cpu.amd.updateMicrocode = true;
    } else if hostname == "jxt" then {
      boot.loader.grub.devices = [ "/dev/nvme0n1" ];
    } else {
      boot.loader.grub.devices = [ "/dev/nvme0n1" ];
    });

  hardwareConfiguration = if isMinimalSystem then
    import
    (pathOr (getNixConfig "hardware/hardware-configuration.${hostname}.nix")
      (getNixConfig "hardware/hardware-configuration.example.nix"))
  else
    import
    (pathOr (getNixConfig "hardware/hardware-configuration.${hostname}.nix")
      /etc/nixos/hardware-configuration.nix);

  commonConfiguration = import (getNixConfig "common.nix");

  overlaysConfiguration = import (getNixConfig "overlays.nix");

  sopsConfiguration = let
    sopsSecretsFile = getNixConfig "/sops/secrets.yaml";
    enableSops = builtins.pathExists sopsSecretsFile;
  in if enableSops then {
    sops = {
      validateSopsFiles = false;
      defaultSopsFile = "${builtins.path {
        name = "sops-secrets";
        path = sopsSecretsFile;
      }}";
      secrets = {
        clash-config-url = { };
        yandex-passwd = {
          mode = "0400";
          owner = prefs.owner;
          group = prefs.ownerGroup;
        };
      } // (if prefs.enableAcme then {
        cloudflare-dns-api-token = {
          mode = "0400";
          owner = "acme";
          group = "acme";
        };
      } else
        { });
    };
  } else
    { };

  homeManagerConfiguration = { ... }: {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users = {
        ${prefs.owner} = {
          _module.args = moduleArgs;
          imports = [ (getNixConfig "/home.nix") ];
        };
      };
    };
  };

in {
  "${hostname}" = inputs.nixpkgs.lib.nixosSystem {
    inherit system;

    modules = [
      systemInfo
      nixpkgsOverlay
      hostConfiguration
      hardwareConfiguration
      commonConfiguration
      inputs.nixpkgs.nixosModules.notDetected
      inputs.sops-nix.nixosModules.sops
      sopsConfiguration
      inputs.home-manager.nixosModules.home-manager
      homeManagerConfiguration
      overlaysConfiguration
    ];

    specialArgs = moduleArgs;
  };
}
