#!/bin/bash
# TechCorp — Arrêt propre du serveur Ollama

export PATH="$HOME/bin/bin:$HOME/bin:$PATH"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PID_FILE="$PROJECT_DIR/logs/ollama.pid"

echo "[INFO] Arrêt du serveur Ollama..."

if [ -f "$PID_FILE" ]; then
    PID=$(cat "$PID_FILE")
    kill "$PID" 2>/dev/null && echo "[OK]   Processus $PID arrêté." || echo "[WARN] Processus déjà arrêté."
    rm -f "$PID_FILE"
else
    pkill -f "ollama serve" 2>/dev/null && echo "[OK]   Ollama arrêté." || echo "[INFO] Aucun processus Ollama trouvé."
fi
