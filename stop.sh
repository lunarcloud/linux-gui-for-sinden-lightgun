#!/bin/bash

PLAYER="$1"
if [ -z "$PLAYER" ]; then
	echo No player provided.
	exit 1
fi
LOCK=/tmp/SindenLightgunP$PLAYER.lock

if [[ ! -e $LOCK ]]; then
	echo P$PLAYER Service not running.
else
  PID=`cat $LOCK`
	kill $PID
	
	echo $?
	if [ $? -eq 0 ]; then
		rm $LOCK
		echo P$PLAYER Service stopped.
	fi
fi
