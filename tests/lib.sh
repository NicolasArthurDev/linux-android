#!/usr/bin/env bash
# Utilidades comuns aos testes.
#
# Os testes NAO instalam nada e NAO tocam no sistema: carregam o 'lx' com o
# main() removido, forcam o contexto e substituem comandos externos por mocks
# que apenas registram como foram chamados.

LX_REPO="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
LX_BIN="$LX_REPO/lx"

_pass=0; _fail=0

chk() { # descricao, esperado, obtido
    if [ "$2" = "$3" ]; then
        printf '  \033[32mok\033[0m   %s\n' "$1"; _pass=$((_pass+1))
    else
        printf '  \033[31mFALHA\033[0m %s\n       esperado: <%s>\n       obtido:   <%s>\n' "$1" "$2" "$3"
        _fail=$((_fail+1))
    fi
}

chk_match() { # descricao, regex esperada, texto
    if printf '%s' "$3" | grep -qiE "$2"; then
        printf '  \033[32mok\033[0m   %s\n' "$1"; _pass=$((_pass+1))
    else
        printf '  \033[31mFALHA\033[0m %s (não casou /%s/)\n' "$1" "$2"; _fail=$((_fail+1))
    fi
}

# Carrega as funcoes do lx sem executar o main, com o contexto forcado.
lx_source() { # $1 = termux|ubuntu, $2 = arquivo de saida
    head -n -1 "$LX_BIN" | sed "s|^readonly CTX=.*|readonly CTX=\"$1\"|" > "$2"
}

finish() {
    echo
    printf 'passou: %d   falhou: %d\n' "$_pass" "$_fail"
    [ "$_fail" -eq 0 ]
}
