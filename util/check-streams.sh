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

check_file() {
    # takes playlist file as input argument
    echo $1
    for stream in `cat $1 | sed -e '/^#/d'`; do
        check_stream $stream
    done
}

check_stream() {
    curl -s -I -o /dev/null -w "[%{http_code}] $1\n" $1
}

if [[ -n "$file" ]]; then
    check_file $file
else
    for file in `find ../general -iname "*m3u8"` ; do
        check_file $file
    done
fi
