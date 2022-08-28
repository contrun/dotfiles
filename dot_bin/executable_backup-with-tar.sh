#!/usr/bin/env bash
set -o nounset # Treat unset variables as an error
set -o errexit # To proceed, some commands must succeed
set -o xtrace  # make script easy to debug

# example usage:

usage() {
  cat <<-EOF
  Example backup workflow:
  du --max-depth=1 -h --apparent-size | sort -rh # show directory size
  clean-artifacts.sh ~ # clean building artifacts
  find ~ -size "+$((1024 * 1024 * 1024))c" # find large files to exclude from backup
  $0 -d ~/Workspace/rust-analyzer -e .cache -e .emacs.d -e .go -e .ccache -e .rustup -e .local/share -e .cargo -e .mail -e .docsets -e .stack -e .ivy2 -e .npm -e .sbt -e .vagrant.d -e .wine -e .m2 -e .oh-my-zsh -e .node -e .local/cache -e Ftemp -e borgbackup -e Backups # backup files
  $0
EOF
}

backup_directory="$PWD"
backup_file="backup.tar.zstd"
excluding_size=
declare -a excludes=()

while getopts "f:d:s:e:" opt; do
    case $opt in
    f)
        backup_file="$OPTARG"
        ;;
    d)
        backup_directory="$OPTARG"
        ;;
    s)
        excluding_size="$OPTARG"
        ;;
    e)
        excludes+=("$OPTARG")
        ;;
    \?)
        echo "Invalid option: -$OPTARG" >&2
        exit 1
        ;;
    esac
done

shift $((OPTIND - 1))

backup_directory="$(realpath "$backup_directory")"
backup_file="$(realpath "$backup_file")"
excludes=("${excludes[@]/#/--exclude=}")

# `-C "$backup_directory"` make sure relative path in `excludes` works.
tar -C "$backup_directory" -cvpaf "$backup_file" --one-file-system --exclude-vcs-ignores --exclude-backups --exclude-caches-all --exclude-from <(if [[ -n "$excluding_size" ]]; then find "$backup_directory" -type f -and -size "$excluding_size"; fi) --exclude="$backup_file" "${excludes[@]}" "$@" "$backup_directory"
