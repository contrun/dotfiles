#!/usr/bin/env bash
set -be

machine="${machine:-}"
serverName="${serverName:-1}"
port=
conf="${conf:-1}"
user="${USER:-}"
dryrun=
while getopts "s:c:p:u:d:" opt; do
        case $opt in
        s)
                serverName="$OPTARG"
                ;;
        c)
                conf="$OPTARG"
                ;;
        p)
                port="$OPTARG"
                ;;
        u)
                user="$OPTARG"
                ;;
        d)
                dryrun=y
                ;;
        \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
done

shift $(("$OPTIND" - 1))
machine="$1"
shift
serverName="autossh$serverName"
[[ -z "$port" ]] && port="$(($(printf '%i' "0x$(echo -n "$serverName->$machine->$conf" | sha512sum | head -c 3)") + 32768 + 4096 * $conf))"
if [[ -n "$dryrun" ]]; then
        echo ssh -p "$port" "$@" "$user@$serverName"
else
        ssh -p "$port" "$@" "$user@$serverName"
fi
