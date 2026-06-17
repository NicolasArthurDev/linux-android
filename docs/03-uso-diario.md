# 3. Uso diário

## Iniciar o desktop

No **Termux**:

```bash
cd ~/linux-in-s23/scripts
./start-kde.sh
```

O app **Termux:X11** abre sozinho mostrando o KDE. Se não abrir, abra-o manualmente.

## Parar o desktop

Volte ao **Termux** (deslize de fora para dentro da borda esquerda no Termux:X11
mostra o teclado/atalhos; para sair, troque de app para o Termux) e rode:

```bash
./stop-kde.sh
```

Sempre encerre com o `stop-kde.sh` para não deixar processos consumindo bateria.

---

## Atalho rápido (opcional)

Crie um atalho no Termux para iniciar com um comando curto:

```bash
echo 'alias kde="bash ~/linux-in-s23/scripts/start-kde.sh"' >> ~/.bashrc
echo 'alias kde-off="bash ~/linux-in-s23/scripts/stop-kde.sh"' >> ~/.bashrc
source ~/.bashrc
```

Depois é só digitar `kde` para iniciar e `kde-off` para parar.

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

Use o `--shared-tmp` (já ativado no `start-kde.sh`) ou acesse o armazenamento do
celular de dentro do Ubuntu. Para montar a pasta de armazenamento compartilhada,
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
