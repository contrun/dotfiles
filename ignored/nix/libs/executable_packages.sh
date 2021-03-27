#!/usr/bin/env bash
set -xeu

githubHelper() {
        result="$(nix-prefetch-github "$@")"
        jq -c '((.owner) + "/" + (.repo)) as $name | . += {"fetchMethod": "fetchFromGitHub"} | {($name): (.)}' <<<"$result"
        jq -c '.repo as $name | . += {"fetchMethod": "fetchFromGitHub"} | {($name): (.)}' <<<"$result"
}

current_file="$(realpath "$0")"
file="${0%.*}"
json_file="$file.json"

while getopts ":p:j:" opt; do
        case $opt in
        p)
                file="$OPTARG"
                ;;
        j)
                json_file="$OPTARG"
                ;;
        \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
done

rendered_json="$(
        . "$file" | jq -s 'add'
)"
if [[ ! -f "$json_file" ]]; then
        tee "$json_file" <<<"$rendered_json"
elif diff "$json_file" - <<<"$rendered_json"; then
        echo "nothing changed"
else
        mv "$json_file" "${json_file%.*}.$(date +%Y-%m-%d-%H-%M-%S).json"
        tee "$json_file" <<<"$rendered_json"
fi
