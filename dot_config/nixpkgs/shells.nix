args@{ config ? (import <nixpkgs> { }).config, pkgs ? (import <nixpkgs> { }) }:
let prefs = (import /etc/nixos/pref.nix { inherit config pkgs; });
in { }
