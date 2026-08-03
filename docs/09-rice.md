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

## Atalhos

`super` = tecla Windows/Command do teclado.

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

## Se algo der errado

**Tela preta ao entrar** — provavelmente o picom. Comente a linha dele no
`bspwmrc` e recarregue. Se resolver, troque o backend:

```conf
backend = "xrender";    # em vez de "glx"
```

**Janelas piscando ou com rastro** — mesma coisa: `xrender`, ou desligue o picom.
Vale também testar `vsync = true`.

**A barra não aparece** — veja o log: `cat /tmp/polybar.log`. Quase sempre é
fonte faltando; confira com `fc-list | grep -i "JetBrainsMono Nerd"`.

**Ícones como quadradinhos** — a Nerd Font não instalou. Rode `lx rice` de novo.

**"o bspwm não foi instalado"** — rode `lx rice` de novo. Ao final ele agora
lista exatamente quais binários faltaram e o que instalar. Se algum insistir:

```bash
lx shell
apt install -y <pacote>
```

**Quero voltar ao KDE** — `lx start --de kde`. Nada foi removido.
