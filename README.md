# Linux com interface gráfica no Galaxy S23 (sem root)

Guia completo e um script único para rodar um **Ubuntu com desktop KDE Plasma**
dentro do Galaxy S23, usando **Termux + proot-distro + Termux-X11** —
**sem root**, com **aceleração de GPU** e opcionalmente num monitor externo.

> Stack escolhida: **Termux-X11** (display nativo, melhor desempenho) +
> **Ubuntu** (via `proot-distro`) + **KDE Plasma** (desktop completo) +
> **Turnip/Mesa** (GPU Adreno de verdade, sem root).

**Dois modos de uso:**

1. **Na tela do celular** — funciona direto, sem hardware extra e sem DeX.
2. **Como computador de mesa** — hub USB-C com HDMI + USB + carregador, virando
   um desktop Linux com monitor, teclado e mouse. Nesse caso o **Samsung DeX é o
   caminho recomendado**, por dar semântica nativa de mouse e não exigir opções
   de desenvolvedor: veja [monitor externo](docs/06-monitor-externo.md).

> ⚠️ **Status do projeto:** guia baseado em conhecimento e nas docs oficiais do
> Termux/proot-distro, **validação em campo (no S23) ainda pendente**. O fluxo e
> os ajustes são bem fundamentados, mas nomes exatos de pacotes e detalhes podem
> precisar de pequenos ajustes na primeira execução. Encontrou um erro? Veja
> [solução de problemas](docs/04-solucao-de-problemas.md) e/ou abra uma *issue*.

---

## Como funciona (visão geral)

```
┌─────────────────────────────────────────────────┐
│  Android (Galaxy S23)                             │
│                                                   │
│  ┌─────────────┐        ┌──────────────────────┐ │
│  │  Termux      │        │  App Termux:X11      │ │
│  │  (ambiente)  │        │  (mostra a tela)     │ │
│  │              │        └──────────▲───────────┘ │
│  │  proot-distro│                   │ display :0  │
│  │   └─ Ubuntu  │───────────────────┘             │
│  │       └─ KDE Plasma (startplasma-x11)          │
│  └─────────────┘                                  │
└─────────────────────────────────────────────────┘
```

- **Termux** roda o ambiente base (não é root, é um app normal).
- **proot-distro** instala uma distro Linux completa (Ubuntu) dentro do Termux.
- **Termux:X11** é um app separado que funciona como "monitor" — o KDE desenha a tela nele.
- **PulseAudio** leva o som do Linux para o Android.

---

## Começando — um comando só

Tudo é feito pelo **`lx`**, o script único na raiz do repositório.

```bash
pkg install -y git
git clone https://github.com/NicolasArthurDev/linux-android.git
cd linux-android
./lx install     # deixa o comando 'lx' disponível de qualquer pasta
lx               # menu interativo
```

O `./lx install` cria um symlink em `$PREFIX/bin`. A partir daí você digita
apenas `lx`, de onde estiver — não precisa lembrar onde clonou o repositório.

> **Por que symlink e não um alias no `.zshrc`?** Um alias só existe em shells
> interativos do shell onde foi definido: não funciona dentro de scripts, em
> `sh -c`, em subshells, nem se você trocar de zsh para bash. O symlink num
> diretório do `PATH` funciona em todos esses casos — é o que um gerenciador de
> pacotes faria. E, por ser symlink e não cópia, um `git pull` já atualiza o
> comando. Para remover: `lx uninstall` (o repositório fica intacto).

Sem argumento nenhum ele abre um **menu interativo**. Se preferir digitar:

| Comando | O que faz |
|---------|-----------|
| `./lx setup` | Instala tudo: Termux, Ubuntu, KDE e GPU. **Pula o que já está feito** — pode rodar de novo sem medo |
| `./lx start` | Inicia o desktop (detecta a GPU sozinho) |
| `./lx stop` | Encerra e libera memória |
| `./lx dev` | Ambiente de desenvolvimento (zsh, NvChad, tmux, lazygit...) |
| `./lx gpu` | Ativa a aceleração de GPU |
| `./lx doctor` | **Diagnostica o que está faltando** — rode este quando algo der errado |
| `./lx status` | Mostra quais etapas já foram concluídas |
| `./lx shell` | Abre um terminal dentro do Ubuntu |
| `./lx update` | Atualiza o repositório **e** os pacotes dos dois ambientes |
| `./lx install` | Habilita o comando `lx` global · `uninstall` remove |
| `./lx version` | Versão e qual arquivo está sendo executado |
| `./lx help` | Ajuda completa |

> ⚠️ **Antes do `setup`**, leia os [pré-requisitos](docs/01-pre-requisitos.md).
> Há dois APKs e uma opção de desenvolvedor que **precisam ser feitos à mão** —
> o `./lx doctor` avisa se algum ficou faltando, mas não consegue fazer por você.

> Os scripts em `scripts/` viraram atalhos que chamam o `lx`. Continuam
> funcionando, mas o caminho recomendado é o `./lx`.

---

## Ambiente de desenvolvimento

```bash
./lx dev              # nos dois: Termux e Ubuntu
./lx dev termux       # só no Termux
./lx dev --no-claude  # sem o Claude Code
```

Instala em ambos: **zsh + Oh My Zsh** (tema `darkblood`), **NvChad**, **tmux**,
**git**, **btop**, **bat**, **fzf**, **lazygit**, **fastfetch** e **Claude Code**.

Dois detalhes que o script resolve por você:

- O Ubuntu 24.04 traz o Neovim 0.9.5, mas o **NvChad exige 0.10+** — então o
  Neovim é instalado do tarball oficial, não do apt.
- O **Claude Code** não roda no Termux nativo (é um binário glibc; o Android usa
  bionic libc). Ele é instalado **dentro do Ubuntu**, e o comando `claude` fica
  disponível no Termux através de um wrapper que executa lá — transparente.

---

## Documentação

| Doc | Assunto |
|-----|---------|
| [pré-requisitos](docs/01-pre-requisitos.md) | apps e opções do Android — **leia antes de tudo** |
| [instalação](docs/02-instalacao.md) | o passo a passo detalhado |
| [uso diário](docs/03-uso-diario.md) | iniciar, parar, arquivos, atalhos |
| [solução de problemas](docs/04-solucao-de-problemas.md) | quando algo dá errado |
| [dicas de desempenho](docs/05-dicas-desempenho.md) | deixar mais leve, alternativas |
| [monitor externo](docs/06-monitor-externo.md) | hub USB-C, HDMI, DeX — virar um computador |
| [aceleração de GPU](docs/07-aceleracao-gpu.md) | Turnip/Adreno, o maior ganho do projeto |

---

## Aviso

Tudo aqui roda **sem root** e em modo de usuário comum. O desempenho é bom no S23
— especialmente com a [GPU ativada](docs/07-aceleracao-gpu.md) —
mas o KDE Plasma em proot pode ter pequenos bugs (efeitos visuais, bloqueio de tela).
A configuração já desativa o que costuma dar problema. Se quiser algo mais leve e
estável, o XFCE é uma ótima alternativa (veja as dicas de desempenho).

Licença: [MIT](LICENSE).
