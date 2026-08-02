#!/data/data/com.termux/files/usr/bin/bash
#
# stop-kde.sh
# Roda NO TERMUX.
# Encerra o desktop, o servidor X11 e o áudio para liberar memória.
#
# Nota importante sobre os padrões abaixo:
#
#   O proot NÃO cria um namespace de PID separado — os processos do Ubuntu são
#   visíveis direto do Termux. Então não precisamos de `proot-distro login` para
#   matá-los, e é melhor não usar: a versão anterior deste script rodava
#
#       proot-distro login ubuntu -- bash -c "pkill -f plasma; pkill -f kwin; ..."
#
#   e se auto-destruía. `pkill -f` casa contra a linha de comando inteira, e a
#   string "pkill -f plasma" aparece na cmdline do próprio bash -c (e do proot,
#   e do proot-distro). O primeiro pkill matava os próprios ancestrais, o bash
#   morria ali, e kwin/dbus NUNCA eram encerrados — deixando o desktop comendo
#   memória justamente quando o objetivo era liberá-la.
#
#   A forma [k]win_x11 evita isso: o padrão literal "[k]win_x11" na cmdline do
#   pkill não casa com a regex "[k]win_x11" (que exige o texto "kwin_x11").
#
echo "==> Encerrando o KDE Plasma..."
pkill -f "[s]tartplasma-x11" 2>/dev/null || true
pkill -f "[p]lasmashell"     2>/dev/null || true
pkill -f "[k]win_x11"        2>/dev/null || true
pkill -f "[k]ded"            2>/dev/null || true
pkill -f "[k]smserver"       2>/dev/null || true
pkill -f "[d]bus-launch"     2>/dev/null || true
pkill -f "[d]bus-daemon"     2>/dev/null || true
sleep 1

echo "==> Encerrando a sessão proot do Ubuntu..."
pkill -f "[p]root-distro"    2>/dev/null || true
pkill -f "[i]nstalled-rootfs/ubuntu" 2>/dev/null || true

echo "==> Encerrando o servidor virgl (se estiver rodando)..."
pkill -f "[v]irgl_test_server" 2>/dev/null || true

echo "==> Encerrando o servidor Termux-X11..."
pkill -f "com.termux.x11" 2>/dev/null || true
pkill -f "termux.x11"     2>/dev/null || true

echo "==> Encerrando o PulseAudio..."
pulseaudio --kill 2>/dev/null || true

echo "==> Liberando o wake-lock..."
termux-wake-unlock 2>/dev/null || true

echo "==> Tudo encerrado. Memória liberada."
