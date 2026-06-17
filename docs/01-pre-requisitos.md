# 1. Pré-requisitos

Antes de rodar qualquer script, você precisa instalar **dois apps** no Galaxy S23.
⚠️ **Importante:** não instale o Termux pela Play Store — a versão de lá está
desatualizada e quebrada. Use o **F-Droid** ou o **GitHub**.

---

## App 1 — Termux

O ambiente base onde tudo roda.

- **Recomendado (F-Droid):** https://f-droid.org/packages/com.termux/
- **Ou GitHub:** https://github.com/termux/termux-app/releases
  (baixe o `termux-app_v*+github-debug_arm64-v8a.apk`)

> O S23 é `arm64-v8a` (64 bits). Sempre escolha esse ABI.

## App 2 — Termux:X11

O app que mostra a tela do desktop. Ele **não** está na Play Store.

- **GitHub (nightly):** https://github.com/termux/termux-x11/releases
  (baixe `app-arm64-v8a-debug.apk`)

> O pacote `termux-x11-nightly` (instalado pelo script no Termux) e o **APK**
> Termux:X11 precisam ser da **mesma origem/época**. Se você atualizar um,
> atualize o outro, ou a tela pode não conectar.

---

## Instalando os APKs

1. Baixe os dois `.apk` no celular.
2. Ao abrir, o Android vai pedir para permitir "instalar apps de fontes desconhecidas" — autorize.
3. Instale primeiro o **Termux**, depois o **Termux:X11**.

---

## Espaço e bateria

- O Ubuntu + KDE ocupa cerca de **4–6 GB**. Tenha espaço livre.
- O primeiro download/instalação consome bastante dados — use **Wi-Fi**.
- Mantenha o celular **carregando** durante a instalação (é demorado).

---

## Recomendado: desativar otimização de bateria do Termux

O Android pode "matar" o Termux em segundo plano e derrubar o desktop.

1. Configurações do Android → Apps → **Termux** → Bateria → **Sem restrições**.
2. Faça o mesmo para o **Termux:X11**.
3. Opcional: dentro do Termux, ative o wake-lock pelo menu da notificação
   (deslize a barra de notificações → toque em **Acquire wakelock** no Termux).

---

Pronto? Vá para o [guia de instalação](02-instalacao.md).
