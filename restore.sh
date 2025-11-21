#!/bin/sh


REPLACE() {
symlink="$1"
    # Comprueba si el archivo es un enlace simbólico
    if [ -L "$symlink" ]; then
        # Obtiene el archivo al que apunta el enlace simbólico
        target=$(readlink "$symlink")

        # Verifica si el archivo de destino existe
        if [ ! -e "$target" ]; then
            echo "El archivo de destino '$target' no existe."
            return
        fi

        # Elimina el enlace simbólico
        rm "$symlink"

        # Mueve el archivo real en lugar del enlace simbólico
        mv -v "$target" "$symlink"

        echo "El enlace simbólico '$symlink' ha sido reemplazado por el archivo real"
    else
        echo "'$symlink' no es un enlace simbólico."
        return
    fi
}

REPLACE "/Users/marane4/.zshrc"
REPLACE "/Users/marane4/.zimrc"
REPLACE "/Users/marane4/.tmux.conf"
REPLACE "/Users/marane4/.config/exercism"
REPLACE "/Users/marane4/.config/gh"
REPLACE "/Users/marane4/Library/Application Support/iTerm2"
REPLACE "/Users/marane4/.config/nvim"
REPLACE "/Users/marane4/.config/zed/settings.json"