# 4. Solução de problemas

## A tela do Termux:X11 fica preta / não carrega o KDE

- Confirme que o app **Termux:X11** está aberto **antes** do KDE terminar de iniciar.
- O primeiro carregamento do Plasma leva 1–2 min. Aguarde.
- Verifique se o pacote `termux-x11-nightly` e o **APK** Termux:X11 são da mesma época.
  Se você atualizou um, atualize o outro.
- Reinicie do zero:
  ```bash
  ./stop-kde.sh
  ./start-kde.sh
  ```
- **Se o `start-kde.sh` insistir em falhar, tente o método alternativo:**
  ```bash
  ./stop-kde.sh
  ./start-kde-alt.sh
  ```
  Ele inicia o servidor X11 e o KDE juntos via `-xstartup`, que alguns aparelhos
  acham mais estável.

## "Cannot open display :0" / KDE não conecta

- O servidor X11 não subiu. Confira se o `termux-x11 :0` está rodando:
  ```bash
  pgrep -f termux-x11
  ```
- Garanta que dentro do Ubuntu o `DISPLAY` está como `:0` (o `start-kde.sh` já faz isso).

## Tela pisca, trava ou os ícones somem

- É o **compositor** do KDE tentando usar GPU que não existe em proot.
- O `02-setup-kde.sh` já desativa o compositor. Se voltou a ativar, rode dentro do Ubuntu:
  ```bash
  proot-distro login ubuntu
  kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
  exit
  ```
- Confirme que `LIBGL_ALWAYS_SOFTWARE=1` está no `start-kde.sh` (renderização por software).

## Sem áudio

- O PulseAudio precisa estar rodando no Termux (o `start-kde.sh` inicia).
- Dentro do Ubuntu, teste:
  ```bash
  PULSE_SERVER=127.0.0.1 pactl info
  ```
- Se falhar, reinicie o áudio no Termux:
  ```bash
  pulseaudio --kill
  pulseaudio --start --exit-idle-time=-1 \
      --load="module-native-protocol-tcp auth-ip-acl=127.0.0.1 auth-anonymous=1"
  ```

## O Android "mata" o Termux em segundo plano

- Desative a otimização de bateria (veja [pré-requisitos](01-pre-requisitos.md)).
- Ative o **wake-lock** pela notificação do Termux.

## "KDE roda como root" / avisos de segurança

- Funciona, mas o KDE reclama. Se quiser, crie um usuário comum: descomente o
  bloco `USERNAME` em `scripts/02-setup-kde.sh` e ajuste o `start-kde.sh` para
  logar como esse usuário (`proot-distro login ubuntu --user linux`).

## Firefox não instala (erro de snap)

- O Firefox no Ubuntu vem como **snap**, que **não funciona em proot**.
- Use o **Chromium** via apt ou instale o Firefox ESR de um `.deb`/PPA.
  Veja [dicas de desempenho](05-dicas-desempenho.md).

## Quero começar do zero

```bash
proot-distro remove ubuntu
./01-install-ubuntu.sh
```

---

Não achou seu problema? Abra uma *issue* no repositório descrevendo o erro e o
que aparece no Termux.
