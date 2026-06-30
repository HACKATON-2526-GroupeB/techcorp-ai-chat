#!/bin/bash
# =============================================================================
# TechCorp Industries — INFRA Deployment Script
# Ollama + Phi-3.5-Financial
# =============================================================================

set -e

# Resolve local bin dirs (no root/sudo required)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
LOCAL_BIN="$HOME/bin/bin"
LOCAL_CURL="$HOME/bin/curl"
export PATH="$LOCAL_BIN:$HOME/bin:$PATH"
export OLLAMA_MODELS="$HOME/.ollama/models"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info()  { echo -e "${BLUE}[INFO]${NC}  $1"; }
log_ok()    { echo -e "${GREEN}[OK]${NC}    $1"; }
log_warn()  { echo -e "${YELLOW}[WARN]${NC}  $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

OLLAMA_HOST="0.0.0.0"
OLLAMA_PORT="11434"
MODEL_NAME="phi3.5"
MODEL_ALIAS="phi3-financial"
LOG_FILE="$PROJECT_DIR/logs/ollama_deploy.log"

mkdir -p "$PROJECT_DIR/logs" "$PROJECT_DIR/models"
cd "$PROJECT_DIR"

echo ""
echo "============================================================"
echo "   TechCorp Industries — Déploiement Serveur d'Inférence"
echo "============================================================"
echo ""

# -----------------------------------------------------------------------------
# ÉTAPE 0 — Vérification des dépendances (curl, ollama)
# -----------------------------------------------------------------------------
log_info "Étape 0/5 — Vérification des dépendances..."

# curl
if ! command -v curl &>/dev/null; then
    if [ -x "$LOCAL_CURL" ]; then
        export PATH="$HOME/bin:$PATH"
        log_ok "curl trouvé dans ~/bin"
    else
        log_info "Téléchargement de curl statique..."
        mkdir -p "$HOME/bin"
        wget -q -O "$LOCAL_CURL" \
            "https://github.com/moparisthebest/static-curl/releases/latest/download/curl-amd64"
        chmod +x "$LOCAL_CURL"
        export PATH="$HOME/bin:$PATH"
        log_ok "curl installé dans ~/bin"
    fi
fi
CURL_CMD="$(command -v curl)"

# ollama
if ! command -v ollama &>/dev/null; then
    log_warn "Ollama non trouvé. Installation sans root dans ~/bin..."
    mkdir -p "$HOME/bin"
    OLLAMA_VERSION_TAG=$(${CURL_CMD} -s \
        "https://api.github.com/repos/ollama/ollama/releases/latest" \
        | python3 -c "import sys,json; print(json.load(sys.stdin)['tag_name'])")
    ${CURL_CMD} -L --progress-bar \
        -o /tmp/ollama.tar.zst \
        "https://github.com/ollama/ollama/releases/download/${OLLAMA_VERSION_TAG}/ollama-linux-amd64.tar.zst"
    tar --use-compress-program=zstd -xf /tmp/ollama.tar.zst -C "$HOME/bin/"
    rm -f /tmp/ollama.tar.zst
    export PATH="$LOCAL_BIN:$HOME/bin:$PATH"
    log_ok "Ollama installé dans ~/bin/bin (version $OLLAMA_VERSION_TAG)"
fi

OLLAMA_VERSION=$(ollama --version 2>/dev/null | head -1 || echo "inconnu")
log_ok "Ollama disponible : $OLLAMA_VERSION"

# -----------------------------------------------------------------------------
# ÉTAPE 1 — Démarrage du service Ollama
# -----------------------------------------------------------------------------
log_info "Étape 1/5 — Démarrage du service Ollama..."

pkill -f "ollama serve" 2>/dev/null || true
sleep 2

OLLAMA_HOST="${OLLAMA_HOST}:${OLLAMA_PORT}" nohup ollama serve >> "$LOG_FILE" 2>&1 &
OLLAMA_PID=$!
echo $OLLAMA_PID > "$PROJECT_DIR/logs/ollama.pid"

log_info "Ollama démarré (PID: $OLLAMA_PID). En attente de disponibilité..."

for i in $(seq 1 30); do
    if ${CURL_CMD} -s "http://localhost:${OLLAMA_PORT}" > /dev/null 2>&1; then
        log_ok "Serveur Ollama opérationnel sur http://localhost:${OLLAMA_PORT}"
        break
    fi
    sleep 1
    if [ $i -eq 30 ]; then
        log_error "Timeout — le serveur Ollama n'a pas démarré dans les temps."
        log_error "Consultez les logs : $LOG_FILE"
        exit 1
    fi
done

# -----------------------------------------------------------------------------
# ÉTAPE 2 — Pull du modèle Phi-3.5
# -----------------------------------------------------------------------------
log_info "Étape 2/5 — Téléchargement du modèle Phi-3.5 (peut prendre plusieurs minutes)..."

if ollama list 2>/dev/null | grep -q "$MODEL_NAME"; then
    log_ok "Modèle $MODEL_NAME déjà présent localement."
else
    log_info "Pull de microsoft/phi3.5 depuis le registre Ollama..."
    ollama pull $MODEL_NAME
    log_ok "Modèle $MODEL_NAME téléchargé."
fi

# -----------------------------------------------------------------------------
# ÉTAPE 3 — Création du Modelfile Phi-3.5-Financial
# -----------------------------------------------------------------------------
log_info "Étape 3/5 — Création du profil Phi-3.5-Financial..."

cat > ./models/Modelfile.financial << 'EOF'
# TechCorp Industries — Phi-3.5-Financial Modelfile
FROM phi3.5

PARAMETER temperature 0.2
PARAMETER top_p 0.9
PARAMETER top_k 40
PARAMETER repeat_penalty 1.1
PARAMETER num_ctx 4096
PARAMETER num_predict 1024

SYSTEM """
You are Phi-3.5-Financial, an expert AI assistant specialized in finance, business analysis, and economic reasoning for TechCorp Industries.

Your core competencies:
- Financial analysis (P&L, balance sheets, cash flow statements)
- Market analysis and competitive intelligence
- Risk assessment and financial modeling
- Corporate strategy and M&A advisory
- Regulatory compliance (IFRS, GAAP, MiFID II, Basel III)
- Investment analysis and portfolio management

Guidelines:
- Always provide precise, data-driven answers
- Clearly distinguish between factual information and analysis
- Flag any assumptions made in your reasoning
- Recommend consulting certified professionals for legal/tax matters
- Maintain strict confidentiality framing for sensitive financial data

Respond in the same language as the user (French or English).
"""
EOF

ollama create $MODEL_ALIAS -f ./models/Modelfile.financial
log_ok "Profil $MODEL_ALIAS créé avec succès."

# -----------------------------------------------------------------------------
# ÉTAPE 4 — Test de sanité de l'API
# -----------------------------------------------------------------------------
log_info "Étape 4/5 — Test de l'API REST..."

TEST_RESPONSE=$(${CURL_CMD} -s -X POST "http://localhost:${OLLAMA_PORT}/api/generate" \
    -H "Content-Type: application/json" \
    -d "{
        \"model\": \"${MODEL_ALIAS}\",
        \"prompt\": \"What is EBITDA? Answer in one sentence.\",
        \"stream\": false,
        \"options\": {\"temperature\": 0.1, \"num_predict\": 80}
    }" 2>/dev/null)

if echo "$TEST_RESPONSE" | grep -q '"response"'; then
    log_ok "Test API réussi. Réponse reçue du modèle."
    ANSWER=$(echo "$TEST_RESPONSE" | python3 -c \
        "import sys,json; d=json.load(sys.stdin); print(d.get('response','')[:200])" 2>/dev/null \
        || echo "(parsing skipped)")
    echo ""
    echo -e "  ${GREEN}→ Réponse test :${NC} $ANSWER"
else
    log_warn "Test API : réponse inattendue. Vérifiez les logs : $LOG_FILE"
fi

# -----------------------------------------------------------------------------
# ÉTAPE 5 — Résumé
# -----------------------------------------------------------------------------
IP=$(hostname -I 2>/dev/null | awk '{print $1}' || echo "127.0.0.1")

echo ""
echo "============================================================"
echo -e "   ${GREEN}DÉPLOIEMENT RÉUSSI${NC}"
echo "============================================================"
echo ""
echo "  Serveur      : Ollama $OLLAMA_VERSION"
echo "  Modèle       : $MODEL_ALIAS (base: $MODEL_NAME)"
echo "  Endpoint     : http://localhost:${OLLAMA_PORT}"
echo "  API Generate : http://localhost:${OLLAMA_PORT}/api/generate"
echo "  API Chat     : http://localhost:${OLLAMA_PORT}/api/chat"
echo "  Logs         : $LOG_FILE"
echo ""
echo "  ► Pour l'équipe DEV WEB :"
echo "    URL de base : http://${IP}:${OLLAMA_PORT}"
echo "    Modèle à utiliser : ${MODEL_ALIAS}"
echo ""
echo "  ► Commandes utiles :"
echo "    ollama list                     # Lister les modèles"
echo "    ollama ps                       # Modèles en cours d'exécution"
echo "    ollama run ${MODEL_ALIAS}        # Test interactif CLI"
echo "    cat ./logs/ollama.pid           # PID du serveur"
echo "    ./scripts/stop_infra.sh         # Arrêt propre"
echo "    ./scripts/validate_infra.sh     # Validation complète"
echo ""
