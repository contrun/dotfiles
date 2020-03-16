#!/usr/bin/env bash
cd "$(dirname "$(readlink -f "$0")")"
get_github_latest() {
        curl -s "https://api.github.com/repos/$1/$2/releases/latest" | grep 'browser_' | cut -d\" -f4 | grep "$3"
}
list="$(
        cat <<EOF
https://www.emacswiki.org/emacs/download/dired%2b.el
dired+/dired+.sh
https://www.emacswiki.org/emacs/download/auto-capitalize.el
auto-capitalize/auto-capitalize.el
https://www.emacswiki.org/emacs/download/info%2b.el
info+/info+.el
EOF
)"
urls="$(awk 'NR % 2 != 0' <<<"$list")"
filenames="$(awk 'NR % 2 == 0' <<<"$list")"
for i in $(seq 1 $(wc <<<"$urls" | awk '{print $1}')); do
        url="$(sed -ne "${i}p" <<<"$urls")"
        filename="$(sed -ne "${i}p" <<<"$filenames")"
        curl --create-dirs -o "$filename" "$url"
done
