#!/bin/bash
# Blender control example
BUTTON=$1

if [[ $BUTTON = "left" ]] ; then
	xdotool key Next
fi

if [[ $BUTTON = "middle" ]] ; then
	xdotool key alt+a
fi

if [[ $BUTTON = "right" ]] ; then
	xdotool key Prior
fi

