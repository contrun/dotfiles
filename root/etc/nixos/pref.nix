{ ... }@args:
let
  fix = f: let x = f x; in x;
  extends = f: rattrs: self: let super = rattrs self; in super // f self super;

  prefFiles = [ ./override.nix ];

  hasPkgs = args ? pkgs;
  pkgs = builtins.trace
    "Calling pref ${if hasPkgs then "with" else "without"} argument pkgs"
    (args.pkgs or (import <nixpkgs> { }));

  hasHostname = args ? hostname;
  hostname = builtins.trace "Calling pref ${
      if hasHostname then
        ("with argument hostname " + args.hostname)
      else
        "without argument hostname"
    }" (args.hostname or (let
      # LC_CTYPE=C tr -dc 'a-z' < /dev/urandom | head -c3 | tee /tmp/hostname
      hostNameFiles = if builtins.pathExists "/tmp/nixos_bootstrap" then [
        /tmp/etc/hostname
        /mnt/etc/hostname
        /tmp/hostname
        /etc/hostname
      ] else
        [ /etc/hostname ];
      fs = builtins.filter (x: builtins.pathExists x) hostNameFiles;
      f = builtins.elemAt fs 0;
      c = builtins.readFile f;
      l = builtins.match "([[:alnum:]]+)[[:space:]]*" c;
    in builtins.elemAt l 0));
  hostId = let
    hash = builtins.trace ''
      Hashing hostname to get hostId by printf "%s" "hostname: ${hostname}" |  sha512sum''
      (builtins.hashString "sha512" "hostname: ${hostname}");
  in builtins.trace "Obtaining hash result ${hash}"
  (builtins.substring 0 8 hash);

  default = self: {
    isBootStrapping = false; # Things fail.
    enableAarch64Cross = false;
    owner = "e";
    ownerUid = 1000;
    ownerGroup = "users";
    ownerGroupGid = 100;
    home = "/home/${self.owner}";
    nixosSystem = "x86_64-linux";
    myLibsPath = "${self.home}/.config/nixpkgs/libs";
    myLibs = if (builtins.pathExists self.myLibsPath) then
      (import self.myLibsPath)
    else
      { };
    consoleFont = null;
    hostname = "hostname";
    hostId = "346b7a87";
    enableSessionVariables = true;
    dpi = 144;
    enableHidpi = true;
    enableIPv6 = true;
    enableGrub = true;
    isRaspberryPi = false;
    # wirelessBackend = "wpa_supplicant";
    wirelessBackend = "iwd";
    enableSupplicant = self.wirelessBackend == "wpa_supplicant";
    enableConnman = false;
    enableWireless = self.enableSupplicant;
    enableIwd = self.wirelessBackend == "iwd";
    enableBumblebee = false;
    enableMediaKeys = true;
    enableEternalTerminal = true;
    enableSmartdns = false;
    enablePrivoxy = false;
    buildZerotierone = true;
    enableZerotierone = true;
    zerotieroneNetworks = [ "9bee8941b5ce6172" ];
    smartdnsSettings = {
      bind = ":5533 -no-rule -group example";
      cache-size = 4096;
      server = [ "180.76.76.76" "223.5.5.5" ] ++ [ "9.9.9.9" ]
        ++ [ "192.0.2.2:53" ];
      server-tls = [ "8.8.8.8:853" "1.1.1.1:853" ];
      server-https =
        "https://cloudflare-dns.com/dns-query -exclude-default-group";
      prefetch-domain = true;
      speed-check-mode = "ping,tcp:80";
      log-level = "info";
    };
    enableSslh = true;
    sslhPort = 44443;
    enableTailScale = true;
    enableX2goServer = false;
    enableDebugInfo = false;
    enableZfs = true;
    enableZfsUnstable = false;
    enableCrashDump = false;
    enableDnsmasq = false;
    dnsmasqListenAddress = "127.0.0.233";
    dnsmasqResolveLocalQueries = false;
    dnsmasqExtraConfig = ''
      listen-address=${self.dnsmasqListenAddress}
      bind-interfaces
      cache-size=1000
    '';
    dnsmasqServers = [ "223.6.6.6" "180.76.76.76" "8.8.8.8" "9.9.9.9" ];
    enableArbtt = false;
    xWindowManager =
      if (self.nixosSystem == "x86_64-linux") then "xmonad" else "i3";
    xDefaultSession = "none+" + self.xWindowManager;
    enableXmonad = self.xWindowManager == "xmonad";
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
      # systemctl --user start ddns &
      # sudo iw dev wlp2s0 set power_save off &
      # ibus-daemon -drx &
      copyq &
      # # libinput-gestures-setup start &
      # autoMount.sh &
      # startupHosts.sh &
      sxhkd -c ~/.config/sxhkd/sxhkdrc &
    '';
    # xSessionCommands = "";
    xDisplayManager = "lightdm";
    buildCores = 0;
    maxJobs = "auto";
    proxy = null;
    myPath = [ "${self.home}/.bin" ];
    enableOfflineimap = true;
    enableSyncthing = false;
    yandexConfig = {
      directory = "${self.home}/Sync";
      excludes = "";
      user = self.owner;
    };
    enableYandexDisk = self.nixosSystem == "x86_64-linux";
    yandexExcludedFiles = "docs/org-mode/roam/.emacs";
    enablePostgres = false;
    enableRedis = false;
    enableVsftpd = true;
    enableRsyncd = false;
    enbleMpd = false;
    enableAccountsDaemon = true;
    enableFlatpak = false;
    enableXdgPortal = false;
    enableJupyter = true;
    enableEmacs = true;
    enableLocate = true;
    enableFail2ban = true;
    davfs2Secrets = "${self.home}/.davfs2/secrets";
    enableDavfs2 = true;
    enableSamba = true;
    enableK3s = false;
    buildMachines = [ ];
    distributedBuilds = true;
    enableNextcloud = false;
    enableYandex = false;
    nextcloudWhere = "/nc/sync";
    nextcloudWhat = "https://uuuuuu.ocloud.de/remote.php/webdav/sync/";
    yandexWhere = "${self.home}/yandex";
    yandexWhat = "https://webdav.yandex.com/sync/";
    enableXserver = true;
    enableXautolock = self.enableXserver;
    enableGPGAgent = true;
    enableADB = self.nixosSystem == "x86_64-linux";
    enableCalibreServer = true;
    calibreServerLibraries = [ "${self.home}/Storage/Calibre" ];
    calibreServerPort = 8213;
    enableSlock = true;
    enableZSH = true;
    enableJava = true;
    enableCcache = true;
    enableFirewall = false;
    enableCompton = false;
    enableFcron = false;
    enableRedshift = false;
    enablePostfix = true;
    enableNfs = true;
    linkedJdks = [ "openjdk15" "openjdk14" "openjdk11" "openjdk8" ];
    enableNextcloudClient = false;
    enableTaskWarriorSync = true;
    enableHolePuncher = true;
    enableDdns = true;
    enableWireshark = true;
    enabledInputMethod = "fcitx";
    # enableVirtualboxHost = true;
    # Build of virtual box frequently fails. touching "$HOME/.cache/disable_virtual_box"
    # is less irritating than editing this file.
    enableVirtualboxHost = false;
    enableLibvirtd = true;
    enableAnbox = false;
    enableUnifi = false;
    enableUdisks2 = true;
    enableAvahi = true;
    enableGvfs = true;
    enableCodeServer = true;
    enablePrinting = true;
    enableBluetooth = true;
    enableAcpilight = true;
    enableThermald = false;
    enableAutoUpgrade = true;
    autoUpgradeChannel = "https://nixos.org/channels/nixos-unstable";
    enableAutossh = true;
    autosshServers = with pkgs.lib;
      let
        configFiles = [ "${self.home}/.ssh/config" ];
        goodConfigFiles =
          builtins.filter (x: builtins.pathExists x) configFiles;
        lines = builtins.foldl' (a: e: a ++ (splitString "\n" (readFile e))) [ ]
          goodConfigFiles;
        autosshLines = filter (x: hasPrefix "Host autossh" x) lines;
        servers = map (x: removePrefix "Host " x) autosshLines;
      in filter (x: x != "autossh") servers;
    enableAutoLogin = true;
    enableLibInput = true;
    enableFprintAuth = false;
    enableBootSSH = true;
    enableGnome = false;
    enableGnomeKeyring = false;
    emulatedSystems =
      if (self.nixosSystem == "x86_64-linux") then [ "aarch64-linux" ] else [ ];
    extraModulePackages = [ ];
    kernelPatches = [ ];
    kernelParams = [ "boot.shell_on_fail" ];
    kernelPackages = pkgs.linuxPackages_latest;
    networkingInterfaces = { };
    nixosStableVersion = "20.09";
    enableUnstableNixosChannel = false;
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

  hostSpecific = self: super:
    {
      inherit hostname hostId;
    } // (if hostname == "uzq" then {
      enableHidpi = true;
      # enableAnbox = true;
      consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
      hostId = "80d17333";
      enableX2goServer = true;
      # kernelPatches = [{
      #   # See https://github.com/NixOS/nixpkgs/issues/91367
      #   name = "anbox-kernel-config";
      #   patch = null;
      #   extraConfig = ''
      #     CONFIG_ASHMEM=y
      #     CONFIG_ANDROID=y
      #     CONFIG_ANDROID_BINDER_IPC=y
      #     CONFIG_ANDROID_BINDERFS=y
      #     CONFIG_ANDROID_BINDER_DEVICES="binder,hwbinder,vndbinder"
      #   '';
      # }];
    } else if hostname == "ssg" then {
      hostId = "034d2ba3";
      dpi = 128;
      enableX2goServer = true;
      enableHidpi = false;
      enableK3s = true;
      enableWireless = true;
      consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
    } else if hostname == "jxt" then {
      hostId = "5ee92b8d";
      enableHolePuncher = false;
      enableAutossh = false;
      enablePrinting = false;
      enableEternalTerminal = false;
      enableCodeServer = false;
      enablePostfix = false;
      # enableCrashDump = true;
      enableZerotierone = false;
      # enableTailScale = false;
      buildMachines = super.buildMachines ++ [
        {
          hostName = "node1";
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" "big-parallel" ];
        }
        {
          hostName = "node2";
          system = "x86_64-linux";
          supportedFeatures = [ "kvm" "big-parallel" ];
        }
      ];
    } else if hostname == "shl" then {
      nixosSystem = "aarch64-linux";
      hostId = "6fce2459";
      kernelPackages = pkgs.linuxPackages_rpi4;
      enableCodeServer = false;
      enableVirtualboxHost = false;
      enableGrub = false;
      isRaspberryPi = true;
      raspberryPiVersion = 4;
      enableVsftpd = false;
      enableAarch64Cross = self.isBootStrapping;
    } else
      { });

  overrides = builtins.map (path: (import (builtins.toPath path)))
    (builtins.filter (x: builtins.pathExists x) prefFiles);

  final = fix (builtins.foldl' (acc: override: extends override acc) default
    ([ hostSpecific ] ++ overrides));
in builtins.trace final final
