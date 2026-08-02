#!/data/data/com.termux/files/usr/bin/bash
#
# start-kde.sh
# Roda NO TERMUX.
# Inicia o servidor X11 + áudio + KDE Plasma e abre o app Termux:X11.
#
# Variáveis opcionais (para contornar problemas de vídeo em alguns aparelhos):
#   X11_EXTRA="-legacy-drawing"   -> tela preta apesar do KDE estar rodando
#   X11_EXTRA="-force-bgra"       -> cores trocadas (azul/vermelho invertidos)
#   X11_EXTRA="-dpi 120"          -> texto muito pequeno/grande
# Exemplo:  X11_EXTRA="-legacy-drawing" ./start-kde.sh
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

# Impede o Android de matar o Termux em segundo plano e derrubar o desktop
# (é o modo de falha nº1). O stop-kde.sh libera de volta.
termux-wake-lock 2>/dev/null || true

echo "==> Iniciando o PulseAudio (áudio do Linux -> Android)..."
pulseaudio --start \
    --exit-idle-time=-1 \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

echo "==> Iniciando o servidor Termux-X11..."
export XDG_RUNTIME_DIR="${TMPDIR}"
# shellcheck disable=SC2086  # X11_EXTRA precisa sofrer word-splitting
termux-x11 "${DISPLAY_NUM}" ${X11_EXTRA} >/dev/null 2>&1 &
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

    # dbus e Plasma exigem um XDG_RUNTIME_DIR privado (modo 0700). Apontar
    # direto para /tmp gera warnings e falhas de sessão, porque com
    # --shared-tmp o /tmp é compartilhado com o Termux.
    export XDG_RUNTIME_DIR=/tmp/runtime-root
    mkdir -p \"\$XDG_RUNTIME_DIR\"
    chmod 700 \"\$XDG_RUNTIME_DIR\"

    export QT_QPA_PLATFORM=xcb
    # Evita problemas de aceleração de hardware ausente
    export LIBGL_ALWAYS_SOFTWARE=1
    dbus-launch --exit-with-session startplasma-x11
"

echo "==> Sessão KDE encerrada."
echo "    Rode ./stop-kde.sh para liberar memória e o wake-lock."
