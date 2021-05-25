{
  description = "Nixos configurations";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-20.09";
    flake-utils.url = "github:numtide/flake-utils";
    gomod2nix.url = "github:tweag/gomod2nix";
    gomod2nix.inputs.nixpkgs.follows = "nixpkgs";
    gomod2nix.inputs.utils.follows = "flake-utils";
    aioproxy.url = "github:contrun/aioproxy/master";
    aioproxy.inputs.nixpkgs.follows = "nixpkgs";
    aioproxy.inputs.gomod2nix.follows = "gomod2nix";
    aioproxy.inputs.flake-utils.follows = "flake-utils";
    infra.url = "github:contrun/infra/master";
    infra.inputs.nixpkgs.follows = "nixpkgs";
    infra.inputs.gomod2nix.follows = "gomod2nix";
    infra.inputs.flake-utils.follows = "flake-utils";
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
          old = ((import (getNixConfig "prefs.nix")) {
            inherit hostname inputs;
          }).pure;
        in old // { system = old.nixosSystem; };

      generateHostConfigurations = hostname: inputs:
        let
          p = getHostPreference hostname;
          pjson = builtins.toJSON (inputs.nixpkgs.lib.filterAttrsRecursive
            (n: v: !builtins.elem (builtins.typeOf v) [ "lambda" ]) p);
          prefs =
            builtins.trace "mininal json configuration for host ${hostname}"
            (builtins.trace pjson p);
        in import (getNixConfig "generate-nixos-configuration.nix") {
          inherit prefs inputs;
        };

      out = system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ ];
          };
        in { };

    in {
      getDotfile = path: ./. + "/${path}";

      nixosConfigurations = builtins.foldl'
        (acc: hostname: acc // generateHostConfigurations hostname inputs) { }
        ([ "default" ] ++ [ "ssg" "jxt" "shl" ] ++ (builtins.attrNames
          (import (getNixConfig "fixed-systems.nix")).systems));
    } // (with inputs.flake-utils.lib; eachSystem defaultSystems out);
}
