#!/bin/bash

BUTTON=$1

if [[ $BUTTON = "left" ]] ; then
	echo "left pressed"
fi

if [[ $BUTTON = "middle" ]] ; then
	echo "middle pressed"
fi

if [[ $BUTTON = "right" ]] ; then
	echo "right pressed"
fi

