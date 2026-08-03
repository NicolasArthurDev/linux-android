#!/usr/bin/env bash
source "$(dirname "$0")/lib.sh"
D="$(dirname "$0")"
run(){ env DRYRUN_PRE="${1:-}" DRYRUN_ARGS="${2:-start}" ${3:+LX_DE=$3} \
       timeout 60 bash "$D/dryrun.sh" 2>&1; }

chk_match "padrao de fabrica = kde"    "Ambiente:.*kde"         "$(run '' start)"
chk_match "'lx de bspwm' grava"        "ambiente padrão: bspwm" "$(run 'de bspwm' start)"
chk_match "start passa a usar bspwm"   "Ambiente:.*bspwm"       "$(run 'de bspwm' start)"
chk_match "--de vence o padrao salvo"  "Ambiente:.*kde"         "$(run 'de bspwm' 'start --de kde')"
chk_match "LX_DE vence o padrao salvo" "Ambiente:.*xfce"        "$(run 'de bspwm' start xfce)"
chk_match "--de vence o LX_DE"         "Ambiente:.*bspwm"       "$(run '' 'start --de bspwm' xfce)"
chk_match "recusa valor invalido"      "desconhecido"           "$(run '' 'de gnome')"
chk_match "lista marcando o atual"     '\*.*bspwm'              "$(run 'de bspwm' de)"
chk_match "arquivo corrompido -> kde"  "Ambiente:.*kde"         "$(run 'de zzz' start)"
finish
