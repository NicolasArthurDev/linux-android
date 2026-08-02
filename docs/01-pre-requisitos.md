# 1. Pré-requisitos

Antes de rodar qualquer script, você precisa instalar **dois apps** no Galaxy S23
(um terceiro é citado mais abaixo apenas para dizer que **não** é necessário).

## 🚨 A regra que quebra tudo: uma origem só

O Termux e seus plugins compartilham o mesmo `sharedUserId` do Android
(`com.termux`). O Android **exige que apps que compartilham UID tenham a mesma
assinatura** — e as builds do F-Droid e do GitHub são assinadas com chaves
diferentes.

**Misturar origens não é "menos ideal", é impossível.** Você recebe
`INSTALL_FAILED_SHARED_USER_INCOMPATIBLE` ou "App não instalado" e trava.

> **Recomendação: baixe tudo do GitHub.** Além de garantir a assinatura
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

## App 3 — Termux:API — ⛔ **NÃO é necessário**

**Você pode pular este.** Nada neste projeto precisa dele.

Uma versão anterior deste guia dizia que o Termux:API era necessário para o
wake-lock. **Isso estava errado.** O `termux-wake-lock` vem do pacote
`termux-tools`, que é marcado como *essential* e **já vem instalado no Termux**.
Ele conversa direto com o serviço do próprio app Termux:

```sh
am startservice -a com.termux.service_wake_lock com.termux/.app.TermuxService
```

Nenhum plugin envolvido. O Termux:API serve para **câmera, SMS, sensores,
notificações, GPS** — coisas que este projeto não usa.

Se ainda assim quiser instalar (para outros usos):

- **GitHub:** https://github.com/termux/termux-api/releases
- **Versão atual: `v0.53.0`** (set/2025) — `termux-api-app_v0.53.0+github.debug.apk`
- Precisa ser da **mesma origem** que o Termux (é um plugin de verdade).

### Se aparecer "App blocked to protect your device"

É o **Google Play Protect**, não o Android. Ele bloqueia o Termux:API por
heurística, porque o app pede permissões sensíveis (SMS, câmera, localização) —
é falso positivo conhecido, mas o bloqueio é real.

Como o app é dispensável aqui, **a resposta mais simples é não instalar**. Se
precisar dele de verdade:

1. Play Store → toque na sua foto de perfil → **Play Protect**
2. Ícone de engrenagem (⚙️) → desligue **"Verificar apps com o Play Protect"**
3. Instale o APK
4. **Ligue o Play Protect de volta**

Em alguns casos a própria tela de bloqueio tem **"Mais detalhes" → "Instalar
mesmo assim"**.

> ⚠️ Só desligue o Play Protect para instalar um APK que você baixou da fonte
> oficial e confia — neste caso, o repositório do Termux no GitHub. E religue
> logo em seguida.

---

## Instalando os APKs

1. Baixe os **dois** `.apk` obrigatórios no celular, ambos do GitHub.
2. Ao abrir o primeiro, o Android pede para permitir "instalar apps de fontes
   desconhecidas" — autorize.
3. Instale **nesta ordem**: **Termux** → **Termux:X11**.
   O Termux precisa vir primeiro.
4. **Abra o Termux:X11 pelo menos uma vez** antes de rodar o `lx start`. Ele
   precisa ter sido iniciado ao menos uma vez para registrar o serviço.

Se algum der "App não instalado" ou
`INSTALL_FAILED_SHARED_USER_INCOMPATIBLE`, é assinatura incompatível: você tem
algum Termux de outra origem instalado. Desinstale **todos** (Termux e plugins)
e recomece do passo 1.

> Depois de instalar, rode `lx doctor`.
>
> ⚠️ Se ele disser **"Termux:X11: não foi possível confirmar"**, está tudo bem.
> Desde o Android 11 um app não enxerga a lista de apps instalados dos outros,
> então o terminal simplesmente não consegue verificar. Confira na gaveta de
> apps do celular.

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

### Como conferir (e por que o `lx doctor` não consegue)

O `lx doctor` normalmente diz **"não foi possível confirmar"** aqui. Isso é
esperado, não é falha sua:

- `settings get global settings_enable_monitor_phantom_procs` só devolve
  `false` se o toggle gravou nessa chave. Em várias ROMs — One UI incluída —
  ele grava em outro lugar, e a leitura volta `null`.
- `device_config get activity_manager max_phantom_processes` exige **root ou
  ADB** no Android 14+. Do Termux dá permissão negada.

**Se você ativou a opção e reiniciou, considere feito.** O teste que vale é
prático: se o desktop rodar por 10+ minutos com o navegador aberto sem morrer,
está desativada.

Para confirmar de fato, com um PC:

```bash
adb shell settings get global settings_enable_monitor_phantom_procs
adb shell device_config get activity_manager max_phantom_processes
```

---

## Recomendado: desativar otimização de bateria do Termux

O Android pode "matar" o Termux em segundo plano e derrubar o desktop.

1. Configurações do Android → Apps → **Termux** → Bateria → **Sem restrições**.
2. Faça o mesmo para o **Termux:X11**.
3. Opcional: dentro do Termux, ative o wake-lock pelo menu da notificação
   (deslize a barra de notificações → toque em **Acquire wakelock** no Termux).

---

Pronto? Vá para o [guia de instalação](02-instalacao.md).
