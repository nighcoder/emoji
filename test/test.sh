#!/bin/bash
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

test_params='running sailboat$ umbrella_on_ground eyes camping$
             golfing:skin_3 ok_hand:skin_4 fairy:skin_2 prince:skin_3
             victory_hand:skin_1
             woman:skin_4+handshake+man:skin_1 man:skin_3+sheaf_of_rice
             biking+female superhero:skin_2+male woman:skin_1+white_hair
             black_flag+skull_and_crossbones'

fail="0"
pass="0"
i="0"

cd src
for t in $test_params; do
  if bash emoji.sh $t >/dev/null; then
    pass=$((++pass))
  else
    echo Test failed on param $t
    fail=$((++fail))
  fi
  i=$((++i))
done

echo Tests complete. Performed: ${i} Passed: $pass Failed: $fail
if [[ $fail -lt 255 ]]; then
  exit $fail
else
  exit 255
fi
