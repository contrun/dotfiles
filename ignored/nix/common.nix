{ config, pkgs, lib, inputs, ... }@args:
let
  prefs = let p = import ./prefs.nix args;
  in builtins.trace "final configuration for host ${p.hostname}"
  (builtins.trace p p);
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
    } // lib.optionalAttrs (prefs.enableCrio && prefs.enableZfs) {
      "crio/crio.conf.d/01-zfs.conf".text = ''
        [crio]
        storage_driver = "zfs"
      '';
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
        # gnome3.dconf
        # gnome3.gsettings-desktop-schemas
        # gnome3.zenity
        # font-manager
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
        nodejs_latest
        gcc
        gnumake
        podman
        podman-compose
        usbutils
        powertop
        fail2ban
        qemu
        ldns
        bind
        tree
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
        (pkgs.myPackages.aioproxy or null)
        rofi
        ruby
        perl
        emacs
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
        file
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
        blueman
        bluez
        bluez-tools
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
        libcap
      ] ++ (if (prefs.enableTailScale) then [ tailscale ] else [ ])
      ++ (if (prefs.enableCodeServer) then [ code-server ] else [ ])
      ++ (if (prefs.enableZfs) then [ zfsbackup ] else [ ])
      ++ (if (prefs.enableBtrfs) then [ btrbk btrfs-progs ] else [ ])
      ++ (if (prefs.enableClashRedir) then [ clash ] else [ ])
      ++ (if (prefs.enableK3s) then [ k3s ] else [ ])
      ++ (if (prefs.nixosSystem == "x86_64-linux") then [
        xmobar
        hardinfo
        # steam-run-native
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
    aria2 = {
      enable = prefs.enableAria2;
      extraArguments = "--rpc-listen-all --rpc-secret $ARIA2_RPC_SECRET";
    };
    openldap = let
      mkCommon = baseDN: ''
        dn: ou=People,${baseDN}
        ou: People
        objectClass: top
        objectClass: organizationalUnit

        dn: ou=Group,${baseDN}
        ou: Group
        objectClass: top
        objectClass: organizationalUnit

        dn: cn=Manager,${baseDN}
        cn: Manager
        objectClass: top
        objectclass: organizationalRole
        roleOccupant: ${baseDN}

        dn: uid=testuser,${baseDN}
        objectClass: account
        uid: testuser

        dn: uid=johndoe,ou=People,${baseDN}
        objectClass: top
        objectClass: person
        objectClass: organizationalPerson
        objectClass: inetOrgPerson
        cn: John Doe
        sn: Doe
        userPassword: xxxxxxxxxx
      '';
      mkDomain = domain: tld: ''
        dn: dc=${domain},dc=${tld}
        objectClass: domain
        dc: ${domain}
      '';
      mkOrg = org: ''
        dn: o=${org}
        objectClass: organization
      '';
    in {
      enable = prefs.enableOpenldap;
      settings = {
        children = {
          "cn=schema".includes = [
            "${pkgs.openldap}/etc/schema/core.ldif"
            "${pkgs.openldap}/etc/schema/cosine.ldif"
            "${pkgs.openldap}/etc/schema/inetorgperson.ldif"
            "${pkgs.openldap}/etc/schema/nis.ldif"
          ];
          "olcDatabase={1}mdb" = {
            attrs = {
              objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
              olcDatabase = "{1}mdb";
              olcDbDirectory = "/var/db/openldap/localhost";
              olcSuffix = "o=localhost";
              olcRootDN = "cn=root,o=localhost";
              olcRootPW = { path = "/run/secrets/openldap-root-password"; };
              olcAccess = [
                ''
                  to attrs=userPassword,givenName,sn,photo by self write by anonymous auth by dn.base="cn=Manager,o=localhost" write by * none''
              ] ++ [
                ''
                  to * by self read by dn.base="cn=Manager,o=localhost" write by * none''
              ];
            };
          };
          "olcDatabase={2}mdb" = {
            attrs = {
              objectClass = [ "olcDatabaseConfig" "olcMdbConfig" ];
              olcDatabase = "{2}mdb";
              olcDbDirectory = "/var/db/openldap/cont.run";
              olcSuffix = "dc=cont,dc=run";
              olcRootDN = "cn=root,dc=cont,dc=run";
              olcRootPW = { path = "/run/secrets/openldap-root-password"; };
            };
          };
        };
      };
      declarativeContents."dc=cont,dc=run" = builtins.concatStringsSep "\n" [
        (mkDomain "cont" "run")
        (mkCommon "dc=cont,dc=run")
      ];

      declarativeContents."o=localhost" = builtins.concatStringsSep "\n" [
        (mkOrg "localhost")
        (mkCommon "o=localhost")
      ];
    };
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
    coredns = {
      enable = prefs.enableCoredns;
      package = args.inputs.infra.coredns.${config.nixpkgs.system};
      config = let
        getTemplate = t: ''
          template IN ${t} ${prefs.mainDomain} {
              match ^(|[.])(?P<p>.*)\.(?P<s>(?P<h>.*?)\.(?P<d>${prefs.mainDomain})[.])$
              answer "{{ .Name }} 60 IN CNAME {{ if eq .Group.h `hub` }}${prefs.hubDomainPrefix}{{ else }}{{ .Group.h }}{{ end }}.{{ .Group.d }}."
              fallthrough
          }
        '';
      in ''
        .:${builtins.toString prefs.corednsPort} {
            ${getTemplate "A"}
            ${getTemplate "AAAA"}
            mdns ${prefs.mainDomain}
            alternate original NXDOMAIN,SERVFAIL,REFUSED . 223.6.6.6
        }
              '';
    };
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
    resolved = {
      enable = prefs.enableResolved;
      extraConfig = ''
        DNS=127.0.0.1:${builtins.toString prefs.corednsPort}#${prefs.mainDomain}
      '';
    };
    openssh = {
      enable = true;
      useDns = true;
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
      browseDomains = [ prefs.mainDomain ];
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
            sshPort = if prefs.enableAioproxy then prefs.aioproxyPort else 22;
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
      enable = prefs.buildZerotierone || prefs.enableZerotierone;
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
    traefik = let
      getRule = domainPrefix:
        lib.concatMapStringsSep " || " (domain: "Host(`${domain}`)")
        (prefs.getFullDomainNames domainPrefix);
    in {
      enable = prefs.enableTraefik;
      dynamicConfigOptions = {
        http = {
          routers = {
            traefik-dashboard = {
              rule = "${
                  getRule "traefik"
                } && (PathPrefix(`/api`) || PathPrefix(`/dashboard`))";
              middlewares = [ "authelia@docker" ];
              entryPoints = [ "websecure" ];
              service = "api@internal";
              tls = { };
            };
            keeweb = {
              rule = getRule "keeweb";
              service = "keeweb";
              tls = { };
            };
            clash = {
              rule = getRule "clash";
              middlewares = [ "authelia@docker" ];
              service = "clash";
              tls = { };
            };
            aria2rpc = {
              rule = "(${getRule "aria2"}) && PathPrefix(`/jsonrpc`)";
              service = "aria2rpc";
              tls = { };
            };
            aria2 = {
              rule = getRule "aria2";
              middlewares = [ "aria2" ];
              service = "aria2";
              tls = { };
            };
            organice = {
              rule = getRule "organice";
              service = "organice";
              tls = { };
            };
          } // lib.optionalAttrs prefs.enableCodeServer {
            codeserver = {
              rule = getRule "codeserver";
              middlewares = [ "authelia@docker" ];
              service = "codeserver";
              tls = { };
            };
          };
          middlewares = {
            aria2 = {
              replacePathRegex = {
                regex = "^/(.*)";
                replacement = "/webui-aria2/$1";
              };
            };
          };
          services = {
            keeweb = {
              loadBalancer = {
                passHostHeader = false;
                servers = [{ url = "https://app.keeweb.info/"; }];
              };
            };
            clash = {
              loadBalancer = {
                passHostHeader = false;
                servers = [{ url = "https://clash.razord.top"; }];
              };
            };
            aria2rpc = {
              loadBalancer = {
                passHostHeader = false;
                servers = [{ url = "http://localhost:6800/"; }];
              };
            };
            aria2 = {
              loadBalancer = {
                passHostHeader = false;
                servers =
                  [{ url = "https://ziahamza.github.io/webui-aria2/"; }];
              };
            };
            organice = {
              loadBalancer = {
                passHostHeader = false;
                servers = [{ url = "https://organice.200ok.ch/"; }];
              };
            };
          } // lib.optionalAttrs prefs.enableCodeServer {
            codeserver = {
              loadBalancer = {
                servers = [{ url = "http://127.0.0.1:4050"; }];
              };
            };
          };
        };
        tcp = {
          routers = {
            to-aioproxy = {
              rule = "HostSNI(`*`)";
              service = "aioproxy";
              tls = { };
            };
          };
          services = {
            aioproxy = {
              loadBalancer = {
                servers = [{
                  address = "127.0.0.1:${builtins.toString prefs.aioproxyPort}";
                }];
              };
            };
          };
        };
        tls = {
          certificates = [{
            certFile = "/var/lib/acme/${prefs.mainDomain}/cert.pem";
            keyFile = "/var/lib/acme/${prefs.mainDomain}/key.pem";
          }];
          stores = {
            default = {
              defaultCertificate = {
                certFile = "/var/lib/acme/${prefs.mainDomain}/cert.pem";
                keyFile = "/var/lib/acme/${prefs.mainDomain}/key.pem";
              };
            };
          };
        };
      };
      staticConfigOptions = {
        api = { dashboard = true; };
        entryPoints = let
          getEntrypoint = address: {
            address = address;
            proxyProtocol = {
              trustedIPs = [
                "127.0.0.0/8"
                "10.0.0.0/8"
                "100.64.0.0/10"
                "169.254.0.0/16"
                "172.16.0.0/12"
                "192.168.0.0/16"
              ];
            };
          };
        in {
          web = getEntrypoint ":80" // {
            http = {
              redirections = {
                entryPoint = {
                  to = "websecure";
                  scheme = "https";
                };
              };
            };
          };
          websecure = getEntrypoint ":443";
        };
        log = { level = "DEBUG"; };
        providers = {
          docker = {
            defaultRule = getRule
              ''{{ (or (index .Labels "domainprefix") .Name) | normalize }}'';
            endpoint = if (prefs.ociContainerBackend == "docker") then
              "unix:///var/run/docker.sock"
            else
              "unix:///var/run/podman/podman.sock";
            network = "${prefs.ociContainerNetwork}";
          };
        };
      };
    };
    postgresql = {
      enable = prefs.enablePostgresql;
      package = pkgs.postgresql_13;
      enableTCPIP = true;
      settings = {
        # password_encryption = "scram-sha-256";
      };
      authentication = ''
        host  all all 0.0.0.0/0 md5
        host  all all ::0/0 md5
      '';
      ensureDatabases = [ "nextcloud" "wallabag" ];
      ensureUsers = [
        {
          name = "nextcloud";
          ensurePermissions = { "DATABASE nextcloud" = "ALL PRIVILEGES"; };
        }
        {
          name = "wallabag";
          ensurePermissions = { "DATABASE wallabag" = "ALL PRIVILEGES"; };
        }
        {
          name = "superuser";
          ensurePermissions = {
            "ALL TABLES IN SCHEMA public" = "ALL PRIVILEGES";
          };
        }
      ];
    };
    postgresqlBackup = {
      enable = prefs.enablePostgresql;
      backupAll = true;
    };
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
    } // (if prefs.enableContainerd then {
      extraFlags =
        "--container-runtime-endpoint /run/containerd/containerd.sock";
    } else if prefs.enableDocker then {
      docker = true;
    } else
      { });

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

        # rKernel = (let
        #   env = pkgs.rWrapper.override {
        #     packages = with pkgs.rPackages; [ IRkernel ggplot2 ];
        #   };
        # in {
        #   displayName = "R";
        #   argv = [
        #     "${env}/bin/R"
        #     "--slave"
        #     "-e"
        #     "IRkernel::main()"
        #     "--args"
        #     "{connection_file}"
        #   ];
        #   language = "R";
        # });

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
        startx = { enable = prefs.enableStartx; };
        sddm = {
          enable = prefs.enableSddm;
          enableHidpi = prefs.enableHidpi;
          autoNumlock = true;
        };
        gdm = { enable = prefs.enableGdm; };
        lightdm = { enable = prefs.enableLightdm; };
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
    clash = {
      createHome = false;
      isNormalUser = false;
      isSystemUser = true;
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
      enable = prefs.enableVirtualboxHost;
      enableExtensionPack = prefs.enableVirtualboxHost;
      # enableHardening = false;
    };
    containerd = { enable = prefs.enableContainerd; };
    cri-o = { enable = prefs.enableCrio; };
    podman = {
      enable = prefs.enablePodman
        || (prefs.enableOciContainers && prefs.ociContainerBackend == "podman");
      dockerCompat = prefs.replaceDockerWithPodman;
      extraPackages = if (prefs.enableZfs) then [ pkgs.zfs ] else [ ];
    };
    docker = {
      enable = prefs.enableDocker && !prefs.replaceDockerWithPodman;
      storageDriver = prefs.dockerStorageDriver;
      autoPrune.enable = true;
    };
    anbox = { enable = prefs.enableAnbox; };
    oci-containers = let
      images = {
        "postgresql" = {
          "x86_64-linux" = "docker.io/postgres:13";
          "aarch64-linux" = "docker.io/arm64v8/postgres:13";
        };
        "redis" = {
          "x86_64-linux" = "docker.io/redis:6";
          "aarch64-linux" = "docker.io/arm64v8/redis:6";
        };
        "authelia" = {
          "x86_64-linux" = "docker.io/authelia/authelia:4";
          "aarch64-linux" = "docker.io/authelia/authelia:4";
        };
        "wallabag" = {
          "x86_64-linux" = "docker.io/wallabag/wallabag:2.4.2";
          "aarch64-linux" = "docker.io/ugeek/wallabag:arm-2.4";
        };
        "cloudbeaver" = {
          "x86_64-linux" = "docker.io/dbeaver/cloudbeaver:latest";
        };
        "n8n" = {
          "x86_64-linux" = "docker.io/n8nio/n8n:latest";
          "aarch64-linux" = "docker.io/n8nio/n8n:latest-rpi";
        };
      };
      mkContainer = name: enable: config: override:
        pkgs.lib.optionalAttrs enable (let
          f = { environmentFiles ? [ ], enableTraefik ? true
            , enableTraefikTls ? true, traefikForwardingPort ? 80
            , entrypoints ? [ "web" "websecure" ], middlewares ? [ ]
            , networkName ? prefs.ociContainerNetwork, ... }@args: {
              result = (builtins.removeAttrs args [
                "environmentFiles"
                "enableTraefik"
                "enableTraefikTls"
                "traefikForwardingPort"
                "entrypoints"
                "middlewares"
                "networkName"
              ]) // {
                image =
                  args.image or (images."${name}"."${prefs.nixosSystem}" or (builtins.throw
                    "Image for ${name} on ${prefs.nixosSystem} not found"));
                extraOptions = (args.extraOptions or [ ])
                  ++ (builtins.map (x: "--env-file=" + x) environmentFiles)
                  ++ (if enableTraefik then
                    [
                      "--label=traefik.http.routers.${name}.service=${name}"
                      "--label=traefik.http.services.${name}.loadbalancer.server.port=${
                        builtins.toString traefikForwardingPort
                      }"
                    ] ++ (lib.optionals (entrypoints != [ ]) [
                      "--label=traefik.http.routers.${name}.entrypoints=${
                        builtins.concatStringsSep "," entrypoints
                      }"
                    ]) ++ (lib.optionals (middlewares != [ ]) [
                      "--label=traefik.http.routers.${name}.middlewares=${
                        builtins.concatStringsSep "," middlewares
                      }"
                    ]) ++ (lib.optionals (enableTraefikTls)
                      [ "--label=traefik.http.routers.${name}.tls=true" ])
                  else
                    [ "--label=traefik.enable=false" ])
                  ++ (lib.optionals (networkName != null)
                    [ "--network=${networkName}" ]);
              };
            };
          overrideWith = config: override:
            ((lib.makeOverridable f config).override override).result;
        in { "${name}" = overrideWith config override; });
    in pkgs.lib.optionalAttrs prefs.enableOciContainers {
      backend = prefs.ociContainerBackend;
      containers =
        mkContainer "postgresql" prefs.ociContainers.enablePostgresql {
          volumes = [
            "/run/secrets/postgresql-initdb-script:/my/init-user-db.sh"
            "/var/data/postgresql:/var/lib/postgresql/data"
          ];
          ports = [ "5432:5432" ];
        } {
          environmentFiles = [ "/run/secrets/postgresql-env" ];
          enableTraefik = false;
        } // mkContainer "redis" prefs.ociContainers.enableRedis {
          # https://stackoverflow.com/questions/42248198/how-to-mount-a-single-file-in-a-volume
          extraOptions = [
            "--mount"
            "type=bind,source=/run/secrets/redis-conf,target=/etc/redis.conf,readonly"
          ];
          ports = [ "6379:6379" ];
          cmd = [ "redis-server" "/etc/redis.conf" ];
        } { enableTraefik = false; }
        // mkContainer "authelia" prefs.ociContainers.enableAuthelia {
          extraOptions = [
            "--mount"
            "type=bind,source=/run/secrets/authelia-conf,target=/config/configuration.yml"
            "--mount"
            "type=bind,source=/run/secrets/authelia-users,target=/config/users.yml"
            "--label"
            "traefik.http.middlewares.authelia.forwardauth.address=http://localhost:9091/api/verify?rd=https://${
              prefs.getFullDomainName "authelia"
            }"
            "--label"
            "traefik.http.middlewares.authelia.forwardauth.trustForwardHeader=true"
            "--label"
            "traefik.http.middlewares.authelia.forwardauth.authResponseHeaders=Remote-User,Remote-Groups,Remote-Name,Remote-Email"
          ];
          ports = [ "9091:9091" ];
        } { traefikForwardingPort = 9091; }
        // mkContainer "cloudbeaver" prefs.ociContainers.enableCloudBeaver {
          volumes =
            [ "/var/data/cloudbeaver/workspace:/opt/cloudbeaver/workspace" ];
        } {
          traefikForwardingPort = 8978;
          middlewares = [ "authelia" ];
        } // mkContainer "wallabag" prefs.ociContainers.enableWallabag {
          dependsOn = [ "postgresql" ];
          environment = {
            "SYMFONY__ENV__DOMAIN_NAME" =
              "https://${prefs.getFullDomainName "wallabag"}";
          };
          volumes = [
            "/var/data/wallabag/data:/var/www/wallabag/data"
            "/var/data/wallabag/images:/var/www/wallabag/web/assets/images"
          ];
        } { environmentFiles = [ "/run/secrets/wallabag-env" ]; }
        // mkContainer "n8n" prefs.ociContainers.enableN8n {
          volumes = [ "/var/data/n8n:/home/node/.n8n" ];
          dependsOn = [ "postgresql" ];
        } {
          middlewares = [ "authelia" ];
          environmentFiles = [ "/run/secrets/n8n-env" ];
          traefikForwardingPort = 5678;
        };
    };
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
      services = notify-systemd-unit-failures // {
        init-oci-container-network = {
          description = "Create oci container networks";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig.Type = "oneshot";
          script = let
            dockercli = "${config.virtualisation.docker.package}/bin/docker";
            podmancli = "${config.virtualisation.podman.package}/bin/docker";
            cli = if prefs.ociContainerBackend == "docker" then
              dockercli
            else
              podmancli;
          in ''
            set -e
            if ! ${cli} network inspect ${prefs.ociContainerNetwork}; then
                if ! ${cli} network create ${prefs.ociContainerNetwork}; then
                    echo "creating network failed"
                fi
            fi
          '';
        };
      } // pkgs.lib.optionalAttrs
        (prefs.buildZerotierone && !prefs.enableZerotierone) {
          # build zero tier one anyway, but enable it on prefs.enableZerotierone is true;
          "zerotierone" = { wantedBy = lib.mkForce [ ]; };
        } // pkgs.lib.optionalAttrs (prefs.enableK3s) {
          "k3s" = let
            k3sPatchScript = pkgs.writeShellScript "add-k3s-config" ''
              ${pkgs.k3s}/bin/k3s kubectl patch -n kube-system services traefik -p '{"spec":{"ports":[{"name":"http","nodePort":30080,"port":30080,"protocol":"TCP","targetPort":"http"},{"name":"https","nodePort":30443,"port":30443,"protocol":"TCP","targetPort":"https"},{"$patch":"replace"}]}}' || ${pkgs.coreutils}/bin/true
              ${pkgs.coreutils}/bin/chown ${prefs.owner} /etc/rancher/k3s/k3s.yaml || ${pkgs.coreutils}/bin/true
            '';
          in {
            path = if prefs.enableZfs then [ pkgs.zfs ] else [ ];
            serviceConfig = { ExecStartPost = [ "${k3sPatchScript}" ]; };
          };
        } // pkgs.lib.optionalAttrs (prefs.enableCrio) {
          "crio" = {
            path = with pkgs;
              [ conntrack-tools ] ++ (lib.optionals prefs.enableZfs [ zfs ]);
          };
        } // pkgs.lib.optionalAttrs (prefs.enableJupyter) {
          "jupyterhub" = { path = with pkgs; [ nodejs_latest ]; };
        } // pkgs.lib.optionalAttrs (prefs.enableAria2) {
          "aria2" = {
            serviceConfig = {
              Environment = "ARIA2_RPC_SECRET=token_nekot";
              EnvironmentFile = "/run/secrets/aria2-env";
            };
          };
        } // pkgs.lib.optionalAttrs (prefs.ociContainers.enableWallabag) {
          "${prefs.ociContainerBackend}-wallabag" = {
            postStart = ''
              set -xe
              # https://github.com/moby/moby/issues/41890
              export HOME=/root
              retries=0
              while ! ${prefs.ociContainerBackend} exec wallabag /entrypoint.sh migrate; do
                  if (( retries > 10 )); then
                      echo "Giving up on initializing postgresql database."
                      exit 0
                  else
                      retries=$(( retries + 1 ))
                      sleep 2
                  fi
              done
            '';
          };
        } // pkgs.lib.optionalAttrs (prefs.enablePostgresql) {
          "postgresql" = { serviceConfig = { SupplementaryGroups = "keys"; }; };
        } // pkgs.lib.optionalAttrs (prefs.enableTraefik) {
          "traefik" = {
            serviceConfig =
              (lib.optionalAttrs (prefs.ociContainerBackend == "docker") {
                SupplementaryGroups = "keys docker acme";
              }) // (lib.optionalAttrs (prefs.ociContainerBackend == "podman") {
                User = lib.mkForce "root";
              });
          };
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
              RuntimeDirectory = "code-server";
              User = prefs.owner;
              Group = prefs.ownerGroup;
            };
          };
        } // pkgs.lib.optionalAttrs
        (prefs.enableAioproxy && ((pkgs.myPackages.aioproxy or null) != null)) {
          "aioproxy" = {
            enable = true;
            description = "All-in-one Reverse Proxy";
            after = [ "network.target" ];
            wantedBy = [ "multi-user.target" ];
            path = [
              pkgs.myPackages.aioproxy
              pkgs.iproute
              pkgs.procps
              pkgs.iptables
            ];

            serviceConfig = {
              Type = "simple";
              ExecStart =
                "${pkgs.myPackages.aioproxy}/bin/aioproxy -v 2 -l 0.0.0.0:${
                  builtins.toString prefs.aioproxyPort
                } -u 127.0.0.1:8000 -p both -ssh 127.0.0.1:22 -eternal-terminal 127.0.0.1:2022 -http 127.0.0.1:8080 -tls 127.0.0.1:30443";
              ExecStartPost = [
                "${pkgs.procps}/bin/sysctl -w net.ipv4.conf.default.route_localnet=1"
                "${pkgs.procps}/bin/sysctl -w net.ipv4.conf.all.route_localnet=1"
                "${pkgs.iproute}/bin/ip rule add from 127.0.0.1/8 iif lo table 123"
                "${pkgs.iproute}/bin/ip route replace local 0.0.0.0/0 dev lo table 123"
              ];
              ExecStopPost = [
                "${pkgs.iproute}/bin/ip rule del from 127.0.0.1/8 iif lo table 123"
                "${pkgs.iproute}/bin/ip route del local 0.0.0.0/0 dev lo table 123"
              ];
            };
          };
        };
    };

    oci-container-postgresql = let
      postgresqlUnitName = "${prefs.ociContainerBackend}-postgresql";
      postgresqlBackupUnitName = "backup-${postgresqlUnitName}";
    in pkgs.lib.optionalAttrs (prefs.ociContainers.enablePostgresql) {
      services = {
        "${postgresqlUnitName}" = {
          postStart = ''
            set -xe
            # https://github.com/moby/moby/issues/41890
            export HOME=/root
            retries=0
            while ! ${prefs.ociContainerBackend} exec postgresql /my/init-user-db.sh; do
                if (( retries > 10 )); then
                    echo "Giving up on initializing postgresql database."
                    exit 0
                else
                    retries=$(( retries + 1 ))
                    sleep 2
                fi
            done
          '';
        };
        "${postgresqlBackupUnitName}" = let
          backup-script = pkgs.writeShellScript "postgresql-backup-script" ''
            set -xeu -o pipefail
            umask 0077
            mkdir -p "$BACKUP_DIR"
            export HOME=/root
            ${prefs.ociContainerBackend} exec -e PGUSER -e PGPASSWORD postgresql pg_dumpall | gzip -c > "$BACKUP_DIR/all.tmp.sql.gz"
            if [ -e "$BACKUP_DIR/all.sql.gz" ]; then
                mv "$BACKUP_DIR/all.sql.gz" "$BACKUP_DIR/all.prev.sql.gz"
            fi
            mv $BACKUP_DIR/all.tmp.sql.gz $BACKUP_DIR/all.sql.gz
          '';
        in {
          description =
            "Backup ${prefs.ociContainerBackend} postgresql database";
          enable = true;
          wants = [ "network-online.target" "${postgresqlUnitName}.service" ];
          after = [ "network-online.target" "${postgresqlUnitName}.service" ];
          path =
            [ pkgs.coreutils pkgs.gzip pkgs.systemd pkgs.curl pkgs.utillinux ]
            ++ (lib.optionals (prefs.ociContainerBackend == "docker")
              [ config.virtualisation.docker.package ])
            ++ (lib.optionals (prefs.ociContainerBackend == "podman")
              [ config.virtualisation.podman.package ]);
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "${backup-script}";
            EnvironmentFile = "/run/secrets/postgresql-backup-env";
            Restart = "on-failure";
          };
        };
      };
      timers = {
        "${postgresqlBackupUnitName}" = {
          enable = true;
          wantedBy = [ "default.target" ];
          onFailure = [
            "notify-systemd-unit-failures@${postgresqlBackupUnitName}.service"
          ];
          timerConfig = {
            OnCalendar = "daily";
            Unit = "${postgresqlBackupUnitName}.service";
            Persistent = true;
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
          pkgs.curl
          pkgs.procps
          pkgs.libcap
          pkgs.iptables
          pkgs.iproute
          pkgs.bash
          pkgs.gawk
        ];
        serviceConfig = {
          Type = "forking";
          ExecStartPre = "${pkgs.writeShellScript "clash-redir-prestart" ''
            set -euxo pipefail
            mkdir -p /etc/clash-redir
            if ! [[ -e /etc/clash-redir/config.yaml ]]; then
                if ! [[ -e /etc/clash-redir/default.yaml ]]; then
                    systemctl restart clash-config-update-script
                fi
                ln -sfn /etc/clash-redir/default.yaml /etc/clash-redir/config.yaml
            fi
          ''}";
          ExecStart = "${script} start";
          ExecStop = "${script} stop";
        };
      };
      services."${updaterName}" = let
        clash-config-update-script =
          pkgs.writeShellScript "clash-config-update-script" ''
            set -xeu
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
        path = [
          pkgs.coreutils
          pkgs.systemd
          pkgs.curl
          pkgs.diffutils
          pkgs.libcap
          pkgs.utillinux
        ];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${clash-config-update-script}";
          EnvironmentFile = "/run/secrets/clash-env";
          Restart = "on-failure";
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
      oci-container-postgresql
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
          instance="44443-${
            builtins.toString
            (if prefs.enableAioproxy then prefs.aioproxyPort else 44443)
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
      kernelParams extraModulePackages kernelModules kernelPatches
      kernelPackages;
    kernel.sysctl = prefs.kernelSysctl;
    loader = {
      generationsDir = {
        enable = prefs.enableGenerationsDir;
        copyKernels = true;
      };
      efi = { canTouchEfiVariables = prefs.efiCanTouchEfiVariables; };
      grub = {
        enable = prefs.enableGrub;
        copyKernels = true;
        efiSupport = true;
        efiInstallAsRemovable = !prefs.efiCanTouchEfiVariables;
        enableCryptodisk = true;
        useOSProber = true;
        zfsSupport = prefs.enableZfs;
      };
      systemd-boot = {
        enable = prefs.enableSystemdBoot;
        configurationLimit = 25;
      };
      raspberryPi = {
        enable = prefs.enableRaspberryPiBoot;
        version = prefs.raspberryPiVersion;
      };
    };

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
