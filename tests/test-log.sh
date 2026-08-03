#!/usr/bin/env bash
# Valida o resumo do 'lx log' contra o padrao real que causou o problema:
# duas linhas que se ALTERNAM, derrotando o 'uniq' simples.
source "$(dirname "$0")/lib.sh"
SB="$(mktemp -d)"; trap 'rm -rf "$SB"' EXIT
export PREFIX="$SB/usr" TMPDIR="$SB/tmp" LX_STATE_DIR="$SB/st"
mkdir -p "$TMPDIR" "$PREFIX/var/lib/proot-distro/containers/ubuntu/rootfs"
lx_source termux "$SB/lib.sh"

LOGF="$TMPDIR/lx-session.log"
# Reproduz o log real: par alternado 500x + algumas linhas singulares no fim.
for _ in $(seq 500); do
    echo 'kpipewire_logging: error: "Failed to connect to PipeWire" 0'
    echo 'received error while creating the stream "Failed to connect to PipeWire" Media monitor will not work.'
done > "$LOGF"
echo "polybar: config loaded" >> "$LOGF"
echo "ERRO IMPORTANTE: fonte JetBrainsMono ausente" >> "$LOGF"

echo "-- premissa: o 'uniq' simples nao colapsa linhas alternadas"
chk "uniq deixa ~1000 linhas" "1002" "$(uniq "$LOGF" | wc -l | tr -d ' ')"
chk "sort+uniq colapsa para 4" "4" "$(sort "$LOGF" | uniq | wc -l | tr -d ' ')"

echo "-- cmd_log"
out="$(NO_COLOR=1 bash -c "source '$SB/lib.sh' >/dev/null 2>&1; cmd_log" 2>&1)"
chk_match "reporta o total de linhas"       "1002 linhas"       "$out"
chk_match "mostra a contagem do ruido"      "500x"              "$out"
chk_match "a linha importante sobrevive"    "fonte JetBrainsMono ausente" "$out"
chk "nao repete o ruido 500 vezes"          "1" \
    "$(printf '%s' "$out" | grep -c 'received error while creating')"

echo "-- filtro de ruido usado ao gravar o log"
chk_match "padrao inclui kpipewire" "kpipewire" \
    "$(grep -o "readonly LX_NOISE=.*" "$LX_BIN" | head -1)"
chk_match "padrao inclui PipeWire"  "Failed to connect to PipeWire" \
    "$(grep -o "readonly LX_NOISE=.*" "$LX_BIN" | head -1)"
finish
