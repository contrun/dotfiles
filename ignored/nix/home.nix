{ config, pkgs, isMinimalSystem, ... }@args:
let
  largePackages = [
    "jetbrains.idea-ultimate"
    "jetbrains.clion"
    "jetbrains.webstorm"
    "jetbrains.datagrip"
    "jetbrains.goland"
    "jetbrains.pycharm-professional"
    "kubernetes"
    "minikube"
    "k3s"
    "gitkraken"
    "flink"
    "postman"
    "libreoffice"
    "myPackages.haskell"
    "androidStudioPackages.dev"
    "confluent-platform"
    "qemu"
    "clang"
    "llvmPackages_latest.llvm"
    "termonad-with-packages"
    "steam"
    "espeak"
    "vagrant"
    "firecracker"
    "code-server"
    "myPackages.texLive"
    "clojure-lsp"
  ];
  # To avoid clash within the buildEnv of home-manager
  overridePkg = pkg: func:
    if pkg ? overrideAttrs then
      pkg.overrideAttrs (oldAttrs: func oldAttrs)
    else
      builtins.trace "${pkg.name or pkg} does not have attribute overrideAttrs"
      pkg;
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
      vanillaPackage = getAttr attrset path;
      tryNewPath = newPath:
        if (newPath == path) then
          null
        else
          pkgs.lib.warn "Package ${path} does not exists, trying ${newPath}"
          (getAttr attrset newPath);
      nixpkgsPackage =
        tryNewPath (builtins.replaceStrings [ "myPackages." ] [ "" ] path);
      unstablePackage = tryNewPath "unstable.${path}";
    in if vanillaPackage != null then
      vanillaPackage
    else if nixpkgsPackage != null then
      nixpkgsPackage
    else if unstablePackage != null then
      unstablePackage
    else
      builtins.throw "${path} not found");
  # Emits a warning when package does not exist, instead of quitting immediately
  getPkg = attrset: path:
    if isMinimalSystem && (builtins.elem path largePackages) then
      builtins.trace "${path} will not be installed in a minimal system" null
    else
      (dontCheckPkg (getMyPkgOrPkg attrset path));
  getPackages = list:
    (builtins.filter (x: x != null) (builtins.map (x: getPkg pkgs x) list));
  allPackages = builtins.foldl' (acc: collection:
    acc ++ (builtins.map (pkg: changePkgPriority pkg collection.priority)
      collection.packages)) [ ] packageCollection;
  packageCollection = [
    {
      name = "command line tools (preferred)";
      priority = 48;
      packages = getPackages [ "parallel" ];
    }
    {
      name = "command line tools (unstable)";
      priority = 48;
      packages = getPackages [ ];
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
        "doxygen"
        "libxslt"
        "xmlto"
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
        "mtr"
        "lynx"
        "elinks"
        "wget"
        "w3m-full"
        "ueberzug"
        "autorandr"
        "xournal"
        "xournalpp"
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
      name = "development tools (more preferred)";
      priority = 38;
      packages = getPackages [
        "myPackages.python"
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
        "stdman"
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
        "bazel"
        "clang"
        # "llvmPackages_latest.llvm"
        "bashdb"
        "bear"
        "upx"
        "rustup"
        "gopls"
        "rust-analyzer"
        "python-language-server"
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
        "stdmanpages"
        "ccls"
        "astyle"
        "caddy"
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
        "bubblewrap"
        "firejail"
        "lorri"
        "yarn"
        "redis"
        "rdbtools"
        "meld"
        "ccache"
        "clang-tools"
        "clang-analyzer"
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
        "dhall-nix"
        "dhall-lsp-server"
        "rlwrap"
        "git-revise"
        "git-crypt"
        "gitkraken"
        "gitAndTools.hub"
        "gitAndTools.gh"
        "gitAndTools.lab"
        "gitAndTools.tig"
        "gitAndTools.git-extras"
        "gitAndTools.git-hub"
        "gitAndTools.git-annex"
        "gitAndTools.git-subrepo"
        "gitAndTools.diff-so-fancy"
        "vscode"
        "code-server"
        "insomnia"
        "jwt-cli"
        "ostree"
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
        "syslinux"
        # "rr"
        "gdbgui"
        "valgrind"
        "wabt"
        "emscripten"
        "arrow-cpp"
        "wasmer"
        "wasmtime"
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
        "xxd"
        "bless"
        "dhex"
        "yj"
        "exa"
        "firecracker"
        "delve"
        "pkgconfig"
        "autoconf"
        "libtool"
        "autogen"
        "geany"
        "cdrkit"
        "gettext"
        "glances"
        "distcc"
        "remake"
        "cntr"
        "docker"
        "docker_compose"
        "lens"
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
        "python3Packages.xdot"
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
        "vite"
        "nodejs_latest"
        "nodePackages.prettier"
        "hadolint"
        "haskellPackages.ormolu"
        "haskellPackages.hlint"
        "haskellPackages.cabal-fmt"
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
        # "dune"
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
        # "julia"
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
        # "cryptopp"
        "gsasl"
        "fuse"
        "fuse3"
        "stress-ng"
        "boost17x"
        "libunwind"
        "gmp"
        "libevdev"
        "libcap"
        "libuuid"
        "libxml2"
        "expat"
        "libpng"
        "libjpeg"
        "libwebp"
        "openssl"
        "libnfnetlink"
        "mkcert"
        "glib-networking"
        "myPackages.python2"
        "myPackages.haskell"
        "perlPackages.Appcpanminus"
        "perlPackages.locallib"
        "perlPackages.Appperlbrew"
        "perlPackages.Po4a"
      ];
    }
    {
      name = "multimedia";
      priority = 60;
      packages = getPackages [
        "gifsicle"
        # "gimp"
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
        # "clementine"
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
      packages = getPackages [ "firefox-nightly-bin" ];
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
        "conntrack-tools"
        "tor"
        # "resilio-sync"
        "iperf"
        "gperf"
        "openssh"
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
        "qutebrowser"
        # telegram-cli
        "spectral"
        "tdesktop"
        "teams"
        # "jitsi-meet"
        "jitsi-meet-electron"
        "nheko"
        "irssi"
        "chromium"
        "brave"
        "aria2"
        "timewarrior"
        "tinc"
        "nebula"
        "tcpdump"
        "geoipWithDatabase"
        # "syncthing"
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
        # "aqemu"
        "udisks"
        "smbclient"
        "cifs-utils"
        "appimage-run"
        "nix-review"
        "nix-prefetch-scripts"
        "nix-prefetch-github"
        "nix-universal-prefetch"
        "pulsemixer"
        "pavucontrol"
        "pciutils"
        "ntfs3g"
        "gparted"
        "parted"
        "mtools"
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
        "bottom"
        "iotop"
        "inotifyTools"
        "noti"
        "barrier"
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
        "f2fs-tools"
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
        # "pdf2djvu"
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
        "myPackages.aspell"
        "pdfgrep"
        "pdfpc"
        "djview"
        "gnumeric"
        "plantuml"
        "texmacs"
        "texlab"
        # "myPackages.texLive"
        "texlab"
        "auctex"
        # "mupdf"
        "graphviz"
        "drawio"
        "impressive"
        "gnuplot"
        "goldendict"
        "okular"
        "anki"
        "zathura"
        "qpdfview"
        "koreader"
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
        "unionfs-fuse"
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
        "cachix"
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
        "xorg.xwd"
        "xorg.xwininfo"
        "fakeroot"
        # fbgrab
        "fbida"
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
        "lshw"
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
        "gnome3.gnome-screenshot"
        "mcabber"
        "mdadm"
        "mg"
        "mongodb"
        "monit"
        "mujs"
        "multitail"
        "neovim"
        "kakoune"
        "kak-lsp"
        "rnix-lsp"
        "ntp"
        "nyancat"
        "openconnect"
        "openvpn"
        "osmo"
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
        "rmlint"
        "rofi"
        "rsibreak"
        # "scite"
        "screen"
        "neofetch"
        "screenkey"
        # seahorse
        "speedcrunch"
        "sshfs"
        # "s3ql"
        "ssh-to-pgp"
        "sftpman"
        "x11vnc"
        "tigervnc"
        "wayvnc"
        "remmina"
        "rsync"
        "filezilla"
        "rclone"
        "yandex-disk"
        "nextcloud-client"
        "gnutar"
        "zstd"
        "gzip"
        "gnugrep"
        "gnused"
        "gawk"
        "dos2unix"
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
        "vit"
        "dstask"
        "tcl"
        "tcllib"
        "termite"
        "termonad-with-packages"
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
    stateVersion = "21.05";
  };
  manual.manpages.enable = true;
}
