import json
import re
import os

REGISTRY_FILE = os.path.expanduser("~/JDEQ/CORE_ORCHESTRATION/agent_registry.json")

def load_registry():
    try:
        with open(REGISTRY_FILE, 'r') as f:
            return json.load(f)
    except:
        return {"routing_rules": {"contains": {}, "default": "local"}}

def classify_intent(user_input):
    registry = load_registry()
    rules = registry.get("routing_rules", {}).get("contains", {})
    for pattern, agent in rules.items():
        if re.search(pattern, user_input, re.IGNORECASE):
            return agent
    return rules.get("default", "local")
