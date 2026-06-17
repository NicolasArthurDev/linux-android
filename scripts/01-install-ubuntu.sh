#!/data/data/com.termux/files/usr/bin/bash
#
# 01-install-ubuntu.sh
# Roda NO TERMUX.
# Instala o Ubuntu via proot-distro.
#
set -e

DISTRO="ubuntu"

if proot-distro list 2>/dev/null | grep -q "^${DISTRO} .*installed"; then
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
     wget https://raw.githubusercontent.com/NicolasArthurDev/linux-in-s23/main/scripts/02-setup-kde.sh
     chmod +x 02-setup-kde.sh
     ./02-setup-kde.sh

 Veja docs/02-instalacao.md para os detalhes.
============================================================
MSG
