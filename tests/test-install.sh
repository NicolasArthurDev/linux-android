#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
mkdir -p "$SB/bin"
sed "s|printf '/usr/local/bin/lx'|printf '$SB/bin/lx'|" "$LX_BIN" > "$SB/lx"
chmod +x "$SB/lx"
export LX_STATE_DIR="$SB/state" PATH="$SB/bin:$PATH"

o="$("$SB/lx" install 2>&1)"
chk "cria o symlink"        "sim"     "$([ -L "$SB/bin/lx" ] && echo sim || echo nao)"
chk "aponta para a origem"  "$SB/lx"  "$(readlink -f "$SB/bin/lx")"
chk_match "idempotente"     "já instalado" "$("$SB/lx" install 2>&1)"
chk_match "roda via symlink" "^lx v"  "$("$SB/bin/lx" version 2>&1)"

# self_path deve resolver o symlink, senao run_in_ubuntu copiaria o arquivo errado
v="$("$SB/bin/lx" version 2>&1)"
chk "self_path resolve o real" "$SB/lx"     "$(echo "$v"|awk -F': +' '/^arquivo:/{print $2}')"
chk "BASH_SOURCE = symlink"    "$SB/bin/lx" "$(echo "$v"|awk -F': +' '/^invocado:/{print $2}')"

"$SB/lx" uninstall >/dev/null 2>&1
chk "uninstall remove"      "nao" "$([ -e "$SB/bin/lx" ] && echo sim || echo nao)"
chk "origem preservada"     "sim" "$([ -f "$SB/lx" ] && echo sim || echo nao)"
"$SB/lx" uninstall >/dev/null 2>&1; chk "uninstall 2x nao quebra" "0" "$?"
finish
