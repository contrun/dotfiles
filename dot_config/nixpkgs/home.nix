{ config, pkgs, ... }:
let
  overridePriority = pkg: priority:
    pkg.overrideAttrs (oldAttrs: { meta = { priority = priority; }; });
  getAttr = attrset: path:
    builtins.foldl' (acc: x:
      if acc ? ${x} then
        acc.${x}
      else
        pkgs.lib.warn "${path} does not exists" null) attrset
    (builtins.splitVersion path);
  getPackages = list:
    (builtins.filter (x: x != null) (builtins.map (x: getAttr pkgs x) list));
  allPackages = builtins.foldl' (acc: collection:
    acc ++ (builtins.map (pkg: overridePriority pkg collection.priority)
      collection.packages)) [ ] packageCollection;
  packageCollection = [
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
        "bind"
        "silver-searcher"
        "ack"
        "patch"
        "pandoc"
        "parallel"
        "nnn"
        "broot"
        "ncdu"
        "links"
        "jq"
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
        "w3m"
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
      name = "development tools";
      priority = 40;
      packages = getPackages [
        "cmake"
        "meson"
        "ninja"
        "bashdb"
        "bear"
        "rustup"
        "cargo-edit"
        "cargo-tree"
        "cargo-xbuild"
        # cargo-update
        "cargo-generate"
        "racket"
        "ruby"
        "zeal"
        "vagrant"
        "shellcheck"
        # stdman
        # stdmanpages
        "ccls"
        # rls
        "astyle"
        "postgresql"
        "myIdrisEnv"
        "myPackages.elba"
        "pydb"
        "protobuf"
        "capnproto"
        "gflags"
        "direnv"
        "lorri"
        "yarn"
        "redis"
        "meld"
        "clang-tools"
        "html-tidy"
        "radare2"
        "luarocks"
        "xmlstarlet"
        "nasm"
        "go"
        "awscli"
        "sqlitebrowser"
        "sqlite"
        "mitscheme"
        "guile"
        "myEmacs"
        "mu"
        "tsung"
        "wrk"
        "yq-go"
        "dhall"
        # dhall.prelude
        # dhall-bash
        # dhall-json
        "rlwrap"
        "git-revise"
        "git-crypt"
        "gitAndTools.hub"
        "gitAndTools.lab"
        "gitAndTools.git-extras"
        "gitAndTools.git-hub"
        "gitAndTools.git-annex"
        "gitAndTools.diff-so-fancy"
        "vscodium"
        # vscode
        "jetbrains.idea-community"
        # jetbrains.pycharm-community
        # haskellIdeEngine
        # haskellPackages.ihaskell
        # haskellPackages.ihaskell-widgets
        # spyder
        "go2nix"
        # clang
        "gnum4"
        "lldb"
        "gcc"
        "linuxPackages_latest.bcc"
        "rr"
        "gdb"
        "gdbgui"
        "valgrind"
        "wabt"
        # "wasm-pack"
        # wasm-strip
        # "wasm-bindgen-cli"
        "hexyl"
        "fd"
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
        "gnumake"
        "cntr"
        "docker"
        "docker_compose"
        # The following does not exist on nixpkgs yet
        # kubernix
        "terraform"
        "kubernetes"
        "kubernetes-helm"
        "kube3d"
        "k9s"
        "minikube"
        "universal-ctags"
        "binutils"
        "bison"
        "stable.tldr-hs"
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
        "android-studio"
        "jq"
        "coq"
        "bundix"
        "buildah"
        "ansible"
        "myPackages.hie"
        "nodejs"
        "nodePackages.prettier"
        # vscode-extensions.ms-python.python
        # stable.hadolint
        "haskellPackages.ormolu"
        "solargraph"
        "nodePackages.dockerfile-language-server-nodejs"
        "nodePackages.bash-language-server"
        "nodePackages.typescript-language-server"
        "nodePackages.ocaml-language-server"
        # ocamlPackages_latest.merlin
        # ocamlPackages_latest.utop
        "opam"
        "ocaml"
        "sqlint"
        "dotty"
        "sbt-extras"
        "gradle"
        "maven"
        "ant"
        "coursier"
        "scala"
        "scalafmt"
        "metals"
        "almond"
        # ihaskell
        "shfmt"
        "erlang"
        "elixir"
        "myPackages.elixir-ls"
        "pkgconfig"
        "zlib"
        "gmp"
        "libpng"
        "openssl"
        "glib-networking"
        "myPythonEnv"
        "myHaskellEnv"
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
        "radiotray-ng"
        "clementine"
        "rhythmbox"
        "mplayer"
        "mps-youtube"
        "mpv"
        "feh"
        "sxiv"
        "arandr"
        "# virtualbox"
        "vlc"
        "exiv2"
        "imagemagick7"
      ];
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
        "iperf"
        "openssh"
        "insomnia"
        "mitmproxy"
        "openssl"
        "redsocks"
        "wget"
        "asciidoctor"
        "hugo"
        "you-get"
        "uget"
        "wireguard"
        # qutebrowser
        # telegram-cli
        # spectral
        "tdesktop"
        "nheko"
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
        "strongswan"
        "stunnel"
        "shadowsocks-libev"
        "v2ray"
        # # simplescreenrecorder
        # sloccount
        # # slop
        # # smartmontools
        # # soapui
        "telnet"
        "socat"
        "neomutt"
        "mu"
        "midori"
        # palemoon
        "luakit"
        "firefox-devedition-bin"
        "sshuttle"
        # youtube-dl
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
        "usbutils"
        "powertop"
        "fail2ban"
        "qemu"
        "aqemu"
        "udisks"
        "smbclient"
        "cifs-utils"
        # filezilla
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
        "dmidecode"
        # dnstracer
        # # doublecmd-gtk2
        # dpkg
        # dropbox
        # dropbox-cli
        # dstat
        "dunst"
        "e2fsprogs"
        # # ebook-tools
        # # eclipse-java
        "efibootmgr"
        "dbus"
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
        "myHunspell"
        "myAspell"
        "pdfgrep"
        "pdfpc"
        "djview"
        "gnumeric"
        # qpdfview
        "plantuml"
        "texmacs"
        "myTexLive"
        "texlab"
        "auctex"
        "mupdf"
        "graphviz"
        "impressive"
        "gnuplot"
        "goldendict"
        "kdeApplications.okular"
        "anki"
        "zathura"
        "myPackages.koreader"
        "abiword"
        "libreoffice"
        # zile
        "freemind"
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
        "zip"
        "xclip"
        "adbfs-rootless"
        "asciinema"
        "pcmanfm"
        "android-file-transfer"
        "qalculate-gtk"
        "bc"
        "go-2fa"
        # audacious
        "sshlatex"
        "tectonic"
        "patchelf"
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
        # lolcat
        "copyq"
        "kpcli"
        "bitwarden-cli"
        "keepassxc"
        "scrot"
        # lynx
        # mcabber
        # mcomix
        # # mconnect-git
        # mdadm
        # mg
        # mongodb
        # monit
        # moreutils
        # most
        # mtpaint
        # # mujs-git
        # multitail
        "neovim"
        "kakoune"
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
        "rclone"
        "gnutar"
        "gzip"
        "gnugrep"
        "gnused"
        "gawk"
        "subdl"
        "subtitleeditor"
        # # surf
        # # sxiv
        # # synapse
        # # sysfsutils
        # # sysstat
        # # tabbed
        # # tasksh
        "taskwarrior"
        # # tcllib
        "termite"
        "stable.termonad-with-packages"
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
  programs.home-manager.enable = true;
  home = {
    extraOutputsToInstall = [ "dev" "lib" "doc" "info" "devdoc" ];
    packages = allPackages;
    # priority = builtins.trace 4 4;
  };
}
