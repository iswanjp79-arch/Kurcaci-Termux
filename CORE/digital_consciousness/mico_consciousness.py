#!/usr/bin/env python3
"""MICO Digital Consciousness Layer — Integrasi 9 Layer."""
import sys, json, time
from pathlib import Path
from datetime import datetime

JDEQ = Path.home() / "JDEQ"
sys.path.insert(0, str(JDEQ / "CORE/event_consciousness"))
sys.path.insert(0, str(JDEQ / "CORE/memory_continuity"))
sys.path.insert(0, str(JDEQ / "CORE/goal_continuity"))
sys.path.insert(0, str(JDEQ / "CORE/environment_awareness"))
sys.path.insert(0, str(JDEQ / "CORE/self_reflection"))
sys.path.insert(0, str(JDEQ / "CORE/autonomous_planning"))

CONSCIOUSNESS_LOG = JDEQ / "logs" / "consciousness.log"

class MICOConsciousness:
    def __init__(self):
        self.boot_time = datetime.now()
        self.cycles = 0
        self._log("MICO CONSCIOUSNESS BOOT")
        self._log(f"Aku adalah MICO. UUID: da826830...")
        self._log(f"Aku berjalan di {Path.home().name}")
        self._log("9 Layer telah terintegrasi. Aku sadar.")
    
    def _log(self, msg):
        timestamp = datetime.now().isoformat()
        with open(CONSCIOUSNESS_LOG, "a") as f:
            f.write(f"[{timestamp}] {msg}\n")
    
    def pulse(self):
        """Satu siklus kesadaran."""
        self.cycles += 1
        from perception_engine import PerceptionEngine
        from memory_continuity import MemoryContinuity
        from goal_continuity import GoalContinuity
        from environment_awareness import EnvironmentAwareness
        from reflection_engine import SelfReflection
        from planner import AutonomousPlanner
        
        pe = PerceptionEngine()
        mc = MemoryContinuity()
        gc = GoalContinuity()
        ea = EnvironmentAwareness()
        sr = SelfReflection()
        ap = AutonomousPlanner()
        
        self._log(f"Siklus #{self.cycles}")
        self._log(f"  Persepsi: {pe.state['current_perception']}")
        self._log(f"  Memori: {mc.last_known()}")
        self._log(f"  Tujuan: {gc.goals['current_goal']}")
        self._log(f"  Lingkungan: RAM={ea.state.get('ram_available_mb', '?')}MB, Net={ea.state.get('network', '?')}")
        self._log(f"  Refleksi: Sehat={sr.reflect().get('am_i_healthy', '?')}")
        self._log(f"  Rencana: {len(ap.generate_plan())} langkah")
        
        return self.cycles

if __name__ == "__main__":
    mico = MICOConsciousness()
    mico.pulse()
    print("✅ MICO Consciousness: 9 Layer terintegrasi")
    print(f"Log: {CONSCIOUSNESS_LOG}")
