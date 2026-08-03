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

## "KDE instalado, mas SEM a sessão X11 (só Wayland)"

Acontece no **Ubuntu 26.04 ou mais novo**, que traz o **Plasma 6**.

O Plasma 6 tirou a sessão X11 do pacote `plasma-workspace` — ele passou a
instalar só o `startplasma-wayland`. O binário que o `lx start` precisa
(`startplasma-x11`) mudou para um pacote separado:

```bash
lx shell
apt install -y plasma-session-x11 kwin-x11
exit
```

Ou simplesmente rode `lx setup` de novo — ele detecta e resolve sozinho.

> Por que X11 e não Wayland? O Termux:X11 é um **servidor X**. Uma sessão
> Wayland não tem como desenhar nele.

## `btop`: "No UTF-8 locale detected!" / acentos quebrados

O `proot-distro` sanitiza o ambiente, então a sessão nascia sem `LANG`. Programas
de terminal que desenham caixas e barras (btop, htop, fastfetch) recusam a
iniciar sem um locale UTF-8.

Corrigido — o `lx start` e o `lx shell` agora definem o locale. Basta atualizar:

```bash
cd ~/linux-android && git pull
lx stop && lx start
```

Contorno imediato, sem atualizar: `btop --force-utf`

## Konsole: "Could not find '', starting '/usr/bin/zsh' instead"

Mesma causa: a variável `SHELL` chegava vazia na sessão, e o Konsole a usa para
saber qual shell abrir. Ele acertava sozinho no fim (caía no zsh), mas avisava a
cada aba nova.

Também corrigido pelo `git pull` acima — o `lx start` passou a exportar `SHELL`.

## Terminal inundado de "Failed to connect to PipeWire"

O componente de mídia do Plasma (`kpipewire`) procura o PipeWire, que não existe
em proot, e **re-tenta para sempre** — milhares de linhas idênticas.

Resolvido: a saída da sessão vai para um log, e esse ruído é filtrado antes de
chegar lá. Basta atualizar:

```bash
cd ~/linux-android && git pull
lx stop && lx start
```

Nada é perdido — o áudio usa PulseAudio, não PipeWire. O que deixa de funcionar
é só o widget de controle de mídia do Plasma, que já não funcionava.

Para ver o log da sessão:

```bash
lx log                  # resumo: linhas mais repetidas + o que é singular
lx start --verbose      # ou acompanhe no terminal, sem log
```

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

## Firefox não instala / instala mas não abre

No Ubuntu, `firefox`, `chromium` e `chromium-browser` são todos **pacotes de
transição para snap** — e snap não roda em proot. A instalação termina sem erro
e o navegador simplesmente não abre.

Use:

```bash
lx browser            # Firefox do repositório .deb oficial da Mozilla
lx browser falkon     # Falkon (Qt/KDE), bem mais leve
```

> `firefox-esr` **não existe** no Ubuntu — é pacote do Debian. Se algum guia
> mandar instalar, vai falhar.

Detalhes em [dicas de desempenho](05-dicas-desempenho.md).

## Quero começar do zero

```bash
proot-distro remove ubuntu
lx setup
```

---

Não achou seu problema? Abra uma *issue* no repositório descrevendo o erro e o
que aparece no Termux.
