# 1. Pré-requisitos

Antes de rodar qualquer script, você precisa instalar **três apps** no Galaxy S23.

## 🚨 A regra que quebra tudo: uma origem só

O Termux e seus plugins compartilham o mesmo `sharedUserId` do Android
(`com.termux`). O Android **exige que apps que compartilham UID tenham a mesma
assinatura** — e as builds do F-Droid e do GitHub são assinadas com chaves
diferentes.

**Misturar origens não é "menos ideal", é impossível.** Você recebe
`INSTALL_FAILED_SHARED_USER_INCOMPATIBLE` ou "App não instalado" e trava.

> **Recomendação: baixe os três do GitHub.** Além de garantir a assinatura
> consistente, é o único caminho que deixa aberta a variante de melhor
> desempenho do Termux:X11 (veja abaixo).
>
> Se você já tem Termux instalado de outra origem, **desinstale tudo antes** —
> Termux e todos os plugins — e reinstale do GitHub.

⚠️ Não use a Play Store: a versão de lá está descontinuada e quebrada.

---

## App 1 — Termux

O ambiente base onde tudo roda.

- **GitHub:** https://github.com/termux/termux-app/releases
- **Versão atual: `v0.118.3`** (mai/2025)
- **Arquivo:** `termux-app_v0.118.3+github-debug_arm64-v8a.apk` (~33 MB)

> O S23 é `arm64-v8a` (64 bits). Escolha esse ABI — o `universal` (112 MB)
> também funciona, mas carrega as outras arquiteturas sem necessidade.

## App 2 — Termux:X11

O app que mostra a tela do desktop. Não está na Play Store nem no F-Droid.

- **GitHub (tag `nightly`):** https://github.com/termux/termux-x11/releases/tag/nightly
- **Arquivo:** `termux-x11-universal-debug.apk` (~14 MB)

> ℹ️ O APK **não é mais separado por arquitetura**. Se algum guia mandar baixar
> `app-arm64-v8a-debug.apk`, está desatualizado — hoje é um `universal` só.

### As duas variantes

Na mesma release existem dois APKs:

| Arquivo | Quando usar |
|---------|-------------|
| `termux-x11-universal-debug.apk` | **padrão — comece por este** |
| `termux-x11-universal-sharedUid-debug.apk` | se sentir lentidão. Roda como parte do próprio Termux, então o Android trata os dois como um app só e não o penaliza em segundo plano. **Só funciona com o Termux do GitHub.** |

> Como o `nightly` é uma tag rolante, ela é reescrita a cada build. Baixe o APK
> **e** rode o `lx setup` no mesmo dia, para o app e o pacote ficarem próximos.
>
> Se a tela não conectar mesmo com tudo certo, é sinal de descompasso entre o
> APK e o pacote `termux-x11-nightly`. A solução é pegar o `.deb` da **mesma
> release** do APK e instalá-lo por cima:
> ```bash
> pkg install ./termux-x11-nightly-*.deb
> ```

## App 3 — Termux:API

Necessário para o **wake-lock automático** do `lx start` — sem ele, o Android
mata o Termux em segundo plano e o desktop cai quando você troca de app.

- **GitHub:** https://github.com/termux/termux-api/releases
- **Versão atual: `v0.53.0`** (set/2025)
- **Arquivo:** `termux-api-app_v0.53.0+github.debug.apk` (~8 MB)

> Este é um plugin de verdade: **precisa** ser da mesma origem que o Termux.

---

## Instalando os APKs

1. Baixe os **três** `.apk` no celular, todos do GitHub.
2. Ao abrir o primeiro, o Android pede para permitir "instalar apps de fontes
   desconhecidas" — autorize.
3. Instale **nesta ordem**: **Termux** → **Termux:API** → **Termux:X11**.
   O Termux precisa vir primeiro porque os outros se apoiam no UID dele.
4. **Abra o Termux:X11 pelo menos uma vez** antes de rodar o `lx start`. Ele
   precisa ter sido iniciado ao menos uma vez para registrar o serviço.

Se algum der "App não instalado" ou
`INSTALL_FAILED_SHARED_USER_INCOMPATIBLE`, é assinatura incompatível: você tem
algum Termux de outra origem instalado. Desinstale **todos** (Termux e plugins)
e recomece do passo 1.

> Depois de instalar, `lx doctor` confirma se o Android enxerga os três apps.

---

## Espaço e bateria

- O Ubuntu + KDE ocupa cerca de **4–6 GB**. Tenha espaço livre.
- O primeiro download/instalação consome bastante dados — use **Wi-Fi**.
- Mantenha o celular **carregando** durante a instalação (é demorado).

---

## ⚠️ Obrigatório: desativar a restrição de processos filhos

Esse é o passo mais importante desta página, e o menos óbvio.

A partir do **Android 12**, o sistema tem o *Phantom Process Killer*: ele limita a
uns **32 processos filhos** por app e mata o excesso, sem avisar. Uma sessão KDE
Plasma passa disso com folga — são dezenas de processos (kwin, plasmashell, kded,
os daemons do KDE, o navegador...).

O sintoma é cruel de diagnosticar: **o desktop simplesmente morre**, ou apps
somem sozinhos, ou tudo trava depois de alguns minutos — sem mensagem de erro.

### Como desativar

1. Ative as **Opções de desenvolvedor** (Configurações → Sobre o telefone →
   Informações de software → toque 7 vezes em "Número da versão").
2. Configurações → **Opções de desenvolvedor** → ative
   **"Desativar restrições de processos filhos"**
   (*"Disable child process restrictions"*).
3. **Reinicie o celular.**

### Se a opção não existir

Em algumas versões dá para fazer via ADB (de um PC, com depuração USB ativa):

```bash
adb shell "/system/bin/device_config set_sync_disabled_for_tests persistent"
adb shell "/system/bin/device_config put activity_manager max_phantom_processes 2147483647"
```

> ⚠️ Em muitas versões do Android isso **volta ao normal após reiniciar**, e
> precisa ser refeito. A opção de desenvolvedor, quando existe, é persistente —
> prefira ela.

---

## Recomendado: desativar otimização de bateria do Termux

O Android pode "matar" o Termux em segundo plano e derrubar o desktop.

1. Configurações do Android → Apps → **Termux** → Bateria → **Sem restrições**.
2. Faça o mesmo para o **Termux:X11**.
3. Opcional: dentro do Termux, ative o wake-lock pelo menu da notificação
   (deslize a barra de notificações → toque em **Acquire wakelock** no Termux).

---

Pronto? Vá para o [guia de instalação](02-instalacao.md).
