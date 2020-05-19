{ config, pkgs, ... }@args: rec {
  owner = "e";
  home = "/home/${owner}";
  hostname = "ssg";
  hostId = "034d2ba3";
  dpi = 128;
  enableHidpi = false;
  enableIPv6 = false;
  enableWireless = true;
  # proxy = "http://127.0.0.1:8118";
  # enableVirtualboxHost = false;
  buildCores = 8;
  consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
}
