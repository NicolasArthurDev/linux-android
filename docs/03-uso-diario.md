# 3. Uso diário

> Estes comandos supõem que você rodou `./lx install` uma vez — a partir daí o
> `lx` funciona de qualquer pasta. Se não rodou, entre no diretório do
> repositório e use `./lx` no lugar de `lx`.

## Iniciar o desktop

No **Termux**:

```bash
lx start
```

O app **Termux:X11** abre sozinho mostrando o KDE. Se não abrir, abra-o manualmente.

## Parar o desktop

Volte ao **Termux** (deslize de fora para dentro da borda esquerda no Termux:X11
mostra o teclado/atalhos; para sair, troque de app para o Termux) e rode:

```bash
lx stop
```

Sempre encerre com o `lx stop` para não deixar processos consumindo bateria —
ele também libera o wake-lock.

## Menu, se preferir não decorar comandos

```bash
lx
```

Sem argumentos, abre um menu com todas as opções numeradas.

---

## Comandos do dia a dia

| Comando | O que faz |
|---------|-----------|
| `lx start` | inicia o desktop |
| `lx stop` | encerra e libera memória |
| `lx status` | o que já está instalado |
| `lx doctor` | diagnostica problemas |
| `lx shell` | terminal dentro do Ubuntu |
| `lx update` | atualiza repositório e pacotes |

---

## Controles dentro do Termux:X11

| Ação | Como |
|------|------|
| Mostrar/ocultar teclado | Toque com **3 dedos** na tela |
| Menu de preferências | Notificação do Termux:X11 → opções |
| Modo trackpad (mouse) | Ative em **Preferences → Touchscreen mode** no app X11 |
| Teclas especiais (Ctrl, Alt, setas) | Barra de teclas extra do Termux ou teclado físico |

> Dica: para uma experiência de "computador", conecte um **teclado e mouse Bluetooth**.
> O S23 reconhece e o KDE responde como um desktop normal.

---

## Compartilhar arquivos entre Android e Linux

Use o `--shared-tmp` (já ativado pelo `lx start`) ou acesse o armazenamento do
celular de dentro do Ubuntu.

> ⚠️ Se o `~/storage` não aparecer, rode o `termux-setup-storage` **com o desktop
> parado** — ele precisa do popup de permissão do Android, que não aparece com o
> Termux:X11 na frente:
> ```bash
> lx stop
> termux-setup-storage      # aceite a permissão na tela
> lx start
> ```

Para montar a pasta de armazenamento compartilhada,
entre no Ubuntu e os arquivos do Termux ficam em:

```
/data/data/com.termux/files/home/storage/
```

Ou copie via `cp` usando o `~/storage` configurado pelo `termux-setup-storage`.

---

## Atualizar o sistema

Dentro do Ubuntu:

```bash
proot-distro login ubuntu
apt update && apt upgrade -y
exit
```
