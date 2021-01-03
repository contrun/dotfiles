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
        pkgs.lib.warn "Package ${path} does not exists" null) attrset
    (pkgs.lib.splitString "." path);
  getMyPkgOrPkg = attrset: path:
    builtins.trace "Installing ${path}" (let
      p = getAttr attrset path;
      newPath = builtins.replaceStrings [ "myPackages." ] [ "" ] path;
      shouldTryNewPath = newPath != path;
    in if p != null then
      p
    else if shouldTryNewPath then
      pkgs.lib.warn "Package ${path} does not exists, trying ${newPath}"
      (getAttr attrset newPath)
    else
      null);
  # Emits a warning when package does not exist, instead of quitting immediately
  getPkg = attrset: path: dontCheckPkg (getMyPkgOrPkg attrset path);
  getPackages = list:
    (builtins.filter (x: x != null) (builtins.map (x: getPkg pkgs x) list));
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
        # "pandoc"
        "moreutils"
        "nnn"
        "glib"
        "broot"
        "navi"
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
        "xournal"
        "wgetpaste"
        "ix"
        "tmux"
        "traceroute"
        "tree"
        # sl
        "fbterm"
        "fasd"
        "fortune"
        "fpp"
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
        # "hadoop_3_1"
        "gnumake"
        "gitAndTools.git-sync"
        "opencl-headers"
      ];
    }
    {
      name = "development tools";
      priority = 40;
      packages = getPackages [
        "gnumake"
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
        "cargo-update"
        "cargo-generate"
        "racket"
        "myPackages.ruby"
        "zeal"
        "vagrant"
        "shellcheck"
        # "zig"
        # "stdman"
        "stdmanpages"
        "ccls"
        "astyle"
        "postgresql"
        "caddy"
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
        # "tsung"
        "wrk"
        "yq-go"
        "dhall"
        # "dhall-bash"
        "dhall-json"
        # "dhall-nix"
        "dhall-lsp-server"
        "rlwrap"
        "git-revise"
        "git-crypt"
        "gitkraken"
        "gitAndTools.hub"
        "gitAndTools.lab"
        "gitAndTools.tig"
        "gitAndTools.git-extras"
        "gitAndTools.git-hub"
        # "gitAndTools.git-annex"
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
        "clinfo"
        "opencl-icd"
        # "cudatoolkit"
        "linuxPackages_latest.bcc"
        "rr"
        "gdbgui"
        "valgrind"
        "wabt"
        "emscripten"
        "arrow-cpp"
        "wasmer"
        "wasm-pack"
        "wasm-bindgen-cli"
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
        "gettext"
        "glances"
        "distcc"
        "remake"
        "cntr"
        "docker"
        "docker_compose"
        # "lens"
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
        "libguestfs-with-appliance"
        "python3Packages.binwalk"
        "binutils"
        "bison"
        "tldr-hs"
        "cht-sh"
        "autokey"
        "automake"
        "autossh"
        "mosh"
        "eternal-terminal"
        "sshpass"
        "dfeet"
        "sqlitebrowser"
        "axel"
        "baobab"
        "neovim-remote"
        "android-file-transfer"
        "androidenv.androidPkgs_9_0.platform-tools"
        "colordiff"
        "androidStudioPackages.dev"
        "jq"
        "coq"
        "bundix"
        "buildah"
        "ansible"
        "gomplate"
        "nodejs_latest"
        "nodePackages.prettier"
        # vscode-extensions.ms-python.python
        "hadolint"
        "haskellPackages.ormolu"
        "haskellPackages.hlint"
        # "haskellPackages.cabal-fmt"
        "haskellPackages.ghcid"
        "haskellPackages.implicit-hie"
        "solargraph"
        "python-language-server"
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
        # "myPackages.jupyter"
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
        "libjpeg"
        "openssl"
        "glib-networking"
        # "myPackages.python"
        "myPackages.haskellStable"
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
        "gimp"
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
        "termshark"
        "nmap"
        "zmap"
        "slirp4netns"
        "squid"
        "proxychains"
        "speedtest-cli"
        "privoxy"
        "badvpn"
        "connect"
        "zeronet"
        "tor"
        # "resilio-sync"
        "iperf"
        "openssh"
        "insomnia"
        "mitmproxy"
        "ettercap"
        "redsocks"
        "wget"
        "asciidoctor"
        "hugo"
        "you-get"
        "uget"
        "udptunnel"
        "wireguard"
        # "qutebrowser"
        # telegram-cli
        "spectral"
        "tdesktop"
        "teams"
        "jitsi-meet"
        "jitsi-meet-electron"
        "nheko"
        "irssi"
        "chromium"
        "brave"
        "aria2"
        "timewarrior"
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
        "simplescreenrecorder"
        "cloc"
        "sloc"
        "sloccount"
        "slop"
        "smartmontools"
        "soapui"
        "telnet"
        "socat"
        "websocat"
        "neomutt"
        "mu"
        "midori"
        "palemoon"
        "luakit"
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
        # "myPackages.nur-combined.repos.kalbasit.nixify"
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
        "kaggle"
        "coreutils"
        "coreutils-prefixed"
        "notify-osd"
        "sxhkd"
        "mimeo"
        "libsecret"
        "gnome3.gnome-keyring"
        "gnome3.libgnome-keyring"
        "gnome3.seahorse"
        "mlocate"
        "htop"
        # "bottom"
        "iotop"
        "inotifyTools"
        "noti"
        "gnutls"
        "iw"
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
        "dnstracer"
        # doublecmd-gtk2
        "dstat"
        "dunst"
        "e2fsprogs"
        "eclipses.eclipse-java"
        "codeblocks"
        "efibootmgr"
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
        "bibtex2html"
        "bibtool"
        "briss"
        "pdf2djvu"
        "calibre"
        "fbreader"
        "ebook_tools"
        "coolreader"
        "languagetool"
        "proselint"
        "sigil"
        "wordnet"
        # "haskellPackages.patat"
        "myPackages.hunspell"
        # "myPackages.aspell"
        "pdfgrep"
        "pdfpc"
        "djview"
        "gnumeric"
        "plantuml"
        "texmacs"
        "texlab"
        "myPackages.texLive"
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
        "qpdfview"
        "myPackages.koreader"
        "abiword"
        "libreoffice"
        "zile"
        "freemind"
        "xmind"
        "zotero"
        # "k2pdfopt"
        "pdftk"
        # "jfbview"
        # "jfbpdf"
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
        "aha"
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
        "audacious"
        "sshlatex"
        "tectonic"
        "patchelf"
        "libelf"
        # "cachix"
        "barcode"
        "bitlbee"
        "blueberry"
        "bookworm"
        "byzanz"
        "calcurse"
        "castget"
        "catfish"
        # ccat
        # cfv
        "cheat"
        # cower
        "davfs2"
        "deluge"
        # d-feet
        "dialog"
        # dictd
        "diffutils"
        # emms
        "entr"
        "epdfview"
        "evince"
        "evtest"
        "exfat-utils"
        "xfce.exo"
        "fakeroot"
        # fbgrab
        "fbida"
        # fbpad-git
        "fbv"
        "fdupes"
        "feedreader"
        "ffcast"
        "figlet"
        # finch
        "findutils"
        "flex"
        # gaupol
        "groff"
        "gv"
        "gvfs"
        "bindfs"
        "proot"
        "hamster"
        "handbrake"
        "hashdeep"
        "haveged"
        "hdparm"
        "hwinfo"
        "icdiff"
        "iftop"
        "flamegraph"
        "ifuse"
        "inetutils"
        "inkscape"
        "iputils"
        "jp2a"
        "khal"
        "krop"
        "libgnome-keyring3"
        "libinput"
        "libinput-gestures"
        "logrotate"
        "lolcat"
        "copyq"
        "kpcli"
        "bitwarden-cli"
        "keepassxc"
        "mkpasswd"
        "scrot"
        "mcabber"
        # mconnect-git
        "mdadm"
        "mg"
        "mongodb"
        "monit"
        "mujs"
        "multitail"
        "neovim"
        "kakoune-unwrapped"
        "kak-lsp"
        "rnix-lsp"
        # "netsurf-browser"
        # net-tools
        # nitrogen
        "ntp"
        "nyancat"
        "openconnect"
        "openvpn"
        "osmo"
        # pass
        "pastebinit"
        "peek"
        "persepolis"
        "pidgin"
        "plan9port"
        "pngquant"
        "polybar"
        "procps-ng"
        "profanity"
        "psmisc"
        "pv"
        "pwgen"
        "pwsafe"
        "qdirstat"
        "qpdf"
        "qrencode"
        "zbar"
        # reiserfsprogs
        "rmlint"
        "rofi"
        "rsibreak"
        "scite"
        "screen"
        "neofetch"
        "screenkey"
        # seahorse
        "speedcrunch"
        "sshfs"
        # "sftpman"
        "remmina"
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
        "surf"
        "synapse"
        "sysfsutils"
        "sysstat"
        "tabbed"
        "tasksh"
        "taskwarrior"
        # "vit"
        "dstask"
        "tcl"
        "tcllib"
        "termite"
        # "termonad-with-packages"
        "tesseract"
        "texinfo"
        "thefuck"
        "tk"
        "tlp"
        "unoconv"
        "unzip"
        "urlscan"
        "vault"
        "viewnior"
        "watson"
        "workrave"
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
