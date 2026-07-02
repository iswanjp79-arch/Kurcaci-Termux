import os, json

def load_ssot_rules():
    """Muat aturan SSOT menyang dict sing bisa diwaca MICO."""
    rules = {}
    # 1. Aturan inti
    core_rule = os.path.expanduser("~/JDEQ/CORE_PROTOCOL/CORE_RULE.md")
    if os.path.isfile(core_rule):
        with open(core_rule) as f:
            rules["core_rule"] = f.read()
    # 2. Agent Registry
    agent_idx = os.path.expanduser("~/JDEQ/SSOT/AGENT_PROFILES/AGENT_INDEX.json")
    if os.path.isfile(agent_idx):
        with open(agent_idx) as f:
            rules["agent_registry"] = json.load(f)
    return rules
