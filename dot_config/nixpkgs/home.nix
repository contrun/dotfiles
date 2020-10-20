{ config, pkgs, ... }:
let
  # To avoid clash within the buildEnv of home-manager
  overridePkg = pkg: func:
    if pkg ? overrideAttrs then
      pkg.overrideAttrs (oldAttrs: func oldAttrs)
    else
      pkgs.lib.warn "${pkg.name} does not have attribute overrideAttrs" pkg;
  dontCheckPkg = pkg:
    overridePkg pkg (oldAttrs: {
      # Fuck, why every package has broken tests? I just want to trust the devil.
      # Fuck, this does not seem to work.
      doCheck = false;
    });
  changePkgPriority = pkg: priority:
    overridePkg pkg (oldAttrs: { meta = { priority = priority; }; });
  getAttr = attrset: path:
    builtins.foldl' (acc: x:
      if acc ? ${x} then
        acc.${x}
      else
        pkgs.lib.warn "${path} does not exists" null) attrset
    (pkgs.lib.splitString "." path);
  getPkg = attrset: path: dontCheckPkg (getAttr attrset path);
  getPackages = list:
    (builtins.filter (x: x != null) (builtins.map (x: getPkg pkgs x) list));
  # To report an error when package does not exist, instead of quit immediately
  allPackages = builtins.foldl' (acc: collection:
    acc ++ (builtins.map (pkg: changePkgPriority pkg collection.priority)
      collection.packages)) [ ] packageCollection;
  packageCollection = [
    {
      name = "command line tools (preferred)";
      priority = 49;
      packages = getPackages [ "parallel" ];
    }
    {
      name = "command line tools";
      priority = 50;
      packages = getPackages [
        "alacritty"
        "bash-completion"
        "zsh-completions"
        "pgcli"
        "mycli"
        "sdcv"
        "ammonite"
        "autojump"
        "remind"
        "ranger"
        "rename"
        "ripgrep"
        "file"
        "silver-searcher"
        "ack"
        "patch"
        "pandoc"
        "moreutils"
        "nnn"
        "glib"
        "broot"
        "ncdu"
        "links"
        "mustache-go"
        "mustache-spec"
        "curl"
        "unrar"
        "bzip2"
        "mc"
        "most"
        "pstree"
        "yaft"
        "st"
        "stow"
        "strace"
        "linuxPackages_latest.bpftrace"
        "mtr"
        "lynx"
        "elinks"
        "wget"
        "w3m-full"
        "ueberzug"
        "autorandr"
        # "xournal"
        "wgetpaste"
        "tmux"
        "traceroute"
        "tree"
        # sl
        "fbterm"
        "fasd"
        "fortune"
        # fpp
        "fzf"
        "cowsay"
        "bashInteractive"
        "bashCompletion"
      ];
    }
    {
      name = "development tools (preferred)";
      priority = 39;
      packages = getPackages [
        "universal-ctags"
        "lldb"
        "lld"
        "gdb"
        "gcc"
        # "glibc"
        "vscodium"
        "hadoop_3_1"
        "gnumake"
      ];
    }
    {
      name = "development tools";
      priority = 40;
      packages = getPackages [
        "cmake"
        "meson"
        "ninja"
        "clang"
        "bashdb"
        "bear"
        "upx"
        "rustup"
        "gopls"
        "rust-analyzer"
        "cargo-edit"
        "cargo-xbuild"
        # cargo-update
        "cargo-generate"
        "racket"
        "myPackages.ruby"
        "zeal"
        "vagrant"
        "shellcheck"
        # "zig"
        # stdman
        # stdmanpages
        "ccls"
        # rls
        "astyle"
        "postgresql"
        # "mariadb"
        "dbeaver"
        "flyway"
        "libmysqlclient"
        "myPackages.idris"
        # "myPackages.elba"
        "pydb"
        "protobuf"
        "capnproto"
        "gflags"
        "chezmoi"
        "direnv"
        "lorri"
        "yarn"
        "redis"
        "rdbtools"
        "meld"
        "ccache"
        "clang-tools"
        "html-tidy"
        "radare2"
        "myPackages.lua"
        "xmlstarlet"
        "nasm"
        "go"
        "awscli"
        "azure-cli"
        "sqlitebrowser"
        "sqlite"
        "mitscheme"
        "guile"
        "myPackages.emacs"
        "mu"
        "tsung"
        "wrk"
        "yq-go"
        "dhall"
        "dhall-bash"
        "dhall-json"
        # "dhall-nix"
        "dhall-lsp-server"
        "rlwrap"
        "git-revise"
        "git-crypt"
        "gitAndTools.hub"
        "gitAndTools.lab"
        "gitAndTools.git-extras"
        "gitAndTools.git-hub"
        "gitAndTools.git-annex"
        "gitAndTools.git-subrepo"
        "gitAndTools.diff-so-fancy"
        "vscode"
        "insomnia"
        "postman"
        "jetbrains.idea-ultimate"
        "jetbrains.clion"
        "jetbrains.webstorm"
        "jetbrains.datagrip"
        "jetbrains.goland"
        "jetbrains.pycharm-professional"
        "go2nix"
        "gnum4"
        # "cudatoolkit"
        "linuxPackages_latest.bcc"
        "rr"
        "gdbgui"
        "valgrind"
        "wabt"
        "stable.emscripten"
        "arrow-cpp"
        "wasm-pack"
        # wasm-strip
        # "wasm-bindgen-cli"
        "hexyl"
        "fd"
        "bat"
        "pastel"
        "tokei"
        "starship"
        "watchexec"
        "zoxide"
        "kmon"
        "bingrep"
        "yj"
        "exa"
        "firecracker"
        "delve"
        "pkgconfig"
        "autoconf"
        "libtool"
        "geany"
        # gettext
        # # gkeyring
        # # glances
        "distcc"
        "remake"
        "cntr"
        "docker"
        "docker_compose"
        "kubernix"
        "terraform"
        "flink"
        "confluent-platform"
        "kubernetes"
        "kubernetes-helm"
        "kustomize"
        "kube3d"
        "k9s"
        "minikube"
        "k3s"
        # "libguestfs-with-appliance"
        "python3Packages.binwalk"
        "binutils"
        "bison"
        "tldr-hs"
        "cht-sh"
        "autokey"
        "automake"
        "autossh"
        "mosh"
        "sshpass"
        "dfeet"
        "sqlitebrowser"
        # awesome
        # axel
        "baobab"
        "neovim-remote"
        "android-file-transfer"
        # androidenv.platformTools
        # adoptopenjdk-jre-openj9-bin-11
        # android-platform-tools
        "colordiff"
        "androidStudioPackages.dev"
        "jq"
        "coq"
        "bundix"
        "buildah"
        "ansible"
        # "myPackages.hie"
        "nodejs_latest"
        "nodePackages.prettier"
        # vscode-extensions.ms-python.python
        "hadolint"
        "haskellPackages.ormolu"
        "solargraph"
        "nodePackages.dockerfile-language-server-nodejs"
        "nodePackages.bash-language-server"
        "nodePackages.typescript-language-server"
        "nodePackages.ocaml-language-server"
        # ocamlPackages_latest.merlin
        # ocamlPackages_latest.utop
        "opam"
        "dune"
        "ocaml"
        "sqlint"
        "dotty"
        "sbt-extras"
        "gradle"
        "maven"
        "ant"
        # "openjdk14"
        "coursier"
        "leiningen"
        "clojure"
        "clojure-lsp"
        "scala"
        "scalafmt"
        # "graalvm8"
        "metals"
        "stack"
        "cabal-install"
        "cabal2nix"
        "haskellPackages.cabalg"
        "haskellPackages.implicit-hie"
        "haskellPackages.hie-bios"
        "haskellPackages.haskell-language-server"
        # "myPackages.almond"
        "myPackages.jupyter"
        # ihaskell
        "shfmt"
        "erlang"
        "elixir"
        "myPackages.elixir-ls"
        "pkgconfig"
        # "gcc.cc.lib"
        "zlib"
        "gsasl"
        "fuse"
        "fuse3"
        "boost17x"
        "libunwind"
        "gmp"
        "libpng"
        # "libjpeg"
        "openssl"
        "glib-networking"
        "myPackages.python"
        "myPackages.haskell"
        "perlPackages.Appcpanminus"
        "perlPackages.locallib"
        "perlPackages.Appperlbrew"
      ];
    }
    {
      name = "multimedia";
      priority = 60;
      packages = getPackages [
        "gifsicle"
        # gimp
        "ncpamixer"
        "maim"
        "pavucontrol"
        "exiftool"
        "flac"
        "mpc_cli"
        "ncmpcpp"
        "shntool"
        "sox"
        "pamixer"
        "imv"
        "cmus"
        # "radiotray-ng"
        "clementine"
        "rhythmbox"
        "mplayer"
        "mps-youtube"
        "mpv"
        "feh"
        "sxiv"
        "arandr"
        # "virtualbox"
        "vlc"
        "pyradio"
        "myPackages.kodi"
        "exiv2"
        "imagemagick7"
      ];
    }
    {
      name = "network tools (preferred)";
      priority = 24;
      packages = getPackages [ "latest.firefox-nightly-bin" ];
    }
    {
      name = "network tools";
      priority = 25;
      packages = getPackages [
        "httpie"
        "wireshark"
        "nmap"
        # slirp4netns
        "proxychains"
        "speedtest-cli"
        "privoxy"
        "badvpn"
        "connect"
        "zeronet"
        "tor"
        "resilio-sync"
        "iperf"
        "openssh"
        "insomnia"
        # "mitmproxy"
        "ettercap"
        "openssl"
        "redsocks"
        "wget"
        "asciidoctor"
        "hugo"
        "you-get"
        "uget"
        "udptunnel"
        "wireguard"
        # qutebrowser
        # telegram-cli
        # spectral
        "tdesktop"
        "stable.nheko"
        "irssi"
        "chromium"
        "brave"
        "aria2"
        "timewarrior"
        # tigervnc
        "tinc"
        "tcpdump"
        "geoipWithDatabase"
        "syncthing"
        "sslh"
        "miniupnpc_2"
        "miniupnpd"
        "gupnp-tools"
        "strongswan"
        "stunnel"
        "shadowsocks-libev"
        "v2ray"
        "clash"
        # # simplescreenrecorder
        # sloccount
        # # slop
        # # smartmontools
        # # soapui
        "telnet"
        "socat"
        "websocat"
        "neomutt"
        "mu"
        "midori"
        # palemoon
        # "luakit"
        "firefox"
        "tridactyl-native"
        "sshuttle"
        "youtube-dl"
        "offlineimap"
      ];
    }
    {
      name = "system";
      priority = 20;
      packages = getPackages [
        "myPackages.nur-combined.repos.kalbasit.nixify"
        "udiskie"
        "acpi"
        "wine"
        "winetricks"
        "usbutils"
        "nethogs"
        "powertop"
        "fail2ban"
        "qemu"
        "aqemu"
        "udisks"
        "smbclient"
        "cifs-utils"
        # filezilla
        "nix-review"
        "nix-prefetch-scripts"
        "nix-prefetch-github"
        "nix-universal-prefetch"
        "pulsemixer"
        "pavucontrol"
        "pciutils"
        "ntfs3g"
        "gparted"
        "gnupg"
        "gptfdisk"
        "at"
        "git"
        "gitRepo"
        "exercism"
        "coreutils"
        "coreutils-prefixed"
        # notify-osd
        "sxhkd"
        "mimeo"
        "libsecret"
        "gnome3.gnome-keyring"
        "gnome3.libgnome-keyring"
        "gnome3.seahorse"
        "mlocate"
        "htop"
        "ytop"
        "iotop"
        "inotifyTools"
        "noti"
        "gnutls"
        # iw
        "lsof"
        "hardinfo"
        "dmenu"
        "dpkg"
        "debootstrap"
        "dmidecode"
        "bind"
        "ldns"
        "smartdns"
        "bridge-utils"
        # dnstracer
        # # doublecmd-gtk2
        # dropbox
        # dropbox-cli
        # dstat
        "dunst"
        "e2fsprogs"
        # # ebook-tools
        # # eclipse-java
        "efibootmgr"
        # "dbus"
        "linuxHeaders"
        "cryptsetup"
        "compton"
        "btrbk"
        "btrfs-progs"
        "exfat"
        "i3blocks"
        "i3-gaps"
        "i3lock"
        "i3status"
      ];
    }
    {
      name = "document";
      priority = 45;
      packages = getPackages [
        "pdf2djvu"
        "calibre"
        "fbreader"
        "languagetool"
        "proselint"
        "sigil"
        "wordnet"
        "stable.haskellPackages.patat"
        "myPackages.hunspell"
        "myPackages.aspell"
        "pdfgrep"
        "pdfpc"
        "djview"
        "gnumeric"
        # qpdfview
        "plantuml"
        "texmacs"
        "texlab"
        "myPackages.texLive"
        # "texlab"
        "auctex"
        "mupdf"
        "graphviz"
        "impressive"
        "gnuplot"
        "goldendict"
        "kdeApplications.okular"
        "anki"
        "zathura"
        "qpdfview"
        "myPackages.koreader"
        "abiword"
        "libreoffice"
        # zile
        "freemind"
        # "xmind"
        "zotero"
        "k2pdfopt"
        "pdftk"
        "jfbview"
        "jfbpdf"
        "djvulibre"
        "djvu2pdf"
      ];
    }
    {
      name = "utilities (preferred)";
      priority = 34;
      packages = getPackages [ "elfutils" ];
    }
    {
      name = "utilities";
      priority = 35;
      packages = getPackages [
        # ack
        # aha
        "lzma"
        "libuchardet"
        "recode"
        "maim"
        "mtpaint"
        "unison"
        "p7zip"
        "xarchiver"
        "lz4"
        "zip"
        "xclip"
        "kdeconnect"
        "adbfs-rootless"
        "asciinema"
        "pcmanfm"
        "xfce.thunar"
        "android-file-transfer"
        "qalculate-gtk"
        "bc"
        "go-2fa"
        # audacious
        "sshlatex"
        "tectonic"
        "patchelf"
        "libelf"
        # cachix
        # barcode
        # # bfg
        # bibtex2html
        # bibtool
        # bitlbee
        # blueberry
        # # bookworm
        # briss
        # byzanz
        # cadaver
        # calcurse
        # # castget
        # catfish
        # # ccat
        # # cclive
        # # cfv
        # cheat
        # # cinelerra-cv
        # clamav
        # cloc
        # cmst
        # codeblocks
        # # coolreader
        # coreutils
        # # cower
        # # cpanminus
        # # create_ap
        # # cronie
        # ctags
        # dash
        # davfs2
        # # dbus-cpp
        # # dconf-editor
        # # debtap
        # deluge # bittorrent
        # # d-feet
        # dhcpcd
        # dialog
        # # dictd
        # diffuse
        # diffutils
        # dillo
        # # elvish-git
        # # emms
        # entr
        # epdfview
        # # etckeeper
        # evince
        # evtest
        # exfat-utils
        # # exo
        # fakeroot
        # falkon
        # # fbgrab
        # fbida
        # # fbpad-git
        # # fbv
        # fdupes
        # feedreader
        # ffcast
        # figlet
        # file
        # # finch
        # findutils
        # fish
        # # flashfocus
        # flex
        # # garcon
        # # gaupol
        # gnunet
        # # gpick
        # gpsd
        # groff
        # guvcview
        # gv
        # gvfs
        # gzip
        # # hamster-time-tracker
        # handbrake
        # hardinfo
        # # hashdeep
        # haveged
        # hdparm
        # hugo
        # hwinfo
        # i7z
        # icdiff
        "iftop"
        "flamegraph"
        # ifuse
        # inetutils
        # inkscape
        # inotify-tools
        # iputils
        # ispell
        # jfsutils
        # jp2a
        # # katarakt-git
        # khal
        # kitty
        # kodi
        # krop
        # ksysguard
        # libgnome-keyring
        # libinput-gestures
        # libtool
        # libudev0-shim
        # libva-utils
        # libvdpau-va-gl
        # liferea
        # logrotate
        "lolcat"
        "copyq"
        "kpcli"
        # "bitwarden-cli"
        "keepassxc"
        "mkpasswd"
        "scrot"
        # lynx
        # mcabber
        # mcomix
        # # mconnect-git
        # mdadm
        # mg
        # mongodb
        # monit

        # most
        # mtpaint
        # # mujs-git
        # multitail
        "neovim"
        "kakoune"
        "kak-lsp"
        # netsurf
        # # # net-tools
        # # networkmanagerapplet
        # # nitrogen
        # # ntp
        # # numlockx
        # # # nyancat
        # okular
        # # openconnect
        # openvpn
        # # osmo
        # # parcellite
        # # pass
        # # pastebinit
        # # peek
        # # # persepolis
        # # pidgin
        # rustracer
        # # plan9port
        # # pngquant
        # # polybar
        # # procps-ng
        # # profanity
        # # psmisc
        # # pulseaudio
        # # pv
        # pwgen
        # pwsafe
        # # qalculate-gtk
        # qdirstat
        # # qpdf
        "qrencode"
        "zbar"
        # # reiserfsprogs
        # # rmlint
        "rofi"
        # # rsibreak
        # # scite
        "screen"
        "neofetch"
        # # screenfetch
        # # screenkey
        # # scrot
        # # # seahorse
        # # # selfspy-git
        # # speedcrunch
        "sshfs"
        "rsync"
        "filezilla"
        "rclone"
        "yandex-disk"
        "gnutar"
        "zstd"
        "gzip"
        "gnugrep"
        "gnused"
        "gawk"
        "subdl"
        "subtitleeditor"
        "espeak"
        # # surf
        # # sxiv
        # # synapse
        # # sysfsutils
        # # sysstat
        # # tabbed
        # # tasksh
        "taskwarrior"
        "dstask"
        # # tcllib
        "termite"
        # "termonad-with-packages"
        # # tesseract
        # # texinfo
        "thefuck"
        # # tk
        # # tlp
        # # unified-remote-server
        # unoconv
        "unzip"
        "urlscan"
        # usbutils
        # uzbl
        # vault
        # viewnior
        # vit
        # watson
        # workrave
        # xarchiver
      ];
    }
  ];
in {
  # Let Home Manager install and manage itself.
  # programs.home-manager.enable = true;
  # programs = {
  #   firefox = {
  #     enable = true;
  #     package = pkgs.firefox-devedition-bin;
  #   };
  # };

  home = {
    extraOutputsToInstall = [ "dev" "lib" "doc" "info" "devdoc" "out" ];
    packages = allPackages;
    # priority = builtins.trace 4 4;
  };
  manual.manpages.enable = false;
}
