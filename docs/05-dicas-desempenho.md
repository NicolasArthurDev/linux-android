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
Dentro do Ubuntu:

```bash
apt install -y xfce4 xfce4-terminal dbus-x11
```

E troque a última linha do `start-kde.sh` de:

```bash
dbus-launch --exit-with-session startplasma-x11
```

para:

```bash
dbus-launch --exit-with-session startxfce4
```

(Você pode duplicar o script como `start-xfce.sh` e manter os dois.)

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
apt install -y \
    firefox-esr \      # navegador
    libreoffice \      # office
    code \             # (precisa do repo da Microsoft) editor de código
    git \
    htop \             # monitor de recursos
    neofetch
```

---

## Reduzir uso de memória

- Sempre encerre com `./stop-kde.sh` quando não estiver usando.
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
