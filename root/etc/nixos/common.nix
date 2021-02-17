{ config, pkgs, ... }:

with import ./pref.nix { inherit config pkgs; };
let
  importWithConfig = x: import x { config = config.nixpkgs.config; };
  importNixChannel = channel: importWithConfig (fetchNixChannel channel);
  nixChannelURL = channel:
    let
      # This currently only runs on nixos, as we possibly cannot read "/root/.nix-defexpr/channels"
      # We need some reliable way to get all available channel list.
      # isNixOS = builtins.pathExists /etc/NIXOS;
      isNixOS = true;
      prefix = if isNixOS then "nixos" else "nixpkgs";
      postfix = if (channel != "stable") then
        channel
      else
        (if isNixOS then nixosStableVersion else "unstable");
    in "https://nixos.org/channels/${prefix}-${postfix}";
  fetchNixChannel = channel:
    builtins.fetchTarball "${nixChannelURL channel}/nixexprs.tar.xz";
  importGithubNixPkgs = rev: importWithConfig (fetchGithubNixPkgs rev);
  fetchGithubNixPkgs = rev:
    builtins.fetchTarball
    "https://github.com/NixOS/nixpkgs/archive/${rev}.tar.gz";
  allChannels = let
    env = builtins.getEnv "HOME";
    root_home = if (env == "") then "/root" else env;
    list = builtins.readDir "${root_home}/.nix-defexpr/channels";
  in pkgs.lib.filterAttrs (n: v: n != "manifest.nix") list;
  stable = if allChannels ? "stable" then
    import <stable> { }
  else
    importNixChannel "stable";
  unstable = if allChannels ? "unstable" then
    import <unstable> { }
  else
    importNixChannel "unstable";
  nivSources = let file = "${home}/.config/nixpkgs/nix/sources.nix";
  in if (builtins.pathExists file) then import file else { };
  nivSourceOr = name: default:
    if nivSources ? name then nivSources.name else default;
  nivSourceOrFetchTarball = name: tarball:
    nivSourceOr name (builtins.fetchTarball tarball);
  sops-nix-import = "${
      nivSourceOrFetchTarball "sops-nix"
      "https://github.com/Mic92/sops-nix/archive/master.tar.gz"
    }/modules/sops";
  sops-secrets-file = "${home}/.config/nixpkgs/sops/secrets.yaml";
  enableSops = builtins.pathExists sops-secrets-file;
