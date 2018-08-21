#!/bin/bash
id="$(xinput list | grep VEC | awk '{print $6}' | sed 's/id=//g')"
echo "Device ID: $id"
xinput test $id | while read in ; do
  [[ $in = "key press   194" ]] && notify-send left
  [[ $in = "key press   195" ]] && notify-send middle
  [[ $in = "key press   196" ]] && notify-send right
  echo "nothing"
done

