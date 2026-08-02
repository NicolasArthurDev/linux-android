#!/data/data/com.termux/files/usr/bin/bash
#
# start-kde.sh
# Roda NO TERMUX.
# Inicia o servidor X11 + áudio + KDE Plasma e abre o app Termux:X11.
#
# ---------------------------------------------------------------------------
# Variáveis opcionais
# ---------------------------------------------------------------------------
#
# GPU_MODE — como o desktop é renderizado:
#   auto      (padrão) usa Turnip se o 03-setup-gpu.sh foi executado,
#             senão cai para software automaticamente
#   turnip    GPU Adreno direto via KGSL — mais rápido (requer 03-setup-gpu.sh)
#   virgl     GPU via servidor virgl no Termux — alternativa mais compatível
#   software  tudo na CPU — mais lento, porém o mais estável (diagnóstico)
#
# X11_EXTRA — contorna problemas de vídeo em alguns aparelhos:
#   "-legacy-drawing"  tela preta apesar do KDE estar rodando
#   "-force-bgra"      cores trocadas (azul/vermelho invertidos)
#   "-dpi 96"          texto muito pequeno/grande (bom para monitor externo)
#
# Exemplos:
#   ./start-kde.sh
#   GPU_MODE=software ./start-kde.sh
#   X11_EXTRA="-force-bgra -dpi 96" ./start-kde.sh
#
set -e

DISTRO="ubuntu"
DISPLAY_NUM=":0"
X11_EXTRA="${X11_EXTRA:-}"
GPU_MODE="${GPU_MODE:-auto}"

ROOTFS="${PREFIX}/var/lib/proot-distro/installed-rootfs/${DISTRO}"

# ---------------------------------------------------------------------------
# Resolve GPU_MODE=auto olhando o marcador deixado pelo 03-setup-gpu.sh.
# Fazemos isso aqui (do Termux, lendo o rootfs direto) para poder decidir se
# precisamos subir o servidor virgl ANTES de entrar no proot.
# ---------------------------------------------------------------------------
if [ "${GPU_MODE}" = "auto" ]; then
    if [ -f "${ROOTFS}/etc/linux-android-gpu.conf" ] &&
       grep -q "GPU_MODE=turnip" "${ROOTFS}/etc/linux-android-gpu.conf" 2>/dev/null; then
        GPU_MODE="turnip"
    else
        GPU_MODE="software"
    fi
fi

case "${GPU_MODE}" in
    turnip|virgl|software) ;;
    *)
        echo "ERRO: GPU_MODE inválido: '${GPU_MODE}'"
        echo "      Use: auto | turnip | virgl | software"
        exit 1
        ;;
esac

echo "==> Modo de renderização: ${GPU_MODE}"
[ "${GPU_MODE}" = "software" ] && \
    echo "    (dica: rode o 03-setup-gpu.sh dentro do Ubuntu para ativar a GPU)"

echo "==> Encerrando sessões antigas (se houver)..."
pkill -f "com.termux.x11" 2>/dev/null || true
pkill -f "termux.x11"     2>/dev/null || true
pkill -f "[v]irgl_test_server" 2>/dev/null || true
pulseaudio --kill         2>/dev/null || true
sleep 1

# Impede o Android de matar o Termux em segundo plano e derrubar o desktop
# (é o modo de falha nº1). O stop-kde.sh libera de volta.
termux-wake-lock 2>/dev/null || true

echo "==> Iniciando o PulseAudio (áudio do Linux -> Android)..."
pulseaudio --start \
    --exit-idle-time=-1 \
    --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"

# ---------------------------------------------------------------------------
# O virgl (e SÓ o virgl) precisa de um servidor rodando no lado do Termux.
# O Turnip fala com a GPU direto de dentro do proot, sem servidor.
# ---------------------------------------------------------------------------
if [ "${GPU_MODE}" = "virgl" ]; then
    echo "==> Iniciando o servidor virgl..."
    if ! command -v virgl_test_server_android >/dev/null 2>&1; then
        echo "ERRO: 'virgl_test_server_android' não encontrado."
        echo "      Instale no Termux:  pkg install virglrenderer-android"
        exit 1
    fi
    virgl_test_server_android >/dev/null 2>&1 &
    sleep 1
fi

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

    case '${GPU_MODE}' in
        turnip)
            # Mesa freedreno/Turnip falando com a Adreno pela interface KGSL.
            export MESA_LOADER_DRIVER_OVERRIDE=kgsl
            # Reduz tearing na composição do Termux:X11.
            export vblank_mode=3
            export MESA_VK_WSI_PRESENT_MODE=mailbox
            ;;
        virgl)
            export GALLIUM_DRIVER=virpipe
            export MESA_GL_VERSION_OVERRIDE=4.0
            ;;
        software)
            export LIBGL_ALWAYS_SOFTWARE=1
            ;;
    esac

    dbus-launch --exit-with-session startplasma-x11
"

echo "==> Sessão KDE encerrada."
echo "    Rode ./stop-kde.sh para liberar memória e o wake-lock."
