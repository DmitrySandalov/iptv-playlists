#!/bin/bash
# ---------------------------------------------------------------------------
# check-streams.sh checks that streams are valid, not 404
# Copyright (C) 2014, 2016, Dmitry Sandalov <dmitry@sandalov.org>
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
usage() { echo "Usage: $0 [-f <string>]" 1>&2; exit 1; }

while getopts ":f:hsn" opt; do
    case $opt in
        h)
            usage
            ;;
        s)
            simple=1
            ;;
        n)
            simple_no_colors=1
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
    if [[ -z "$simple" ]]; then
        echo -e '\e[1;32m'[${1}] ${2}'\e[0m'
    else
        if [[ -z "$simple_no_colors" ]]; then
            echo -e '\e[1;32m'${2}'\e[0m'
        else
            echo ${2}
        fi
    fi
}

echo_red() {
    if [[ -z "$simple" ]]; then
        echo -e '\e[1;31m'[${1}] ${2}'\e[0m'
    fi
}

echo_yellow() {
    if [[ -z "$simple" ]]; then
        echo -e '\e[1;33m'[${1}] ${2}'\e[0m'
    else
        if [[ -z "$simple_no_colors" ]]; then
            echo -e '\e[1;33m'${3}'\e[0m'
        else
            echo ${3}
        fi
    fi
}

check_file() {
    # takes playlist file as input argument
    echo Checking $1
    for stream in `cat $1 | sed '/^\s*$/d' | sed -e '/^#/d' | sed -e 's///g'`; do
        check_stream $stream
    done
}

check_stream() {
    resp_code=$(curl -m 5 -s -I -o /dev/null -w "%{http_code}" $1)
    if [ $resp_code = '200' ]; then
        echo_green $resp_code $1
    elif [ $resp_code = '301' ] || [ $resp_code = '302' ]; then
        url_effective=$(check_stream_302 $1)
        echo_yellow $resp_code $1
        check_stream $url_effective
    else
        check_stream_get $1
    fi
}

check_stream_302() {
    curl -m 5 -s -I -L -o /dev/null -w "%{url_effective}\n" $1
}

check_stream_get() {
    response=$(curl -m 3 -o /dev/null -sL -w "%{http_code} %{url_effective}\\n" $1)
    resp_code=`echo $response | awk '{print $1}'`
    if [ $resp_code = '200' ]; then
        echo_green $resp_code $1
    else
        echo_red $resp_code $1
    fi
}

if [[ -n "$file" ]]; then
    check_file $file
else
    for file in `find ../general -iname "*m3u8"` ; do
        check_file $file
    done
fi
