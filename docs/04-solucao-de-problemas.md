# 4. Solução de problemas

## A tela do Termux:X11 fica preta / não carrega o KDE

- Confirme que o app **Termux:X11** está aberto **antes** do KDE terminar de iniciar.
- O primeiro carregamento do Plasma leva 1–2 min. Aguarde.
- Verifique se o pacote `termux-x11-nightly` e o **APK** Termux:X11 são da mesma época.
  Se você atualizou um, atualize o outro.
- Reinicie do zero:
  ```bash
  lx stop
  lx start
  ```
- **Se o `lx start` insistir em falhar, tente o método alternativo:**
  ```bash
  lx stop
  lx start --alt
  ```
  Ele inicia o servidor X11 e o KDE juntos via `-xstartup`, que alguns aparelhos
  acham mais estável.
- **Tela preta mesmo com o KDE rodando** — é um problema de desenho do
  Termux:X11, não do KDE. Use a flag oficial de contorno:
  ```bash
  lx stop
  lx start --extra "-legacy-drawing"
  ```

## Cores trocadas (azul aparece como vermelho)

Alguns aparelhos invertem a ordem dos canais de cor:

```bash
lx stop
lx start --extra "-force-bgra"
```

## "Cannot open display :0" / KDE não conecta

- O servidor X11 não subiu. Confira se o `termux-x11 :0` está rodando:
  ```bash
  pgrep -f termux-x11
  ```
- Garanta que dentro do Ubuntu o `DISPLAY` está como `:0` (o `lx start` já faz isso).

## Tela pisca, trava ou os ícones somem

- É o **compositor** do KDE tentando usar GPU que não existe em proot.
- O `lx setup` já desativa o compositor. Se voltou a ativar, rode dentro do Ubuntu:
  ```bash
  proot-distro login ubuntu
  kwriteconfig5 --file kwinrc --group Compositing --key Enabled false
  exit
  ```
  > No Ubuntu 24.04 o comando é `kwriteconfig5` (Plasma 5). Se a imagem do
  > proot-distro for Ubuntu 25.x ou mais nova, o Plasma é 6 e o comando vira
  > `kwriteconfig6`. Cheque com `kwriteconfig6 --help` se o 5 não existir.
- Confirme que `LIBGL_ALWAYS_SOFTWARE=1` está ativo — use `lx start --gpu software`.

## Sem áudio

- O PulseAudio precisa estar rodando no Termux (o `lx start` inicia).
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

## O desktop morre sozinho depois de alguns minutos / apps somem

Esta é a causa nº1 de instabilidade, e não gera mensagem de erro nenhuma:
o **Phantom Process Killer** do Android 12+ limita a ~32 processos filhos por app
e mata o excesso. O KDE passa disso com folga.

Solução: Opções de desenvolvedor → **"Desativar restrições de processos filhos"**
→ **reiniciar o celular**. Passo a passo em [pré-requisitos](01-pre-requisitos.md).

Se o desktop cai sempre por volta do mesmo ponto (ex.: ao abrir o navegador),
é quase certo que seja isso.

## O Android "mata" o Termux em segundo plano

- Desative a otimização de bateria (veja [pré-requisitos](01-pre-requisitos.md)).
- O `lx start` já ativa o **wake-lock** automaticamente. Ele vem do pacote
  `termux-tools`, que já é parte do Termux — **não** precisa do Termux:API.
- Confira também a restrição de processos filhos, acima.

## "KDE roda como root" / avisos de segurança

Funciona, mas o KDE reclama. Se quiser rodar como usuário comum, crie um dentro
do Ubuntu:

```bash
lx shell
# (dentro do Ubuntu)
useradd -m -s /bin/bash linux
echo "linux:linux" | chpasswd
usermod -aG sudo linux
passwd linux          # troque a senha
exit
```

Depois é preciso ajustar o `lx` para logar como esse usuário: no `cmd_start`,
troque `proot-distro login "$DISTRO" --shared-tmp` por
`proot-distro login "$DISTRO" --shared-tmp --user linux`.

> Nota: o `lx` não tem opção pronta para isso ainda. Rodar como root funciona e
> é o padrão do projeto — só gera avisos.

## Firefox não instala (erro de snap)

- O Firefox no Ubuntu vem como **snap**, que **não funciona em proot**.
- Use o **Chromium** via apt ou instale o Firefox ESR de um `.deb`/PPA.
  Veja [dicas de desempenho](05-dicas-desempenho.md).

## Quero começar do zero

```bash
proot-distro remove ubuntu
lx setup
```

---

Não achou seu problema? Abra uma *issue* no repositório descrevendo o erro e o
que aparece no Termux.
