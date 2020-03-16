#!/usr/bin/env bash
set -e
# suppress curl output
name=unamed
# placeholder will be replaced by actual username
placeholder=ttestt
# non-null value of multiplyInstances will start multiply curl process simultaneously
multiplyInstances=y
# shortest username length, default value 1
# max processes to run
maxProcs=10
lowerBound=1
# longest username length, default value 20
upperBound=20
# failure pattern
failurePattern=
# success pattern
successPattern=
# success file
successFile=useravi
# failure file
failureFile=useruna
# error file
errorFile=usererr
# curl command to replace
cmd=()

while getopts ":n:p:P:m:l:u:s:f:S:F:E:" opt; do
        case $opt in
        n)
                name="$OPTARG"
                ;;
        p)
                placeholder="$OPTARG"
                ;;
        P)
                maxProcs="$OPTARG"
                ;;
        m)
                multiplyInstances="$OPTARG"
                ;;
        l)
                lowerBound="$OPTARG"
                ;;
        u)
                upperBound="$OPTARG"
                ;;
        s)
                successPattern="$OPTARG"
                ;;
        f)
                failurePattern="$OPTARG"
                ;;
        S)
                successFile="$OPTARG"
                ;;
        F)
                failureFile="$OPTARG"
                ;;
        E)
                errorFile="$OPTARG"
                ;;
        \?)
                echo "Invalid option: -$OPTARG" >&2
                exit 1
                ;;
        esac
done

shift "$(($OPTIND - 1))"
cmd=("$@")
if [[ "0" -eq "${#cmd}" ]]; then
        echo "command not provided" >&2
        exit 1
fi
if [[ -z "$successPattern" ]]; then
        echo "success pattern not provided" >&2
        exit 1
fi
if [[ -z "$failurePattern" ]]; then
        echo "failure pattern not provided" >&2
        exit 1
fi

curl() {
        command curl -sS "$@"
}

export cmd placeholder failureFile failurePattern successFile successPattern errorFile name
checkUserName() {
        username="$0"
        newcmd=("${@/$placeholder/$username}")
        result="$("${newcmd[@]}")"
        if [[ $? == 0 ]]; then
                if grep -q -E "$failurePattern" <<<"$result"; then
                        tee -a "${failureFile}" <<<"$name username unavailable: $username"
                elif grep -q -E "$successPattern" <<<"$result"; then
                        tee -a "${successFile}" <<<"$name username available: $username"
                else
                        echo "result: $result"
                        tee -a "${errorFile}" <<<"$name username error: $username"
                fi
        else
                echo "result: $result"
                tee -a ${errorFile:-usererr} <<<"$name username error: $username"
        fi
}

repl() { printf "$1"'%.s' $(seq 1 $2); }

export -f curl
export -f checkUserName

echoUsernames() {
        for i in $(seq "${lowerBound}" "${upperBound}"); do
                for letter in {a..z}; do
                        echo "$(repl "$letter" "$i")"
                done
        done
}

echoUsernames | xargs -I _ -P "$maxProcs" bash -c 'checkUserName "$@"' _ "${cmd[@]}"
