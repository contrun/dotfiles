#!/usr/bin/env bash
set -xe
modules=$(
        grep -v '^\s*#' <<EOF
https://github.com/robbyrussell/oh-my-zsh.git
.oh-my-zsh

https://github.com/vivien/i3blocks-contrib.git
.config/i3blocks-contrib

https://github.com/gpakosz/.tmux.git
.tmux
cd ~ && ln -s -f ~/.tmux/.tmux.conf
https://github.com/tmux-plugins/tpm
.tmux/plugins/tpm

# https://github.com/farseer90718/vim-taskwarrior
# vim_runtime/my_plugins/vim-taskwarrior
#
https://github.com/wilsonchaney/pomodoro.git
.local/src/pomodoro

https://github.com/zsh-users/zaw.git
.zaw

https://github.com/skywind3000/z.lua.git
.z.lua

EOF
)

files=$(
        grep -v '^\s*#' <<EOF
https://raw.githubusercontent.com/danishprakash/goodreadsh/master/goodreads
.local/bin/goodreads
chmod +x .local/bin/goodreads
EOF
)

die() {
        echo "$@"
        exit 1
}

do_download_install() {
        local filename="$1"
        local url="$2"
        echo "downloading $url into $filename"
        curl --create-dirs -o "$filename" "$url"
}

do_download_uninstall() {
        rm -r --interactive=never "$@"
}

do_download_reinstall() {
        do_download_uninstall "$@"
        do_download_install "$@"
}

do_download() {
        local action="$1"
        local urls="$(awk 'NR % 3 == 1' <<<"$files")"
        local filenames="$(awk 'NR % 3 == 2' <<<"$files")"
        local scripts="$(awk 'NR % 3 == 0' <<<"$files")"
        local filename url scripts
        for i in $(seq 1 $(wc -l <<<"$repos")); do
                filename="$HOME/$(sed -ne "${i}p" <<<"$filenames")"
                url="$(sed -ne "${i}p" <<<"$urls")"
                script="$(sed -ne "${i}p" <<<"$scripts")"
                do_download_"$action" "$filename" "$url" || die "${action}ing $repo into $dir failed"
                cd "$HOME"
                [[ -n "$script" ]] && eval "$script"
                cd -
        done
}

do_git_install() {
        local dir="$1"
        local repo="$2"
        echo "pulling $repo into $dir"
        if [[ ! -d "$dir" ]]; then
                mkdir -p "$dir"
                cd "$dir"
                git clone "$repo" .
        else
                cd "$dir"
                git pull
        fi
}

do_git_uninstall() {
        rm -r --interactive=never "$@"
}

do_git_reinstall() {
        do_git_uninstall "$@"
        do_git_install "$@"
}

do_git() {
        local action="$1"
        local repos="$(awk 'NR % 3 == 1' <<<"$modules")"
        local paths="$(awk 'NR % 3 == 2' <<<"$modules")"
        local scripts="$(awk 'NR % 3 == 0' <<<"$modules")"
        local dir repo script
        for i in $(seq 1 $(wc -l <<<"$repos")); do
                dir="$HOME/$(sed -ne "${i}p" <<<"$paths")"
                repo="$(sed -ne "${i}p" <<<"$repos")"
                script="$(sed -ne "${i}p" <<<"$scripts")"
                do_git_"$action" "$dir" "$repo" || die "${action}ing $repo into $dir failed"
                cd "$dir"
                [[ -n "$script" ]] && eval "$script"
                cd -
        done
}

act() {
        do_download "$@"
        do_git "$@"
}

case "$1" in
install | update | pull)
        shift
        act install "$@"
        ;;
uninstall | reinstall)
        act "$@"
        ;;
*)
        die "unrecognized options $*"
        ;;
esac
