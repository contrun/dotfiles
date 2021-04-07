{ config, pkgs, inputs, ... }@args:
let
  prefs = import ./prefs.nix args;
  stable = pkgs.stable;
  unstable = pkgs.unstable;
  impure = {
    mitmproxyCAFile = "${prefs.home}/.mitmproxy/mitmproxy-ca.pem";
    wpaSupplicantConfigFile =
      "${prefs.home}/.config/wpa_supplicant/wpa_supplicant.conf";
    consoleKeyMapFile = "${prefs.home}/.local/share/kbd/keymaps/personal.map";
    sslhConfigFile = "${prefs.home}/.config/sslh/sslh.conf";
    sshAuthorizedKeys = "${prefs.home}/.ssh/authorized_keys";
    sshHostKeys = [
      "${prefs.home}/.local/secrets/initrd/ssh_host_rsa_key"
      "${prefs.home}/.local/secrets/initrd/ssh_host_ed25519_key"
    ];
  };
in {
  imports =
    (builtins.filter (x: builtins.pathExists x) [ ./machine.nix ./cachix.nix ]);
  security = {
    sudo = { wheelNeedsPassword = false; };
    acme = {
      acceptTerms = true;
      email = prefs.acmeEmail;
      certs = prefs.acmeCerts;
    };
    pki = {
      caCertificateBlacklist = [
        "WoSign"
        "WoSign China"
        "CA WoSign ECC Root"
        "Certification Authority of WoSign G2"
      ];
      certificateFiles = let
        mitmCA = pkgs.lib.optionals (builtins.pathExists impure.mitmproxyCAFile)
          [
            (builtins.toFile "mitmproxy-ca.pem"
              (builtins.readFile impure.mitmproxyCAFile))
          ];
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
      services."${prefs.owner}" = {
        fprintAuth = prefs.enableFprintAuth;
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
        enableGnomeKeyring = prefs.enableGnomeKeyring;
        pamMount = true;
        sshAgentAuth = true;
        setEnvironment = true;
      };
    };
  };

  networking = {
    hostName = prefs.hostname;
    hostId = prefs.hostId;
    wireless = {
      enable = prefs.enableSupplicant;
      # userControlled = { enable = true; };
      iwd.enable = prefs.enableIwd;
    };
    supplicant = pkgs.lib.optionalAttrs prefs.enableSupplicant {
      "WLAN" = {
        configFile = let
          defaultPath = "/etc/wpa_supplicant.conf";
          path = if builtins.pathExists impure.wpaSupplicantConfigFile then
            impure.wpaSupplicantConfigFile
          else
            defaultPath;
        in {
          # TODO: figure out why this does not work.
          inherit (path)
          ;
          writable = true;
        };
      };
    };
    proxy.default = prefs.proxy;
    enableIPv6 = prefs.enableIPv6;
  };

  console = {
    keyMap = let p = impure.consoleKeyMapFile;
    in if builtins.pathExists p then
      (builtins.toFile "personal-keymap" (builtins.readFile p))
    else
      "us";
    font = if prefs.consoleFont != null then
      prefs.consoleFont
    else if prefs.enableHidpi then
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
      enabled = prefs.enabledInputMethod;
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
        enable = prefs.enableDavfs2 && builtins.pathExists prefs.davfs2Secrets;
        mode = "0600";
        source = prefs.davfs2Secrets;
      };
      hosts.mode = "0644";
    };

    extraOutputsToInstall = prefs.extraOutputsToInstall;
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
        nvimpager
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
        cryptsetup
        compton
        btrbk
        blueman
        bluez
        bluez-tools
        btrfs-progs
        exfat
        i3blocks
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
      ] ++ (if (prefs.enableTailScale) then [ tailscale ] else [ ])
      ++ (if (prefs.enableCodeServer) then [ code-server ] else [ ])
      ++ (if (prefs.enableZfs) then [ zfsbackup ] else [ ])
      ++ (if (prefs.nixosSystem == "x86_64-linux") then [
        xmobar
        hardinfo
        steam-run-native
        # aqemu
        wine
        bpftool
        prefs.kernelPackages.perf
        prefs.kernelPackages.bpftrace
        prefs.kernelPackages.bcc
      ] else
        [ ]);
    enableDebugInfo = prefs.enableDebugInfo;
    shellAliases = {
      ssh = "ssh -C";
      bc = "bc -l";
    };
    sessionVariables = pkgs.lib.optionalAttrs (prefs.enableSessionVariables)
      (rec {
        MYSHELL = if prefs.enableZSH then "zsh" else "bash";
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
        MY_LD_LIBRARY_PATH =
          "$HOME/.nix-profile/lib:/run/current-system/sw/lib";
        # cmake does not respect LIBRARY_PATH
        CMAKE_LIBRARY_PATH =
          "$HOME/.nix-profile/lib:/run/current-system/sw/lib";
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
        MYPYTHONPATH =
          (pkgs.myPackages.pythonPackages.makePythonPath or pkgs.python3Packages.makePythonPath)
          [ (pkgs.myPackages.python or pkgs.python) ];
        PAGER = "nvimpager";
      });
    variables = {
      # systemctl --user does not work without this
      # https://serverfault.com/questions/887283/systemctl-user-process-org-freedesktop-systemd1-exited-with-status-1/887298#887298
      # XDG_RUNTIME_DIR = ''/run/user/"$(id -u)"'';
    };
  };

  programs = {
    ccache = { enable = prefs.enableCcache; };
    java = { enable = prefs.enableJava; };
    gnupg.agent = { enable = prefs.enableGPGAgent; };
    ssh = { startAgent = true; };
    # vim.defaultEditor = true;
    adb.enable = prefs.enableADB;
    slock.enable = prefs.enableSlock;
    bash = { enableCompletion = true; };
    x2goserver = { enable = prefs.enableX2goServer; };
    zsh = {
      enable = prefs.enableZSH;
      enableCompletion = true;
      ohMyZsh = { enable = true; };
      shellInit = "zsh-newuser-install() { :; }";
    };
    # light.enable = true;
    sway = {
      enable = true;
      extraPackages = with pkgs; [ swaylock swayidle alacritty dmenu ];
    };
    tmux = { enable = true; };
    wireshark.enable = prefs.enableWireshark;
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
  networking.firewall.enable = prefs.enableFirewall;

  sound = {
    enable = true;
    mediaKeys = { enable = prefs.enableMediaKeys; };
  };

  nixpkgs = let
    cross = if prefs.enableAarch64Cross then rec {
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
  in configAttr // cross;

  hardware = {
    enableAllFirmware = true;
    enableRedistributableFirmware = true;
    opengl = {
      enable = true;
      driSupport = true;
    };
    bumblebee = {
      enable = prefs.enableBumblebee;
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
      enable = prefs.enableBluetooth;
      package = pkgs.bluezFull;
      powerOnBoot = prefs.enableBluetooth;
    };
    acpilight = { enable = prefs.enableAcpilight; };
  };

  location = {
    latitude = 39.55;
    longitude = 116.23;
  };

  system = {
    activationScripts = let
      jdks = builtins.filter (x: pkgs ? x) prefs.linkedJdks;
      addjdk = jdk:
        if pkgs ? jdk then
          let p = pkgs.${jdk}.home; in "ln -sfn ${p} /local/jdks/${jdk}"
        else
          "";
    in pkgs.lib.optionalAttrs (prefs.enableJava && jdks != [ ]) {
      jdks = {
        text = pkgs.lib.concatMapStringsSep "\n" addjdk jdks;
        deps = [ "local" ];
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
        text =
          "install -d -m 0700 -o ${prefs.owner} -g ${prefs.ownerGroup} /mnt/sshfs";
        deps = [ ];
      };

      # rclone
      mntrclone = {
        text =
          "install -d -m 0700 -o ${prefs.owner} -g ${prefs.ownerGroup} /mnt/rclone";
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
    };
  };

  services = {
    arbtt = { enable = prefs.enableArbtt; };
    compton = { enable = prefs.enableCompton; };
    connman = { enable = prefs.enableConnman; };
    # calibre-server = {
    #   enable = prefs.enableCalibreServer;
    #   libraries = calibreServerLibraries;
    # };
    vsftpd = {
      enable = prefs.enableVsftpd;
      userlist = [ prefs.owner ];
      userlistEnable = true;
    };
    fcron = {
      enable = prefs.enableFcron;
      maxSerialJobs = 5;
      systab = "";
    };
    offlineimap = {
      enable = prefs.enableOfflineimap;
      install = true;
      path = [ pkgs.libsecret pkgs.dbus ];
    };
    davfs2 = { enable = prefs.enableDavfs2; };
    dnsmasq = {
      enable = prefs.enableDnsmasq;
      resolveLocalQueries = prefs.dnsmasqResolveLocalQueries;
      servers = prefs.dnsmasqServers;
      extraConfig = prefs.dnsmasqExtraConfig;
    };
    smartdns = {
      enable = prefs.enableSmartdns;
      settings = prefs.smartdnsSettings;
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
      enable = prefs.enableSamba;
      extraConfig = ''
        workgroup = WORKGROUP
        security = user
      '';
      shares = {
        owner = {
          comment = "home folder";
          path = prefs.home;
          public = "no";
          writable = "yes";
          printable = "no";
          "create mask" = "0644";
          "force user" = prefs.owner;
          "force group" = "users";
        };
        data = {
          comment = "data folder";
          path = "/data";
          public = "no";
          writable = "yes";
          printable = "no";
          "create mask" = "0644";
          "force user" = prefs.owner;
          "force group" = "users";
        };
      };
    };
    privoxy = {
      enable = prefs.enablePrivoxy;
      settings = { listen-address = "0.0.0.0:8118"; };
    };
    redshift = { enable = prefs.enableRedshift; };
    avahi = {
      enable = prefs.enableAvahi;
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
      enable = prefs.enableNfs;
      extraNfsdConfig = ''
        udp=y
      '';
    };
    zfs = {
      autoScrub.enable = prefs.enableZfs;

      autoSnapshot = {
        enable = prefs.enableZfs;
        frequent = 8;
        hourly = 24;
        daily = 0;
        weekly = 0;
        monthly = 0;
      };
    };

    autossh = {
      sessions = pkgs.lib.optionals (prefs.enableAutossh) (let
        go = server:
          let
            sshPort = if prefs.enableSslh then prefs.sslhPort else 22;
            autosshPorts = prefs.helpers.autossh {
              hostname = prefs.hostname;
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
            user = prefs.owner;
          };
      in map go prefs.autosshServers);
    };
    eternal-terminal = { enable = prefs.enableEternalTerminal; };
    printing = {
      enable = prefs.enablePrinting;
      drivers = [ pkgs.hplip ];
    };
    tailscale = { enable = prefs.enableTailScale; };
    zerotierone = {
      enable = prefs.buildZerotierone;
      joinNetworks = prefs.zerotieroneNetworks;
    };
    system-config-printer.enable = prefs.enablePrinting;
    logind.extraConfig = ''
      HandlePowerKey=suspend
      HandleLidSwitch=ignore
      RuntimeDirectorySize=50%
    '';
    postfix = {
      enable = prefs.enablePostfix;
      rootAlias = prefs.owner;
      extraConfig = ''
        myhostname = ${prefs.hostname}
        mydomain = localdomain
        mydestination = $myhostname, localhost.$mydomain, localhost
        mynetworks_style = host
      '';
    };
    postgresql.enable = prefs.enablePostgres;
    udisks2.enable = prefs.enableUdisks2;
    redis.enable = prefs.enableRedis;
    fail2ban.enable = prefs.enableFail2ban && config.networking.firewall.enable;
    mpd.enable = prefs.enableMpd;
    # mosquitto.enable = true;
    rsyncd.enable = prefs.enableRsyncd;
    # accounts-daemon.enable = prefs.enableAccountsDaemon || prefs.enableFlatpak;
    flatpak.enable = prefs.enableFlatpak;
    thermald = { enable = prefs.enableThermald; };
    gnome3 = { gnome-keyring.enable = prefs.enableGnomeKeyring; };

    locate = {
      enable = prefs.enableLocate;
      locate = pkgs.mlocate;
      localuser = null;
      interval = "hourly";
      pruneBindMounts = true;
    };

    # change port
    # sudo chown -R e /etc/rancher/k3s/
    # k3s kubectl patch service traefik -n kube-system -p '{"spec": {"ports": [{"port": 443,"targetPort": 443, "nodePort": 30443, "protocol": "TCP", "name": "https"},{"port": 80,"targetPort": 80, "nodePort": 30080, "protocol": "TCP", "name": "http"}], "type": "LoadBalancer"}}'
    k3s = {
      enable = prefs.enableK3s;
      docker = true;
    };

    jupyterhub = {
      enable = prefs.enableJupyter;
      jupyterhubEnv = prefs.helpers.mkIfAttrExists pkgs "myPackages.jupyterhub";
      # TODO: the following will not produce the required binary like jupyterhub-singleuser
      # jupyterlabEnv = prefs.helpers.mkIfAttrExists pkgs "myPackages.jupyterlab";
      jupyterlabEnv = with pkgs;
        python3.withPackages
        (p: with p; [ jupyterhub jupyterlab jupyterlab_server ]);
      port = 8899;
      kernels = {
        python3Kernel = (let
          env = pkgs.python3.withPackages
            (p: with p; [ ipykernel dask-gateway numpy scipy ]);
        in {
          displayName = "Python 3";
          argv = [
            "${env.interpreter}"
            "-m"
            "ipykernel_launcher"
            "-f"
            "{connection_file}"
          ];
          language = "python";
          logo32 =
            "${env}/${env.sitePackages}/ipykernel/resources/logo-32x32.png";
          logo64 =
            "${env}/${env.sitePackages}/ipykernel/resources/logo-64x64.png";
        });

        cKernel = (let
          env = pkgs.python3.withPackages (p: with p; [ jupyter-c-kernel ]);
        in {
          displayName = "C";
          argv = [
            "${env.interpreter}"
            "-m"
            "jupyter_c_kernel"
            "-f"
            "{connection_file}"
          ];
          language = "c";
        });

        rustKernel = {
          displayName = "Rust";
          argv = [
            "${pkgs.evcxr}/bin/evcxr_jupyter"
            "--control_file"
            "{connection_file}"
          ];
          language = "Rust";
        };

        rKernel = (let
          env = pkgs.rWrapper.override {
            packages = with pkgs.rPackages; [ IRkernel ggplot2 ];
          };
        in {
          displayName = "R";
          argv = [
            "${env}/bin/R"
            "--slave"
            "-e"
            "IRkernel::main()"
            "--args"
            "{connection_file}"
          ];
          language = "R";
        });

        ansibleKernel = (let
          env = (pkgs.python3.withPackages
            (p: with p; [ ansible-kernel ansible ])).override
            (args: { ignoreCollisions = true; });
        in {
          displayName = "Ansible";
          argv = [
            "${env.interpreter}"
            "-m"
            "ansible_kernel"
            "-f"
            "{connection_file}"
          ];
          language = "ansible";
        });

        bashKernel =
          (let env = pkgs.python3.withPackages (p: with p; [ bash_kernel ]);
          in {
            displayName = "Bash";
            argv = [
              "${env.interpreter}"
              "-m"
              "bash_kernel"
              "-f"
              "{connection_file}"
            ];
            language = "Bash";
          });

        nixKernel =
          (let env = pkgs.python3.withPackages (p: with p; [ nix-kernel ]);
          in {
            displayName = "Nix";
            argv = [
              "${env.interpreter}"
              "-m"
              "nix-kernel"
              "-f"
              "{connection_file}"
            ];
            language = "Nix";
          });

        rubyKernel = {
          displayName = "Ruby";
          argv = [ "${pkgs.iruby}/bin/iruby" "kernel" "{connection_file}" ];
          language = "ruby";
        };

        # TODO: Below build failed with
        # RPATH of binary /nix/store/ilhgzcydg3vn4mp7k5yawlsjwfpm8xi8-ihaskell-0.10.1.2/bin/ihaskell contains a forbidden reference to /build/
        #   haskellKernel = (let
        #     env = pkgs.haskellPackages.ghcWithPackages (pkgs: [ pkgs.ihaskell ]);
        #     ihaskellSh = pkgs.writeScriptBin "ihaskell" ''
        #       #! ${pkgs.stdenv.shell}
        #       export GHC_PACKAGE_PATH="$(echo ${env}/lib/*/package.conf.d| tr ' ' ':'):$GHC_PACKAGE_PATH"
        #       export PATH="${pkgs.stdenv.lib.makeBinPath ([ env ])}:$PATH"
        #       ${env}/bin/ihaskell -l $(${env}/bin/ghc --print-libdir) "$@"
        #     '';
        #   in {
        #     displayName = "Haskell";
        #     argv = [
        #       "${ihaskellSh}/bin/ihaskell"
        #       "kernel"
        #       "{connection_file}"
        #       "+RTS"
        #       "-M3g"
        #       "-N2"
        #       "-RTS"
        #     ];
        #     language = "Haskell";
        #   });
      };
    };

    cfssl = { enable = prefs.enableCfssl; };

    sslh = {
      enable = prefs.enableSslh;
      port = prefs.sslhPort;
      transparent = false;
      verbose = true;
    } // (let p = impure.sslhConfigFile;
    in pkgs.lib.optionalAttrs (builtins.pathExists p) {
      appendConfig = (builtins.readFile p);
    });

    unifi.enable = prefs.enableUnifi;

    gvfs.enable = prefs.enableGvfs;

    emacs = {
      enable = prefs.enableEmacs;
      install = prefs.enableEmacs;
      package = pkgs.myPackages.emacs or pkgs.emacs;
    };

    syncthing = {
      enable = prefs.enableSyncthing;
      user = prefs.owner;
      group = "users";
      dataDir = prefs.home;
      systemService = false;
    };

    # yandex-disk = { enable = prefs.enableYandexDisk; } // yandexConfig;

    xserver = {
      enable = prefs.enableXserver;
      verbose = 7;
      autorun = true;
      exportConfiguration = true;
      layout = "us";
      dpi = prefs.dpi;
      libinput = {
        enable = prefs.enableLibInput;
        touchpad = {
          tapping = true;
          disableWhileTyping = true;
        };
      };
      # videoDrivers = [ "dummy" ] ++ [ "intel" ];
      virtualScreen = {
        x = 1200;
        y = 1920;
      };
      xautolock = let
        locker = "${pkgs.i3lock}/bin/i3lock";
        killer = "${pkgs.systemd}/bin/systemctl suspend";
        notifier =
          ''${pkgs.libnotify}/bin/notify-send "Locking in 10 seconds"'';
      in {
        inherit locker killer notifier;
        enable = prefs.enableXautolock;
        enableNotifier = true;
        nowlocker = locker;
      };
      # desktopManager.xfce.enable = true;
      desktopManager.gnome3.enable = prefs.enableGnome;
      # desktopManager.plasma5.enable = true;
      # desktopManager.xfce.enableXfwm = false;
      windowManager = {
        i3 = {
          enable = true;
          package = pkgs.i3-gaps;
        };
        awesome.enable = true;
      } // (if (prefs.enableXmonad) then {
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
        defaultSession = prefs.xDefaultSession;
        autoLogin = {
          enable = prefs.enableAutoLogin;
          user = prefs.owner;
        };
      in {
        sessionCommands = prefs.xSessionCommands;
        startx = { enable = prefs.xDisplayManager == "startx"; };
        sddm = {
          enable = prefs.xDisplayManager == "sddm";
          enableHidpi = prefs.enableHidpi;
          autoNumlock = true;
        };
        gdm = { enable = prefs.xDisplayManager == "gdm"; };
        lightdm = { enable = prefs.xDisplayManager == "lightdm"; };
      };
    };
  };

  # xdg.portal.enable = prefs.enableXdgPortal || prefs.enableFlatpak;

  users.users = let
    extraGroups = [
      "wheel"
      "cups"
      "video"
      "kvm"
      "libvirtd"
      "qemu-libvirtd"
      "audio"
      "disk"
      "keys"
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
    "${prefs.owner}" = {
      createHome = true;
      inherit extraGroups;
      group = prefs.ownerGroup;
      home = prefs.home;
      isNormalUser = true;
      uid = prefs.ownerUid;
      shell = if prefs.enableZSH then pkgs.zsh else pkgs.bash;
      initialHashedPassword =
        "$6$eE6pKPpxdZLueg$WHb./PjNICw7nYnPK8R4Vscu/Rw4l5Mk24/Gi4ijAsNP22LG9L471Ox..yUfFRy5feXtjvog9DM/jJl82VHuI1";
    };
  } // (if prefs.enableFallbackAccount then {
    # Fallback user when "${prefs.owner}" encounters problems
    fallback = {
      createHome = true;
      isNormalUser = true;
      useDefaultShell = true;
      initialHashedPassword =
        "$6$nstJFDdZZ$uENeWO2lup09Je7UzVlJpwPlU1SvLwzTrbm/Gr.4PUpkKUuGcNEFmUrfgotWF3HoofVrGg1ENW.uzTGT6kX3v1";
    };
  } else
    { });

  users.groups."${prefs.ownerGroup}" = { gid = prefs.ownerGroupGid; };

  virtualisation = {
    libvirtd = { enable = prefs.enableLibvirtd; };
    virtualbox.host = {
      # package = stable.virtuablbox or pkgs.virtualbox;
      enable = prefs.enableVirtualboxHost;
      enableExtensionPack = prefs.enableVirtualboxHost;
      # enableHardening = false;
    };
    podman = {
      enable = prefs.enablePodman;
      dockerCompat = prefs.replaceDockerWithPodman;
    };
    docker = {
      enable = prefs.enableDocker && !prefs.replaceDockerWithPodman;
      storageDriver = prefs.dockerStorageDriver;
      autoPrune.enable = true;
    };
    anbox = { enable = prefs.enableAnbox; };
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
            ${pkgs.bash}/bin/bash -c "${pkgs.mailutils}/bin/mail --set=noASKCC --subject 'Systemd unit %i failed' ${prefs.owner} < /dev/null"
          '';
        };
      };
    };

    myMounts = {
      automounts = let
        nextcloud = {
          enable = prefs.enableNextcloud;
          description = "Automount nextcloud sync directory.";
          where = prefs.nextcloudWhere;
          wantedBy = [ "multi-user.target" ];
        };
        yandex = {
          enable = prefs.enableYandex;
          description = "Automount yandex sync directory.";
          where = prefs.yandexWhere;
          wantedBy = [ "multi-user.target" ];
        };
      in [ nextcloud yandex ];
      mounts = let
        nextcloud = {
          enable = prefs.enableNextcloud;
          where = prefs.nextcloudWhere;
          what = prefs.nextcloudWhat;
          type = "davfs";
          options = "rw,uid=${builtins.toString prefs.ownerUid},gid=${
              builtins.toString prefs.ownerGroupGid
            }";
          wants = [ "network-online.target" ];
          wantedBy = [ "remote-fs.target" ];
          after = [ "network-online.target" ];
          unitConfig = { path = [ pkgs.utillinux ]; };
        };
        yandex = {
          enable = prefs.enableYandex;
          where = prefs.yandexWhere;
          what = prefs.yandexWhat;
          type = "davfs";
          options = "rw,user=uid=${builtins.toString prefs.ownerUid},gid=${
              builtins.toString prefs.ownerGroupGid
            }";
          wants = [ "network-online.target" ];
          wantedBy = [ "remote-fs.target" ];
          after = [ "network-online.target" ];
          unitConfig = { paths = [ pkgs.utillinux ]; };
        };
      in [ nextcloud yandex ];
    };

    myPackages = {
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
    };

    myServices = {
      services = notify-systemd-unit-failures // pkgs.lib.optionalAttrs
        (prefs.buildZerotierone && !prefs.enableZerotierone) {
          # build zero tier one anyway, but enable it on prefs.enableZerotierone is true;
          "zerotierone" = { wantedBy = pkgs.lib.mkForce [ ]; };
        } // pkgs.lib.optionalAttrs (prefs.enableK3s) {
          "k3s" = let
            k3sPatchScript = pkgs.writeShellScript "add-k3s-config" ''
              ${pkgs.k3s}/bin/k3s kubectl patch -n kube-system services traefik -p '{"spec":{"ports":[{"name":"http","nodePort":30080,"port":30080,"protocol":"TCP","targetPort":"http"},{"name":"https","nodePort":30443,"port":30443,"protocol":"TCP","targetPort":"https"}]}}' || ${pkgs.coreutils}/bin/true
              ${pkgs.coreutils}/bin/chown ${prefs.owner} /etc/rancher/k3s/k3s.yaml || ${pkgs.coreutils}/bin/true
            '';
          in {
            path = if prefs.enableZfs then [ pkgs.zfs ] else [ ];
            serviceConfig = { ExecStartPost = [ "${k3sPatchScript}" ]; };
          };
        } // pkgs.lib.optionalAttrs (prefs.enableJupyter) {
          "jupyterhub" = { path = with pkgs; [ nodejs_latest ]; };
        } // pkgs.lib.optionalAttrs (prefs.enableCodeServer) {
          "code-server" = {
            enable = true;
            description = "Remote VSCode Server";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [ pkgs.go pkgs.git pkgs.direnv ];

            serviceConfig = {
              Type = "simple";
              ExecStart =
                "${pkgs.code-server}/bin/code-server --user-data-dir ${prefs.home}/.vscode --disable-telemetry";
              WorkingDirectory = prefs.home;
              NoNewPrivileges = true;
              User = prefs.owner;
              Group = prefs.ownerGroup;
            };
          };
        };
    };

    clash-redir = let
      name = "clash-redir";
      updaterName = "${name}-config-updater";
      script = builtins.path {
        inherit name;
        path = prefs.getDotfile "dot_bin/executable_clash-redir";
      };
    in {
      services."${name}" = {
        description = "transparent proxy with clash";
        enable = prefs.enableClashRedir;
        wantedBy = [ "default.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path = [
          pkgs.coreutils
          pkgs.clash
          pkgs.libcap
          pkgs.iptables
          pkgs.iproute
          pkgs.bash
          pkgs.gawk
        ];
        serviceConfig = {
          Type = "forking";
          ExecStart = "${script} start";
          ExecStop = "${script} stop";
        };
      };
      services."${updaterName}" = let
        clash-config-update-script =
          pkgs.writeShellScript "clash-config-update-script" ''
            set -xeu
            if ! CLASH_URL="$(cat /run/secrets/clash-config-url)"; then
                exit 0
            fi
            CLASH_USER=clash
            CLASH_UID="$(id -u "$CLASH_USER")"
            CLASH_TEMP_CONFIG="''${TMPDIR:-/tmp}/clash-config-$(date -u +"%Y-%m-%dT%H:%M:%SZ").yaml"
            CLASH_CONFIG=/etc/clash-redir/default.yaml
            if ! sudo -u "$CLASH_USER" curl "$CLASH_URL" -o "$CLASH_TEMP_CONFIG"; then
                if ! curl "$CLASH_URL" -o "$CLASH_TEMP_CONFIG"; then
                    >&2 echo "Failed to download clash config"
                    exit 1
                fi
            fi
            if diff "$CLASH_TEMP_CONFIG" "$CLASH_CONFIG";
                then exit 0
            fi
            cp "$CLASH_TEMP_CONFIG" "$CLASH_CONFIG"
            if ! curl -X PUT -H 'content-type: application/json' -d "{\"path\": \"$CLASH_CONFIG\"}" 'http://localhost:9090/configs/'; then
                systemctl restart ${name}
            fi
          '';
      in {
        description = "update clash config";
        enable = prefs.enableClashRedir;
        wantedBy = [ "default.target" ];
        wants = [ "network-online.target" ];
        after = [ "network-online.target" ];
        path =
          [ pkgs.coreutils pkgs.systemd pkgs.curl pkgs.diffutils pkgs.libcap ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${clash-config-update-script}";
        };
      };
      timers."${updaterName}" = {
        enable = prefs.enableClashRedir;
        wantedBy = [ "default.target" ];
        onFailure = [ "notify-systemd-unit-failures@${updaterName}.service" ];
        timerConfig = {
          OnCalendar = "hourly";
          Unit = "${updaterName}.service";
          Persistent = true;
        };
      };
    };

    all = [
      myMounts
      # The following is not pure, disable it for now.
      # myPackages
      myServices
      clash-redir
    ];
  in (builtins.foldl' (a: e: pkgs.lib.recursiveUpdate a e) { } all) // {
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
          enable = prefs.enableDdns;
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
          enable = prefs.enableDdns;
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
          enable = prefs.enableNextcloudClient;
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
          instance="${builtins.toString prefs.sslhPort}-${
            builtins.toString prefs.sslhPort
          }"
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
          enable = prefs.enableHolePuncher && prefs.enableSslh;
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
          enable = prefs.enableHolePuncher;
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
          enable = prefs.enableTaskWarriorSync;
          wantedBy = [ "default.target" ];
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${pkgs.taskwarrior}/bin/task synchronize";
          };
        };
        timers.${name} = {
          enable = prefs.enableTaskWarriorSync;
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
        syncFolder = "${prefs.home}/Sync";
      in if prefs.enableYandexDisk then {
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
              "${pkgs.yandex-disk}/bin/yandex-disk start --no-daemon --auth=/run/secrets/yandex-passwd --dir='${syncFolder}' --exclude-dirs='${prefs.yandexExcludedFiles}'";
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
    inherit (prefs) buildMachines buildCores maxJobs distributedBuilds;
    package = pkgs.nixFlakes;
    extraOptions =
      pkgs.lib.optionalString (config.nix.package == pkgs.nixFlakes)
      "experimental-features = nix-command flakes";
    binaryCaches =
      [ "https://mirrors.tuna.tsinghua.edu.cn/nix-channels/store" ];
    binaryCachePublicKeys = [ ];
    useSandbox = true;
    gc = {
      automatic = true;
      options = "--delete-older-than 60d";
    };
    optimise = { automatic = true; };
    autoOptimiseStore = true;
  };

  boot = {
    binfmt = { inherit (prefs) emulatedSystems; };
    inherit (prefs)
      kernelParams extraModulePackages kernelPatches kernelPackages;
    kernel.sysctl = prefs.kernelSysctl;
    loader = {
      efi.canTouchEfiVariables = false;
    } // (if prefs.enableGrub then {
      grub = {
        enable = true;
        copyKernels = true;
        efiSupport = true;
        efiInstallAsRemovable = true;
        enableCryptodisk = true;
        useOSProber = true;
      };
    } else
      { }) // (if prefs.isRaspberryPi then {
        raspberryPi = {
          enable = true;
          version = prefs.raspberryPiVersion;
        };
      } else
        { });

    supportedFilesystems = if (prefs.enableZfs) then [ "zfs" ] else [ ];
    zfs = { enableUnstable = prefs.enableZfsUnstable; };
    crashDump = { enable = prefs.enableCrashDump; };
    initrd.network = {
      enable = true;
      ssh = let
        f = impure.sshAuthorizedKeys;
        authorizedKeys = pkgs.lib.optionals (builtins.pathExists f)
          (builtins.filter (x: x != "")
            (pkgs.lib.splitString "\n" (builtins.readFile f)));
        hostKeys =
          builtins.filter (x: builtins.pathExists x) impure.sshHostKeys;
      in {
        inherit (prefs) authorizedKeys hostKeys;
        enable = false && prefs.enableBootSSH && prefs.authorizedKeys != [ ]
          && prefs.hostKeys != [ ];
      };
    };
  };
}