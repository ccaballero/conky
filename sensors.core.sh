#!/bin/sh

sensors | awk '/Core 0/{print $3}' | sed 's/^\+\(.*\)\..*°C/\1/'

