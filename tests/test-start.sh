#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
D="$(dirname "$0")"
run(){ env DRYRUN_ARGS="${1:-start}" DRYRUN_PRE="${2:-}" DRYRUN_ONLY_KDE="${3:-}" \
       timeout 60 bash "$D/dryrun.sh" 2>&1; }

echo "-- ambientes"
chk_match "padrao = kde"             "Ambiente:.*kde"   "$(run start)"
chk_match "--de bspwm"               "Ambiente:.*bspwm" "$(run 'start --de bspwm')"
chk_match "--de xfce"                "Ambiente:.*xfce"  "$(run 'start --de xfce')"
chk_match "--de invalido recusado"   "desconhecido"     "$(run 'start --de gnome')"
chk_match "--de sem valor recusado"  "exige um valor"   "$(run 'start --de')"

echo "-- guard: binario da sessao ausente"
chk_match "avisa bspwm ausente"      "bspwm.*não encontrado" "$(run 'start --de bspwm' '' 1)"
chk_match "  e sugere 'lx rice'"     "lx rice"               "$(run 'start --de bspwm' '' 1)"

echo "-- GPU"
chk_match "marcador -> turnip"       "Renderização:.*turnip"   "$(run start)"
chk_match "--gpu software"           "Renderização:.*software" "$(run 'start --gpu software')"
chk_match "--gpu sem valor recusado" "exige um valor"          "$(run 'start --gpu')"
chk_match "virgl sobe o servidor antes" "virgl_test_server_android" "$(run 'start --gpu virgl')"

echo "-- ambiente enviado ao proot"
o="$(run start)"
chk_match "DISPLAY expandido"        "export DISPLAY=:0"                 "$o"
chk_match "fuso do Android repassado" "export TZ='America/Sao_Paulo'"    "$o"
chk_match "LANG resolvido no destino" 'case .\$\{LANG:-\}'               "$o"
chk_match "XDG_RUNTIME_DIR literal"   'mkdir -p .\$XDG_RUNTIME_DIR'      "$o"
chk_match "kpipewire silenciado"      "QT_LOGGING_RULES"                 "$o"
chk_match "SHELL exportado"           "export SHELL="                    "$o"

echo "-- o LANG do Termux nao vaza para dentro"
o2="$(LANG=pt_BR.ISO-8859-1 env DRYRUN_ARGS=start timeout 60 bash "$D/dryrun.sh" 2>&1)"
chk "LANG do host ausente" "0" "$(printf '%s' "$o2" | grep -c 'ISO-8859-1')"

echo "-- word splitting do --extra"
chk_match '--extra "a b" vira argumentos separados' '\[2\] <-force-bgra>' "$(run 'start --extra "-force-bgra -dpi 96"')"

echo "-- vsync (padrao off: X aninhado nao tem vblank de hardware)"
# O comando enviado ao proot leva as DUAS ramificacoes do case, entao nao da
# para conferir por grep no corpo: o que importa e qual ramo o case seleciona.
o="$(run start)"
chk_match "padrão seleciona o ramo 'off'" "case 'off' in" "$o"
chk_match "as duas opções estão no script" "vblank_mode=0" "$o"
ov="$(run 'start --vsync on')"
chk_match "--vsync on seleciona o ramo 'on'" "case 'on' in" "$ov"
chk "e nada mais muda entre os dois"  "1" \
    "$( [ "$(printf '%s' "$o" | grep -c 'MESA_LOADER_DRIVER_OVERRIDE=kgsl')" = \
         "$(printf '%s' "$ov" | grep -c 'MESA_LOADER_DRIVER_OVERRIDE=kgsl')" ] && echo 1 || echo 0)"
chk_match "--vsync invalido recusado"     "use 'on' ou 'off'" "$(run 'start --vsync sim')"
chk_match "--vsync sem valor recusado"    "exige um valor"    "$(run 'start --vsync')"

echo "-- log em vez de inundar o terminal"
chk_match "informa o caminho do log" "log da sessão" "$(run start)"
chk_match "--verbose nao redireciona" "Ambiente"     "$(run 'start --verbose')"
finish
