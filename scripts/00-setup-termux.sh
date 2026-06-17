#!/data/data/com.termux/files/usr/bin/bash
#
# 00-setup-termux.sh
# Roda NO TERMUX (não dentro do Ubuntu).
# Prepara o Termux: repositórios, proot-distro, Termux-X11, PulseAudio.
#
set -e

echo "==> Atualizando pacotes do Termux..."
pkg update -y
pkg upgrade -y

echo "==> Habilitando o repositório x11 (necessário para o Termux-X11)..."
pkg install -y x11-repo

echo "==> Instalando proot-distro, Termux-X11, PulseAudio e utilitários..."
pkg install -y \
    proot-distro \
    termux-x11-nightly \
    pulseaudio \
    git \
    wget \
    nano \
    termux-api

echo "==> Configurando acesso ao armazenamento (aceite a permissão na tela)..."
termux-setup-storage || true

cat <<'MSG'

============================================================
 Termux preparado com sucesso!

 Lembre-se: o APP "Termux:X11" precisa estar instalado
 separadamente (veja docs/01-pre-requisitos.md).

 Próximo passo:
     ./01-install-ubuntu.sh
============================================================
MSG
