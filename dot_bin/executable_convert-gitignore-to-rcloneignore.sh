#!/usr/bin/env bash

set -euo pipefail

if ! cd "$@"; then
  >&2 echo "Folder $* not found"
  exit 1
fi

rcloneignore=.rcloneignore
tmprcloneignore=.rcloneignore.tmp

if [[ -f "$rcloneignore" ]] && [[ -z "$(find ./ -type f -name '.gitignore' -newer "$rcloneignore" -print0)" ]]; then
  >&2 echo "No newer gitignore file found, exiting"
  exit 0
fi

while IFS= read -r -d $'\0' path <&3; do
  root="$(dirname "$path")/"
  root=${root#.}

  while IFS= read -r ignore || [[ -n "$ignore" ]]; do
    # A line starting with # serves as a comment.
    [[ $ignore =~ ^# ]] && continue

    # Trim spaces using parameter expansion
    ignore=${ignore##+([[:space:]])}

    # Ignore empty lines
    [[ -z "$ignore" ]] && continue

    # An optional prefix "!" which negates the pattern.
    if [[ $ignore == !* ]]; then
      # Use parameter expansion instead of sed
      ignore=${ignore#!}
      include=true
    else
      include=false
    fi

    pattern="$ignore"

    # A separator before the end of the pattern makes it absolute
    if [[ $ignore =~ / && $ignore != */ ]]; then
      # Use parameter expansion instead of sed
      pattern="${root%/}/${pattern#/}"
    else
      # Mimic relative search by making an absolute WRT to current directory,
      # preceded by a recursive glob `**`
      pattern="${root%/}/**/$pattern"
    fi

    # A separator at the end only matches directories
    if [[ $ignore =~ /$ ]]; then
      # rclone only matches files, so we need to add `**` to match a directory
      pattern="$pattern**"
    fi

    if [[ $include = true ]]; then
      pattern="+ $pattern"
    else
      pattern="- $pattern"

    fi

    # If the pattern doesn't end with `/`, include the file variant:
    [[ $ignore =~ [^/]$ ]] && echo "$pattern"

    # In any case, include the directory variant:
    # Use parameter expansion instead of sed
    echo "${pattern%/}/**"
  done <"$path"
done 3< <(find ./ -type f -name '.gitignore' -print0) | tee "$tmprcloneignore"

# If above script exited with error and we directly updated the rcloneignore
# file, then the rcloneignore will always newer than the gitignore files.
# So we need to be sure that above script finished without error first
# before we update the rcloneignore file.
mv "$tmprcloneignore" "$rcloneignore"
