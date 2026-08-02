# 6. Usar como computador de verdade (monitor externo + teclado + mouse)

Este é o objetivo final: plugar um **hub USB-C** no S23 e ter um computador Linux
com monitor, teclado, mouse e carregando ao mesmo tempo.

> **Resumo honesto:** é possível, mas **não é automático**. Dar imagem no monitor
> é a parte fácil (o S23 tem DisplayPort Alt Mode). Fazer a janela do **Termux:X11
> aparecer no monitor** em vez de ficar espelhando o celular é a parte que exige
> configuração — e é exatamente o que este documento resolve.

---

## O hardware

O S23 suporta **DisplayPort Alt Mode** pela USB-C, que é o que permite saída de
vídeo. Qualquer hub/dock USB-C que anuncie "DP Alt Mode" funciona — incluindo
docks Thunderbolt, que são compatíveis com USB-C DP Alt Mode.

O que procurar num hub:

| Recurso | Por quê |
|---------|---------|
| **HDMI com DP Alt Mode** | sem isso não há vídeo, só dados |
| **Power Delivery (PD) passthrough** | rodar desktop + tela externa drena bateria rápido; você **precisa** carregar enquanto usa |
| **2–3 portas USB-A** | teclado, mouse, pendrive |

> ℹ️ O S23 (modelo base) tem USB **2.0** para dados. Isso não afeta o vídeo (que
> vai por linhas dedicadas do DP Alt Mode), mas limita a velocidade de pendrives
> e HDs externos. Teclado e mouse não se importam.

> 💡 Prefira hub **com alimentação externa**. Há relatos de instabilidade em
> Galaxy conectados direto a monitores USB-C sem hub alimentado.

---

## O problema central: o Android não move apps para a tela externa

Por padrão, ligar o HDMI no Android **espelha** a tela do celular. O app
Termux:X11 continua na tela do celular; o monitor só mostra uma cópia esticada.
Você teria um desktop KDE em formato de celular, esticado num monitor — inútil.

Existem **dois caminhos** para resolver. **Comece pelo A (DeX)** — é mais simples
e, na prática, costuma dar a melhor experiência.

---

## Caminho A — Samsung DeX ✅ recomendado

### O que o DeX é (e o que ele não é)

Vale desfazer uma confusão comum: **o DeX não é um segundo sistema operacional.**
Não é VM, não é emulador, não é uma "máquina Linux da Samsung". É apenas um
**shell diferente do próprio Android** — outro launcher, outra barra de tarefas,
janelas redimensionáveis. Mesmo kernel, mesmos processos, mesmos apps.

É o equivalente a trocar o GNOME pelo KDE no mesmo Linux: o sistema por baixo é
idêntico, muda só como as janelas são desenhadas.

Então rodar "Linux dentro do DeX" **não empilha dois sistemas**. A pilha real é:

```
Kernel Linux            <- o Android JÁ é Linux
└─ Android userspace
   └─ DeX               <- só o modo janela/taskbar do Android
      └─ Termux         <- app Android comum
         └─ proot       <- tradução de syscalls (NÃO é VM)
            └─ Ubuntu
               └─ KDE   <- desenha via protocolo X
                  ↓
         Termux:X11     <- app Android que É um servidor X
            └─ uma janela no DeX, maximizada no monitor
```

**Um kernel. Um sistema operacional.** O custo extra do DeX é pequeno — é o
SystemUI do Android operando em outro modo.

### Como usar

1. Conecte o hub. O DeX inicia sozinho (ou aparece a notificação
   **"Iniciar o Samsung DeX"**).
2. No DeX, abra o **Termux** e rode `lx start`.
3. A janela do **Termux:X11** aparece — **maximize** e pronto: KDE em tela cheia
   no monitor.

### Por que este caminho costuma ser melhor

| Vantagem | Detalhe |
|----------|---------|
| **Zero configuração de risco** | sem opções de desenvolvedor, sem ADB, sem reboot |
| **Mouse de verdade** | o DeX dá semântica nativa de ponteiro: clique direito, scroll, arrastar — ponto fraco conhecido do Caminho B |
| **Android + Linux lado a lado** | WhatsApp, Spotify, app do banco em janelas ao lado do KDE |
| **Caminho testado** | é a rota mais usada pela comunidade; com Termux:X11 é bem mais rápida que VNC |
| **Mais rápido que espelhar** | rodar em DeX real rende bem mais quadros que deixar o monitor espelhando a tela do celular — a diferença é visível em vídeo e ao rolar página |

### Limitações

- Por padrão o DeX limita a saída a **1920x1080**. Para **1440p ou 4K**, instale o
  app **Good Lock** → módulo **MultiStar**, que destrava as resoluções maiores.
- Há relatos de **cores ou brilho estranhos** no Termux:X11 sob DeX em alguns
  Samsung. Se acontecer:
  ```bash
  lx stop
  lx start --extra "-force-bgra"
  ```

---

## Caminho B — Modo desktop experimental (sem DeX)

Use este se o DeX te incomodar por algum motivo específico — por exemplo, se você
quiser o Termux:X11 ocupando a tela sozinho, sem a barra de tarefas do DeX.

O Termux:X11 tem suporte nativo a isto: quando detecta um display externo **e** o
modo desktop experimental está ativo, ele abre **em tela cheia direto no monitor**,
sem barra de navegação. Esse comportamento existe no app desde 2022.

Ele depende da flag de sistema `force_desktop_mode_on_external_displays`.

### Ativando

1. **Ative as Opções de desenvolvedor** (se ainda não estiverem):
   Configurações → Sobre o telefone → Informações de software →
   toque **7 vezes** em "Número da versão".

