# 7. Aceleração de GPU

Por padrão, o KDE em proot é desenhado **inteiramente pela CPU**
(`LIBGL_ALWAYS_SOFTWARE=1`). Funciona, mas rolagem engasga, vídeo trava, o
navegador sofre e o celular esquenta — e o Snapdragon 8 Gen 2 acaba fazendo na
CPU um trabalho que a GPU faria muito melhor.

Dá para usar a **GPU de verdade**, sem root. Isso muda bastante a experiência.

---

## Qual caminho usar

O S23 tem GPU **Adreno 740**. Existem dois caminhos, e para essa GPU um deles é
claramente melhor:

| | **Turnip** ✅ recomendado | **virgl** (alternativo) |
|---|---|---|
| Como funciona | driver Mesa freedreno falando direto com a Adreno pela interface **KGSL** do kernel | servidor tradutor rodando no Termux; o Linux fala com ele por socket |
| Desempenho | melhor — sem camada intermediária | menor — tudo passa pelo servidor |
| Processo extra | nenhum | `virgl_test_server_android` precisa ficar rodando |
| Compatibilidade | Adreno 660, 710–750, 810–840 | quase qualquer GPU Android |
| Onde instala | dentro do Ubuntu | no Termux |

Como a Adreno 740 está na lista de suportadas do Turnip, **use Turnip**. O virgl
fica como plano B.

### E o "Zink + Turnip"?

Você vai encontrar guias e vídeos usando **Mesa Zink** com o Turnip. Vale
entender a diferença, porque os dois usam o mesmo driver Turnip por baixo:

```
Zink:      KDE -> OpenGL -> Zink -> Vulkan -> Turnip -> Adreno
Freedreno: KDE -> OpenGL --------------------> freedreno -> Adreno   (usado aqui)
```

O Zink traduz OpenGL para Vulkan antes de chegar na GPU. Funciona, e é o que
muitos guias usam. Mas o Mesa tem um driver **OpenGL nativo** para Adreno
(freedreno), que dispensa essa tradução — é o caminho mais curto e tende a usar
melhor a GPU.

Por isso este projeto usa o freedreno/KGSL direto. Se você seguir um guia com
Zink e ele funcionar melhor no seu aparelho, ótimo — não há resposta única. Para
conferir qual está ativo, veja o `glxinfo -B` abaixo: `Zink (Adreno ...)` indica o
caminho Zink; `freedreno`/`Turnip` indica o caminho direto.

---

## Instalando (Turnip)

Um comando, direto do Termux:

```bash
lx gpu
```

O `lx` se copia para dentro do Ubuntu e faz o trabalho lá — você não precisa
entrar no Ubuntu nem baixar nada à mão.

O que ele faz:

1. detecta a versão do Ubuntu e escolhe o build correto;
2. baixa o Mesa de [lfdevs/mesa-for-android-container][mesa] (~11 MB) — um Mesa
   compilado especificamente para containers em Android, porque o Mesa normal do
   Ubuntu não sabe falar com a GPU do Android;
3. extrai em `/` e roda `ldconfig`;
4. grava `/etc/linux-android-gpu.conf`, que o `lx start` lê para ativar a GPU
   sozinho.

> Se você rodou `lx setup`, isso **já foi feito** — o setup inclui a GPU.

Depois disso, é só iniciar normalmente — a GPU passa a ser usada:

```bash
lx start
```

Você deve ver `==> Modo de renderização: turnip` no início.

[mesa]: https://github.com/lfdevs/mesa-for-android-container

---

## Conferindo se está funcionando

Com o desktop rodando, abra o **Konsole** dentro do KDE:

```bash
glxinfo -B
```

Olhe a linha **OpenGL renderer string**:

| Valor | Significado |
|-------|-------------|
| **`FD740`**, `FD730`, `FD650`… | ✅ **GPU ativa.** `FD` = FreeDreno, o número é o modelo da Adreno. `FD740` é o que o **Galaxy S23** mostra |
| `Turnip`, `Adreno`, `freedreno` | ✅ GPU ativa (outras formas de o Mesa se identificar) |
| `Zink (Adreno …)` | ✅ GPU ativa, pelo caminho Zink/Vulkan |
| `llvmpipe`, `softpipe` | ❌ caiu na CPU |

