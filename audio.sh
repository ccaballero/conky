#!/usr/bin/env bash
export LC_ALL=C
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

procesar_audio() {
    local tipo=$1      # "sink-inputs" o "source-outputs"
    local titulo=$2    # "Altavoces" o "Microfono"
    
    # Obtener flujos activos
    local items=$(pactl list short "$tipo" 2>/dev/null | awk '{print $1}')
    
    # Imprimir el título de la sección
    echo "\${voffset 4}${titulo}:"

    if [ -z "$items" ]; then
        echo "\${voffset 4}none"
        echo "\${voffset 4}\${execbar 5,278 echo 0}" # Barra vacía/invisible
        return
    fi

    # Procesar cada aplicación activa encontrada
    echo "$items" | while read -r id; do
        [ -z "$id" ] && continue

        local block=$(pactl list "$tipo" | awk -v id="$id" '
            $0 ~ "^(Sink Input|Source Output) #"id {print_block=1; next}
            /^(Sink Input|Source Output) #/ {print_block=0}
            print_block {print}
        ')

        # Extraer nombre
        local app_name=$(echo "$block" | grep "application.name =" | cut -d'"' -f2 | head -n1)
        [ -z "$app_name" ] && app_name=$(echo "$block" | grep "media.name =" | cut -d'"' -f2 | head -n1)
        [ -z "$app_name" ] && app_name="Desconocido"
        app_name=$(echo "$app_name" | cut -c1-18)

        # Extraer volumen numérico
        local volumen=$(echo "$block" | grep "Volume:" | head -n1 | awk -F'/' '{print $2}' | tr -d '[:space:]%')
        [ -z "$volumen" ] && volumen=0

        # Verificar silencio
        local mute=$(echo "$block" | grep "Mute:" | head -n1 | awk '{print $2}')

        if [ "$mute" = "yes" ]; then
            # Línea de texto con aviso en rojo y barra en 0
            echo "\${voffset 4}${app_name}\${alignr 20}[muted]"
            echo "\${voffset 4}\${execbar 5,278 echo 0}"
        else
            # Línea de texto con porcentaje y su respectiva barra de volumen nativa
            echo "\${voffset 4}${app_name}\${alignr 20}${volumen}%"
            echo "\${voffset 4}\${execbar 5,278 echo ${volumen}}"
        fi
    done
}

# Ejecutar ambas secciones de un solo golpe separadas por un salto de línea
procesar_audio "sink-inputs" "SPEAKERS"
procesar_audio "source-outputs" "MICROPHONE"

