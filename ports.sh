#!/bin/bash
# Fuerza sudo en segundo plano sin TTY y limpia el nombre del proceso
sudo -n ss -tulpn | awk 'NR>1 {
    proto = toupper($1);
    
    # Aislar número de puerto
    split($5, a, ":");
    puerto = a[length(a)];
    
    # Extraer el proceso de la columna 6 u 7 según tu distribución
    columna_proc = ($6 ~ /users:/) ? $6 : $7;
    proc = "Desconocido";
    
    if (match(columna_proc, /"([^"]+)"/, m)) {
        proc = m[1];
    }
    
    # Clave única para evitar duplicados reales
    clave = proto "_" proc "_" puerto;
    
    if (!vistos[clave]) {
        vistos[clave] = 1;
        print "${voffset 4}" proto "/" puerto "${alignr 0}" proc;
    }
}' | sort -V -k2

