#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
lx_source ubuntu "$SB/lib.sh"
export HOME="$SB/home"; mkdir -p "$HOME"
( NO_COLOR=1 PREFIX="$SB/usr" LX_STATE_DIR="$SB/st" source "$SB/lib.sh" >/dev/null 2>&1
  write_rice_configs >/dev/null 2>&1 )
C="$HOME/.config"

echo "-- arquivos gerados"
for f in bspwm/bspwmrc sxhkd/sxhkdrc polybar/config.ini polybar/launch.sh \
         picom/picom.conf rofi/config.rasi kitty/kitty.conf dunst/dunstrc; do
    chk "$f" "sim" "$([ -s "$C/$f" ] && echo sim || echo nao)"
done

echo "-- scripts validos e executaveis"
for f in bspwm/bspwmrc polybar/launch.sh; do
    sh -n "$C/$f" 2>/dev/null && r=ok || r=erro
    chk "sintaxe de $f" "ok" "$r"
    chk "$f executavel" "sim" "$([ -x "$C/$f" ] && echo sim || echo nao)"
done

echo "-- picom"
chk "corner-radius definido" "sim" "$(grep -q '^corner-radius' "$C/picom/picom.conf" && echo sim || echo nao)"
# Procura DIRETIVA de blur, nao a palavra: o proprio comentario do arquivo
# explica por que o blur foi omitido, e casava com um grep ingenuo.
chk "sem diretiva de blur" "sim" "$(grep -qiE '^ *blur' "$C/picom/picom.conf" && echo nao || echo sim)"
chk "toda atribuicao termina em ;" "0" "$(grep -cE '^[a-z-]+ *=[^;]*$' "$C/picom/picom.conf")"

echo "-- sxhkd: atalhos e comandos balanceados"
b=$(grep -cE '^[a-zA-Z]' "$C/sxhkd/sxhkdrc"); c=$(grep -cE '^    ' "$C/sxhkd/sxhkdrc")
chk "pares atalho/comando ($b/$c)" "$b" "$c"

echo "-- polybar: modulos referenciados existem"
for mod in $(grep -E '^modules-(left|center|right)' "$C/polybar/config.ini" | cut -d= -f2); do
    chk "module/$mod definido" "sim" "$(grep -q "^\[module/$mod\]" "$C/polybar/config.ini" && echo sim || echo nao)"
done
chk "usa 'label' e nao 'content' (deprecado na 3.7)" "0" "$(grep -c '^content *=' "$C/polybar/config.ini")"

echo "-- dunst: sintaxe nova (1.12+)"
chk "height em tupla" "sim" "$(grep -qE '^ *height *= *\(' "$C/dunst/dunstrc" && echo sim || echo nao)"
chk "offset em tupla" "sim" "$(grep -qE '^ *offset *= *\(' "$C/dunst/dunstrc" && echo sim || echo nao)"

echo "-- Catppuccin Mocha"
for f in polybar/config.ini kitty/kitty.conf rofi/config.rasi; do
    chk "cor base #1e1e2e em $f" "sim" "$(grep -qi '#1e1e2e' "$C/$f" && echo sim || echo nao)"
done

echo "-- abre um terminal para a sessao nao parecer vazia"
chk_match "bspwmrc lanca kitty" "kitty" "$(cat "$C/bspwm/bspwmrc")"
finish
