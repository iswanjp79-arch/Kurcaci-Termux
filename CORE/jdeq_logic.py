"""JDEQ QUANTUM LOGIC — Protokol 10-5-3-1"""
class JDEQQuantumLogic:
    def __init__(self):
        self.priority = {1: "EMERGENCY", 2: "INCOME", 3: "MAINTENANCE"}
    
    def evaluate(self, sensors):
        batt = sensors.get('battery', 100)
        clip = sensors.get('clipboard', '')
        if "project" in clip.lower() or "order" in clip.lower():
            return {"path": "INCOME", "action": "GENERATE_PROPOSAL", "priority": 1}
        if batt < 15:
            return {"path": "POWER_SAVE", "action": "HIBERNATE", "priority": 2}
        return {"path": "MONITOR", "action": "IDLE", "priority": 3}
