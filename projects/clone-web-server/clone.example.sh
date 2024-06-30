#!/bin/bash

# Función para clonar un sitio web
clone_site() {
    local url=$1
    local directory=$2


    # Verifica si el directorio existe, si no, lo crea
    if [[ ! -d "$directory" ]]; then
        echo "El directorio $directory no existe. Creándolo..."
        mkdir -p "$directory"
    fi

    # Comando de wget para clonar el sitio web
    wget --mirror --convert-links --adjust-extension --page-requisites --no-parent -P "$directory" "$url"
}

# Clona sitio web x
clone_site "http://sitioweb.cl" "./sitiweb"

