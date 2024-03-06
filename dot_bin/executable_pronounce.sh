#!/usr/bin/env bash

with_curl=
if command -v curl >/dev/null; then
  with_curl=y
fi
lookup_file="$HOME/.local/share/lookups.csv"
mkdir -p "$(dirname "$lookup_file")"

pronounce_word() {
  if [[ -z "$with_curl" ]]; then
    mpv "https://dict.youdao.com/dictvoice?audio=${word}&type=2"
  else
    # Encode word more properly with curl
    curl --get --data-urlencode "type=2" --data-urlencode "audio=${word}" https://dict.youdao.com/dictvoice | mpv -
  fi
}

lookup_word() {
  local word="$1"
  sdcv --data-dir="$HOME/Storage/dict" -n -c "$word" | less
}

go() {
  local word
  for word in "$@"; do
    # remove leading whitespace characters
    word="${word#"${word%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    word="${word%"${word##*[![:space:]]}"}"
    if [[ -z "$word" ]]; then
      continue
    fi
    # Save my look up of works to this file for later usage
    echo "$(date -u +"%Y-%m-%dT%H:%M:%SZ"),${word}" >>"$lookup_file"
    pronounce_word "$word"
    lookup_word "$word"
  done
}

if [[ $# -eq 0 ]]; then
  go "$(wl-paste)"
else
  go "$@"
fi
