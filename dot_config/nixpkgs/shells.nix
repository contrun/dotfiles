args@{ config ? (import <nixpkgs> { }).config, pkgs ? (import <nixpkgs> { }) }:
let prefs = (import /etc/nixos/prefs.nix { inherit config pkgs; });
in { }
