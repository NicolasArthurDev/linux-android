#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
mkdir -p "$SB/mock"
head -n -1 "$LX_BIN" | sed -e 's|^readonly CTX=.*|readonly CTX="termux"|' \
    -e "s|/system/bin/device_config|$SB/mock/device_config|g" > "$SB/lib.sh"

caso() { # settings, device_config, esperado
    printf '#!/bin/bash\nprintf "%%s\\n" %q\n' "$1" > "$SB/mock/settings"
    printf '#!/bin/bash\nprintf "%%s\\n" %q\n' "$2" > "$SB/mock/device_config"
    chmod +x "$SB/mock/settings" "$SB/mock/device_config"
    PATH="$SB/mock:$PATH" PREFIX="$SB/usr" LX_STATE_DIR="$SB/st" \
        bash -c "source '$SB/lib.sh' >/dev/null 2>&1; check_phantom_killer"
    case $? in 0) echo DESATIVADA;; 1) echo ATIVA;; 2) echo INDETERMINADO;; *) echo "?";; esac
}
echo "-- settings responde (definitivo)"
chk "false -> desativada" "DESATIVADA" "$(caso false null)"
chk "true  -> ativa"      "ATIVA"      "$(caso true null)"
echo "-- settings=null: cai no device_config"
chk "sem permissao -> indeterminado" "INDETERMINADO" "$(caso null 'Permission denial')"
chk "vazio -> indeterminado"         "INDETERMINADO" "$(caso null '')"
chk "null -> indeterminado"          "INDETERMINADO" "$(caso null null)"
chk "valor alto -> desativada"       "DESATIVADA"    "$(caso null 2147483647)"
chk "limite 32 -> ativa"             "ATIVA"         "$(caso null 32)"
finish
