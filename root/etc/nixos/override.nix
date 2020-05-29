{ config, pkgs, ... }@args:
let hostNameFile = /etc/hostname;
in pkgs.lib.optionalAttrs (builtins.pathExists hostNameFile) (let
  hostname =
    builtins.elemAt (pkgs.lib.splitString "\n" (builtins.readFile hostNameFile))
    0;
in if hostname == "uzq" then rec {
  inherit (hostname);
  hostId = "80d17333";
  enableHidpi = true;
  buildCores = 40;
} else if hostname == "ssg" then rec {
  inherit (hostname);
  hostId = "034d2ba3";
  dpi = 128;
  enableHidpi = false;
  enableIPv6 = false;
  enableWireless = true;
  buildCores = 8;
  consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
} else
  { })
