{
  description = "Nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
    aioproxy.url = "github:contrun/aioproxy/master";
    aioproxy.inputs.nixpkgs.follows = "nixpkgs";
    aioproxy.inputs.utils.follows = "flake-utils";
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
      getNixConfig = path: ./. + "/ignored/nix/${path}";

      getHostPreference = hostname:
        let
          old =
            (import (getNixConfig "prefs.nix")) { inherit hostname inputs; };
        in old // { system = old.nixosSystem; };

      generateHostConfigurations = hostname: inputs:
        import (getNixConfig "generate-nixos-configuration.nix") {
          prefs = getHostPreference hostname;
          inputs = inputs;
        };
    in {
      nixosConfigurations = builtins.foldl'
        (acc: hostname: acc // generateHostConfigurations hostname inputs) { }
        ([ "default" ] ++ [ "ssg" "jxt" "shl" ]
          ++ (builtins.attrNames (import (getNixConfig "fixed-systems.nix")).systems));
    };
}
