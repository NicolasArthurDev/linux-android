# 2. Instalação passo a passo

Tempo estimado: **30–60 min** (depende da internet). Mantenha o celular no Wi-Fi e carregando.

Vamos baixar os scripts deste repositório diretamente no Termux e executá-los na ordem.

---

## Passo 0 — Baixar os scripts no Termux

Abra o **Termux** e rode:

```bash
pkg install -y git
git clone https://github.com/NicolasArthurDev/linux-in-s23.git
cd linux-in-s23/scripts
chmod +x *.sh
```

> Se o repositório ainda não estiver publicado no GitHub, dá para copiar os
> scripts manualmente (veja a pasta `scripts/`).

---

## Passo 1 — Preparar o Termux

```bash
./00-setup-termux.sh
```

Isso instala: `proot-distro`, `termux-x11-nightly`, `pulseaudio` e dependências.
Também roda o `termux-setup-storage` (vai pedir permissão de armazenamento — **aceite**).

---

## Passo 2 — Instalar o Ubuntu

```bash
./01-install-ubuntu.sh
```

Faz o download e instala o Ubuntu via proot-distro. Pode demorar alguns minutos.

---

## Passo 3 — Instalar o KDE Plasma (dentro do Ubuntu)

Primeiro entre no Ubuntu:

```bash
proot-distro login ubuntu
```

Agora você está **dentro do Ubuntu** (o prompt vira `root@localhost`).
Rode o script de setup do KDE — ele está acessível pelo armazenamento compartilhado,
mas o jeito mais simples é copiá-lo para dentro. Faça assim:

```bash
# (ainda dentro do Ubuntu)
cd /root
# baixe de novo só este script, ou cole o conteúdo:
apt update && apt install -y wget
wget https://raw.githubusercontent.com/NicolasArthurDev/linux-in-s23/main/scripts/02-setup-kde.sh
chmod +x 02-setup-kde.sh
./02-setup-kde.sh
```

Esse é o passo mais demorado (baixa o KDE inteiro). Ao terminar, **saia do Ubuntu**:

```bash
exit
```

---

## Passo 4 — Iniciar o desktop

De volta ao Termux (fora do Ubuntu):

```bash
cd ~/linux-in-s23/scripts
./start-kde.sh
```

O script inicia o servidor X11, o áudio e o KDE, e **abre o app Termux:X11 automaticamente**.
Se não abrir sozinho, abra o app **Termux:X11** manualmente — o desktop estará lá.

> Na primeira vez o KDE leva 1–2 min para carregar. Tenha paciência.

---

## Passo 5 — Encerrar

Para fechar o desktop e liberar memória, volte ao Termux e rode:

```bash
./stop-kde.sh
```

---

## Resumo dos comandos do dia a dia

```bash
cd ~/linux-in-s23/scripts
./start-kde.sh   # iniciar
./stop-kde.sh    # parar
```

Veja mais em [uso diário](03-uso-diario.md).