2. Configurações → **Opções de desenvolvedor** → procure por
   **"Forçar modo desktop"** / *"Force desktop mode"*
   (descrição: *"Forçar modo desktop experimental em telas secundárias"*).
   Ative.

3. **Reinicie o celular.** A flag só passa a valer após reboot.

4. Conecte o hub, abra o Termux e rode `lx start`.

### Se a opção não existir no menu

A One UI da Samsung às vezes esconde ou remove essa opção, porque o DeX ocupa o
mesmo espaço. Dá para setar a flag direto, via ADB (de um PC, com depuração USB
ativa):

```bash
adb shell settings put global force_desktop_mode_on_external_displays 1
adb reboot
```

Para reverter: troque `1` por `0` e reinicie.

> ⚠️ Se o "Forçar modo desktop" não existir **e** o ADB não pegar, volte para o
> **Caminho A (DeX)**. Não force — o comportamento da One UI varia entre versões.

### Desvantagem deste caminho

O mapeamento de mouse e teclado em telas secundárias fora do DeX é
historicamente problemático no Android. Se o ponteiro se comportar de forma
estranha, o DeX resolve.

> O README diz que o projeto "não depende do DeX" — isso continua verdade para
> usar **na tela do celular**, que funciona sem DeX nenhum. Para o monitor
> externo, o DeX é o caminho recomendado.

---

## Ajustando a experiência no monitor

### Resolução

Por padrão o Termux:X11 usa a resolução da tela onde está. No monitor, você quer
resolução de monitor. No app **Termux:X11 → Preferences**:

- **Display resolution mode** → `Native` (usa a resolução real do monitor), ou
  **Custom** com algo como `1920x1080`.
- Resolução menor = mais fluido. Como tudo é renderizado por software
  (`LIBGL_ALWAYS_SOFTWARE=1`), **1280x720 pode ser bem mais agradável que 1080p**
  em uso pesado. Teste os dois.

Dá para fazer isso por linha de comando também:

```bash
termux-x11-preference list                      # ver tudo que dá pra ajustar
termux-x11-preference "fullscreen"="true"
```

### Escala / DPI

Num monitor de 24", a escala de celular deixa tudo gigante. Duas opções:

```bash
# no Termux, ao iniciar:
lx start --extra "-dpi 96"
```

Ou dentro do KDE: **Configurações do Sistema → Tela e Monitor → Escala Global**
→ 100%.

### Teclado e mouse

Plugados no hub, o Android os reconhece e o Termux:X11 repassa para o KDE — o
comportamento é de desktop normal (clique direito, scroll, atalhos de teclado).

Se o teclado digitar caracteres errados, ajuste o layout dentro do Ubuntu:

```bash
setxkbmap -model abnt2 -layout br      # teclado ABNT2 brasileiro
setxkbmap -layout us -variant intl     # US internacional
```

Para tornar permanente, adicione a linha no `~/.bashrc` do Ubuntu ou configure em
**Configurações do Sistema → Dispositivos de Entrada → Teclado → Layouts**.

### Áudio

O som vai pelo PulseAudio para o Android, e o Android manda para o HDMI se o
monitor tiver alto-falantes. Não precisa configurar nada além do que o
`lx start` já faz.

---

## Bateria e energia

Isto **não é opcional** neste modo de uso:

- Use um hub com **PD passthrough** e mantenha o carregador ligado. Desktop +
  tela externa + CPU em renderização por software drena a bateria mais rápido do
  que o telefone consegue repor sem carregador.
- Desative a otimização de bateria do Termux e do Termux:X11
  (veja [pré-requisitos](01-pre-requisitos.md)).
- O `lx start` já ativa **wake-lock** automaticamente, e o `lx stop`
  libera. Não pule o `lx stop`.
- O S23 vai **esquentar** e reduzir o clock (throttling) em sessões longas.
  Resolução menor e compositor desligado ajudam bastante.

---

## Problemas comuns

### O monitor mostra o celular espelhado, não o desktop

O modo desktop não está ativo. Refaça o **Caminho A** (incluindo o **reboot** —
é o passo mais esquecido), ou use o **Caminho B**.

### Tela preta no monitor, mas o KDE parece estar rodando

```bash
lx stop
lx start --extra "-legacy-drawing"
```

### Cores invertidas (azul vira vermelho)

Sintoma clássico em alguns aparelhos, e especialmente relatado sob DeX:

```bash
lx stop
lx start --extra "-force-bgra"
```

### O desktop cai quando eu troco de app no celular

Wake-lock não ativou (o pacote `termux-api` precisa do **app** Termux:API
instalado) ou a otimização de bateria está ligada. Confira os dois.

### O hub desconecta sozinho

Quase sempre é hub sem alimentação própria tentando puxar corrente demais do
telefone. Use um hub alimentado ou conecte o carregador na porta PD.

---

## Então: dá para virar um computador?

Sim, com expectativas calibradas:

✅ Navegar, escrever, terminal, código, LibreOffice, ferramentas de linha de
comando — tudo isso funciona bem no Snapdragon 8 Gen 2.

✅ **Com aceleração de GPU ativada** (`lx gpu`), a interface fica fluida
e o navegador deixa de engasgar. Não pule esse passo —
veja [aceleração de GPU](07-aceleracao-gpu.md).

⚠️ Tudo roda em **proot**, que traduz syscalls. Isso custa desempenho em cargas
pesadas de I/O e chamadas de sistema, mesmo com a GPU acelerada.

⚠️ Os 8 GB de RAM são compartilhados com o Android. KDE + navegador com muitas
abas chega perto do limite. Se apertar, o XFCE é bem mais leve
(veja [dicas de desempenho](05-dicas-desempenho.md)).

---

Voltar para o [uso diário](03-uso-diario.md) ou a
[solução de problemas](04-solucao-de-problemas.md).
