#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
lx_source ubuntu "$SB/lib.sh"
export LX_STATE_DIR="$SB/state" PREFIX="$SB/usr"
# shellcheck disable=SC1090
NO_COLOR=1 source "$SB/lib.sh" 2>/dev/null

echo "-- resolve_gpu_mode"
chk "auto sem marcador -> software" "software" "$(resolve_gpu_mode auto)"
chk "turnip explicito"              "turnip"   "$(resolve_gpu_mode turnip)"
chk "virgl explicito"               "virgl"    "$(resolve_gpu_mode virgl)"
chk "software explicito"            "software" "$(resolve_gpu_mode software)"
resolve_gpu_mode lixo >/dev/null 2>&1 && r=aceitou || r=rejeitado
chk "valor invalido rejeitado" "rejeitado" "$r"

echo "-- estado"
state_init
state_has termux && r=sim || r=nao; chk "vazio: nao marcado" "nao" "$r"
state_set termux; state_has termux && r=sim || r=nao; chk "apos set: marcado" "sim" "$r"
state_set termux; state_set termux
chk "sem duplicatas" "1" "$(grep -c '^termux$' "$LX_STATE_DIR/state")"
state_clear termux; state_has termux && r=sim || r=nao; chk "apos clear" "nao" "$r"

echo "-- append_shell_rc (idempotencia)"
H="$SB/home"; mkdir -p "$H"; touch "$H/.zshrc" "$H/.bashrc"
append_shell_rc "$H" 'alias t="echo oi"'
append_shell_rc "$H" 'alias t="echo oi"'
append_shell_rc "$H" 'alias t="echo oi"'
chk "bloco no .zshrc uma vez"  "1" "$(grep -c '>>> lx dev >>>' "$H/.zshrc")"
chk "bloco no .bashrc uma vez" "1" "$(grep -c '>>> lx dev >>>' "$H/.bashrc")"

echo "-- setup_tmux_conf preserva config do usuario"
setup_tmux_conf "$H" >/dev/null
chk "cria o arquivo" "1" "$([ -f "$H/.tmux.conf" ] && echo 1 || echo 0)"
echo "MEU" > "$H/.tmux.conf"; setup_tmux_conf "$H" >/dev/null
chk "nao sobrescreve"  "MEU" "$(cat "$H/.tmux.conf")"

echo "-- padroes de pkill nao se auto-casam"
for p in "[s]tartplasma-x11" "[p]lasmashell" "[k]win_x11" "[v]irgl_test_server" "[c]ontainers/ubuntu/rootfs"; do
    echo "pkill -f $p" | grep -qE "$p" && r=AUTOCASA || r=ok
    chk "padrao $p" "ok" "$r"
done
finish
