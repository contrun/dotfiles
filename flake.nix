{
  description = "Nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nur-no-pkgs.url = "github:nix-community/NUR/master";
    authinfo = {
      url = "github:aartamonau/authinfo";
      flake = false;
    };
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    flake-firefox-nightly.url = "github:colemickens/flake-firefox-nightly";
    flake-firefox-nightly.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-mozilla = {
      url = "github:mozilla/nixpkgs-mozilla";
      flake = false;
    };
    old-ghc-nix = {
      url = "github:mpickering/old-ghc-nix";
      flake = false;
    };
  };

  outputs = { ... }@inputs:
    let
      myNixConfigPath = path: ./. + "/ignored/nix/${path}";

      systemsList = [
        "x86_64-linux"
        "i686-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "armv6l-linux"
        "armv7l-linux"
      ];
      systems =
        builtins.foldl' (acc: current: acc // { "${current}" = current; }) { }
        systemsList;

      getHostPreference = hostname:
        let old = (import (myNixConfigPath "prefs.nix")) { inherit hostname; };
        in old // {
          system = systems.hostname or old.nixosSystem or "x86_64-linux";
        };

      generateHostConfigurations = hostname: inputs:
        import (myNixConfigPath "generateNixOSConfiguration.nix") {
          prefs = getHostPreference hostname;
          inputs = inputs;
        };
    in {
      nixosConfigurations = builtins.foldl'
        (acc: current: acc // generateHostConfigurations current inputs) { }
        ([ "default" "ssg" "jxt" "shl" ] ++ systemsList);
    };
}
