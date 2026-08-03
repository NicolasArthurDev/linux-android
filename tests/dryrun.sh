#!/usr/bin/env bash
# Simula um Termux completo e roda o 'lx' com todo comando externo trocado por
# um mock que registra o argv recebido. Nada e instalado.
#
# Variaveis:
#   DRYRUN_ARGS      argumentos passados ao lx        (padrao: "start")
#   DRYRUN_PRE       comando extra rodado antes
#   DRYRUN_ONLY_KDE  =1 instala so o binario do KDE (testa o guard de --de)
#   DRYRUN_TZ        fuso devolvido pelo getprop      (padrao: America/Sao_Paulo)
set -u
REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT

export PREFIX="$SB/usr" TMPDIR="$SB/tmp" LX_STATE_DIR="$SB/usr/var/lib/lx"
RB="$PREFIX/var/lib/proot-distro/containers/ubuntu"
mkdir -p "$PREFIX/bin" "$TMPDIR" "$LX_STATE_DIR" "$RB/rootfs/usr/bin" "$RB/rootfs/etc"

inst(){ touch "$RB/rootfs/usr/bin/$1"; chmod +x "$RB/rootfs/usr/bin/$1"; }
inst startplasma-x11
[ -n "${DRYRUN_ONLY_KDE:-}" ] || { inst bspwm; inst startxfce4; }
echo "GPU_MODE=turnip" > "$RB/rootfs/etc/linux-android-gpu.conf"

MOCK="$SB/mock"; mkdir -p "$MOCK"; LOG="$SB/calls.log"; : > "$LOG"
for c in pkill pulseaudio termux-wake-lock termux-wake-unlock am termux-x11 \
         virgl_test_server_android proot-distro pm settings sleep killall; do
    { echo '#!/bin/bash'
      echo "{ echo \"### $c\"; i=0; for a in \"\$@\"; do i=\$((i+1)); echo \"  [\$i] <\$a>\"; done; } >> '$LOG'"
      echo 'exit 0'; } > "$MOCK/$c"
    chmod +x "$MOCK/$c"
done
{ echo '#!/bin/bash'
  echo "[ \"\$1\" = persist.sys.timezone ] && echo '${DRYRUN_TZ:-America/Sao_Paulo}'"
  echo 'exit 0'; } > "$MOCK/getprop"; chmod +x "$MOCK/getprop"
export PATH="$MOCK:$PATH"

head -n -1 "$REPO/lx" > /dev/null   # sanidade
sed 's|^readonly CTX=.*|readonly CTX="termux"|' "$REPO/lx" > "$SB/lx"; chmod +x "$SB/lx"

# eval para preservar aspas nos argumentos: sem isto um
# --extra "-force-bgra -dpi 96" seria quebrado em palavras soltas.
[ -n "${DRYRUN_PRE:-}" ] && eval "bash \"\$SB/lx\" ${DRYRUN_PRE}" 2>&1
eval "bash \"\$SB/lx\" ${DRYRUN_ARGS:-start}" 2>&1
echo "=== CHAMADAS ==="
cat "$LOG"
