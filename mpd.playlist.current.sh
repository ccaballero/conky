#!/bin/sh

CURRENT=$(mpc --format '%position%' current)
LENGTH=$(mpc playlist | wc -l)

if [ $LENGTH -ne 0 ] && [ ! -z $CURRENT ]
then
    echo $CURRENT/$LENGTH
fi

