#!/usr/bin/env python3
"""Goal Continuity — Mengetahui tujuan aktif."""
import json
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
GOAL_FILE = JDEQ / "state" / "active_goals.json"

DEFAULT_GOALS = {
    "current_goal": "Membangun 9 Layer Consciousness",
    "next_goal": "Aktivasi penuh MICO Consciousness",
    "blocked_goal": None
}

class GoalContinuity:
    def __init__(self):
        self.goals = self._load()
    
    def _load(self):
        if GOAL_FILE.exists():
            return json.loads(GOAL_FILE.read_text())
        return DEFAULT_GOALS
    
    def set_goal(self, goal_type, description):
        self.goals[goal_type] = description
        GOAL_FILE.parent.mkdir(parents=True, exist_ok=True)
        GOAL_FILE.write_text(json.dumps(self.goals, indent=2))

if __name__ == "__main__":
    gc = GoalContinuity()
    print("Tujuan saat ini:", gc.goals["current_goal"])
    print("Tujuan berikutnya:", gc.goals["next_goal"])
