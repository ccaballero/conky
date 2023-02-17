#!/bin/sh

SINKS=$(pactl list sinks)
DEVICE=$(echo "$SINKS" | \
    grep "device.profile.description" | \
    sed 's/^.*"\(.*\)".*$/\1/')
VOLUME=$(echo "$SINKS" | \
    grep "Volume: front-left")
MLEFT=$(echo $VOLUME | \
    sed 's/^.*front-left: .* \/ \(.*\)% \/ .*front-right.*/\1/')

echo "\${font Futura-Medium:size=8}$DEVICE\${font}"
echo "\${voffset -2}\${execbar echo $MLEFT}"
echo ""

pactl list sink-inputs | \
    grep "Volume: front-left" | \
    sed 's/^.* front-left: .* \/ \(.*\)% \/ .*front-right.*/\1/' | \
    while read VOLUME
    do
        echo "\${voffset -7}\${execbar echo $VOLUME}"
    done

