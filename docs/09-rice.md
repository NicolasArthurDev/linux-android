# 9. Rice — deixando bonito (bspwm + Catppuccin Mocha)

*Rice* é o apelido da comunidade Linux para customização visual pesada do
desktop. A ideia aqui é trocar o KDE por um **tiling window manager** dirigido
pelo teclado, muito mais leve e com um visual minimalista.

```bash
lx rice                 # instala e configura tudo
lx stop
lx start --de bspwm     # inicia nesse ambiente
lx start --de kde       # volta para o KDE quando quiser
```

Os dois convivem — nada é desinstalado.

### Não quero digitar `--de` toda vez

```bash
lx de bspwm     # define o padrão
lx start        # agora sobe o bspwm sozinho
lx de           # mostra qual está ativo e o que já está instalado
```

A flag continua valendo para uma vez só, sem mexer no padrão:
`lx start --de kde`.

A precedência é: `--de` > `$LX_DE` > padrão salvo > `kde`.

---

## Por que não Hyprland

É a primeira pergunta de quem vem do ricing moderno, e a resposta é estrutural:

**O Hyprland é Wayland puro. O Termux:X11 é um servidor X.** São protocolos
diferentes; um não desenha no outro.

Em tese o wlroots (base do Hyprland) tem um backend X11 que permitiria rodar
aninhado, mas ele precisa ser **compilado explicitamente** — e nenhum pacote de
distribuição faz isso. Compilar o wlroots dentro de um proot em ARM é um projeto
por si só, com chance alta de não valer o esforço.

**O mesmo vale para o Waybar**, que também é Wayland-only. Por isso a barra aqui
é a **Polybar**.

### E o visual do Hyprland?

Dá para chegar muito perto sem ele. O que caracteriza aqueles rices são três
coisas, e todas existem no X11:

| Efeito | Como |
|--------|------|
| Cantos arredondados | `picom` → `corner-radius = 12` |
| Margens largas (gaps) | `bspwm` → `window_gap 14` |
| Transparência | `picom` → `inactive-opacity` |

**O que ficou de fora foi o blur** — de propósito. É o efeito mais caro de
todos e o único que realmente derruba o desempenho em proot. Os outros três são
baratos e respondem por quase toda a estética.

---

## O que é instalado

| Componente | Papel |
|------------|-------|
| **bspwm** | tiling por árvore binária; tudo controlável por `bspc` |
| **sxhkd** | atalhos de teclado (arquivo separado) |
| **polybar** | barra de status |
| **rofi** | launcher de aplicativos |
| **picom** | compositor: cantos, sombras, transparência |
| **kitty** | terminal acelerado por GPU — faz sentido com a Adreno ativa |
| **dunst** | notificações |
| **JetBrainsMono Nerd Font** | fonte com os glifos de ícone da polybar |

Tudo em **Catppuccin Mocha**.

> A `fonts-jetbrains-mono` do apt **não** serve: é a fonte original, sem os
> glifos de ícone. O `lx rice` baixa a versão *patched* do projeto nerd-fonts.

---

## ⚠️ No Samsung DeX, use `alt`

O DeX **intercepta a tecla Super no nível do sistema** — ela abre a gaveta de
apps e nunca chega ao Termux:X11. Os atalhos do DeX (`Win+B` navegador, `Win+E`
e-mail, `Win+L` bloquear...) são **hard-coded**: não há como desativá-los nem
remapeá-los.

Então, se você usa monitor externo via DeX:

```bash
lx rice --mod alt
lx stop && lx start
```

A escolha fica guardada — um `lx rice` futuro mantém o `alt`.

| Opção | Quando usar |
|-------|-------------|
| `--mod super` | padrão; só na tela do celular, fora do DeX |
| `--mod alt` | **DeX** — recomendado |
| `--mod ctrl-alt` | se o `alt` conflitar com algum programa |

> Por que o `alt` funciona: o DeX só reserva o Super e o `Alt+Tab`. Como o
> `sxhkd` captura as teclas no servidor X, ele tem precedência sobre os
> programas de dentro da sessão — um `alt + d` vai para o bspwm, não para a
> barra de endereços do navegador.

---

## Atalhos

Substitua `super` pelo modificador que você escolheu.

