#!/bin/bash
# TechCorp — Script de validation / sanity check du serveur d'inférence

export PATH="$HOME/bin/bin:$HOME/bin:$PATH"
CURL_CMD="$(command -v curl || echo "$HOME/bin/curl")"

OLLAMA_PORT="${OLLAMA_PORT:-11434}"
MODEL_ALIAS="phi3-financial"
PASS=0
FAIL=0

check() {
    local label="$1"
    local cmd="$2"
    if eval "$cmd" > /dev/null 2>&1; then
        echo -e "\033[0;32m[PASS]\033[0m $label"
        ((PASS++))
    else
        echo -e "\033[0;31m[FAIL]\033[0m $label"
        ((FAIL++))
    fi
}

echo ""
echo "=== TechCorp — Validation Infrastructure ==="
echo ""

check "Processus Ollama en cours d'exécution"     "pgrep -f 'ollama serve'"
check "Port $OLLAMA_PORT accessible (localhost)"   "${CURL_CMD} -s --max-time 3 http://localhost:${OLLAMA_PORT}"
check "Modèle '$MODEL_ALIAS' listé dans Ollama"   "ollama list 2>/dev/null | grep -q $MODEL_ALIAS"
check "Endpoint /api/tags opérationnel"            \
    "${CURL_CMD} -s http://localhost:${OLLAMA_PORT}/api/tags | grep -q 'models'"

echo -n "  [TEST] Inférence sur '$MODEL_ALIAS'... "
RESP=$(${CURL_CMD} -s --max-time 120 -X POST "http://localhost:${OLLAMA_PORT}/api/generate" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL_ALIAS}\",\"prompt\":\"Reply OK\",\"stream\":false,\"options\":{\"num_predict\":5}}" 2>/dev/null)

if echo "$RESP" | grep -q '"response"'; then
    echo -e "\033[0;32m[PASS]\033[0m Inférence fonctionnelle"
    ((PASS++))
else
    echo -e "\033[0;31m[FAIL]\033[0m Inférence échouée"
    ((FAIL++))
fi

CHAT_RESP=$(${CURL_CMD} -s --max-time 120 -X POST "http://localhost:${OLLAMA_PORT}/api/chat" \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"${MODEL_ALIAS}\",\"messages\":[{\"role\":\"user\",\"content\":\"ping\"}],\"stream\":false}" 2>/dev/null)
if echo "$CHAT_RESP" | grep -q 'message'; then
    echo -e "\033[0;32m[PASS]\033[0m Endpoint /api/chat accessible"
    ((PASS++))
else
    echo -e "\033[0;31m[FAIL]\033[0m Endpoint /api/chat accessible"
    ((FAIL++))
fi

echo ""
echo "=== Résultat : $PASS passed / $((PASS+FAIL)) total ==="
echo ""

IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "127.0.0.1")
echo "  Endpoint réseau : http://${IP}:${OLLAMA_PORT}"
echo "  Modèle actif    : ${MODEL_ALIAS}"
echo "  API Generate    : POST http://${IP}:${OLLAMA_PORT}/api/generate"
echo "  API Chat        : POST http://${IP}:${OLLAMA_PORT}/api/chat"
echo ""

if [ $FAIL -gt 0 ]; then exit 1; fi
