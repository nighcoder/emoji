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

search_test="tool truck"
fail="0"
pass="0"
i="0"

cd src
for t in $test_params; do
  em=$(bash emoji.sh $t 2>/dev/null)
  if [[ -n $em ]]; then
    pass=$((++pass))
    i=$((++i))
    revem=$(bash emoji.sh -i $em 2>/dev/null)
    if [[ -n $revem ]]; then
	    pass=$((++pass))
	    i=$((++i))
    else
	    echo Reverse test failed on param $t
	    fail=$((++fail))
	    i=$((++i))
    fi
  else
    echo Test failed on param $t
    fail=$((++fail))
  fi
done

n=$(bash emoji.sh -s tool | wc -l)
if [[ $n == 23 ]]; then
	pass=$((++pass))
else
	fail=$((++fail))
fi
i=$((++i))

n=$(bash emoji.sh -s truck | wc -l)
if [[ $n == 22 ]]; then
	pass=$((++pass))
else
	fail=$((++fail))
fi
i=$((++i))

echo Tests complete. Performed: ${i} Passed: $pass Failed: $fail
if [[ $fail -lt 255 ]]; then
  exit $fail
else
  exit 255
fi
