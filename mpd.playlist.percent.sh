#!/bin/sh

CURRENT=$(mpc --format '%position%' current)
LENGTH=$(mpc playlist | wc -l)

if [ $LENGTH -ne 0 ] && [ ! -z $CURRENT ]
then
    echo $(((100 * $CURRENT) / $LENGTH))
else
    echo 0
fi

