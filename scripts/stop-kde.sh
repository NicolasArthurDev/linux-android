#!/data/data/com.termux/files/usr/bin/bash
#
# stop-kde.sh
# Roda NO TERMUX.
# Encerra o desktop, o servidor X11 e o áudio para liberar memória.
#
echo "==> Encerrando o KDE Plasma..."
proot-distro login ubuntu -- /bin/bash -c "pkill -f plasma; pkill -f kwin; pkill -f dbus" 2>/dev/null || true

echo "==> Encerrando o servidor Termux-X11..."
pkill -f "com.termux.x11" 2>/dev/null || true
pkill -f "termux.x11"     2>/dev/null || true

echo "==> Encerrando o PulseAudio..."
pulseaudio --kill 2>/dev/null || true

echo "==> Tudo encerrado. Memória liberada."
