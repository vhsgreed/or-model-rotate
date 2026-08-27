#!/usr/bin/env bash
# or-model-rotate.sh — round-robin selection of free OpenRouter models for subagent spawns.
# Each free model has its own rate-limit bucket (20 req/min, 1000 req/day per model, account-wide),
# so rotating spreads throughput instead of sharing one model's quota.
# Usage:
#   ./scripts/or-model-rotate.sh            # print next model (and advance)
#   ./scripts/or-model-rotate.sh --peek     # print next model without advancing
#   ./scripts/or-model-rotate.sh --list     # list all models in rotation
#   ./scripts/or-model-rotate.sh --batch N  # print N distinct models, one per line, advancing state (wraps)
set -u

STATE="${OR_ROTATE_STATE:-$(dirname "$0")/.or-model-state}"

MODELS=(
  "openrouter/nvidia/nemotron-3-ultra-550b-a55b:free"
  "openrouter/nvidia/nemotron-3-super-120b-a12b:free"
  "openrouter/z-ai/glm-5.2:free"
  "openrouter/google/gemma-4-31b-it:free"
  "openrouter/thinkingmachines/inkling:free"
  "openrouter/openrouter/free"
)

case "${1:-}" in
  --list) printf '%s\n' "${MODELS[@]}"; exit 0 ;;
  --peek)
    i=0; [ -f "$STATE" ] && i=$(cat "$STATE" 2>/dev/null || echo 0)
    echo "${MODELS[$i]}"; exit 0 ;;
  --batch)
    n="${2:-}"
    if ! [[ "$n" =~ ^[0-9]+$ ]] || [ "$n" -lt 1 ]; then echo "usage: $0 --batch N (N>=1)" >&2; exit 1; fi
    i=0; [ -f "$STATE" ] && i=$(cat "$STATE" 2>/dev/null || echo 0)
    for _ in $(seq 1 "$n"); do
      echo "${MODELS[$i]}"
      i=$(( (i + 1) % ${#MODELS[@]} ))
    done
    printf '%s' "$i" > "$STATE"
    exit 0 ;;
  "")
    i=0; [ -f "$STATE" ] && i=$(cat "$STATE" 2>/dev/null || echo 0)
    echo "${MODELS[$i]}"
    i=$(( (i + 1) % ${#MODELS[@]} ))
    printf '%s' "$i" > "$STATE"
    exit 0 ;;
  *) echo "usage: $0 [--peek|--list|--batch N]" >&2; exit 1 ;;
esac
