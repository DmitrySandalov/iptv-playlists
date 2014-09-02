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
for file in `find ../general -iname "*m3u8"` 
do
    echo $file
    for stream in `cat $file | sed -e '/^#/d'` 
    do
        curl -s -I -o /dev/null -w "[%{http_code}] $stream\n" $stream
    done
done
