# 5. Dicas de desempenho e personalização

O S23 (Snapdragon 8 Gen 2, 8 GB RAM) roda bem, mas como tudo é emulado via proot
e renderizado por software, alguns ajustes ajudam muito.

---

## Deixar o KDE mais leve

- **Compositor desativado** (já feito no setup) — o maior ganho.
- Em **Configurações do Sistema → Aparência → Espaço de trabalho**, escolha um tema simples.
- Desative animações: **Configurações → Comportamento do espaço de trabalho → Animações** (velocidade no mínimo / desligado).
- Desative a indexação de arquivos (Baloo):
  ```bash
  balooctl disable
  ```
- Evite papéis de parede animados e widgets pesados.

---

## Alternativa mais leve: XFCE

Se o KDE ficar pesado demais, o **XFCE** é muito mais leve e estável em proot.
Vários guias de Linux no Android usam XFCE justamente por isso.

Instale dentro do Ubuntu:

```bash
lx shell
apt install -y xfce4 xfce4-terminal dbus-x11
exit
```

Depois edite o `lx`: no final da função `cmd_start`, na variável `inner`,
troque a última linha de

```bash
dbus-launch --exit-with-session startplasma-x11
```

para

```bash
dbus-launch --exit-with-session startxfce4
```

> ⚠️ **O `lx` ainda não tem uma flag para escolher o desktop** — por enquanto é
> edição manual, e um `git pull` sobrescreve a mudança. Se você acabar usando
> XFCE de vez, vale abrir uma *issue* pedindo um `lx start --de xfce`.

Antes de migrar, teste ativar a [GPU](07-aceleracao-gpu.md): o KDE acelerado
costuma ficar mais confortável que o XFCE em software.

---

## Navegador que funciona em proot

O Firefox do Ubuntu é snap e **não roda** em proot. Use uma destas opções:

```bash
# Chromium via apt (precisa de flags por causa do sandbox)
apt install -y chromium-browser
# rode com:  chromium-browser --no-sandbox --disable-gpu
```

Ou Firefox ESR:

```bash
apt install -y firefox-esr
```

> Para o Chromium iniciar sem travar, sempre use `--no-sandbox --disable-gpu`.
> Crie um atalho no menu apontando para isso.

---

## Programas úteis para instalar (dentro do Ubuntu)

```bash
apt install -y firefox-esr libreoffice git htop neofetch
```

| Pacote | Para quê |
|--------|----------|
| `firefox-esr` | navegador (o Firefox normal do Ubuntu é snap e não roda em proot) |
| `libreoffice` | suíte de escritório |
| `git` | controle de versão |
| `htop` | monitor de recursos |
| `neofetch` | info do sistema |

O **VS Code** não está na lista porque exige o repositório da Microsoft. Se quiser:

```bash
apt install -y wget gpg
wget -qO- https://packages.microsoft.com/keys/microsoft.asc \
    | gpg --dearmor > /usr/share/keyrings/microsoft.gpg
echo "deb [arch=arm64 signed-by=/usr/share/keyrings/microsoft.gpg] \
https://packages.microsoft.com/repos/code stable main" \
    > /etc/apt/sources.list.d/vscode.list
apt update && apt install -y code
```

> ⚠️ Não coloque comentários `#` no fim de linhas continuadas com `\` num
> `apt install` — isso quebra a continuação e o comando falha.

---

## Reduzir uso de memória

- Sempre encerre com `lx stop` quando não estiver usando.
- Feche apps pesados antes de trocar de app no Android.
- Monitore com `htop` dentro do Ubuntu.

---

## Resolução / DPI

No app **Termux:X11 → Preferences** você pode ajustar:

- **Display resolution mode**: experimente "Native" ou uma resolução customizada menor
  (resolução menor = mais fluido).
- **Scale / DPI**: se os textos ficarem minúsculos, aumente o fator de escala no KDE
  (Configurações → Tela → Escala).

---

## Tela cheia e modo paisagem

- Gire o celular para **paisagem** para mais espaço.
- Use o Termux:X11 em **tela cheia** (oculta as barras do Android).
- Com teclado + mouse Bluetooth, a experiência fica próxima de um notebook.
