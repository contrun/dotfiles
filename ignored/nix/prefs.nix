{ ... }@args:
let
  fix = f: let x = f x; in x;
  extends = f: rattrs: self: let super = rattrs self; in super // f self super;

  prefFiles = [ ./prefs.local.nix ./prefs.secret.nix ];

  pkgs = let
    hasPkgs = args ? pkgs;
    hasInputs = args ? inputs;
    hasHostname = args ? hostname;
  in builtins.trace
  "calling prefs ${if hasPkgs then "with" else "without"} argument pkgs, ${
    if hasInputs then "with" else "without"
  } argument inputs, ${
    if hasHostname then
      ("with argument hostname " + args.hostname)
    else
      "without argument hostname"
  }" (args.pkgs or (import (args.inputs.nixpkgs-stable or <nixpkgs>) { }));

  hostname = args.hostname or (let
    # LC_CTYPE=C tr -dc 'a-z' < /dev/urandom | head -c3 | tee /tmp/hostname
    hostNameFiles = if builtins.pathExists "/tmp/nixos_bootstrap" then [
      /tmp/etc/hostname
      /mnt/etc/hostname
      /tmp/hostname
      /etc/hostname
    ] else
      [ /etc/hostname ];
    fs = builtins.filter (x:
      let e = builtins.pathExists x;
      in builtins.trace "hostname file ${x} exists? ${builtins.toString e}" e)
      hostNameFiles;
    f = builtins.elemAt fs 0;
    c = builtins.readFile f;
    l = builtins.match "([[:alnum:]]+)[[:space:]]*" c;
    newHostname = builtins.elemAt l 0;
  in builtins.trace "obtained new hostname ${newHostname} from disk"
  newHostname);
  hostId = let
    hash = builtins.trace ''
      Hashing hostname to get hostId by printf "%s" "hostname: ${hostname}" |  sha512sum''
      (builtins.hashString "sha512" "hostname: ${hostname}");
  in builtins.trace "Obtaining hash result ${hash}"
  (builtins.substring 0 8 hash);

  default = self: {
    isMinimalSystem = false;
    enableAarch64Cross = false;
    owner = "e";
    ownerUid = 1000;
    ownerGroup = "users";
    ownerGroupGid = 100;
    home = "/home/${self.owner}";
    nixosSystem = "x86_64-linux";
    getNixConfig = path: ./. + "/${path}";
    getDotfile = path: ./../.. + "/${path}";
    helpersPath = self.getNixConfig "lib/mkHelpers.nix";
    helpers = import self.helpersPath { inherit pkgs; };
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
    enableFallbackAccount = false;
    buildZerotierone = !self.isMinimalSystem;
    enableZerotierone = self.buildZerotierone;
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
    enableCfssl = false;
    enableSslh = true;
    sslhPort = 44443;
    enableTailScale = !self.isMinimalSystem;
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
    enableClashRedir = true;
    myPath = [ "${self.home}/.bin" ];
    enableOfflineimap = true;
    enableSyncthing = false;
    yandexConfig = {
      directory = "${self.home}/Sync";
      excludes = "";
      user = self.owner;
    };
    acmeEmail = "to_be_overridden@example.com";
    acmeMainDoamin = "";
    enableAcme = self.acmeMainDoamin != "";
    acmeCerts = if self.enableAcme then {
      "${self.acmeMainDoamin}" = {
        domain = "*.${self.acmeMainDoamin}";
        extraDomainNames =
          [ self.acmeMainDoamin "*.hub.${self.acmeMainDoamin}" ];
        dnsProvider = "cloudflare";
        credentialsFile = "/run/secrets/cloudflare-dns-api-token";
      };
    } else
      { };
    enableYandexDisk = self.nixosSystem == "x86_64-linux";
    yandexExcludedFiles = "docs/org-mode/roam/.emacs";
    enablePostgres = false;
    enableRedis = false;
    enableVsftpd = true;
    enableRsyncd = false;
    enableMpd = false;
    enableAccountsDaemon = true;
    enableFlatpak = false;
    enableXdgPortal = false;
    enableJupyter = false;
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
    linkedJdks = if self.isMinimalSystem then
      [ "openjdk8" ]
    else [
      "openjdk15"
      "openjdk14"
      "openjdk11"
      "openjdk8"
    ];
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
    enableDocker = !self.isMinimalSystem;
    enablePodman = true;
    replaceDockerWithPodman = !self.enableDocker;
    dockerStorageDriver = if self.enableZfs then "zfs" else "overlay2";
    enableLibvirtd = !self.isMinimalSystem;
    enableAnbox = false;
    enableUnifi = false;
    enableUdisks2 = true;
    enableAvahi = true;
    enableGvfs = true;
    enableCodeServer = !self.isMinimalSystem;
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
    kernelSysctl = {
      "fs.file-max" = 51200;
      "net.core.rmem_max" = 67108864;
      "net.core.wmem_max" = 67108864;
      "net.core.netdev_max_backlog" = 250000;
      "net.core.somaxconn" = 4096;
      "net.core.default_qdisc" = "fq";
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.tcp_tw_reuse" = 1;
      "net.ipv4.tcp_fin_timeout" = 30;
      "net.ipv4.tcp_keepalive_time" = 1200;
      "net.ipv4.ip_local_port_range" = "10000 65000";
      "net.ipv4.tcp_max_syn_backlog" = 8192;
      "net.ipv4.tcp_max_tw_buckets" = 5000;
      "net.ipv4.tcp_fastopen" = 3;
      "net.ipv4.tcp_mem" = "25600 51200 102400";
      "net.ipv4.tcp_rmem" = "4096 87380 67108864";
      "net.ipv4.tcp_wmem" = "4096 65536 67108864";
      "net.ipv4.tcp_mtu_probing" = 1;
      "net.ipv4.tcp_congestion_control" = "bbr";
      # https://github.com/springzfx/cgproxy/blob/aaa628a76b2911018fc93b2e3276c177e85e0861/readme.md#known-issues
      # Transparent proxy does not work with these options on.
      "net.bridge.bridge-nf-call-arptables" = 0;
      "net.bridge.bridge-nf-call-ip6tables" = 0;
      "net.bridge.bridge-nf-call-iptables" = 0;
      "vfs.usermount" = 1;
      "net.ipv4.igmp_max_memberships" = 256;
      "fs.inotify.max_user_instances" = 256;
      "fs.inotify.max_user_watches" = 524288;
      "kernel.kptr_restrict" = 0;
      "kernel.perf_event_paranoid" = 1;
    };
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
    let
      rtl8188gu =
        (self.kernelPackages.callPackage ./hardware/rtl8188gu.nix { });
    in {
      inherit hostname hostId;
    } // (if hostname == "default" then {
      isMinimalSystem = true;
    } else if hostname == "cicd" then {
      isMinimalSystem = true;
      enableJupyter = true;
    } else if hostname == "uzq" then {
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
      enableJupyter = true;
      enableX2goServer = true;
      enableHidpi = false;
      maxJobs = 6;
      enableCfssl = true;
      enableK3s = true;
      enableWireless = true;
      acmeEmail = "webmaster@${self.acmeMainDoamin}";
      acmeMainDoamin = "cont.run";
      extraModulePackages = [ rtl8188gu ];
      consoleFont = "${pkgs.terminus_font}/share/consolefonts/ter-g20n.psf.gz";
    } else if hostname == "jxt" then {
      hostId = "5ee92b8d";
      extraModulePackages = [ rtl8188gu ];
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
          maxJobs = 32;
          supportedFeatures = [ "kvm" "big-parallel" ];
        }
        {
          hostName = "node2";
          system = "x86_64-linux";
          maxJobs = 32;
          supportedFeatures = [ "kvm" "big-parallel" ];
        }
      ];
    } else if hostname == "shl" then {
      nixosSystem = "aarch64-linux";
      isMinimalSystem = true;
      hostId = "6fce2459";
      kernelPackages = pkgs.linuxPackages_rpi4;
      enableCodeServer = false;
      enableVirtualboxHost = false;
      enableGrub = false;
      isRaspberryPi = true;
      raspberryPiVersion = 4;
      enableVsftpd = false;
      # enableAarch64Cross = true;
    } else {
      isMinimalSystem = true; # set unknown host to be minimal system
    });

  overrides = builtins.map (path: (import (builtins.toPath path)))
    (builtins.filter (x: builtins.pathExists x) prefFiles);

  final = fix (builtins.foldl' (acc: override: extends override acc) default
    ([ hostSpecific ] ++ overrides));
in builtins.trace "final configuration for ${hostname}"
(builtins.trace final final)