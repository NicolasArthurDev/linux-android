#!/data/data/com.termux/files/usr/bin/bash
#
# start-kde.sh
# Roda NO TERMUX.
# Inicia o servidor X11 + áudio + KDE Plasma e abre o app Termux:X11.
#
set -e

DISTRO="ubuntu"
DISPLAY_NUM=":0"

echo "==> Encerrando sessões antigas (se houver)..."
pkill -f "com.termux.x11" 2>/dev/null || true
pkill -f "termux.x11"     2>/dev/null || true
pulseaudio --kill         2>/dev/null || true
sleep 1

echo "==> Iniciando o PulseAudio (áudio do Linux -> Android)..."
pulseaudio --start \
    --exit-idle-time=-1 \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

echo "==> Iniciando o servidor Termux-X11..."
export XDG_RUNTIME_DIR="${TMPDIR}"
termux-x11 "${DISPLAY_NUM}" >/dev/null 2>&1 &
sleep 3

echo "==> Abrindo o app Termux:X11..."
am start --user 0 \
    -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || \
    echo "    (Não consegui abrir automaticamente — abra o app Termux:X11 na mão.)"
sleep 2

echo "==> Iniciando o KDE Plasma dentro do Ubuntu..."
proot-distro login "${DISTRO}" --shared-tmp -- /bin/bash -c "
    export DISPLAY=${DISPLAY_NUM}
    export PULSE_SERVER=127.0.0.1
    export XDG_RUNTIME_DIR=/tmp
    export QT_QPA_PLATFORM=xcb
    # Evita problemas de aceleração de hardware ausente
    export LIBGL_ALWAYS_SOFTWARE=1
    dbus-launch --exit-with-session startplasma-x11
"

echo "==> Sessão KDE encerrada."
