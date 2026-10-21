#!/bin/bash
# Cierra instancias previas para evitar duplicados al reiniciar Awesome
killall conky

# Lanza cada conky en segundo plano
conky -c ~/.conky/conkyrc.mayuri.1 &
conky -c ~/.conky/conkyrc.mayuri.2 &
conky -c ~/.conky/conkyrc.mayuri.3 &
conky -c ~/.conky/conkyrc.mayuri.4 &
conky -c ~/.conky/conkyrc.mayuri.5 &

