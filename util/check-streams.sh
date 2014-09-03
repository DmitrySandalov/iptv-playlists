#!/bin/bash
# ---------------------------------------------------------------------------
# check-streams.sh checks that streams are valid, not 404
# Copyright (C) 2014, Dmitry Sandalov <dmitry@sandalov.org>
# 
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License at <http://www.gnu.org/licenses/> for
# more details.
# ---------------------------------------------------------------------------
usage() { echo "Usage: $0 [-f <sting>]" 1>&2; exit 1; }

while getopts ":f:h" opt; do
    case $opt in
        h)
            usage
            ;;
        f)
            file=${OPTARG}
            ;;
        \?)
            echo "Invalid option: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Option -$OPTARG requires an argument." >&2
            exit 1
            ;;
    esac
done

echo_green() {
    echo -e '\e[1;32m'${1}'\e[0m'
}

echo_red() {
    echo -e '\e[1;31m'${1}'\e[0m'
}

echo_yellow() {
    echo -e '\e[1;33m'${1}'\e[0m'
}

check_file() {
    # takes playlist file as input argument
    echo Checking $1
    for stream in `cat $1 | sed -e '/^#/d'`; do
        check_stream $stream
    done
}

check_stream() {
    status=$(curl -s -I -L -o /dev/null -w "%{http_code}" $1)
    if [ $status = '200' ]; then
        echo_green "[$status] $1"
    elif [ $status = '302' ]; then
        echo_yellow "$(check_stream_302 $1)"
        echo_yellow {$1}
    else
        echo_red "[$status] $1"
    fi
}

check_stream_302() {
    curl -s -I -L -o /dev/null -w "[%{http_code}] %{url_effective}\n" $1
}

if [[ -n "$file" ]]; then
    check_file $file
else
    for file in `find ../general -iname "*m3u8"` ; do
        check_file $file
    done
fi
