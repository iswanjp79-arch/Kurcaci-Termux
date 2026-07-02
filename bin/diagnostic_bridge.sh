#!/data/data/com.termux/files/usr/bin/bash
LOG="$HOME/JDEQ/logs/diagnostic_$(date +%Y%m%d_%H%M).log"
stamp() { echo "[$(date '+%H:%M:%S')] $1" | tee -a $LOG; }

stamp "===== DIAGNOSTIC PONT MICO ====="

# 1. Vérifier le pont Node.js
stamp "1. Vérification du pont Node.js..."
if pgrep -f "pocketpal_node.js" > /dev/null; then
    stamp "✅ Pont Node.js actif"
else
    stamp "❌ Pont Node.js arrêté - Redémarrage..."
    nohup node ~/JDEQ/bridge/pocketpal_node.js > /dev/null 2>&1 &
    sleep 2
    pgrep -f "pocketpal_node.js" > /dev/null && stamp "✅ Pont redémarré" || stamp "❌ Échec du redémarrage"
fi

# 2. Vérifier le LLM (llama-server)
stamp "2. Vérification du LLM..."
if pgrep llama-server > /dev/null; then
    stamp "✅ LLM (llama-server) actif"
else
    stamp "❌ LLM arrêté - Redémarrage..."
    nohup llama-server -m ~/JDEQ/models/mico.gguf --port 8082 -ngl 99 > /dev/null 2>&1 &
    sleep 5
    pgrep llama-server > /dev/null && stamp "✅ LLM redémarré" || stamp "❌ Échec du redémarrage LLM"
fi

# 3. Tester la connexion locale
stamp "3. Test de connexion locale..."
RESPONSE=$(curl -s --max-time 10 -X POST http://localhost:9090/v1/chat/completions \
  -H "Content-Type: application/json" \
  -d '{"messages":[{"role":"user","content":"1+1"}],"max_tokens":10}')
if echo "$RESPONSE" | grep -q "2"; then
    stamp "✅ Réponse correcte du pont"
elif echo "$RESPONSE" | grep -q "Qwen"; then
    stamp "⚠️ Le pont répond mais semble utiliser Qwen au lieu de MICO"
else
    stamp "❌ Le pont ne répond pas correctement"
    echo "   Réponse: $RESPONSE" >> $LOG
fi

# 4. Vérifier le modèle utilisé
stamp "4. Vérification du modèle..."
if [ -f ~/JDEQ/models/mico.gguf ]; then
    stamp "✅ Modèle mico.gguf trouvé"
    ls -la ~/JDEQ/models/mico.gguf | tee -a $LOG
else
    stamp "❌ Modèle mico.gguf introuvable"
    find ~/JDEQ/models -name "*.gguf" 2>/dev/null | head -5 | tee -a $LOG
fi

stamp "===== FIN DU DIAGNOSTIC ====="
echo "📋 Rapport: $LOG"
