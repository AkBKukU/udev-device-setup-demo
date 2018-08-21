#!/bin/bash
id="$(xinput list | grep VEC | awk '{print $6}' | sed 's/id=//g')"
echo "Device ID: $id"
xinput test $id | while read in ; do
  [[ $in = "key press   194" ]] && ./inputAction.sh left
  [[ $in = "key press   195" ]] && ./inputAction.sh middle
  [[ $in = "key press   196" ]] && ./inputAction.sh right
  echo "nothing"
done

