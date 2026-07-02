#!/usr/bin/env python3
class GoalEngine:
    def map_goal(self, intent):
        goals = {"lihat":"CAPTURE_IMAGE","lapor":"GENERATE_REPORT"}
        return {"goal":goals.get(intent,"UNKNOWN")}
