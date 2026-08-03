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

```bash
lx shell
apt install -y xfce4 xfce4-terminal dbus-x11
exit

lx start --de xfce      # uma vez
lx de xfce              # ou como padrão
```

Os três ambientes convivem — `lx de` mostra qual está ativo e o que já está
instalado.

Antes de migrar, teste ativar a [GPU](07-aceleracao-gpu.md): o KDE acelerado
costuma ficar mais confortável que o XFCE em software.

---

## Navegador que funciona em proot

```bash
lx browser            # Firefox (.deb oficial da Mozilla)
lx browser falkon     # Falkon — Qt/KDE, bem mais leve
```

### Por que não dá para usar o apt direto

Três armadilhas, e o comando acima existe justamente para desviar delas:

| Armadilha | O que acontece |
|---|---|
| `apt install firefox` | é **pacote de transição para snap**. Snap não roda em proot (precisa de systemd e montagens privilegiadas) |
| `apt install chromium-browser` / `chromium` | **idem** — também são snap no Ubuntu |
| `apt install falkon` | falha com *"Unable to locate package"*: está no componente **universe**, que a imagem do proot-distro não habilita |

O `lx browser` habilita o `universe`, configura o repositório **.deb oficial da
Mozilla** (que publica arm64) com pin para não cair no snap, e desativa o
sandbox do Firefox — que depende de *namespaces* de usuário indisponíveis em
proot, e sem isso as abas morrem ao abrir.

### Qual escolher

- **Firefox** — completo, o que você já conhece. Pesa mais na RAM.
- **Falkon** — navegador Qt do próprio KDE. Bem mais leve, integra melhor com o
  Plasma. Bom quando a RAM apertar (o KDE já usa ~4,5 GB dos 8 GB).

## Programas úteis para instalar (dentro do Ubuntu)

Boa parte destes está no componente **`universe`**, que a imagem do
proot-distro não habilita. Faça isso uma vez:

```bash
apt install -y software-properties-common
add-apt-repository -y universe && apt update
```

Depois:

```bash
apt install -y libreoffice git htop fastfetch glmark2
```

| Pacote | Para quê |
|--------|----------|
| `libreoffice` | suíte de escritório |
| `git` | controle de versão |
| `htop` | monitor de recursos |
| `fastfetch` | info do sistema — mostra CPU, GPU e RAM de uma vez |
| `glmark2` | benchmark de GPU, para comparar com e sem aceleração |

> O **navegador** não está aqui de propósito: use `lx browser` (veja acima).
> O `firefox-esr` não existe no Ubuntu, e o `firefox` do apt é snap.
>
> Sobre o **`neofetch`**: ele foi arquivado pelo autor em 2024 e não conhece o
> Ubuntu 26.04 nem a Adreno 740 — mostra "Unknown" em vários campos. O
> `fastfetch` é o sucessor mantido e detecta a GPU corretamente.

O **VS Code** tem comando próprio, porque envolve duas armadilhas:

```bash
lx vscode
```

1. Não está em repositório nenhum do Ubuntu — vem do repo da Microsoft (que
   publica arm64).
2. É **Electron**: o sandbox do Chromium precisa de namespaces de usuário, que o
   proot não oferece. Sem desativar, ele não abre.

O comando resolve os dois e cria o wrapper `code-proot`, com as flags já postas.
O `code` puro não vai abrir.

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
