#!/bin/sh

CURRENT=$(mpc --format '%position%' current)
LENGTH=$(mpc playlist | wc -l)

if [ $LENGTH -ne 0 ] && [ ! -z $CURRENT ]
then
    START=$(($CURRENT - 3))

    if [ $START -lt 1 ]
    then
        START=1
    fi

    END=$(($START + 6))

    if [ $END -gt $LENGTH ]
    then
        END=$LENGTH
    fi

    DIFF=$((7 - ($END - ($START - 1))))

    mpc --format '%time% %title%' playlist | \
        sed -n "${START},${END}p" | \
        while read DURATION TITLE
        do
            if [ $CURRENT -eq $START ]
            then
                echo "▣  [$START] $DURATION - $TITLE"
            else
                echo "□  [$START] $DURATION - $TITLE"
            fi

            ((START=START+1))
        done

    case "$DIFF" in
        6) printf "\n\n\n\n\n\n"
            ;;
        5) printf "\n\n\n\n\n"
            ;;
        4) printf "\n\n\n\n"
            ;;
        3) printf "\n\n\n"
            ;;
        2) printf "\n\n"
            ;;
        1) printf "\n"
            ;;
        *)  printf ""
            ;;
    esac
else
    printf "\n\n\n\n\n\n\n\n"
fi

