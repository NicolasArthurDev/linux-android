#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
lx_source termux "$SB/lib.sh"

cenario() { # $1 = v5|legado|nenhum
    local R; R="$(mktemp -d)"
    local base="$R/usr/var/lib/proot-distro"
    case "$1" in
        v5)     mkdir -p "$base/containers/ubuntu/rootfs" ;;
        legado) mkdir -p "$base/installed-rootfs/ubuntu"  ;;
        *)      mkdir -p "$base" ;;
    esac
    ( PREFIX="$R/usr" LX_STATE_DIR="$R/st" bash -c "
        source '$SB/lib.sh' >/dev/null 2>&1
        resolve_rootfs
        [ -d \"\$ROOTFS\" ] && echo ACHOU || echo AUSENTE" )
    rm -rf "$R"
}
echo "-- deteccao do rootfs"
chk "layout v5 (containers/<n>/rootfs)"   "ACHOU"   "$(cenario v5)"
chk "layout legado (installed-rootfs/<n>)" "ACHOU"   "$(cenario legado)"
chk "nada instalado"                       "AUSENTE" "$(cenario nenhum)"

echo "-- re-resolucao apos instalar (o bug original)"
R="$(mktemp -d)"; mkdir -p "$R/usr/var/lib/proot-distro"
out=$(PREFIX="$R/usr" LX_STATE_DIR="$R/st" bash -c "
  source '$SB/lib.sh' >/dev/null 2>&1
  a=\$( [ -d \"\$ROOTFS\" ] && echo existe || echo nao )
  mkdir -p '$R/usr/var/lib/proot-distro/containers/ubuntu/rootfs'
  resolve_rootfs
  b=\$( [ -d \"\$ROOTFS\" ] && echo existe || echo nao )
  echo \"\$a/\$b\"")
chk "antes/depois de criar o rootfs" "nao/existe" "$out"
rm -rf "$R"
finish
