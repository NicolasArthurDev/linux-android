# Linux com interface gráfica no Galaxy S23 (sem root)

Guia completo e scripts para rodar um **Ubuntu com desktop KDE Plasma** dentro do
Galaxy S23, usando **Termux + proot-distro + Termux-X11** — sem precisar de root e
sem depender do Samsung DeX.

> Stack escolhida: **Termux-X11** (display nativo, melhor desempenho) +
> **Ubuntu** (via `proot-distro`) + **KDE Plasma** (desktop completo).

**Dois modos de uso:**

1. **Na tela do celular** — funciona direto, sem hardware extra.
2. **Como computador de mesa** — hub USB-C com HDMI + USB + carregador, virando
   um desktop Linux com monitor, teclado e mouse. Isso exige um passo extra de
   configuração no Android: veja [monitor externo](docs/06-monitor-externo.md).

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

## Por onde começar

1. Leia os [pré-requisitos](docs/01-pre-requisitos.md) — apps que precisam ser instalados manualmente.
2. Siga o [guia de instalação](docs/02-instalacao.md) passo a passo.
3. Aprenda o [uso diário](docs/03-uso-diario.md) (iniciar/parar o desktop).
4. Se algo der errado, veja a [solução de problemas](docs/04-solucao-de-problemas.md).
5. Para deixar mais rápido, veja as [dicas de desempenho](docs/05-dicas-desempenho.md).
6. Para usar num **monitor externo** (hub USB-C com HDMI, teclado e mouse), veja
   [monitor externo](docs/06-monitor-externo.md).

---

## Scripts

| Script | Onde roda | O que faz |
|--------|-----------|-----------|
| [`scripts/00-setup-termux.sh`](scripts/00-setup-termux.sh) | Termux | Instala proot-distro, Termux-X11, PulseAudio e dependências |
| [`scripts/01-install-ubuntu.sh`](scripts/01-install-ubuntu.sh) | Termux | Instala o Ubuntu via proot-distro |
| [`scripts/02-setup-kde.sh`](scripts/02-setup-kde.sh) | **Dentro do Ubuntu** | Instala o KDE Plasma e ajusta o ambiente |
| [`scripts/start-kde.sh`](scripts/start-kde.sh) | Termux | Inicia o desktop KDE (método principal) |
| [`scripts/start-kde-alt.sh`](scripts/start-kde-alt.sh) | Termux | Inicia o KDE pelo método alternativo (`-xstartup`), caso o principal falhe |
| [`scripts/stop-kde.sh`](scripts/stop-kde.sh) | Termux | Encerra o desktop e libera memória |

---

## Aviso

Tudo aqui roda **sem root** e em modo de usuário comum. O desempenho é bom no S23,
mas o KDE Plasma em proot pode ter pequenos bugs (efeitos visuais, bloqueio de tela).
A configuração já desativa o que costuma dar problema. Se quiser algo mais leve e
estável, o XFCE é uma ótima alternativa (veja as dicas de desempenho).

Licença: [MIT](LICENSE).
