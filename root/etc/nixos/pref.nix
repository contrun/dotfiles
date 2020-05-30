{ ... }@args:
let
  pkgs = args.pkgs or (import <nixpkgs> { });
  config = args.config or args.pkgs.config or pkgs.config;
  myArgs = args // {
    pkgs = pkgs;
    config = config;
  };
  defaults = rec {
    isBootStrapping = false; # Things fail.
    owner = "e";
    ownerUid = 1000;
    ownerGroup = "users";
    ownerGroupGid = 100;
    home = "/home/${owner}";
    myLibsPath = "${home}/.config/nixpkgs/libs";
    myLibs = pkgs.lib.optionalAttrs (builtins.pathExists myLibsPath)
      (import myLibsPath);
    consoleFont = null;
    hostname = "hostname";
    hostId = "346b7a87";
    dpi = 144;
    enableHidpi = true;
    enableIPv6 = true;
    wirelessBackend = "iwd";
    enableSupplicant = wirelessBackend == "wpa_supplicant";
    enableWireless = enableSupplicant;
    enableIwd = wirelessBackend == "iwd";
    enableBumblebee = false;
    enableMediaKeys = true;
    enableDnsmasq = false;
    enableDebugInfo = false;
    dnsmasqListenAddress = "127.0.0.233";
    dnsmasqResolveLocalQueries = false;
    dnsmasqExtraConfig = ''
      listen-address=${dnsmasqListenAddress}
      bind-interfaces
      cache-size=1000
    '';
    dnsmasqServers = [ "223.6.6.6" "180.76.76.76" "8.8.8.8" "9.9.9.9" ];
    enableArbtt = true;
    myWindowManager = "xmonad";
    myDefaultSession = "none+" + myWindowManager;
    xSessionCommands = ''
      # echo "$(date -R): $@" >> ~/log
      # . ~/.xinitrc &
      keymap.sh &
      dunst &
      # alacritty &
      terminalLayout.sh 3 &
      feh --bg-fill "$(shuf -n1 -e ~/Storage/wallpapers/*)" &
      # shadowsocksControl.sh restart 4 1 &
      # systemctl --user start syncthing &
      systemctl --user start ddns &
      # sudo iw dev wlp2s0 set power_save off &
      # ibus-daemon -drx &
      copyq &
      # # libinput-gestures-setup start &
      # autoMount.sh &
      # startupHosts.sh &
      sxhkd -c ~/.config/sxhkd/sxhkdrc &
    '';
    myDisplayManager = "lightdm";
    buildCores = 0;
    maxJobs = 6;
    proxy = null;
    myPath = [ "${home}/.bin" ];
    enableOfflineimap = true;
    enableSyncthing = false;
    yandexConfig = let myConfig = "${home}/.config/yandex-disk/config.json";
    in {
      directory = "${home}/Sync";
      excludes = "";
      user = owner;
    } // pkgs.lib.optionalAttrs (builtins.pathExists myConfig)
    (builtins.fromJSON (pkgs.lib.readFile myConfig));
    enableYandexDisk = yandexConfig ? "username" && yandexConfig ? "password";
    enablePostgres = false;
    enableRedis = false;
    enableRsyncd = false;
    enbleMpd = false;
    enableAccountsDaemon = true;
    enableFlatpak = false;
    enableXdgPortal = false;
    enableJupyter = true;
    enableEmacs = true;
    enableLocate = true;
    enableFail2ban = true;
    davfs2Secrets = "${home}/.davfs2/secrets";
    enableDavfs2 = true;
    systemdMounts = let
      enableNextcloud = true;
      enableYandex = false;
      nextcloudWhere = "/nc/sync";
      nextcloudWhat = "https://uuuuuu.ocloud.de/remote.php/webdav/sync/";
      yandexWhere = "${home}/yandex";
      yandexWhat = "https://webdav.yandex.com/sync/";
    in {
      autoMounts = let
        nextcloud = {
          enable = enableNextcloud;
          description = "Automount nextcloud sync directory.";
          where = nextcloudWhere;
          wantedBy = [ "multi-user.target" ];
        };
        yandex = {
          enable = enableYandex;
          description = "Automount yandex sync directory.";
          where = yandexWhere;
          wantedBy = [ "multi-user.target" ];
        };
      in [ nextcloud yandex ];
      mounts = let
        nextcloud = {
          enable = enableNextcloud;
          where = nextcloudWhere;
          what = nextcloudWhat;
          type = "davfs";
          options = "rw,uid=${builtins.toString ownerUid},gid=${
              builtins.toString ownerGroupGid
            }";
          wants = [ "network-online.target" ];
          wantedBy = [ "remote-fs.target" ];
          after = [ "network-online.target" ];
          unitConfig = { path = [ pkgs.utillinux ]; };
        };
        yandex = {
          enable = enableYandex;
          where = yandexWhere;
          what = yandexWhat;
          type = "davfs";
          options = "rw,user=uid=${builtins.toString ownerUid},gid=${
              builtins.toString ownerGroupGid
            }";
          wants = [ "network-online.target" ];
          wantedBy = [ "remote-fs.target" ];
          after = [ "network-online.target" ];
          unitConfig = { paths = [ pkgs.utillinux ]; };
        };
      in [ nextcloud yandex ];
    };
    enableXserver = true;
    enableXautolock = enableXserver;
    xautolockLocker = "${pkgs.i3lock}/bin/i3lock";
    xautolockKiller = "${pkgs.systemd}/bin/systemctl suspend";
    xautolockNotifier =
      ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
    enableGPGAgent = true;
    enableADB = true;
    enableCalibreServer = true;
    calibreServerLibraryDir = "${home}/Storage/Calibre";
    calibreServerPort = 8213;
    enableSlock = true;
    enableZSH = true;
    enableNextcloudClient = false;
    enableWireshark = true;
    enabledInputMethod = "fcitx";
    enableVirtualboxHost = true;
    enableLibvirtd = true;
    enableUnifi = false;
    enableUdisks2 = true;
    enableAvahi = true;
    enableGvfs = true;
    enablePrinting = true;
    enableBluetooth = true;
    enableAcpilight = true;
    enableThermald = false;
    enableAutoUpgrade = true;
    autoUpgradeChannel = "https://nixos.org/channels/nixos-unstable";
    autosshServers = with pkgs.lib;
      let
        lines = splitString "\n" (readFile "${home}/.ssh/config");
        autosshLines = filter (x: hasPrefix "Host autossh" x) lines;
        servers = map (x: removePrefix "Host " x) autosshLines;
      in filter (x: x != "autossh") servers;
    enableAutoLogin = true;
    enableLibInput = true;
    enableFprintAuth = false;
    enableBootSSH = true;
    enableGnomeKeyring = false;
    networkingInterfaces = { };
    nixosStableVersion = "20.03";
    nixosAutoUpgrade = {
      nixosChannelList = [ "stable" "unstable" "unstable-small" ];
      homeManagerChannel =
        "https://github.com/rycee/home-manager/archive/master.tar.gz";
      enableHomeManager = true;
      updateMyPackages = true;
      allowReboot = false;
      nixosRebuildFlags = [ ];
      onCalendar = "04:30";
    };
    extraOutputsToInstall = [ "dev" "lib" "doc" "info" "devdoc" ];
  };
  hostSpecific = let
    hostname = let
      # LC_CTYPE=C tr -dc 'a-z' < /dev/urandom | head -c3 | tee /tmp/hostname
      hostNameFiles = [ /etc/hostname /tmp/hostname ];
      fs = builtins.filter (x: builtins.pathExists x) hostNameFiles;
      f = builtins.elemAt fs 0;
      c = builtins.readFile f;
      l = builtins.match "([[:alnum:]]+)[[:space:]]*" c;
    in builtins.elemAt l 0;
    hash = builtins.hashString "sha512" "hostname: ${hostname}";
    hostId = builtins.substring 0 7 hash;
  in {
    inherit hostname hostId;
  } // (if hostname == "uzq" then {
    enableHidpi = true;
    hostId = "80d17333";
  } else if hostname == "ssg" then {
    hostId = "034d2ba3";
    dpi = 128;
    enableHidpi = false;
    enableIPv6 = false;
    enableWireless = true;
    consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
  } else
    { });
  prefFiles = [ "/etc/nixos/override.nix" ];
  effectiveFiles = builtins.filter (x: builtins.pathExists x) prefFiles;
  readPref = path: (import (builtins.toPath path)) myArgs;
in defaults // hostSpecific
// (builtins.foldl' (accumulator: path: accumulator // readPref path) { }
  effectiveFiles)
