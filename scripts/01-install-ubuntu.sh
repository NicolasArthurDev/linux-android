#!/data/data/com.termux/files/usr/bin/bash
#
# 01-install-ubuntu.sh
# Roda NO TERMUX.
# Instala o Ubuntu via proot-distro.
#
set -e

DISTRO="ubuntu"
ROOTFS="${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO}"

# Nota: NÃO dá para detectar isso com `proot-distro list | grep`. A saída do
# list é multi-linha ("Alias: ubuntu" / "Status: installed"), então qualquer
# grep de linha única falha silenciosamente. Checar o rootfs é confiável.
if [ -d "${ROOTFS}" ]; then
    echo "==> Ubuntu já parece estar instalado."
    echo "    Para reinstalar do zero: proot-distro remove ${DISTRO}"
else
    echo "==> Instalando o Ubuntu (pode demorar alguns minutos)..."
    proot-distro install "${DISTRO}"
fi

cat <<'MSG'

============================================================
 Ubuntu instalado!

 Agora entre no Ubuntu e instale o KDE:

     proot-distro login ubuntu
     # (dentro do Ubuntu)
     apt update && apt install -y wget
     wget https://raw.githubusercontent.com/NicolasArthurDev/linux-android/main/scripts/02-setup-kde.sh
     chmod +x 02-setup-kde.sh
     ./02-setup-kde.sh

 Veja docs/02-instalacao.md para os detalhes.
============================================================
MSG
