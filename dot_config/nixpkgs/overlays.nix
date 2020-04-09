let
  unstable = (import <unstable> { });
  stable = (import <stable> { });
  originalNixpkgs = import <nixpkgs> { };

  mySources = import ./nix/pkgs.nix { pkgs = originalNixpkgs; };
  # mySources = import ./nix/sources.nix;

  mozOverlay = import mySources.nixpkgs-mozilla;

  emacsOverlay = import mySources.emacs-overlay;

  myOverlay = self: super: {
    my-all = with self;
      buildEnv {
        name = "my-all";
        meta = { priority = 50; };
        # fuck it. https://github.com/NixOS/nixpkgs/issues/7425#issuecomment-296408581
        # a higher value represents a lower priority.
        # default is 5
        paths = [
          my-commandline
          my-devtools
          my-devlibs
          my-multimedia
          my-network
          my-system
          my-utilities
          my-document
        ];
      };

    my-commandline = with self;
      buildEnv {
        name = "my-commandline";
        meta = { priority = 30; };
        paths = [
          alacritty
          bash-completion
          zsh-completions
          pgcli
          mycli
          sdcv
          ammonite
          autojump
          remind
          ranger
          rename
          ripgrep
          file
          bind
          silver-searcher
          ack
          patch
          pandoc
          parallel
          nnn
          broot
          ncdu
          links
          jq
          curl
          unrar
          bzip2
          mc
          most
          pstree
          yaft
          st
          stow
          strace
          linuxPackages_latest.bpftrace
          mtr
          lynx
          elinks
          wget
          w3m
          autorandr
          # xournal
          wgetpaste
          tmux
          traceroute
          tree
          # sl
          fbterm
          fasd
          fortune
          # fpp
          fzf
          cowsay
          bashInteractive
          bashCompletion
        ];
      };

    my-devtools = with self;
      buildEnv {
        name = "my-devtools";
        meta = { priority = 20; };
        paths = [
          cmake
          meson
          ninja
          bashdb
          bear
          rustup
          cargo-edit
          cargo-tree
          cargo-xbuild
          # cargo-update
          cargo-generate
          racket
          ruby
          zeal
          vagrant
          shellcheck
          # stdman
          # stdmanpages
          ccls
          # rls
          astyle
          postgresql
          myIdrisEnv
          myPackages.elba
          pydb
          protobuf
          capnproto
          gflags
          direnv
          lorri
          yarn
          redis
          meld
          clang-tools
          html-tidy
          radare2
          luarocks
          xmlstarlet
          nasm
          go
          awscli
          sqlitebrowser
          sqlite
          mitscheme
          guile
          myEmacs
          mu
          tsung
          wrk
          yq-go
          dhall
          # dhall.prelude
          # dhall-bash
          # dhall-json
          rlwrap
          git-revise
          git-crypt
          gitAndTools.hub
          gitAndTools.lab
          gitAndTools.git-extras
          gitAndTools.git-hub
          gitAndTools.git-annex
          gitAndTools.diff-so-fancy
          vscodium
          # vscode
          jetbrains.idea-community
          # jetbrains.pycharm-community
          # haskellIdeEngine
          # haskellPackages.ihaskell
          # haskellPackages.ihaskell-widgets
          # spyder
          go2nix
          # clang
          m4
          lldb
          gcc
          linuxPackages_latest.bcc
          rr
          gdb
          gdbgui
          valgrind
          wabt
          wasm-pack
          # wasm-strip
          wasm-bindgen-cli
          hexyl
          fd
          exa
          firecracker
          delve
          pkgconfig
          autoconf
          libtool
          geany
          # gettext
          # # gkeyring
          # # glances
          distcc
          gnumake
          cntr
          docker
          docker_compose
          # The following does not exist on nixpkgs yet
          # kubernix
          terraform
          kubernetes
          kubernetes-helm
          kube3d
          k9s
          minikube
          universal-ctags
          binutils
          bison
          stable.tldr-hs
          cht-sh
          autokey
          automake
          autossh
          mosh
          sshpass
          dfeet
          sqlitebrowser
          # awesome
          # axel
          baobab
          neovim-remote
          android-file-transfer
          # androidenv.platformTools
          # adoptopenjdk-jre-openj9-bin-11
          # android-platform-tools
          colordiff
          android-studio
          jq
          coq
          bundix
          buildah
          ansible
          myPackages.hie
          nodejs
          nodePackages.prettier
          # vscode-extensions.ms-python.python
          # stable.hadolint
          haskellPackages.ormolu
          solargraph
          nodePackages.dockerfile-language-server-nodejs
          nodePackages.bash-language-server
          nodePackages.typescript-language-server
          nodePackages.ocaml-language-server
          # ocamlPackages_latest.merlin
          # ocamlPackages_latest.utop
          opam
          ocaml
          sqlint
          dotty
          # sbt
          sbt-extras
          gradle
          maven
          ant
          coursier
          scala
          scalafmt
          metals
          almond
          # ihaskell
          shfmt
          erlang
          elixir
          myPackages.elixir-ls
          pkgconfig
        ];
      };

    my-devlibs = with self;
      buildEnv {
        name = "my-devlibs";
        meta = { priority = 40; };
        paths = [
          zlib
          libpng
          openssl.dev
          glib-networking
          myPythonEnv
          # myHaskellEnv
          perlPackages.Appcpanminus
          perlPackages.locallib
          perlPackages.Appperlbrew
        ];
      };

    my-multimedia = with self;
      buildEnv {
        name = "my-multimedia";
        meta = { priority = 40; };
        paths = [
          gifsicle
          # gimp
          ncpamixer
          maim
          pavucontrol
          exiftool
          flac
          mpc_cli
          ncmpcpp
          shntool
          sox
          pamixer
          imv
          cmus
          radiotray-ng
          clementine
          rhythmbox
          mplayer
          mps-youtube
          mpv
          feh
          sxiv
          arandr
          # virtualbox
          vlc
          exiv2
          imagemagick7
        ];
      };

    my-network = with self;
      buildEnv {
        name = "my-network";
        meta = { priority = 25; };
        paths = [
          httpie
          wireshark
          nmap
          # slirp4netns
          proxychains
          speedtest-cli
          privoxy
          badvpn
          connect
          iperf
          openssh
          insomnia
          (mitmproxy.overrideAttrs (attrs: { doInstallCheck = false; }))
          openssl
          redsocks
          wget
          asciidoctor
          hugo
          you-get
          uget
          wireguard
          # qutebrowser
          # telegram-cli
          # spectral
          tdesktop
          nheko
          irssi
          chromium
          brave
          aria2
          timewarrior
          # tigervnc
          tinc
          tcpdump
          geoipWithDatabase
          syncthing
          sslh
          strongswan
          stunnel
          shadowsocks-libev
          v2ray
          # # simplescreenrecorder
          # sloccount
          # # slop
          # # smartmontools
          # # soapui
          telnet
          socat
          neomutt
          mu
          midori
          # palemoon
          luakit
          firefox-devedition-bin
          sshuttle
          # youtube-dl
          offlineimap
        ];
      };

    my-system = with self;
      buildEnv {
        name = "my-system";
        meta = { priority = 10; };
        paths = [
          myPackages.nur-combined.repos.kalbasit.nixify
          udiskie
          acpi
          wine
          usbutils
          powertop
          fail2ban
          qemu
          aqemu
          udisks
          smbclient
          cifs-utils
          # filezilla
          nix-prefetch-scripts
          nix-prefetch-github
          nix-universal-prefetch
          pulsemixer
          pavucontrol
          pciutils
          utillinux
          ntfs3g
          gparted
          gnupg
          gptfdisk
          at
          git
          gitRepo
          exercism
          coreutils
          # notify-osd
          sxhkd
          mimeo
          libsecret
          gnome3.gnome-keyring
          gnome3.libgnome-keyring
          gnome3.seahorse
          mlocate
          htop
          ytop
          iotop
          inotifyTools
          noti
          gnutls
          # iw
          lsof
          hardinfo
          dmenu
          dmidecode
          # dnstracer
          # # doublecmd-gtk2
          # dpkg
          # dropbox
          # dropbox-cli
          # dstat
          dunst
          e2fsprogs
          # # ebook-tools
          # # eclipse-java
          efibootmgr
          dbus
          linuxHeaders
          cryptsetup
          compton
          btrbk
          btrfs-progs
          exfat
          i3blocks
          i3-gaps
          i3lock
          i3status
        ];
      };

    my-document = with self;
      buildEnv {
        name = "my-document";
        meta = { priority = 40; };
        paths = [
          pdf2djvu
          calibre
          fbreader
          languagetool
          proselint
          sigil
          wordnet
          myHunspell
          myAspell
          pdfgrep
          pdfpc
          djview
          gnumeric
          # qpdfview
          plantuml
          texmacs
          myTexLive
          texlab
          auctex
          mupdf
          graphviz
          impressive
          gnuplot
          goldendict
          kdeApplications.okular
          anki
          zathura
          myPackages.koreader
          abiword
          libreoffice
          # zile
          freemind
          zotero
          k2pdfopt
          pdftk
          jfbview
          jfbpdf
          djvulibre
          djvu2pdf
        ];
      };

    my-utilities = with self;
      buildEnv {
        name = "my-utilities";
        meta = { priority = 30; };
        paths = [
          # ack
          # aha
          lzma
          libuchardet
          recode
          maim
          mtpaint
          unison
          p7zip
          zip
          xclip
          adbfs-rootless
          asciinema
          pcmanfm
          android-file-transfer
          qalculate-gtk
          bc
          go-2fa
          # audacious
          sshlatex
          tectonic
          patchelf
          # cachix
          # barcode
          # # bfg
          # bibtex2html
          # bibtool
          # bitlbee
          # blueberry
          # # bookworm
          # briss
          # byobu
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
          # connman
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
          iftop
          flamegraph
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
          copyq
          kpcli
          bitwarden-cli
          keepassxc
          scrot
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
          neovim
          kakoune
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
          qrencode
          zbar
          # # reiserfsprogs
          # # rmlint
          rofi
          # # rsibreak
          # # scite
          screen
          neofetch
          # # screenfetch
          # # screenkey
          # # scrot
          # # # seahorse
          # # # selfspy-git
          # # speedcrunch
          sshfs
          rsync
          rclone
          gnutar
          gzip
          gnugrep
          gnused
          gawk
          subdl
          subtitleeditor
          # # surf
          # # sxiv
          # # synapse
          # # sysfsutils
          # # sysstat
          # # tabbed
          # # tasksh
          taskwarrior
          # # tcllib
          terminus_font
          termite
          stable.termonad-with-packages
          # # tesseract
          # # texinfo
          thefuck
          # # tk
          # # tlp
          # # unified-remote-server
          # unoconv
          unzip
          urlscan
          # usbutils
          # uzbl
          # vault
          # viewnior
          # vit
          # watson
          # workrave
          # xarchiver
        ];
      };

    myAspell = with super;
      aspellWithDicts (ps: with ps; [ en fr de en-science en-computers ]);

    myHunspell = with super;
      hunspellWithDicts (with hunspellDicts; [ en-us fr-any de-de ]);

    myXmonad = self.xmonad-with-packages.override {
      packages = haskellPackages:
        with haskellPackages; [
          xmobar
          taffybar
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

    myAllHaskellPackages = haskellPackages:
      with haskellPackages; rec {
        binaries = [
          # stylish-haskell
          hindent
          hlint
          # floskell
          # hfmt
          # brittany
          hoogle
          # stack2nix
          cabal2nix
          # cabal-install
          stack
          git-annex
          # hie
          # leksah
        ];
        libraries = [
          zlib
          classy-prelude
          lens
          aeson
          servant
          yesod
          yesod-form
          yesod-auth
          # mighttpd2
          warp-tls
          # postgrest
          optparse-applicative
          optparse-simple
          optparse-generic
          # hw-prim
          QuickCheck
          attoparsec
          # bloodhound
          texmath
          sbv
          vty
          pandoc-types
          proto-lens
          proto-lens-optparse
          pipes
          network
          http-client
          text
          propellor
          # esqueleto
          postgresql-simple
          persistent
          persistent-postgresql
          persistent-sqlite
          microlens
          dhall
          monad-logger
          mtl
          semigroups
          comonad
          vector
          massiv
          profunctors
          hashable
          unordered-containers
          HUnit
          hspec
          diagrams
          conduit
          conduit-extra
          arbtt
        ];
      };

    myHaskellCompilers = import mySources.old-ghc-nix { pkgs = self; };

    getMyHaskellEnv = pkgs:
      pkgs.haskellPackages.ghcWithPackages (haskellPackages:
        let allPackages = self.myAllHaskellPackages haskellPackages;
        in stable.lib.flatten (stable.lib.attrValues allPackages));

    myStableHaskellEnv = self.getMyHaskellEnv stable;

    myHaskellEnv = self.getMyHaskellEnv self;

    myIdrisEnv = stable.idrisPackages.with-packages
      (with stable.idrisPackages; [
        base
        effects
        contrib
        pruviloj
        lightyear
        protobuf
      ]);

    myPythonEnv = with super;
      python3Full.withPackages (ps:
        with ps; [
          pip
          chardet
          setuptools
          virtualenvwrapper
          yapf
          pycparser
          python-language-server
          pynvim
          pyparsing
          black
          requests
          jupyter
          ipykernel
          ipywidgets
          jupyter_client
          jupyter_console
          jupyter_core
          jupyterhub
          jupyterlab
          jupyterlab_launcher
          jupyterlab_server
          jupyterhub-ldapauthenticator
          jupytext
          nbconvert
          nbformat
          nbsphinx
          nbstripout
          matplotlib
          bokeh
          plotly
          altair
          bokeh
          vega.override
          ({ doCheckt = false; })
          vega_datasets
          numpy
          pandas
          scipy
          subliminal
          lxml
          django
          cookiecutter
          pillow
          elasticsearch-dsl
          pyyaml
        ]);

    python-rocksdb = with self;
      python2Packages.buildPythonPackage rec {
        pname = "python-rocksdb";
        version = "0.7.0";
        src = python2Packages.fetchPypi {
          inherit pname version;
          sha256 =
            "17d3335863e8cf8392eea71add33dab3f96d060666fe68ab7382469d307f4490";
        };
        buildInputs = [ sqlite rocksdb snappy zlib lz4 bzip2 ];
        meta = with stdenv.lib; {
          homepage = "https://github.com/twmht/python-rocksdb";
          description = "Python bindings for RocksDB";
        };
      };

    myPython2Env = with super;
      python2Full.withPackages
      (ps: with ps; [ pip setuptools sortedcontainers pycparser ]);
    # (ps: with ps; [ pip setuptools pynvim jmespath pylint flake8 ]);

    myTexLive = self.texlive.combine { inherit (self.texlive) scheme-full; };

    myEmacs = (super.emacsPackagesGen super.emacsGit).emacsWithPackages
      (epkgs: [ self.mu self.notmuch ]);

    almond = let
      scalaVersion = "2.12.8";
      almondVersion = "0.6.0";
    in super.runCommand "almond" { nativeBuildInputs = [ self.coursier ]; } ''
      export COURSIER_CACHE=$(pwd)
      mkdir -p $out/bin
      coursier bootstrap \
          -r jitpack \
          -i user -I user:sh.almond:scala-kernel-api_${scalaVersion}:${almondVersion} \
          sh.almond:scala-kernel_${scalaVersion}:${almondVersion} \
          -o $out/bin/almond
    '';

    myPackages = {
      hie = (import mySources.all-hies { }).selection { selector = p: p; };

      ihaskell = let
        compiler = "ghc865";
        releaseFile = "release.nix";
        ihaskellRelease = import "${mySources.ihaskell}/${releaseFile}";
        oldIhaskell = ihaskellRelease {
          inherit compiler;
          packages = haskellPackages:
            (self.myAllHaskellPackages haskellPackages).libraries;
        };
      in oldIhaskell.override { meta = { priority = 10; }; };

      ghcide = (import mySources.ghcide { }).ghcide-ghc865;

      pboy = import mySources.pboy;

      nur-combined = import mySources.nur-combined { pkgs = self; };

      elba = self.myPackages.nur-combined.repos.yurrriq.pkgs.elba;

      cached-nix-shell = import mySources.cached-nix-shell;

      ugdb = with self;
        with rustPlatform; {
          ugdb = buildRustPackage rec {
            pname = "ugdb";
            version = "0.1.4";

            src = fetchFromGitHub {
              owner = "ftilde";
              repo = pname;
              rev = version;
              sha256 = "0521x40f8clzg4g1gdf30mb7cnyrmripifssvdprgi51dcnblnyz";
            };

            cargoSha256 =
              "0bndhj441znd46ms7as66bi3ilr0glvi0wmj47spak90s97w67ci";
            nativeBuildInputs = [ pkgconfig ];
            buildInputs = [ openssl libgit2 ];
            LIBGIT2_SYS_USE_PKG_CONFIG = true;
          };
        };

      pyradio = with super;
        python3Packages.buildPythonPackage rec {
          pname = "pyradio";
          version = "HEAD";
          src = mySources.pyradio;

          doCheck = false;

          meta = with lib; {
            homepage = "http://www.coderholic.com/pyradio/";
            description = "Curses based internet radio player";
            license = licenses.mit;
          };
        };

      authinfo = with super;
        stdenv.mkDerivation rec {
          version = "HEAD";
          pname = "authinfo";
          src = mySources.authinfo;

          buildInputs = [ gpgme libassuan python ];
          nativeBuildInputs = [ autoreconfHook pkgconfig ];

          meta = with stdenv.lib; {
            description = "KISS password manager";
            homepage = "https://github.com/aartamonau/authinfo";
            platforms = platforms.all;
          };
        };

      # https://github.com/LnL7/dotfiles/blob/master/nixpkgs/pkgs/elixir-ls/default.nix
      elixir-ls = with super;
        stdenv.mkDerivation rec {
          name = "elixir-ls-${version}";
          version = "0.2.24";
          src = fetchurl {
            url =
              "https://github.com/JakeBecker/elixir-ls/releases/download/v${version}/elixir-ls.zip";
            sha256 = "0p0fnsqcm0572cgzzyki7i5wvhsa6hx7a9zw1jrgwczhcgvmgpab";
          };

          nativeBuildInputs = [ makeWrapper unzip ];

          unpackPhase = ''
            unzip -d elixir-ls $src
          '';

          installPhase = ''
            mkdir -p $out/bin $out/libexec
            cp -r elixir-ls $out/libexec
            chmod +x $out/libexec/elixir-ls/language_server.sh
            makeWrapper $out/libexec/elixir-ls/language_server.sh $out/bin/elixir-ls \
                --suffix PATH ":" "${elixir}/bin"
            makeWrapper $out/libexec/elixir-ls/language_server.sh $out/bin/language_server.sh \
                --suffix PATH ":" "${elixir}/bin"
          '';

          meta = with stdenv.lib; {
            description = "A language server for Elixir";
            # license = stdenv.lib.licenses.unspecified;
            homepage = "https://github.com/JakeBecker/elixir-ls";
            platforms = platforms.unix;
          };
        };

      koreader = with super;
        stdenv.mkDerivation rec {
          pname = "koreader";
          version = "2020.02";

          src = fetchurl {
            url =
              "https://github.com/koreader/koreader/releases/download/v${version}/koreader-${version}-amd64.deb";
            sha256 = "14cag2b8bhgvnx4f1sjrsw51l13c3c5v5ha60i85sffgslh9fjxz";
          };
          sourceRoot = ".";
          nativeBuildInputs = [ makeWrapper dpkg ];
          buildInputs = [ luajit gtk3-x11 SDL2 glib ];
          unpackCmd = "dpkg-deb -x ${src} .";

          dontConfigure = true;
          dontBuild = true;

          installPhase = ''
            mkdir -p $out/bin
            cp -R usr/* $out/
            cp ${luajit}/bin/luajit $out/lib/koreader/luajit
            wrapProgram $out/bin/koreader --prefix LD_LIBRARY_PATH : ${
              stdenv.lib.makeLibraryPath [ gtk3-x11 SDL2 glib ]
            }
          '';

          meta = with stdenv.lib; {
            homepage = "https://github.com/koreader/koreader";
            description =
              "An ebook reader application supporting PDF, DjVu, EPUB, FB2 and many more formats, running on Cervantes, Kindle, Kobo, PocketBook and Android devices";
            platforms = platforms.linux;
          };
        };
    };
  };

  shellsOverlay = self: super: {
    # This env is used to setup LD_LIBRARY_PATH appropirately in nix-shell
    # e.g. nix-shell -p zlib my-add-ld-library-path --run 'echo "$LD_LIBRARY_PATH"'
    my-add-ld-library-path = super.stdenv.mkDerivation {
      name = "my-add-ld-library-path";
      phases = [ "fixupPhase" ];
      setupHook = super.writeText "setupHook.sh" ''
        addLdLibraryPath() {
          addToSearchPath LD_LIBRARY_PATH $1/lib
        }

        addEnvHooks "$targetOffset" addLdLibraryPath
        echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
      '';
    };

    # Usage: nix-shell -E 'with import <nixpkgs> {}; myDropIntoBuildShell hello'
    myDropIntoBuildShell = pkg:
      pkg.overrideAttrs ({ nativeBuildInputs ? [ ], ... }: {
        nativeBuildInputs = nativeBuildInputs
          ++ [ self.my-drop-into-build-shell ];
      });

    my-drop-into-build-shell = super.stdenv.mkDerivation {
      # Copied from https://discourse.nixos.org/t/nix-shell-and-output-path/4043/5
      # Usage: nix-shell -E 'with import <nixpkgs> {}; hello.overrideAttrs ({ nativeBuildInputs ? [], ...} : { nativeBuildInputs = nativeBuildInputs ++ [ dropIntoBuildShellHook ]; })'
      name = "my-drop-into-build-shell";
      phases = [ "fixupPhase" ];
      setupHook = super.writeText "setupHook.sh" ''
        dropIntoBuildShell() {
          if [[ -v "NIX_SET_LOCAL_OUTPUTS" ]] && [[ "$NIX_SET_LOCAL_OUTPUTS" ]]; then
            return
          fi

          # Note: we override TMPDIR to avoid auditTmpdir failure
          # (outputs cannot be children of "$TMPDIR")
          export base="$(mktemp -t -d "build-$name.XXXXXXXXXX")"
          export TMPDIR="$base/tmpdir"
          mkdir -p "$TMPDIR"

          echo "dropIntoBuildShell: settings outputs in $base directory"
          for output in $outputs; do
            export "$output"="$base/$output"
          done

          echo "dropIntoBuildShell: moving to $TMPDIR"
          cd "$TMPDIR"

          echo "dropIntoBuildShell: will automatically run genericBuild"
          export shellHook+=" genericBuild"

          export NIX_SET_LOCAL_OUTPUTS=1
        }
        addEnvHooks "$hostOffset" dropIntoBuildShell
      '';
    };

    myBuildEnv = super.stdenv.mkDerivation {
      name = "my-build-env";
      nativeBuildInputs = [ super.pkg-config ];
      phases = [ "fixupPhase" ];
      setupHook = super.writeText "setupHook.sh" ''
        addPkgConfigPath() {
                addToSearchPath PKG_CONFIG_PATH $1/lib/pkgconfig
                addToSearchPath PKG_CONFIG_PATH $1/share/pkgconfig
        }

        addLdLibraryPath() {
                addToSearchPath LD_LIBRARY_PATH $1/lib
        }

        addEnvHooks "$targetOffset" addLdLibraryPath
        addEnvHooks "$targetOffset" addPkgConfigPath
        # echo "PKG_CONFIG_PATH=$PKG_CONFIG_PATH"
        # echo "LD_LIBRARY_PATH=$LD_LIBRARY_PATH"
      '';
    };

    myRustDevEnvFn = let
      defaultMozOverlay = import (builtins.fetchTarball
        "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz");
    in { pkgsPath ? <nixpkgs>, mozOverlay ? defaultMozOverlay
    , crossSystem ? null, channel ? "nightly" }:
    let
      pkgs = import pkgsPath {
        inherit crossSystem;
        overlays = [ mozOverlay ];
      };
      targets = [ pkgs.stdenv.targetPlatform.config "wasm32-unknown-unknown" ];
      myBuildPackageRust =
        pkgs.buildPackages.buildPackages.latest.rustChannels."${channel}".rust.override {
          inherit targets;
        };
      myRust =
        pkgs.rustChannels."${channel}".rust.override { inherit targets; };
    in with pkgs;
    let my_static_openssl = openssl.override { static = true; };
    in stdenv.mkDerivation {
      name = "my-rust-dev-env";
      # build time dependencies targeting the build platform
      depsBuildBuild = [ buildPackages.stdenv.cc ];
      HOST_CC = "cc";
      OPENSSL_LIB_DIR = "${my_static_openssl.out}/lib";
      OPENSSL_STATIC = "yes";
      OPENSSL_LIBRARIES = "${my_static_openssl.out}/lib";
      OPENSSL_INCLUDE_DIR = "${my_static_openssl.dev}/include";
      # build time dependencies targeting the host platform
      nativeBuildInputs = [ llvmPackages.libclang stdenv.cc.cc.lib pkgconfig ];
      buildInputs = [
        stdenv.cc.cc.lib
        libgcc
        llvmPackages.libclang
        llvmPackages.libstdcxxClang
        pkgconfig
        rocksdb
        my_static_openssl
        my_static_openssl.dev
        protobuf
        myRust
      ];
      CARGO_BUILD_TARGET = [ pkgs.stdenv.targetPlatform.config ];

      # run time dependencies
      LIBCLANG_PATH = "${llvmPackages.libclang}/lib";
      RUST_BACKTRACE = "full";
      PROTOC = "${protobuf}/bin/protoc";
    };

    myRustDevEnv = { ... }@args:
      self.myRustDevEnvFn args // {
        mozOverlay = mozOverlay;
      };
  };

  isInList = a: list: builtins.foldl' (acc: x: x == a || acc) false list;

  uniqueList = list:
    if list == [ ] then
      [ ]
    else
      let x = builtins.head list;
      in [ x ] ++ uniqueList (builtins.filter (e: e != x) list);

  recursivelyOverrideOutputsToInstall = attr:
    if builtins.isAttrs attr && attr ? meta && attr ? overrideAttrs then
      overrideOutputsToInstall attr [ "dev" ]
    else if builtins.isAttrs attr then
      builtins.mapAttrs (name: drv: recursivelyOverrideOutputsToInstall drv)
      attr
    else
      attr;

  overrideOutputsToInstall = attr: outputs:
    if !(builtins.isAttrs attr && attr ? meta && attr ? overrideAttrs && attr
      ? outputs) then
      attr
    else
      let
        myOutputsToInstall =
          builtins.filter (x: isInList x attr.outputs) outputs;
        oldOutputsToInstall = if attr.meta ? outputsToInstall then
          attr.meta.outputsToInstall
        else
          [ ];
        newOutputsToInstall =
          uniqueList (oldOutputsToInstall ++ myOutputsToInstall);
        newMeta = attr.meta // { outputsToInstall = newOutputsToInstall; };
      in attr.overrideAttrs (oldAttrs: { meta = newMeta; });

  # TODO: Below does not work.
  # additionalOutputsOverlay = self: super: recursivelyOverrideOutputsToInstall super;
  # TODO: This also does not work. I can not rebuild nixos with this
  # additionalOutputsOverlay = self: super:
  # builtins.mapAttrs (name: drv: overrideOutputsToInstall drv) super;

  additionalOutputsOverlay = self: super:
    let
      defaultOutputs = [ "doc" "dev" "lib" ];
      mkDefault = list:
        builtins.foldl' (acc: x: acc // { ${x} = defaultOutputs; }) { } list;
      merge = a1: a2:
        builtins.mapAttrs (name: outputs:
          if a2 ? name then uniqueList (outputs ++ a2.name) else outputs)
        (a2 // a1);
      mergeList = list: builtins.foldl' (acc: a: merge acc a) { } list;
      mkDrv = attrs:
        builtins.mapAttrs
        (name: outputs: overrideOutputsToInstall super.${name} outputs) attrs;
      mkDrvs = list: mkDrv (mergeList list);
    in mkDrvs [
      (mkDefault [ "zlib" "openssl" "libffi" ])
      {
        zlib = [ "static" ];
      }
    ];

in [
  mozOverlay
  emacsOverlay
  myOverlay
  shellsOverlay
  # additionalOutputsOverlay
]
