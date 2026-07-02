"""Jembatan antar lapis: Memory, PEP DNA, Workflow Arteri-Vena"""
import os, json

JDEQ = "/data/data/com.termux/files/home/JDEQ"

def load_pep():
    path = os.path.join(JDEQ, "ORCHESTRATOR/PEP_DNA.json")
    if os.path.isfile(path):
        with open(path) as f:
            return json.load(f)
    return None

def load_workflow():
    path = os.path.join(JDEQ, "ORCHESTRATOR/WORKFLOW_ARTERI.json")
    if os.path.isfile(path):
        with open(path) as f:
            return json.load(f)
    return None

def load_agent_registry():
    path = os.path.join(JDEQ, "ORCHESTRATOR/AGENT_REGISTRY.json")
    if os.path.isfile(path):
        with open(path) as f:
            return json.load(f)
    return None