| Atalho | Ação |
|--------|------|
| `super + Enter` | terminal (kitty) |
| `super + d` | launcher (rofi) |
| `super + b` | navegador |
| `super + shift + q` | fechar janela |
| `super + 1..5` | trocar de área de trabalho |
| `super + shift + 1..5` | mover a janela para outra área |
| `super + h/j/k/l` | mover o foco |
| `super + shift + h/j/k/l` | mover a janela |
| `super + control + h/j/k/l` | redimensionar |
| `super + f` | tela cheia |
| `super + space` | alternar flutuante |
| `super + m` | alternar layout (monocle) |
| `super + shift + r` | recarregar o bspwm |
| `super + shift + e` | encerrar a sessão |

> ⚠️ **Sem teclado físico o bspwm é pouco usável.** Ele é feito para ser
> dirigido pelo teclado — não há menu iniciar nem botão de fechar. Faz muito mais
> sentido no [monitor externo](06-monitor-externo.md) com teclado e mouse.
> Na tela do celular, o KDE continua sendo a escolha prática.

---

## Onde mexer

Tudo em `~/.config` dentro do Ubuntu (`lx shell`):

| Arquivo | Para quê |
|---------|----------|
| `bspwm/bspwmrc` | gaps, bordas, cores, regras de janela, o que abre no login |
| `sxhkd/sxhkdrc` | atalhos de teclado |
| `polybar/config.ini` | módulos e aparência da barra |
| `picom/picom.conf` | cantos, sombras, transparência |
| `rofi/config.rasi` | aparência do launcher |
| `kitty/kitty.conf` | fonte, cores e opacidade do terminal |
| `dunst/dunstrc` | notificações |

Depois de editar o `bspwmrc` ou o `sxhkdrc`: `super + shift + r`.

### Papel de parede

O padrão é uma cor sólida (`#1e1e2e`). Para usar uma imagem:

```bash
feh --bg-fill ~/wallpaper.png
```

E troque a linha do `xsetroot` no `bspwmrc` por esse comando, para valer sempre.

---

## "Iniciou mas a tela está vazia"

**Provavelmente está funcionando.** Um tiling WM sem janelas abertas mostra só
uma cor sólida — não existe papel de parede, ícone de área de trabalho nem menu
iniciar. Visualmente é idêntico a uma falha.

Como confirmar, no Termux:

```bash
pgrep -a bspwm     # se aparecer, está rodando
```

Por isso o `bspwmrc` agora **abre um terminal automaticamente** na primeira
janela: assim fica óbvio que a sessão subiu.

### Sem teclado físico

Este é o ponto mais importante do bspwm no celular: **não existe a tecla `super`
no teclado virtual do Android**, então nenhum atalho funciona.

A barra tem dois botões clicáveis para isso:

| Botão | Ação |
|-------|------|
| `☰` | abre o launcher (rofi) |
| `❯` | abre um terminal |

Fora deles, sem teclado você não consegue abrir nada. Para uso na tela do
celular, o KDE continua sendo o prático.

---

## Se algo der errado

**Tela preta com tudo rodando** — era o caso mais comum, e a causa é o
compositor com o backend **glx**.

O picom redireciona todas as janelas para buffers fora da tela e as recompõe.
Com `glx` sob o Termux:X11 a apresentação congela: bspwm, polybar e terminal
todos sobem, e a tela fica preta. É um problema conhecido do picom
([yshui/picom#1395](https://github.com/yshui/picom/issues/1395)), não específico
do Android.

O padrão agora é `backend = "xrender"`, que não tem esse problema **e também faz
cantos arredondados** — não se perde nada no visual.

Para confirmar que o culpado é o compositor:

```bash
lx stop
lx start --no-picom     # se a tela aparecer, era ele
```

**Janelas piscando ou com rastro** — mesma coisa: `xrender`, ou desligue o picom.
Vale também testar `vsync = true`.

**A barra não aparece** — veja `lx log`, que agora inclui o passo a passo do
`bspwmrc`. Quase sempre é fonte faltando; confira com
`fc-list | grep -i "JetBrainsMono Nerd"`.

**Atualizei o `lx` mas nada mudou** — os arquivos de configuração são escritos
pelo `lx rice`, **não** pelo `git pull`. Depois de atualizar, rode `lx rice` de
novo para regerá-los. O `lx start` avisa quando detecta configs antigos.

**Ícones como quadradinhos** — a Nerd Font não instalou. Rode `lx rice` de novo.

**"o bspwm não foi instalado"** — rode `lx rice` de novo. Ao final ele agora
lista exatamente quais binários faltaram e o que instalar. Se algum insistir:

```bash
lx shell
apt install -y <pacote>
```

**Quero voltar ao KDE** — `lx start --de kde`. Nada foi removido.

---

*[linux-android](https://github.com/NicolasArthurDev/linux-android) — por Nicolas Arthur.*
