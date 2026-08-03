#!/usr/bin/env bash
# Roda toda a suite.  Uso:  ./tests/run.sh  [nome-parcial]
cd -- "$(dirname -- "${BASH_SOURCE[0]}")" || exit 1

filtro="${1:-}"
total_p=0; total_f=0; suites=0

for t in test-*.sh; do
    [ -n "$filtro" ] && case "$t" in *"$filtro"*) ;; *) continue ;; esac
    printf '\033[1m### %s\033[0m\n' "$t"
    out="$(bash "$t" 2>&1)"; rc=$?
    echo "$out" | sed 's/^/  /'
    p=$(echo "$out" | grep -oE 'passou: [0-9]+' | grep -oE '[0-9]+' | tail -1)
    f=$(echo "$out" | grep -oE 'falhou: [0-9]+' | grep -oE '[0-9]+' | tail -1)
    total_p=$((total_p + ${p:-0})); total_f=$((total_f + ${f:-0}))
    suites=$((suites+1))
    [ "$rc" -ne 0 ] && printf '\033[31m  ^ suite falhou\033[0m\n'
    echo
done

printf '\033[1m=== %d suites · %d passaram · %d falharam ===\033[0m\n' "$suites" "$total_p" "$total_f"
[ "$total_f" -eq 0 ]
