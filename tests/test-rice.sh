#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
lx_source ubuntu "$SB/lib.sh"
export HOME="$SB/home"; mkdir -p "$HOME"
( NO_COLOR=1 PREFIX="$SB/usr" LX_STATE_DIR="$SB/st" source "$SB/lib.sh" >/dev/null 2>&1
  write_rice_configs super >/dev/null 2>&1 )
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
# glx congela a renderizacao sob o Termux:X11 (yshui/picom#1395): tela preta
# com todo o desktop rodando. O xrender nao tem o problema e mantem os cantos.
chk "backend = xrender (nao glx)" "sim" "$(grep -qE '^backend *= *"xrender"' "$C/picom/picom.conf" && echo sim || echo nao)"
chk "glx nao esta ativo"          "sim" "$(grep -qE '^backend *= *"glx"' "$C/picom/picom.conf" && echo nao || echo sim)"
chk_match "bspwmrc respeita LX_NO_PICOM" "LX_NO_PICOM" "$(cat "$C/bspwm/bspwmrc")"
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

echo "-- bspwmrc com TODOS os binarios ausentes (cenario da tela preta)"
# Nenhum comando existe: o script deve registrar cada falta e terminar ok,
# em vez de morrer em silencio e deixar a tela vazia sem pista do motivo.
BIN="$SB/nada"; mkdir -p "$BIN"
# /bin/sh por caminho absoluto: o PATH aponta para um diretorio VAZIO de
# proposito, para que nenhum dos comandos do bspwmrc seja encontrado.
out="$(cd "$SB" && env -i PATH="$BIN" HOME="$HOME" DISPLAY=:0 \
        /bin/sh "$C/bspwm/bspwmrc" 2>&1; echo "rc=$?")"
chk_match "termina sem erro"          "rc=0"                "$out"
LOGB="/tmp/lx-bspwm.log"
chk "gera o log de passos"            "sim" "$([ -f "$LOGB" ] && echo sim || echo nao)"
if [ -f "$LOGB" ]; then
    for b in sxhkd xsetroot picom dunst; do
        chk_match "registra $b ausente" "$b AUSENTE" "$(cat "$LOGB")"
    done
    chk_match "avisa a falta de terminal" "NENHUM terminal" "$(cat "$LOGB")"
    chk_match "diz onde achar o xsetroot" "x11-xserver-utils" "$(cat "$LOGB")"
    rm -f "$LOGB"
fi
echo "-- modificador configuravel (o DeX intercepta o Super)"
gera_mod() { # $1 = modificador
    local H2="$SB/h-$1"; mkdir -p "$H2"
    # 'export' de verdade: um prefixo 'VAR=x source ...' vale apenas para o
    # source, e o write_rice_configs seguinte usaria o HOME real.
    ( export NO_COLOR=1 HOME="$H2" PREFIX="$SB/usr" LX_STATE_DIR="$SB/st"
      source "$SB/lib.sh" >/dev/null 2>&1
      write_rice_configs "$1" >/dev/null 2>&1 )
    echo "$H2"
}
Hs="$(gera_mod super)"; Ha="$(gera_mod alt)"; Hc="$(gera_mod ctrl-alt)"
chk_match "super: atalhos com 'super +'" "^super \+ Return"    "$(cat "$Hs/.config/sxhkd/sxhkdrc")"
chk_match "alt: atalhos com 'alt +'"     "^alt \+ Return"      "$(cat "$Ha/.config/sxhkd/sxhkdrc")"
chk_match "ctrl-alt: 'ctrl + alt +'"     "^ctrl \+ alt \+ Return" "$(cat "$Hc/.config/sxhkd/sxhkdrc")"
chk "alt nao deixa 'super' sobrando"  "0" "$(grep -c '^super +' "$Ha/.config/sxhkd/sxhkdrc")"
chk "nenhum placeholder @MOD@ restante" "0" "$(grep -c '@MOD@\|@MODNOME@\|@PTRMOD@' "$Ha/.config/sxhkd/sxhkdrc" "$Ha/.config/bspwm/bspwmrc" | awk -F: '{t+=$2} END{print t+0}')"
chk_match "pointer_modifier mod1 com alt"   "pointer_modifier +mod1" "$(cat "$Ha/.config/bspwm/bspwmrc")"
chk_match "pointer_modifier mod4 com super" "pointer_modifier +mod4" "$(cat "$Hs/.config/bspwm/bspwmrc")"

finish
