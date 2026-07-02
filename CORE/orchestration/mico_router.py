import json, subprocess, sys, os
JDEQ = os.path.expanduser("~/JDEQ")
REGISTRY_FILE = os.path.join(JDEQ, "CORE_ORCHESTRATION", "agent_registry.json")
EXECUTOR_DIR = os.path.join(JDEQ, "CORE_ORCHESTRATION", "executors")

def load_registry():
    with open(REGISTRY_FILE, 'r') as f: return json.load(f)

def classify_intent(user_input):
    registry = load_registry()
    rules = registry.get("routing_rules", {}).get("contains", {})
    for pattern, agent in rules.items():
        import re
        if re.search(pattern, user_input, re.IGNORECASE):
            return agent
    return rules.get("default", "qwen")

def route_task(user_input):
    agent_name = classify_intent(user_input)
    registry = load_registry()
    agents = registry.get("agents", {})
    agent = agents.get(agent_name, agents.get("qwen", {}))
    executor = agent.get("executor", "local_qwen.sh")
    if executor.startswith("executors/"):
        executor_path = os.path.join(EXECUTOR_DIR, os.path.basename(executor))
        if os.path.exists(executor_path) and os.access(executor_path, os.X_OK):
            try:
                result = subprocess.run([executor_path, user_input], capture_output=True, text=True, timeout=120)
                return result.stdout.strip() or "Tidak ada output"
            except subprocess.TimeoutExpired:
                return "Timeout (120 detik)"
            except Exception as e:
                return f"Error: {str(e)}"
        else:
            return f"Executor {executor} tidak ditemukan"
    # fallback ke Qwen lokal
    cmd = f'timeout 60 curl -s -X POST http://127.0.0.1:8082/completion -H "Content-Type: application/json" -d \'{{"prompt":"{user_input}","n_predict":30}}\''
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True, timeout=65)
        if result.stdout:
            try:
                data = json.loads(result.stdout)
                return data.get("content", "Tidak ada konten")
            except:
                return result.stdout[:200]
        return "Tidak ada respons dari server"
    except:
        return "Timeout server lokal"

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Gunakan: mico_router.py 'perintah'")
        sys.exit(1)
    user_input = " ".join(sys.argv[1:])
    print(route_task(user_input))
