# 2. Instalação passo a passo

Tempo estimado: **30–60 min** (depende da internet). Mantenha o celular no Wi-Fi e carregando.

---

## Caminho rápido

Se você só quer instalar, são três comandos:

```bash
pkg install -y git
git clone https://github.com/NicolasArthurDev/linux-android.git
cd linux-android && ./lx setup
```

O `./lx setup` cuida de tudo — Termux, Ubuntu, KDE e GPU — e **pula o que já
está feito**, então pode ser interrompido e rodado de novo à vontade.

Ao terminar, ele roda o `doctor` sozinho e lista o que ainda falta do lado do
Android (os APKs e a opção de desenvolvedor, que não dá para automatizar).

Depois:

```bash
./lx dev      # ambiente de desenvolvimento (opcional)
./lx start    # iniciar o desktop
```

O resto desta página explica **o que cada etapa faz**, para quem quer entender
ou precisa resolver algum problema no meio do caminho.

---

## Passo a passo detalhado

---

## Passo 0 — Baixar o projeto

Abra o **Termux** e rode:

```bash
pkg install -y git
git clone https://github.com/NicolasArthurDev/linux-android.git
cd linux-android
./lx install     # habilita o comando 'lx' de qualquer pasta
```

O `install` cria um symlink em `$PREFIX/bin`. Se você pular esse passo, tudo
funciona igual — só troque `lx` por `./lx` e fique dentro do diretório.

---

## Passo 1 — `lx setup`

```bash
lx setup
```

Este único comando faz as quatro etapas, em ordem, **pulando o que já estiver
feito**:

| Etapa | O que acontece | Tempo |
|-------|----------------|-------|
| 1/4 Termux | instala `proot-distro`, `termux-x11-nightly`, `pulseaudio`, `git`, `termux-api` e o virgl; roda o `termux-setup-storage` | ~3 min |
| 2/4 Ubuntu | baixa e instala o Ubuntu via proot-distro | ~5 min |
| 3/4 KDE | entra no Ubuntu e instala o Plasma, fontes, locales e os ajustes para proot | **~30 min** |
| 4/4 GPU | baixa o Mesa com Turnip e ativa a aceleração da Adreno | ~2 min |

Coisas que vão pedir sua atenção durante o processo:

- **Permissão de armazenamento** — um popup do Android. Aceite.
- Se cair a internet ou o Termux for morto, **rode `lx setup` de novo**. Ele
  retoma de onde parou; não refaz o que já terminou.

Ao final ele roda o `doctor` sozinho e lista o que ainda falta do lado do
Android — os APKs e as opções de desenvolvedor, que nenhum script consegue
fazer por você.

> ℹ️ Note que na etapa 3/4 o `lx` **entra no Ubuntu sozinho**: ele se copia para
> dentro do rootfs e se re-invoca lá. Você não precisa fazer
> `proot-distro login` nem baixar scripts à mão.

---

## Passo 2 — Conferir o que falta

```bash
lx doctor
```

Ele verifica: os dois APKs (Termux:X11 e Termux:API), a restrição de processos
filhos, os pacotes, o Ubuntu, o KDE, a GPU e o que está rodando.

Resolva o que ele apontar antes de seguir — em especial a
**restrição de processos filhos**, que é a causa mais comum de o desktop morrer
sozinho. Passo a passo em [pré-requisitos](01-pre-requisitos.md).

---

## Passo 3 — Ambiente de desenvolvimento (opcional)

```bash
lx dev
```

Instala no Termux **e** no Ubuntu: zsh + Oh My Zsh (tema `darkblood`), NvChad,
tmux, git, btop, bat, fzf, lazygit, fastfetch e Claude Code.

```bash
lx dev termux        # só no Termux
lx dev --no-claude   # sem o Claude Code
```

---

## Passo 4 — Iniciar o desktop

```bash
lx start
```

Inicia o servidor X11, o áudio e o KDE, e **abre o app Termux:X11
automaticamente**. Se não abrir sozinho, abra o app manualmente.

> Na primeira vez o KDE leva 1–2 min para carregar. Tenha paciência.

Se a tela ficar preta ou as cores saírem trocadas, veja
[solução de problemas](04-solucao-de-problemas.md) — há flags prontas para isso.

---

## Passo 5 — Encerrar

```bash
lx stop
```

Encerra o KDE, o X11, o áudio e o proot, e libera o wake-lock. **Sempre use**,
para não deixar processos consumindo bateria.

---

## Resumo

```bash
lx start   # iniciar
lx stop    # parar
lx doctor  # quando algo der errado
lx         # menu, se preferir não decorar
```

Veja mais em [uso diário](03-uso-diario.md).
