#! /usr/bin/bash
# emoji - Command line tool for generating Unicode compatible emojis.
# Copyright © 2019 Daniel Ciumberică
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
#

if [[ ${EUID} = "0" ]]; then
  prefix=/usr/local/
else
  prefix=${HOME}"/.local/"
fi

echo Installing in ${prefix}
install -d .install
sed "s|datadir=.*|datadir=${prefix}share/emoji/|" src/emoji.sh > .install/emoji
install -d ${prefix}{bin/,share/emoji}
install .install/emoji ${prefix}bin/emoji
cp -r resources/. ${prefix}share/emoji/.
rm -r .install
echo Done
