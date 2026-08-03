#!/usr/bin/env bash
# Reproduz o bug do 'xsetroot': um nome invalido no lote fazia o apt abortar
# e nao instalar NENHUM dos outros pacotes.
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
mkdir -p "$SB/mock" "$SB/inst"
lx_source ubuntu "$SB/lib.sh"

cat > "$SB/mock/apt" <<EOS
#!/bin/bash
[ "\$1" = "install" ] || exit 0
shift; args=(); for a in "\$@"; do [ "\$a" = "-y" ] || args+=("\$a"); done
for p in "\${args[@]}"; do
  [ "\$p" = "xsetroot" ] && { echo "Unable to locate package xsetroot" >&2; exit 100; }
done
for p in "\${args[@]}"; do touch "$SB/inst/\$p"; done
EOS
chmod +x "$SB/mock/apt"

roda() { rm -f "$SB/inst"/*
    PATH="$SB/mock:$PATH" PREFIX="$SB/usr" LX_STATE_DIR="$SB/st" \
      bash -c "source '$SB/lib.sh' >/dev/null 2>&1; $1" >/dev/null 2>&1
    ls "$SB/inst" 2>/dev/null | sort | tr '\n' ' ' | sed 's/ $//'; }

echo "-- comportamento do apt puro (o bug)"
chk "lote com nome invalido instala NADA" "" "$(roda 'apt install -y bspwm sxhkd xsetroot polybar')"
echo "-- apt_install_soft (a correcao)"
chk "instala os validos, pula o invalido" "bspwm polybar sxhkd" "$(roda 'apt_install_soft bspwm sxhkd xsetroot polybar')"
chk "lote todo valido"                    "bspwm polybar sxhkd" "$(roda 'apt_install_soft bspwm sxhkd polybar')"
chk "um valido"                           "bspwm"               "$(roda 'apt_install_soft bspwm')"
chk "um invalido"                         ""                    "$(roda 'apt_install_soft xsetroot')"
out=$(PATH="$SB/mock:$PATH" PREFIX="$SB/usr" bash -c "source '$SB/lib.sh' >/dev/null 2>&1
  apt_install_soft bspwm xsetroot polybar" 2>&1)
chk_match "avisa qual faltou" "xsetroot" "$out"
finish
