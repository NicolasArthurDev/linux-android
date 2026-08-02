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

# O índice do repositório recém-habilitado precisa ser lido antes de instalar
# qualquer pacote dele, senão dá "package not found" de forma intermitente.
pkg update -y

echo "==> Instalando proot-distro, Termux-X11, PulseAudio e utilitários..."
pkg install -y \
    proot-distro \
    termux-x11-nightly \
    pulseaudio \
    git \
    wget \
    nano \
    termux-api

# Aceleração de GPU pelo caminho ALTERNATIVO (virgl). O caminho principal do S23
# é o Turnip, instalado dentro do Ubuntu pelo 03-setup-gpu.sh e que não precisa
# de nada aqui. Instalamos o virgl mesmo assim porque é o plano B se o Turnip
# não funcionar. Se falhar (pacote renomeado, repo indisponível), seguimos —
# não é essencial para o desktop subir.
echo "==> Instalando suporte a GPU pelo caminho alternativo (virgl)..."
pkg install -y virglrenderer-android || \
    echo "    (virgl indisponível — sem problema, o caminho principal é o Turnip.)"

echo "==> Configurando acesso ao armazenamento (aceite a permissão na tela)..."
termux-setup-storage || true

cat <<'MSG'

============================================================
 Termux preparado com sucesso!

 Lembre-se dos APKs que precisam ser instalados à mão
 (veja docs/01-pre-requisitos.md):
   - Termux:X11  (obrigatório — é a "tela")
   - Termux:API  (opcional — o pacote 'termux-api' instalado aqui
                  só funciona se o app também estiver instalado)

 Próximo passo:
     ./01-install-ubuntu.sh
============================================================
MSG
