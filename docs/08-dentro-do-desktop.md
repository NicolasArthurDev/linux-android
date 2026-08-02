# 8. Primeiros passos dentro do desktop

O KDE subiu. Esta página responde o que quase todo mundo pergunta nos primeiros
cinco minutos.

---

## "A internet não funciona"

**Funciona.** O aviso é mentira.

O widget de rede do KDE mostra *"NetworkManager service is not running"* — e está
certo: o NetworkManager realmente não roda em proot. Ele precisa gerenciar
interfaces de rede e falar com o systemd, coisas que não existem aqui.

Mas o Linux **não usa** o NetworkManager para ter internet. Ele usa a pilha de
rede do próprio Android, direto. Prova: o `apt` baixou o KDE inteiro (uns 2 GB)
durante a instalação.

Teste você mesmo, no terminal do KDE:

```bash
ping -c3 archive.ubuntu.com
apt update
```

### Tirando o aviso da tela

O widget é inútil aqui e só atrapalha:

1. Clique com o **botão direito** no ícone de rede, na barra inferior
2. **Configurar Ícones da Bandeja do Sistema** (*Configure System Tray*)
3. Em **Entradas**, mude **Rede** para **Oculto** (*Disabled*)

> ⚠️ O que **não** funciona: Wi-Fi/Bluetooth pelo KDE. Gerenciar conexões é
> papel do Android. Conecte pelo celular; o Linux herda.

---

## Onde está o terminal?

O **Konsole** já está instalado — só não está fixado na barra.

**Jeito rápido:** pressione `Alt` + `Espaço` (o KRunner), digite `konsole`, Enter.

**Pelo menu:** primeiro ícone da barra inferior (canto esquerdo) → digite
`konsole` na busca.

### Fixe na barra, você vai usar muito

Com o Konsole aberto, clique com o **botão direito** no ícone dele na barra de
tarefas → **Fixar no Gerenciador de Tarefas** (*Pin to Task Manager*).

Vale fixar também o **Dolphin** (arquivos) e o **Kate** (editor de texto) — os
três já vêm instalados.

---

## Como saber se o sistema está completo

Abra o Konsole e rode:

```bash
# 1. Qual sistema é este, afinal?
cat /etc/os-release | head -2          # deve dizer Ubuntu 26.04

# 2. A GPU está sendo usada?  ← o mais importante
glxinfo -B | grep -i "renderer string"
#   Turnip / Adreno / freedreno  -> GPU ativa
#   llvmpipe / softpipe          -> caindo na CPU

# 3. Internet
apt update

# 4. Espaço em disco
df -h /

# 5. Memória
free -h
```

Para uma visão bonita de tudo de uma vez, instale o ambiente de dev — que já
traz `fastfetch`, `btop`, `bat`, `fzf`, `lazygit`, NvChad e zsh:

```bash
# no TERMUX (não no KDE):
lx dev
```

Depois, no Konsole: `fastfetch` mostra sistema, kernel, RAM e GPU num painel só.

> **Sim, é Ubuntu de verdade.** Um `apt install` funciona como em qualquer
> Ubuntu ARM64. A única diferença é que roda em proot, sem systemd — então
> serviços (`systemctl`) não funcionam, mas programas normais sim.

---

## Deixando menos feio

Concordo. O padrão do Plasma numa tela de celular em pé fica ruim. Em ordem de
impacto:

### 1. Vire o celular (maior ganho, custo zero)

Em **paisagem** o desktop deixa de ser uma coluna estreita e passa a parecer um
computador. Se a tela não girar, destrave a rotação no Android.

### 2. Ajuste a escala

Numa tela de 6", os elementos do Plasma ficam minúsculos ou gigantes demais.

**Configurações do Sistema → Tela e Monitor → Escala Global.** Teste 125% ou
150% no celular; num monitor externo, 100%.

Ou force o DPI ao iniciar:

```bash
lx start --extra "-dpi 120"     # celular
lx start --extra "-dpi 96"      # monitor externo
```

### 3. Resolução do Termux:X11

No app **Termux:X11 → Preferences → Display resolution mode**. Resolução menor
= mais fluido e elementos maiores. Vale testar `1280x720`.

### 4. Tema escuro e menos enfeite

**Configurações do Sistema → Aparência:**

- **Tema global** → *Breeze Dark*
- **Papel de parede** → uma cor sólida escura (mais leve que a imagem padrão)
- **Comportamento do Espaço de Trabalho → Animações** → reduza ou desligue

### 5. Barra de tarefas mais útil

Clique com o botão direito na barra → **Editar Painel**. Dá para:

- reduzir a **altura** (ganha espaço vertical, precioso no celular)
- remover widgets inúteis em proot (rede, bateria, bluetooth)
- fixar Konsole, Dolphin e o navegador

---

## Instale um navegador

O Firefox do Ubuntu é **snap** e não roda em proot. Use:

```bash
apt install -y firefox-esr
# ou
apt install -y chromium-browser
# e rode com: chromium-browser --no-sandbox
```

Detalhes em [dicas de desempenho](05-dicas-desempenho.md).

---

## O relógio está errado?

Foi corrigido — o `lx start` agora repassa o fuso do Android. Se você iniciou
antes dessa correção, um `git pull` e reiniciar a sessão resolve.

O motivo: o container nasce em UTC e não herda nada do Android.

---

## Próximo passo

Se a ideia é usar como computador de mesa, o pulo do gato é o
[monitor externo](06-monitor-externo.md) — com teclado e mouse a experiência
muda completamente.
