#!/bin/bash

COUNTER=0
TIME=15000

WINDOWS_WIDTH=1000
WINDOW_HEIGHT=1000

PIDS=$(xdotool search "Tibia")
NAME=$(xdotool getwindowname $PIDS)

$(xdotool search "Tibia" windowactivate)

xdotool windowsize $PIDS $WINDOWS_WIDTH $WINDOW_HEIGHT

CHAR_POS_X=400
CHAR_POS_Y=375

ARM_POS_X=850
ARM_POS_Y=185

TEST() {
	while :
	do
		if (($CHAR_POS_X == $ARM_POS_X)) || (($CHAR_POS_Y == $ARM_POS_Y));
		then
			xdotool mousemove --window $PIDS $CHAR_POS_X $CHAR_POS_Y mouseup 1		
			break;

		fi

		if (("$CHAR_POS_X" > "$ARM_POS_X")); then
			((CHAR_POS_X--))
		elif  (("$CHAR_POS_X" < "$ARM_POS_X")); then
			((CHAR_POS_X++))
		fi

		if (("$CHAR_POS_Y" > "$ARM_POS_Y")); then
			((CHAR_POS_Y--))
		elif  (("$CHAR_POS_Y" < "$ARM_POS_Y")); then
			((CHAR_POS_Y++))
		fi

		xdotool mousemove --window $PIDS $CHAR_POS_X $CHAR_POS_Y mousedown 1
	done
}

while :
do
	if [ "$COUNTER" -eq "$TIME" ]
	then
		$(xdotool search "Tibia - Smolista Golonka" key --clearmodifiers F1)

		$(xdotool search "Tibia - Smolista Golonka" key --clearmodifiers F2)
		COUNTER=0
	else
		((COUNTER++))
	fi

	xdotool getmouselocation --shell
	TEST
done