in {
  imports = (if enableSops then [ sops-nix-import ] else [ ])
    ++ (builtins.filter (x: builtins.pathExists x) [
      ./machine.nix
      ./cachix.nix
    ]);
  security = {
    sudo = { wheelNeedsPassword = false; };
    pki = {
      caCertificateBlacklist = [
        "WoSign"
        "WoSign China"
        "CA WoSign ECC Root"
        "Certification Authority of WoSign G2"
      ];
      certificateFiles = let
        mitmCA = let p = "${home}/.mitmproxy/mitmproxy-ca.pem";
        in pkgs.lib.optionals (builtins.pathExists p)
        [ (builtins.toFile "mitmproxy-ca.pem" (builtins.readFile p)) ];
        CAs = [ ];
      in mitmCA ++ CAs;
    };
    pam = {
      enableSSHAgentAuth = true;
      mount = {
        enable = true;
        extraVolumes = [
          ''<luserconf name=".pam_mount.conf.xml" />''
          ''
            <fusemount>${pkgs.fuse}/bin/mount.fuse %(VOLUME) %(MNTPT) "%(before=\"-o \" OPTIONS)"</fusemount>''
          "<fuseumount>${pkgs.fuse}/bin/fusermount -u %(MNTPT)</fuseumount>"
          "<path>${pkgs.fuse}/bin:${pkgs.coreutils}/bin:${pkgs.utillinux}/bin:${pkgs.gocryptfs}/bin</path>"
        ];
      };
      services."${owner}" = {
        fprintAuth = enableFprintAuth;
        limits = [
          {
            domain = "*";
            type = "hard";
            item = "nofile";
            value = "51200";
          }
          {
            domain = "*";
            type = "soft";
            item = "nofile";
            value = "51200";
          }
        ];
        enableGnomeKeyring = enableGnomeKeyring;
        pamMount = true;
        sshAgentAuth = true;
        setEnvironment = true;
      };
    };
  };

  networking = {
    hostName = hostname;
    hostId = hostId;
    wireless = {
      enable = enableSupplicant;
      # userControlled = { enable = true; };
      iwd.enable = enableIwd;
    };
    supplicant = pkgs.lib.optionalAttrs enableSupplicant {
      "WLAN" = {
        configFile = let
          myPath = "${home}/.config/wpa_supplicant/wpa_supplicant.conf";
          defaultPath = "/etc/wpa_supplicant.conf";
          path = if builtins.pathExists myPath then myPath else defaultPath;
        in {
          # TODO: figure out why this does not work.
          inherit (path)
          ;
          writable = true;
        };
      };
    };
    proxy.default = proxy;
    enableIPv6 = enableIPv6;
    extraHosts = let
      readHostsFile = p:
        pkgs.lib.optionalString (builtins.pathExists p) (builtins.readFile p);
      hostsFiles = [ "${home}/.hosts" "${home}/.hosts.tmp" ];
    in builtins.foldl' (a: p: a + (readHostsFile p)) "" hostsFiles;
  };

  console = {
    keyMap = let p = "${home}/.local/share/kbd/keymaps/personal.map";
    in if builtins.pathExists p then
      (builtins.toFile "personal-keymap" (builtins.readFile p))
    else
      "us";
    font = if consoleFont != null then
      consoleFont
    else if enableHidpi then
      "${pkgs.terminus_font}/share/consolefonts/ter-g28n.psf.gz"
    else
      "${pkgs.terminus_font}/share/consolefonts/ter-g16n.psf.gz";
  };

  i18n = {
    defaultLocale = "de_DE.UTF-8";
    supportedLocales = [
      "en_US.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "fr_FR.UTF-8/UTF-8"
      "zh_CN.UTF-8/UTF-8"
    ];
    inputMethod = {
      enabled = enabledInputMethod;
      ibus.engines = with pkgs.ibus-engines; [
        libpinyin
        table
        table-chinese
        table-others
      ];
      fcitx.engines = with pkgs.fcitx-engines; [
        libpinyin
        cloudpinyin
        rime
        table-extra
        table-other
      ];
    };
  };

  time = {
    timeZone = "Asia/Shanghai";
    hardwareClockInLocalTime = true;
  };

  environment = {
    etc = {
      "davfs2/secrets" = {
        enable = enableDavfs2 && builtins.pathExists davfs2Secrets;
        mode = "0600";
        source = davfs2Secrets;
      };
      hosts.mode = "0644";
    };

    extraOutputsToInstall = extraOutputsToInstall;
    systemPackages = with pkgs;
      builtins.filter (x: x != null) [
        manpages
        fuse
        iptables
        iproute
        ethtool
        nftables
        ipset
        dnsmasq
        nixFlakes
        nix-info
        nixos-generators
        niv
        nix-serve
        home-manager
        nixpkgs-fmt
        nixfmt
        nix-du
        nix-index
        nix-top
        # gnome3.adwaita-icon-theme
        gnome3.dconf
        gnome3.gsettings-desktop-schemas
        gnome3.zenity
        font-manager
        udiskie
        fzf
        jq
        virt-manager
        fdm
        mailutils
        notify-osd-customizable
        noti
        libnotify
        (pkgs.myPackages.lua or lua)
        gcc
        gnumake
        usbutils
        powertop
        fail2ban
        qemu
        ldns
        bind
        nix-prefetch-scripts
        pulsemixer
        acpilight
        xorg.xev
        xorg.libX11
        xorg.libXft
        xorg.libXpm
        xorg.libXinerama
        xorg.libXext
        xorg.libXrandr
        xorg.libXrender
        xorg.xorgproto
        libxkbcommon
        pixman
        wlroots
        libevdev
        wayland
        wayland-protocols
        python3
        # (pkgs.myPackages.pythonStable or python3)
        # (pkgs.myPackages.python2 or python2)
        (pkgs.myPackages.nvimpager or null)
        (pkgs.myPackages.nvimdiff or null)
        rofi
        ruby
        perl
        neovim
        vim
        libffi
        pciutils
        utillinux
        ntfs3g
        gparted
        gnupg
        pinentry
        atool
        atop
        bash
        zsh
        ranger
        gptfdisk
        curl
        at
        git
        chezmoi
        coreutils
        sudo
        gettext
        sxhkd
        mimeo
        libsecret
        gnome3.seahorse
        mlocate
        htop
        iotop
        iftop
        iw
        lsof
        age
        sops
        dmenu
        dmidecode
        dunst
        cachix
        e2fsprogs
        efibootmgr
        dbus
        linuxHeaders
        cryptsetup
        compton
        btrbk
        blueman
        bluez
        bluez-tools
        btrfs-progs
        exfat
        i3blocks
        i3-gaps
        i3lock
        i3status
        firefox
        rsync
        rclone
        sshfs
        termite
        xbindkeys
        xcape
        xautolock
        xdotool
        xlibs.xmodmap
        xmacro
        autokey
        xsel
        xvkbd
        fcron
        gmp
      ] ++ (if (enableTailScale) then [ tailscale ] else [ ])
      ++ (if (enableCodeServer) then [ code-server ] else [ ])
      ++ (if (currentSystem == "x86_64-linux") then [
        xmobar
        hardinfo
        steam-run-native
        aqemu
        wine
        kernelPackages.perf
        kernelPackages.bpftrace
        kernelPackages.bcc
      ] else
        [ ]);
    enableDebugInfo = enableDebugInfo;
    shellAliases = {
      ssh = "ssh -C";
      bc = "bc -l";
    };
    sessionVariables = pkgs.lib.optionalAttrs (enableSessionVariables) (rec {
      MYSHELL = if enableZSH then "zsh" else "bash";
      MYTERMINAL = "alacritty";
      GOPATH = "$HOME/.go";
      CABALPATH = "$HOME/.cabal";
      CARGOPATH = "$HOME/.cargo";
      NODE_PATH = "$HOME/.node";
      PERLBREW_ROOT = "$HOME/.perlbrew-root";
      LOCALBINPATH = "$HOME/.local/bin";
      # help building locally compiled programs
      LIBRARY_PATH = "$HOME/.nix-profile/lib:/run/current-system/sw/lib";
      # Don't set LD_LIBRARY_PATH here, there will be various problems.
      MY_LD_LIBRARY_PATH = "$HOME/.nix-profile/lib:/run/current-system/sw/lib";
      # cmake does not respect LIBRARY_PATH
      CMAKE_LIBRARY_PATH = "$HOME/.nix-profile/lib:/run/current-system/sw/lib";
      # Linking can sometimes fails because ld is unable to find libraries like libstdc++.
      # export LIBRARY_PATH="$LIBRARY_PATH:$CC_LIBRARY_PATH"
      CC_LIBRARY_PATH = "/local/lib";
      # header files
      CPATH = "$HOME/.nix-profile/include:/run/current-system/sw/include";
      C_INCLUDE_PATH =
        "$HOME/.nix-profile/include:/run/current-system/sw/include";
      CPLUS_INCLUDE_PATH =
        "$HOME/.nix-profile/include:/run/current-system/sw/include";
      CMAKE_INCLUDE_PATH =
        "$HOME/.nix-profile/include:/run/current-system/sw/include";
      # pkg-config
      PKG_CONFIG_PATH =
        "$HOME/.nix-profile/lib/pkgconfig:$HOME/.nix-profile/share/pkgconfig:/run/current-system/sw/lib/pkgconfig:/run/current-system/sw/share/pkgconfig";
      PATH = [ "$HOME/.bin" "$HOME/.local/bin" ]
        ++ (map (x: x + "/bin") [ CABALPATH CARGOPATH GOPATH ])
        ++ [ "${NODE_PATH}/node_modules/.bin" ] ++ [ "/usr/local/bin" ];
      LESS = "-F -X -R";
      EDITOR = "nvim";
    } // pkgs.lib.optionalAttrs (pkgs ? myPackages) {
      # export PYTHONPATH="$MYPYTHONPATH:$PYTHONPATH"
      MYPYTHONPATH = pkgs.myPackages.pythonPackages.makePythonPath
        [ pkgs.myPackages.python ];
      PAGER = "nvimpager";
    });
    variables = {
      # systemctl --user does not work without this
      # https://serverfault.com/questions/887283/systemctl-user-process-org-freedesktop-systemd1-exited-with-status-1/887298#887298
      # XDG_RUNTIME_DIR = ''/run/user/"$(id -u)"'';
    };
  };

  programs = {
    ccache = { enable = true; };
    java = { enable = enableJava; };
    gnupg.agent = { enable = enableGPGAgent; };
    ssh = { startAgent = true; };
    # vim.defaultEditor = true;
    adb.enable = enableADB;
    slock.enable = enableSlock;
    bash = { enableCompletion = true; };
    x2goserver = { enable = enableX2goServer; };
    zsh = {
      enable = enableZSH;
      enableCompletion = true;
      # ohMyZsh = {
      #   enable = true;
      # };
    };
    # light.enable = true;
    sway = {
      enable = true;
      extraPackages = with pkgs; [ swaylock swayidle alacritty dmenu ];
    };
    tmux = { enable = true; };
    wireshark.enable = enableWireshark;
  };

  fonts = {
    enableDefaultFonts = true;
    # fontDir.enable = true;
    fontconfig = { enable = true; };
    fonts = with pkgs; [
      wqy_microhei
      wqy_zenhei
      source-han-sans-simplified-chinese
      source-han-serif-simplified-chinese
      arphic-ukai
      arphic-uming
      noto-fonts-cjk
      inconsolata
      ubuntu_font_family
      hasklig
      fira-code
      fira-code-symbols
      cascadia-code
      jetbrains-mono
      corefonts
      source-code-pro
      source-sans-pro
      source-serif-pro
      noto-fonts-emoji
      lato
      line-awesome
      material-icons
      material-design-icons
      font-awesome
      font-awesome_4
      fantasque-sans-mono
      dejavu_fonts
      terminus_font
    ];
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  sound = {
    enable = true;
    mediaKeys = { enable = enableMediaKeys; };
  };

  nixpkgs = let
    cross = if enableAarch64Cross then rec {
      crossSystem = (import <nixpkgs>
        { }).pkgsCross.aarch64-multiplatform.stdenv.targetPlatform;
      localSystem = crossSystem;
    } else
      { };
    configAttr = {
      config = {
        allowUnfree = true;
        allowBroken = true;
        pulseaudio = true;
        experimental-features = "nix-command flakes";
      };
    };
    localPkgs = "${home}/Local/nixpkgs";
    pkgsAttr = if (builtins.pathExists "${localPkgs}/.useme") then {
      pkgs = import localPkgs { inherit (configAttr) config; };
    } else
      { };
    overlaysFile = "${home}/.config/nixpkgs/overlays.nix";
    overlaysAttr = if (builtins.pathExists overlaysFile) then {
      overlays = import overlaysFile;
    } else
      { };
  in overlaysAttr // pkgsAttr // configAttr // cross;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = false;
    };
    bumblebee = {
      enable = enableBumblebee;
      connectDisplay = true;
    };
    pulseaudio = {
      enable = true;
      package = pkgs.pulseaudioFull;
      support32Bit = true;
      systemWide = true;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
    };
    bluetooth = {
      enable = enableBluetooth;
      package = pkgs.bluezFull;
      powerOnBoot = enableBluetooth;
    };
    acpilight = { enable = enableAcpilight; };
  };

  location = {
    latitude = 39.55;
    longitude = 116.23;
  };

  system = {
    activationScripts = let
      jdks = builtins.filter (x: pkgs ? x) linkedJdks;
      addjdk = jdk:
        if pkgs ? jdk then
          let p = pkgs.${jdk}.home; in "ln -sfn ${p} /local/jdks/${jdk}"
        else
          "";
    in pkgs.lib.optionalAttrs (enableJava && jdks != [ ]) {
      jdks = {
        text = pkgs.lib.concatMapStringsSep "\n" addjdk jdks;
        deps = [ "local" ];
      };
    } // pkgs.lib.optionalAttrs nixosAutoUpgrade.enableHomeManager {
      addHomeManagerChannel = {
        text =
          "${config.nix.package.out}/bin/nix-channel --add ${nixosAutoUpgrade.homeManagerChannel} home-manager";
        deps = [ ];
      };
    } // {
      addNixosChannel = {
        text = if enableUnstableNixosChannel then
          "${config.nix.package.out}/bin/nix-channel --add https://nixos.org/channels/nixos-unstable nixos"
        else
          "${config.nix.package.out}/bin/nix-channel --add https://nixos.org/channels/nixos-${nixosStableVersion} nixos";
        deps = [ ];
      };
    } // {
      mkCcacheDirs = {
        text = "install -d -m 0777 -o root -g nixbld /var/cache/ccache";
        deps = [ ];
      };
      usrlocalbin = {
        text = "mkdir -m 0755 -p /usr/local/bin";
        deps = [ ];
      };
      local = {
        text =
          "mkdir -m 0755 -p /local/bin && mkdir -m 0755 -p /local/lib && mkdir -m 0755 -p /local/jdks";
        deps = [ ];
      };
      cclibs = {
        text =
          "cd /local/lib; for i in ${pkgs.gcc.cc.lib}/lib/*; do ln -sfn $i; done";
        deps = [ "local" ];
      };

      # Fuck /bin/bash
      binbash = {
        text = "ln -sfn ${pkgs.bash}/bin/bash /bin/bash";
        deps = [ "binsh" ];
      };

      # sftpman
      mntsshfs = {
        text = "install -d -m 0700 -o ${owner} -g ${ownerGroup} /mnt/sshfs";
        deps = [ ];
      };

      # rclone
      mntrclone = {
        text = "install -d -m 0700 -o ${owner} -g ${ownerGroup} /mnt/rclone";
        deps = [ ];
      };

      # Fuck pre-built dynamic binaries
      # copied from https://github.com/NixOS/nixpkgs/pull/69057
      ldlinux = {
        text = with pkgs.lib;
          concatStrings (mapAttrsToList (target: source: ''
            mkdir -m 0755 -p $(dirname ${target})
            ln -sfn ${escapeShellArg source} ${target}.tmp
            mv -f ${target}.tmp ${target} # atomically replace
          '') {
            "i686-linux"."/lib/ld-linux.so.2" =
              "${pkgs.glibc.out}/lib/ld-linux.so.2";
            "x86_64-linux"."/lib/ld-linux.so.2" =
              "${pkgs.pkgsi686Linux.glibc.out}/lib/ld-linux.so.2";
            "x86_64-linux"."/lib64/ld-linux-x86-64.so.2" =
              "${pkgs.glibc.out}/lib64/ld-linux-x86-64.so.2";
            "aarch64-linux"."/lib/ld-linux-aarch64.so.1" =
              "${pkgs.glibc.out}/lib/ld-linux-aarch64.so.1";
            "armv7l-linux"."/lib/ld-linux-armhf.so.3" =
              "${pkgs.glibc.out}/lib/ld-linux-armhf.so.3";
          }.${pkgs.stdenv.system} or { });
        deps = [ ];
      };

      # make some symlinks to /bin, just for convenience
      binShortcuts = {
        text = ''
          ln -sfn ${pkgs.neovim}/bin/nvim /usr/local/bin/nv
        '';
        deps = [ "binsh" "usrlocalbin" ];
      };

      addChannels = let
        add-channel = channel:
          "${config.nix.package.out}/bin/nix-channel --add ${
            nixChannelURL channel
          } ${channel}";
      in {
        text = pkgs.lib.concatMapStringsSep "\n" add-channel
          nixosAutoUpgrade.nixosChannelList;
        deps = [ ];
      };
    };
  };

  services = {
    arbtt = {
      enable = false;
      # enable = enableArbtt;
    };
    compton = { enable = true; };
    connman = { enable = enableConnman; };
    # calibre-server = {
    #   enable = enableCalibreServer;
    #   libraries = calibreServerLibraries;
    # };
    vsftpd = {
      enable = enableVsftpd;
      userlist = [ owner ];
      userlistEnable = true;
    };
    fcron = {
      enable = false;
      maxSerialJobs = 5;
      systab = "";
    };
    offlineimap = {
      enable = enableOfflineimap;
      install = true;
      path = [ pkgs.libsecret pkgs.dbus ];
    };
    davfs2 = { enable = enableDavfs2; };
    dnsmasq = {
      enable = enableDnsmasq;
      resolveLocalQueries = dnsmasqResolveLocalQueries;
      servers = dnsmasqServers;
      extraConfig = dnsmasqExtraConfig;
    };
    smartdns = {
      enable = enableSmartdns;
      settings = smartdnsSettings;
    };
    openssh = {
      enable = true;
      allowSFTP = true;
      forwardX11 = true;
      gatewayPorts = "yes";
      permitRootLogin = "yes";
      startWhenNeeded = true;
    };
    samba = {
      enable = enableSamba;
      extraConfig = ''
        workgroup = WORKGROUP
        security = user
      '';
      shares = {
        owner = {
          comment = "home folder";
          path = home;
          public = "no";
          writable = "yes";
          printable = "no";
          "create mask" = "0644";
          "force user" = owner;
          "force group" = "users";
        };
        data = {
          comment = "data folder";
          path = "/data";
          public = "no";
          writable = "yes";
          printable = "no";
          "create mask" = "0644";
          "force user" = owner;
          "force group" = "users";
        };
      };
    };
    privoxy = {
      enable = true;
      listenAddress = "0.0.0.0:8118";
      extraConfig = ''
        forward-socks5   /               127.0.0.1:1081 .
      '';
    };
    redshift = { enable = true; };
    avahi = {
      enable = enableAvahi;
      nssmdns = true;
      publish = {
        enable = true;
        userServices = true;
        addresses = true;
        domain = true;
        hinfo = true;
        workstation = true;
      };
      extraServiceFiles = (builtins.foldl' (a: t:
        a // {
          "${t}" = ''
            <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">${t} server at %h</name>
              <service>
                <type>_${t}._tcp</type>
                <port>22</port>
              </service>
            </service-group>
          '';
        }) { } [ "ssh" "sftp-ssh" ]) // {
          smb = ''
            <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
            <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
            <service-group>
              <name replace-wildcards="yes">samba server at %h</name>
              <service>
                <type>_smb._tcp</type>
                <port>445</port>
              </service>
            </service-group>
          '';
        };

    };
    nfs.server = {
      enable = true;
      extraNfsdConfig = ''
        udp=y
      '';
    };
    zfs = {
      autoScrub.enable = enableZfs;

      autoSnapshot = {
        enable = enableZfs;
        frequent = 8;
        hourly = 24;
        daily = 0;
        weekly = 0;
        monthly = 0;
      };
    };

    autossh = {
      sessions = pkgs.lib.optionals (enableAutossh && myLibs ? myAutossh) (let
        go = server:
          let
            sshPort = if enableSslh then sslhPort else 22;
            autosshPorts = myLibs.myAutossh {
              hostname = hostname;
              serverName = server;
            };
            extraArguments = let
              getReverseArgument = port:
                "-R :${builtins.toString port}:localhost:${
                  builtins.toString sshPort
                }";
              reversePorts = builtins.concatStringsSep " "
                (builtins.map (x: getReverseArgument x) autosshPorts);
            in "-o ServerAliveInterval=15 -o ServerAliveCountMax=4 -N ${reversePorts} ${server}";
          in {
            extraArguments = extraArguments;
            name = server;
            user = owner;
          };
      in map go autosshServers);
    };
    eternal-terminal = { enable = enableEternalTerminal; };
    printing = {
      enable = enablePrinting;
      drivers = [ pkgs.hplip ];
    };
    tailscale = { enable = enableTailScale; };
    system-config-printer.enable = enablePrinting;
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=ignore
      RuntimeDirectorySize=50%
    '';
    postfix = {
      enable = true;
      rootAlias = owner;
      extraConfig = ''
        myhostname = ${hostname}
        mydomain = localdomain
        mydestination = $myhostname, localhost.$mydomain, localhost
        mynetworks_style = host
      '';
    };
    postgresql.enable = enablePostgres;
    udisks2.enable = enableUdisks2;
    redis.enable = enableRedis;
    fail2ban.enable = enableFail2ban && config.networking.firewall.enable;
    mpd.enable = enbleMpd;
    # mosquitto.enable = true;
    rsyncd.enable = enableRsyncd;
    # accounts-daemon.enable = enableAccountsDaemon || enableFlatpak;
    flatpak.enable = enableFlatpak;
    thermald = { enable = enableThermald; };
    gnome3 = { gnome-keyring.enable = enableGnomeKeyring; };

    locate = {
      enable = enableLocate;
      locate = pkgs.mlocate;
      localuser = null;
      interval = "hourly";
      pruneBindMounts = true;
    };

    # change port
    # sudo chown -R e /etc/rancher/k3s/
    # k3s kubectl patch service traefik -n kube-system -p '{"spec": {"ports": [{"port": 443,"targetPort": 443, "nodePort": 30443, "protocol": "TCP", "name": "https"},{"port": 80,"targetPort": 80, "nodePort": 30080, "protocol": "TCP", "name": "http"}], "type": "LoadBalancer"}}'
    k3s = {
      enable = enableK3s;
      docker = true;
    };

    sslh = {
      enable = enableSslh;
      port = sslhPort;
      transparent = false;
      verbose = true;
    } // (let p = "${home}/.config/sslh/sslh.conf";
    in pkgs.lib.optionalAttrs (builtins.pathExists p) {
      appendConfig = (builtins.readFile p);
    });

    unifi.enable = enableUnifi;

    gvfs.enable = enableGvfs;

    emacs = {
      enable = enableEmacs;
      install = enableEmacs;
      package = pkgs.myPackages.emacs or pkgs.emacs;
    };

    syncthing = {
      enable = enableSyncthing;
      user = owner;
      group = "users";
      dataDir = home;
      systemService = false;
    };

    # yandex-disk = { enable = enableYandexDisk; } // yandexConfig;

    xserver = {
      enable = enableXserver;
      verbose = 7;
      autorun = true;
      exportConfiguration = true;
      layout = "us";
      dpi = dpi;
      libinput = {
        enable = enableLibInput;
        tapping = true;
        disableWhileTyping = true;
      };
      # videoDrivers = [ "dummy" ] ++ [ "intel" ];
      virtualScreen = {
        x = 1200;
        y = 1920;
      };
      xautolock = let
        locker = xautolockLocker;
        killer = xautolockKiller;
        notifier = xautolockNotifier;
      in {
        inherit locker killer notifier;
        enable = enableXautolock;
        enableNotifier = true;
        nowlocker = locker;
      };
      # desktopManager.xfce.enable = true;
      desktopManager.gnome3.enable = enableGnome;
      # desktopManager.plasma5.enable = true;
      # desktopManager.xfce.enableXfwm = false;
      windowManager = {
        i3.enable = true;
        awesome.enable = true;
      } // (if (enableXmonad) then {
        xmonad = {
          enable = true;
          enableContribAndExtras = true;
          extraPackages = haskellPackages:
            with haskellPackages; [
              xmobar
              # taffybar
              xmonad-contrib
              xmonad-extras
              xmonad-utils
              # xmonad-windownames
              xmonad-entryhelper
              yeganesh
              libmpd
              dbus
            ];
        };
      } else
        { });
      displayManager = let
        defaultSession = xDefaultSession;
        autoLogin = {
          enable = enableAutoLogin;
          user = owner;
        };
      in {
        sessionCommands = xSessionCommands;
        startx = { enable = xDisplayManager == "startx"; };
        sddm = {
          enable = xDisplayManager == "sddm";
          enableHidpi = enableHidpi;
          autoNumlock = true;
        };
        gdm = { enable = xDisplayManager == "gdm"; };
        lightdm = { enable = xDisplayManager == "lightdm"; };
      };
    };
  };

  # xdg.portal.enable = enableXdgPortal || enableFlatpak;

  users.users = let
    extraGroups = [
      "wheel"
      "video"
      "kvm"
      "libvirt"
      "audio"
      "disk"
      "networkmanager"
      "adbusers"
      "docker"
      "davfs2"
      "wireshark"
      "vboxusers"
      "lp"
      "input"
      "mlocate"
      "postfix"
    ];
  in {
    "${owner}" = {
      createHome = true;
      inherit extraGroups;
      group = ownerGroup;
      home = home;
      isNormalUser = true;
      uid = ownerUid;
      shell = if enableZSH then pkgs.zsh else pkgs.bash;
    };
    # Fallback user when "${owner}" encounters problems
    fallback = {
      createHome = true;
      inherit extraGroups;
      isNormalUser = true;
      useDefaultShell = true;
    };
  };

  users.groups."${ownerGroup}" = { gid = ownerGroupGid; };

  virtualisation = {
    libvirtd = { enable = enableLibvirtd; };
    virtualbox.host = {
      # package = stable.virtuablbox or pkgs.virtualbox;
      enable = enableVirtualboxHost;
      enableExtensionPack = enableVirtualboxHost;
      # enableHardening = false;
    };
    docker.enable = true;
    anbox = { enable = enableAnbox; };
  };
  # powerManagement = {
  #   enable = true;
  #   cpuFreqGovernor = "ondemand";
  # };

  systemd = let
    notify-systemd-unit-failures = let name = "notify-systemd-unit-failures";
    in {
      "${name}@" = {
        description = "notify systemd unit failures with mailutils";
        serviceConfig = {
          Type = "oneshot";
          ExecStart = ''
            ${pkgs.bash}/bin/bash -c "${pkgs.mailutils}/bin/mail --set=noASKCC --subject 'Systemd unit %i failed' ${owner} < /dev/null"
          '';
        };
      };
    };
  in {
    automounts = systemdMounts.autoMounts;
    mounts = systemdMounts.mounts;

    packages = let
      usrLocalPrefix = "/usr/local/lib/systemd/system";
      etcPrefix = "/etc/systemd/system";
      makeUnit = from: to: unit:
        pkgs.writeTextFile {
          name = builtins.replaceStrings [ "@" ] [ "__" ] unit;
          text = builtins.readFile "${from}/${unit}";
          destination = "${to}/${unit}";
        };
      getAllUnits = from: to:
        let
          files = builtins.readDir from;
          units = pkgs.lib.attrNames
            (pkgs.lib.filterAttrs (n: v: v == "regular" || v == "symlink")
              files);
          newUnits = map (unit: makeUnit from to unit) units;
        in pkgs.lib.optionals (builtins.pathExists from) newUnits;
    in getAllUnits usrLocalPrefix etcPrefix;

    timers = {
      nixos-update = {
        timerConfig = {
          OnCalendar = nixosAutoUpgrade.onCalendar;
          Unit = "nixos-update@.service";
          Persistent = true;
        };
      };
    };

    services = notify-systemd-unit-failures // {
      # copied from https://github.com/NixOS/nixpkgs/blob/7803ff314c707ee11a6d8d1c9ac4cde70737d22e/nixos/modules/tasks/auto-upgrade.nix#L72
      "nixos-update@" = {
        description = "NixOS Update";
        restartIfChanged = false;
        unitConfig = { X-StopOnRemoval = false; };
        serviceConfig.Type = "oneshot";

        environment = config.nix.envVars // {
          inherit (config.environment.sessionVariables) NIX_PATH;
          HOME = "/root";
          ARGS = "%I";
        } // config.networking.proxy.envVars;

        path = [
          pkgs.coreutils
          pkgs.gnutar
          pkgs.xz.bin
          pkgs.shadow.su
          pkgs.gitMinimal
          config.nix.package.out
          config.system.build.nixos-rebuild
          pkgs.niv
          pkgs.home-manager
          pkgs.chezmoi
        ];

        scriptArgs = "$ARGS";
        script = with nixosAutoUpgrade;
          let
            update-channels = ''
              nix-channel --update
            '';
            update-my-packages = pkgs.lib.optionalString updateMyPackages ''
              if cd "${home}/.local/share/chezmoi/dot_config/nixpkgs/"; then
                  su "${owner}" -c "niv update; chezmoi apply -v" || true
              fi
              if [[ -f "${home}/.local/share/chezmoi/root/chezmoi.toml" ]]; then
                  cd "${home}"
                  chezmoi -c "${home}/.local/share/chezmoi/root/chezmoi.toml" apply -v || true
              fi
            '';
            upgrade-system = if allowReboot then ''
              nixos-rebuild boot ${toString nixosRebuildFlags}
              booted="$(readlink /run/booted-system/{initrd,kernel,kernel-modules})"
              built="$(readlink /nix/var/nix/profiles/system/{initrd,kernel,kernel-modules})"
              if [ "$booted" = "$built" ]; then
                nixos-rebuild switch ${toString nixosRebuildFlags}
              else
                /run/current-system/sw/bin/shutdown -r +1
              fi
            '' else ''
              nixos-rebuild switch ${toString nixosRebuildFlags}
            '';
            update-home-manager = pkgs.lib.optionalString enableHomeManager ''
              su "${owner}" -c "nix-shell '<home-manager>' -A install" || true
              su "${owner}" -c "home-manager switch" || true
            '';
          in update-channels + update-my-packages + update-home-manager
          + upgrade-system;
      };
    } // pkgs.lib.optionalAttrs (enableK3s) {
      "k3s" = {
        serviceConfig = {
          ExecStartPost = [
            ''
              ${pkgs.k3s}/bin/k3s kubectl patch -n kube-system services traefik -p '{"spec":{"ports":[{"name":"http","nodePort":30080,"port":80,"protocol":"TCP","targetPort":"http"},{"name":"https","nodePort":30443,"port":443,"protocol":"TCP","targetPort":"https"}]}}'
                          ''
            ''
              ${pkgs.coreutils}/bin/chown ${owner} /etc/rancher/k3s/k3s.yaml
            ''
          ];
        };
      };
    } // pkgs.lib.optionalAttrs (enableCodeServer) {
      "code-server" = {
        enable = true;
        description = "Remote VSCode Server";
        after = [ "network.target" ];
        wantedBy = [ "multi-user.target" ];
        path = [ pkgs.go pkgs.git pkgs.direnv ];

        serviceConfig = {
          Type = "simple";
          ExecStart =
            "${pkgs.code-server}/bin/code-server --user-data-dir ${home}/.vscode --disable-telemetry";
          WorkingDirectory = home;
          NoNewPrivileges = true;
          User = owner;
          Group = ownerGroup;
        };
      };
    };

    user = let
      ddns = let
        name = "ddns";
        unitName = "${name}@";
        script = pkgs.writeShellScript "ddns" ''
          set -xe
          host="''${host:-$(hostname)}"
          if [[ -n "$1" ]] && [[ "$1" != "default" ]]; then host="$1"; fi
          base="''${base:-example.com}"
          domain="$host.$base"
          password="''${password:-simpelPassword}"
          interfaces="$(ip link show up | awk -F'[ :]' '/MULTICAST/&&/LOWER_UP/ {print $3}')"
          ipAddr="$(parallel -k -r -v upnpc -m {1} -s ::: $interfaces 2>/dev/null | awk '/ExternalIPAddress/ {print $3}' | head -n1 || true)"
          if [[ -z "$ipAddr" ]]; then ipAddr="$(curl -s myip.ipip.net | perl -pe 's/.*?([0-9]{1,3}.*[0-9]{1,3}?).*/\1/g')"; fi
          curl "https://dyn.dns.he.net/nic/update?hostname=$domain&password=$password&myip=$ipAddr"
          ipv6Addr="$(ip -6 addr show scope global primary | grep -v mngtmpaddr | awk '/inet6/ {print $2}' | head -n1 | awk -F/ '{print $1}')"
          if [[ -n "$ipv6Addr" ]]; then curl "https://dyn.dns.he.net/nic/update?hostname=$domain&password=$password&myip=$ipv6Addr"; fi
        '';
      in {
        services.${unitName} = {
          description = "ddns worker";
          enable = enableDdns;
          wantedBy = [ "default.target" ];
          path = [
            pkgs.coreutils
            pkgs.inetutils
            pkgs.parallel
            pkgs.miniupnpc
            pkgs.iproute
            pkgs.gawk
            pkgs.perl
            pkgs.curl
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${script} %i";
            EnvironmentFile = "%h/.config/ddns/env";
          };
        };
        timers.${unitName} = {
          enable = enableDdns;
          wantedBy = [ "default.target" ];
          onFailure = [ "notify-systemd-unit-failures@%i.service" ];
          timerConfig = {
            OnCalendar = "*-*-* *:2/10:43";
            Unit = "${unitName}%i.service";
            Persistent = true;
          };
        };
      };

      nextcloud-client = {
        services.nextcloud-client = {
          enable = enableNextcloudClient;
          description = "nextcloud client";
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Restart = "always";
            EnvironmentFile = "%h/.config/Nextcloud/env";
          };
          path = [ pkgs.nextcloud-client pkgs.inotify-tools ];
          script = ''
            mkdir -p "$HOME/$localFolder"
            while true; do
                  nextcloudcmd --non-interactive --silent --user "$user" --password "$password" "$localFolder" "$remoteUrl" || true
                  inotifywait -t 120 "$localFolder" > /dev/null 2>&1 || true
            done
          '';
        };
      };

      hole-puncher = let
        name = "hole-puncher";
        unitName = "${name}@";
        script = pkgs.writeShellScript "hole-puncher" ''
          set -eu
          instance="${builtins.toString sslhPort}-${builtins.toString sslhPort}"
          if [[ -n "$1" ]] && grep -Eq '[0-9]+-[0-9]+' <<< "$1"; then instance="$1"; fi
          externalPort="$(awk -F- '{print $2}' <<< "$instance")"
          internalPort="$(awk -F- '{print $1}' <<< "$instance")"
          interfaces="$(ip link show up | awk -F'[ :]' '/MULTICAST/&&/LOWER_UP/ {print $3}' | grep -v veth)"
          ipAddresses="$(parallel -k ip addr show dev {1} ::: $interfaces | grep -Po 'inet \K[\d.]+')"
          protocols="tcp udp"
          result="$(parallel -r -v upnpc -m {1} -a {2} $internalPort $externalPort {3} ::: $interfaces :::+ $ipAddresses ::: $protocols || true)"
          awk -v OFS=, '/is redirected to/ {print $2, $8, $3}' <<< "$result"
        '';
      in {
        services.${unitName} = {
          description = "NAT traversal worker";
          enable = enableHolePuncher && enableSslh;
          wantedBy = [ "default.target" ];
          path = [
            pkgs.coreutils
            pkgs.parallel
            pkgs.miniupnpc
            pkgs.iproute
            pkgs.gawk
          ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${script} %i";
          };
        };
        timers.${unitName} = {
          enable = enableHolePuncher;
          wantedBy = [ "default.target" ];
          onFailure = [ "notify-systemd-unit-failures@%i.service" ];
          timerConfig = {
            OnCalendar = "*-*-* *:3/20:00";
            Unit = "${unitName}%i.service";
            Persistent = true;
          };
        };
      };

      task-warrior-sync = let name = "task-warrior-sync";
      in {
        services.${name} = {
          description = "sync task warrior tasks";
          enable = enableTaskWarriorSync;
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.taskwarrior}/bin/task synchronize";
          };
        };
        timers.${name} = {
          enable = enableTaskWarriorSync;
          onFailure = [ "notify-systemd-unit-failures@%i.service" ];
          wantedBy = [ "default.target" ];
          timerConfig = {
            OnCalendar = "*-*-* *:1/3:00";
            Unit = "${name}.service";
            Persistent = true;
          };
        };
      };

      yandex-disk = let
        name = "yandex-disk";
        syncFolder = "${home}/Sync";
      in if enableYandexDisk then {
        services.${name} = {
          enable = true;
          description = "Yandex-disk server";
          onFailure = [ "notify-systemd-unit-failures@%i.service" ];
          after = [ "network.target" ];
          wantedBy = [ "default.target" ];
          unitConfig.RequiresMountsFor = syncFolder;
          serviceConfig = {
            Restart = "always";
            ExecStart =
              "${pkgs.yandex-disk}/bin/yandex-disk start --no-daemon --dir='${syncFolder}'";
          };
        };
      } else
        { };

      all = [
        { services = notify-systemd-unit-failures; }
        ddns
        nextcloud-client
        hole-puncher
        task-warrior-sync
        yandex-disk
      ];
    in builtins.foldl' (a: e: pkgs.lib.recursiveUpdate a e) { } all;
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions =
      pkgs.lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes";
    binaryCaches = [
      "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store"
      "https://cache.nixos.org"
      "https://hydra.iohk.io"
    ];
    binaryCachePublicKeys = [
      "hydra.iohk.io:f/Ea+s+dFdN+3Y/G+FDgSq+a5NEWhJGzdjvKNGv0/EQ=" # cardano
      "ryantrinkle.com-1:JJiAKaRv9mWgpVAz8dwewnZe0AzzEAzPkagE9SP5NWI=" # reflex
    ];
    buildCores = buildCores;
    maxJobs = maxJobs;
    useSandbox = "relaxed";
    gc = {
      automatic = true;
      options = "--delete-older-than 60d";
    };
    optimise = { automatic = true; };
    autoOptimiseStore = true;
  };

  boot = {
    binfmt = {
      emulatedSystems =
        if (currentSystem == "x86_64-linux") then [ "aarch64-linux" ] else [ ];
    };
    kernelParams = [ "boot.shell_on_fail" "iommu=pt" "iommu=1" ];
    kernelPackages = kernelPackages;
    kernelPatches = kernelPatches;
    kernel.sysctl = {
      "fs.file-max" = 51200;
      "net.core.rmem_max" = 67108864;
      "net.core.wmem_max" = 67108864;
      "net.core.netdev_max_backlog" = 250000;
      "net.core.somaxconn" = 4096;
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
      "net.core.default_qdisc" = "fq";
      "vfs.usermount" = 1;
      "kernel.kptr_restrict" = 0;
      "kernel.perf_event_paranoid" = 1;
    };
    loader = {
      efi.canTouchEfiVariables = false;
    } // (if enableGrub then {
      grub = {
        enable = true;
        copyKernels = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        enableCryptodisk = true;
        useOSProber = true;
      };
    } else
      { }) // (if isRaspberryPi then {
        raspberryPi = {
          enable = true;
          version = raspberryPiVersion;
        };
      } else
        { });

    supportedFilesystems = if (enableZfs) then [ "zfs" ] else [ ];
    zfs = { enableUnstable = enableZfsUnstable; };
    crashDump = { enable = enableCrashDump; };
    initrd.network = {
      enable = true;
      ssh = let
        f = "${home}/.ssh/authorized_keys";
        authorizedKeys = pkgs.lib.optionals (builtins.pathExists f)
          (builtins.filter (x: x != "")
            (pkgs.lib.splitString "\n" (builtins.readFile f)));
        hostKeys = builtins.filter (x: builtins.pathExists x) [
          "${home}/.local/secrets/initrd/ssh_host_rsa_key"
          "${home}/.local/secrets/initrd/ssh_host_ed25519_key"
        ];
      in {
        inherit authorizedKeys hostKeys;
        enable = false && enableBootSSH && authorizedKeys != [ ] && hostKeys
          != [ ];
      };
    };
  };
  system.stateVersion = nixosStableVersion;
} // (if enableSops then {
  sops = {
    validateSopsFiles = false;
    defaultSopsFile = "${builtins.path {
      name = "sops-secrets";
      path = sops-secrets-file;
    }}";
    secrets = {
      hello = {
        mode = "0440";
        owner = owner;
        group = ownerGroup;
      };
    };
  };
} else
  { })
