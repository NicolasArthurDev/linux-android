#!/usr/bin/env bash
# Garante que o menu interativo nao fica defasado em relacao ao dispatch:
# toda opcao oferecida deve ter tratamento, e todo comando publico deve estar
# alcancavel pelo menu.
source "$(dirname "$0")/lib.sh"

MENU="$(sed -n '/^cmd_menu() {/,/^menu_rice() {/p' "$LX_BIN")"

echo "-- toda opção oferecida tem tratamento no case"
ofer="$(printf '%s' "$MENU" | grep -oE '\$\{C_BOLD\}[0-9a-z]\$\{C_RESET\}\)' | grep -oE '\}[0-9a-z]\$' | tr -d '}$' | sort -u)"
falta=""
for o in $ofer; do
    printf '%s' "$MENU" | grep -qE "^ +${o}(\||\))" || falta="$falta $o"
done
chk "nenhuma opção sem tratamento" "" "$falta"
chk "menu não está vazio" "sim" "$([ -n "$ofer" ] && echo sim || echo nao)"

echo "-- comandos publicos alcancaveis pelo menu"
# Comandos que fazem sentido no menu (os internos e aliases ficam de fora).
for c in setup dev gpu browser rice vscode start stop de shell doctor status log report update clean install; do
    printf '%s' "$MENU" | grep -qE "cmd_${c}|menu_${c}" \
        && { printf '  \033[32mok\033[0m   %s\n' "$c"; _pass=$((_pass+1)); } \
        || { printf '  \033[31mFALHA\033[0m %s ausente do menu\n' "$c"; _fail=$((_fail+1)); }
done

echo "-- submenus existem"
for m in menu_dev menu_browser menu_rice menu_de; do
    chk "$m definido" "sim" "$(grep -qE "^${m}\(\) \{" "$LX_BIN" && echo sim || echo nao)"
done

echo "-- créditos"
chk_match "autor no cabeçalho"      "Nicolas Arthur" "$(head -12 "$LX_BIN")"
chk_match "autor na constante"      'LX_AUTHOR="Nicolas Arthur"' "$(cat "$LX_BIN")"
chk_match "autor no help"           "Nicolas Arthur" "$(NO_COLOR=1 bash "$LX_BIN" help 2>&1)"
chk_match "autor no version"        "Nicolas Arthur" "$(NO_COLOR=1 bash "$LX_BIN" version 2>&1)"
chk_match "LICENSE com o nome"      "Nicolas Arthur" "$(cat "$LX_REPO/LICENSE")"
finish
