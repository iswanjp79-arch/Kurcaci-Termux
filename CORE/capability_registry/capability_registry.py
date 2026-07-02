#!/usr/bin/env python3
class CapabilityRegistry:
    def __init__(self): self.cap={"CAPTURE_IMAGE":"camera_capture","GENERATE_REPORT":"report_generator"}
    def resolve(self, goal): return {"capability":self.cap.get(goal,"UNKNOWN")}
