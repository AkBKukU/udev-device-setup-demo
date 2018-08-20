#!/bin/bash
#xinput list for id
xinput test 15 | while read in ; do
  [[ $in = "key press   194" ]] && notify-send left
  [[ $in = "key press   194" ]] && notify-send middle
  [[ $in = "key press   194" ]] && notify-send right
  echo "nothing"
done
