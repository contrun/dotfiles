# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ ];

  boot.loader = {
    efi = { efiSysMountPoint = "/boot"; };
    grub = {
      enable = true;
      devices = [ "/dev/nvme0n1" ];
    };
  };

  system.stateVersion = "20.09";
}
