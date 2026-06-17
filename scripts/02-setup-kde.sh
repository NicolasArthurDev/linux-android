#!/bin/bash
#
# 02-setup-kde.sh
# Roda DENTRO DO UBUNTU (após `proot-distro login ubuntu`).
# Instala o KDE Plasma e ajusta o ambiente para rodar bem em proot.
#
set -e

if [ ! -f /etc/os-release ] || ! grep -qi ubuntu /etc/os-release; then
    echo "ERRO: este script deve rodar DENTRO do Ubuntu (proot-distro login ubuntu)."
    exit 1
fi

echo "==> Atualizando o Ubuntu..."
apt update
apt upgrade -y

echo "==> Instalando o KDE Plasma e dependências essenciais..."
# kde-plasma-desktop = base do Plasma (mais enxuto que o kubuntu-desktop completo).
# dbus-x11 = necessário para o Plasma iniciar via dbus-launch.
DEBIAN_FRONTEND=noninteractive apt install -y \
    kde-plasma-desktop \
    dbus-x11 \
    konsole \
    dolphin \
    kate \
    sudo \
    nano \
    pulseaudio-utils \
    fonts-noto \
    fonts-noto-cjk \
    locales

echo "==> Configurando locale (evita avisos do KDE)..."
locale-gen en_US.UTF-8 pt_BR.UTF-8 || true
update-locale LANG=pt_BR.UTF-8 || true

# -------------------------------------------------------------------
# Ajustes do KDE para proot: desativa efeitos que costumam travar/piscar
# -------------------------------------------------------------------
echo "==> Aplicando ajustes do KDE para proot (desativando compositor problemático)..."
mkdir -p /root/.config

# Desativa o compositor (efeitos translúcidos costumam falhar sem GPU dedicada)
cat > /root/.config/kwinrc <<'EOF'
[Compositing]
Enabled=false
EOF

# Evita que o KDE tente bloquear a tela (lock screen quebra em proot)
cat > /root/.config/kscreenlockerrc <<'EOF'
[Daemon]
Autolock=false
LockOnResume=false
EOF

# -------------------------------------------------------------------
# Usuário comum (opcional, mas recomendado — KDE reclama de rodar como root)
# Descomente o bloco abaixo se quiser criar um usuário não-root.
# -------------------------------------------------------------------
# USERNAME="linux"
# if ! id "$USERNAME" >/dev/null 2>&1; then
#     useradd -m -s /bin/bash "$USERNAME"
#     echo "$USERNAME:$USERNAME" | chpasswd
#     usermod -aG sudo "$USERNAME"
#     echo "Usuário '$USERNAME' criado (senha: '$USERNAME'). Troque com: passwd $USERNAME"
# fi

cat <<'MSG'

============================================================
 KDE Plasma instalado e configurado!

 Saia do Ubuntu:
     exit

 Depois, no Termux:
     cd ~/linux-in-s23/scripts
     ./start-kde.sh
============================================================
MSG
