#!/usr/bin/env bash
#
# 03-setup-gpu.sh — atalho de compatibilidade.
#
# Toda a lógica do projeto agora vive num script único, o './lx' na raiz do
# repositório. Este arquivo existe só para não quebrar quem já usava os
# scripts separados, e apenas repassa a chamada.
#
# Equivalente moderno:  ./lx gpu
#
# Ativa a aceleração de GPU.
#
set -euo pipefail

DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LX="$DIR/lx"

if [ ! -x "$LX" ]; then
    echo "erro: não encontrei o 'lx' em $LX" >&2
    echo "      atualize o repositório: git pull" >&2
    exit 1
fi

echo "nota: este script agora é só um atalho para './lx gpu'" >&2
exec "$LX" gpu "$@"
