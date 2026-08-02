#!/data/data/com.termux/files/usr/bin/bash
#
# start-kde-alt.sh  (MÉTODO ALTERNATIVO)
# Roda NO TERMUX.
#
# Diferença para o start-kde.sh:
#   Aqui o KDE é lançado pelo próprio Termux-X11 via "-xstartup". O servidor X11
#   sobe e já inicia o desktop como cliente, gerenciando o ciclo de vida junto.
#   Alguns aparelhos acham esse método mais estável. Use se o start-kde.sh falhar.
#
set -e

DISTRO="ubuntu"
DISPLAY_NUM=":0"
X11_EXTRA="${X11_EXTRA:-}"

echo "==> Encerrando sessões antigas (se houver)..."
pkill -f "com.termux.x11" 2>/dev/null || true
pkill -f "termux.x11"     2>/dev/null || true
pulseaudio --kill         2>/dev/null || true
sleep 1

termux-wake-lock 2>/dev/null || true

echo "==> Iniciando o PulseAudio (áudio do Linux -> Android)..."
pulseaudio --start \
    --exit-idle-time=-1 \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

echo "==> Abrindo o app Termux:X11..."
am start --user 0 \
    -n com.termux.x11/com.termux.x11.MainActivity >/dev/null 2>&1 || \
    echo "    (Não consegui abrir automaticamente — abra o app Termux:X11 na mão.)"
sleep 2

echo "==> Iniciando o servidor X11 e o KDE juntos (-xstartup)..."
export XDG_RUNTIME_DIR="${TMPDIR}"

# O Termux-X11 sobe o display :0 e executa o comando do -xstartup como cliente,
# definindo DISPLAY no ambiente desse cliente.
#
# ATENÇÃO: isso NÃO basta aqui. O cliente é o `proot-distro login`, que sanitiza
# o ambiente antes de entrar no rootfs — o DISPLAY herdado é descartado e o KDE
# morre com "Cannot open display". Por isso exportamos DISPLAY explicitamente
# dentro do bash -c.
# shellcheck disable=SC2086
termux-x11 "${DISPLAY_NUM}" ${X11_EXTRA} -xstartup "proot-distro login ${DISTRO} --shared-tmp -- /bin/bash -c '
    export DISPLAY=${DISPLAY_NUM}
    export PULSE_SERVER=127.0.0.1

    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p \"\$XDG_RUNTIME_DIR\"
    chmod 700 \"\$XDG_RUNTIME_DIR\"

    export QT_QPA_PLATFORM=xcb
    export LIBGL_ALWAYS_SOFTWARE=1
    dbus-launch --exit-with-session startplasma-x11
'"

echo "==> Sessão KDE encerrada."
echo "    Rode ./stop-kde.sh para liberar memória e o wake-lock."
