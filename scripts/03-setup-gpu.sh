#!/bin/bash
#
# 03-setup-gpu.sh
# Roda DENTRO DO UBUNTU (após `proot-distro login ubuntu`).
#
# Instala aceleração de GPU real (Turnip / Mesa freedreno via KGSL).
#
# Por que isto importa:
#   Sem GPU, o KDE é desenhado 100% pela CPU (LIBGL_ALWAYS_SOFTWARE=1). Funciona,
#   mas rolagem, vídeo e o navegador ficam pesados e o celular esquenta.
#   O S23 tem GPU Adreno 740, que é suportada pelo driver Turnip do Mesa.
#
# Como funciona:
#   O Mesa do Ubuntu não fala com a GPU do Android. O projeto
#   lfdevs/mesa-for-android-container distribui um Mesa compilado para
#   containers em Android, que acessa a Adreno pela interface KGSL do kernel.
#   Não precisa de root e não precisa de servidor auxiliar rodando no Termux
#   (diferente do virgl).
#
set -e

export DEBIAN_FRONTEND=noninteractive

REPO="lfdevs/mesa-for-android-container"
MARKER="/etc/linux-android-gpu.conf"

# ---------------------------------------------------------------------------
# Sanidade
# ---------------------------------------------------------------------------
if [ ! -f /etc/os-release ]; then
    echo "ERRO: rode este script DENTRO do Ubuntu (proot-distro login ubuntu)."
    exit 1
fi

# shellcheck disable=SC1091
. /etc/os-release

if [ "$(uname -m)" != "aarch64" ]; then
    echo "ERRO: este build do Mesa é só para arm64 (aarch64). Detectado: $(uname -m)"
    exit 1
fi

# Mapeia o codename do Ubuntu para o sufixo do pacote publicado no release.
case "${VERSION_CODENAME:-}" in
    noble)    SUFFIX="ubuntu_noble_arm64"    ;;  # 24.04 LTS (padrão do proot-distro)
    questing) SUFFIX="ubuntu_questing_arm64" ;;  # 25.10
    resolute) SUFFIX="ubuntu_resolute_arm64" ;;  # 26.04 LTS
    *)
        echo "ERRO: não há build do Mesa para '${VERSION_CODENAME:-desconhecido}'."
        echo "      Versões suportadas: noble (24.04), questing (25.10), resolute (26.04)."
        echo
        echo "      Você ainda pode usar a GPU pelo caminho alternativo (virgl):"
        echo "      veja docs/07-aceleracao-gpu.md"
        exit 1
        ;;
esac

echo "==> Ubuntu ${VERSION_ID} (${VERSION_CODENAME}) — usando build '${SUFFIX}'."

# ---------------------------------------------------------------------------
# Dependências
# ---------------------------------------------------------------------------
echo "==> Instalando dependências..."
apt update
apt install -y curl ca-certificates mesa-utils vulkan-tools

# ---------------------------------------------------------------------------
# Descobre a URL do release mais recente
# ---------------------------------------------------------------------------
echo "==> Consultando o release mais recente de ${REPO}..."
URL="$(curl -fsSL "https://api.github.com/repos/${REPO}/releases/latest" \
    | grep -o "https://[^\"]*_${SUFFIX}\.tar\.gz" \
    | head -n 1)"

if [ -z "${URL}" ]; then
    echo "ERRO: não achei o pacote '${SUFFIX}' no release mais recente."
    echo "      Baixe manualmente em: https://github.com/${REPO}/releases"
    exit 1
fi

echo "    ${URL}"

# ---------------------------------------------------------------------------
# Baixa e instala
# ---------------------------------------------------------------------------
TMPFILE="$(mktemp /tmp/mesa-android-XXXXXX.tar.gz)"
# shellcheck disable=SC2064
trap "rm -f '${TMPFILE}'" EXIT

echo "==> Baixando (~11 MB)..."
curl -fL --progress-bar -o "${TMPFILE}" "${URL}"

echo "==> Extraindo para / ..."
tar -zxf "${TMPFILE}" -C /

echo "==> Atualizando o cache do linker..."
ldconfig

# ---------------------------------------------------------------------------
# Marca o modo para o start-kde.sh detectar automaticamente
# ---------------------------------------------------------------------------
cat > "${MARKER}" <<EOF
# Gerado por 03-setup-gpu.sh — lido pelo start-kde.sh
GPU_MODE=turnip
EOF

# ---------------------------------------------------------------------------
# Teste
# ---------------------------------------------------------------------------
cat <<'MSG'

============================================================
 Aceleração de GPU instalada (Turnip / KGSL).

 Para TESTAR, com o desktop rodando, abra um terminal dentro
 do KDE e rode:

     MESA_LOADER_DRIVER_OVERRIDE=kgsl glxinfo -B

 Procure por "OpenGL renderer string". Se aparecer algo com
 "Turnip" ou "Adreno", a GPU está sendo usada.
 Se aparecer "llvmpipe" ou "softpipe", ainda está na CPU.

 Benchmark rápido:

     MESA_LOADER_DRIVER_OVERRIDE=kgsl glmark2      # (apt install glmark2)

 O start-kde.sh agora detecta isto sozinho e usa a GPU.
 Para forçar um modo específico:

     GPU_MODE=turnip   ./start-kde.sh   # GPU (padrão se instalado)
     GPU_MODE=virgl    ./start-kde.sh   # GPU via virgl (alternativo)
     GPU_MODE=software ./start-kde.sh   # sem GPU (diagnóstico)

 Se o desktop ficar instável ou com artefatos, volte para
 'software' e veja docs/07-aceleracao-gpu.md.
============================================================
MSG
