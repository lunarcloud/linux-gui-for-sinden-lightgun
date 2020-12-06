#!/bin/bash

PLAYER="$1"
if [ -z "$PLAYER" ]; then
	echo No player provided.
	exit 1
fi
LOCK=/tmp/SindenLightgunP$PLAYER.lock

if [[ -e $LOCK ]]; then
	echo P$PLAYER Service already running.
fi

WORKING_FOLDER="$2"
if [ -z "$WORKING_FOLDER" ]; then
	echo No executable directory provided.
	exit 2
fi

mono-service LightgunMono.exe -l:$LOCK -d:$WORKING_FOLDER