> ⚠️ Não estranhe o formato enxuto: o driver se identifica como **`FD740`**, sem
> a palavra "Adreno" nem "Turnip". É a resposta certa.

> ⚠️ Rode o `glxinfo` **dentro do KDE** (Konsole), não numa sessão sem X.
> Sem `DISPLAY` válido ele falha ou reporta o driver errado.

### Avisos que aparecem junto (e são normais)

O `glxinfo` costuma cuspir isto antes do resultado. **Nada aqui é problema:**

```
ATTENTION: default value of option vblank_mode overridden by environment.
```
É o próprio `lx start`, que define `vblank_mode=3` para reduzir tearing.

```
MESA-LOADER: failed to retrieve device information
```
O Mesa não consegue ler os metadados do dispositivo pelo caminho usual do
Linux (`/sys`), porque no Android o acesso é pela interface KGSL. Ele segue
adiante e usa a GPU normalmente — a prova é o `FD740` logo abaixo.

```
os_same_file_description couldn't determine if two DRM fds reference
the same file description. (Function not implemented)
```
O Mesa tentou usar a syscall `kcmp()` para comparar descritores de arquivo.
Ela não é permitida em proot, então ele adota a suposição conservadora e
continua. Limitação estrutural de rodar sem root, sem consequência prática
aqui.

Benchmark, para comparar antes e depois:

```bash
apt install -y glmark2
glmark2
```

---

## Escolhendo o modo manualmente

O `lx start` aceita a flag `--gpu`:

```bash
lx start                     # auto — usa Turnip se instalado
lx start --gpu turnip        # força GPU via Turnip
lx start --gpu virgl         # força GPU via virgl
lx start --gpu software      # força CPU (diagnóstico)
```

> 💡 **Ao investigar qualquer bug visual, teste primeiro com
> `lx start --gpu software`.** Se o problema sumir, é do driver de GPU e não do
> KDE. Isso economiza muito tempo.

---

## Caminho alternativo: virgl

Se o Turnip não funcionar no seu caso, o virgl é mais compatível. O
`lx setup` já instala o pacote necessário. Basta:

```bash
lx start --gpu virgl
```

O `lx start` sobe o `virgl_test_server_android` automaticamente antes do
desktop, e o `lx stop` o encerra junto.

Se faltar o pacote:

```bash
pkg install virglrenderer-android
```

---

## Problemas

### Artefatos, piscadas ou janelas corrompidas

O compositor do KDE fica desativado pelo `lx setup` justamente porque, sem
GPU, ele quebrava. **Com GPU, vale reativar** — pode ficar melhor:

```bash
kwriteconfig5 --file kwinrc --group Compositing --key Enabled true
```

Se piorar, desative de novo (`false`). No Plasma 6 o comando é `kwriteconfig6`.

### Tearing (a imagem "rasga" ao rolar)

O `lx start` já exporta `vblank_mode=3` e `MESA_VK_WSI_PRESENT_MODE=mailbox`
no modo Turnip, que é o contorno recomendado. Se persistir, reative o compositor
(acima) — ele sincroniza o desenho.

### O desktop não sobe depois de ativar a GPU

Volte para software e confirme que o problema é o driver:

```bash
lx stop
lx start --gpu software
```

Se assim funcionar, o release do Mesa pode não bater com a sua versão do Ubuntu.
Rode o `lx gpu` de novo (ele sempre pega o release mais recente) ou
baixe o build "Turnip-prefixed" (versão sem patches, para diagnóstico) direto
das [releases do projeto][mesa].

### `glxinfo: command not found`

```bash
apt install -y mesa-utils
```

---

## Vale a pena?

Sim. Esta é a diferença mais perceptível que você pode fazer no projeto — mais do
que trocar o KDE pelo XFCE. Sem GPU, o gargalo é a CPU desenhando cada pixel;
com GPU, o Adreno 740 tem folga de sobra para uma interface de desktop.

Se ainda assim ficar pesado, aí sim veja as
[dicas de desempenho](05-dicas-desempenho.md).

---

*[linux-android](https://github.com/NicolasArthurDev/linux-android) — por Nicolas Arthur.*
