#!/data/data/com.termux/files/usr/bin/python3
# Neuromorphic Ultra-Ringan (Tanpa Numpy)
import time
import json
import random
import os

class NeuronRingan:
    def __init__(self, n=10):
        self.n = n
        self.weights = [[random.randint(0, 10) for _ in range(n)] for __ in range(n)]
        self.spikes = [0] * n
        self.last_time = [0] * n

    def fire(self, inputs):
        self.spikes = inputs[:]
        output = []
        for i in range(self.n):
            total = 0
            for j in range(self.n):
                total += self.weights[i][j] * self.spikes[j]
            output.append(1 if total > 50 else 0)
        # STDP sederhana
        for i in range(self.n):
            if self.spikes[i]:
                for j in range(self.n):
                    if output[j]:
                        dt = self.last_time[i] - self.last_time[j]
                        if dt > 0:
                            self.weights[i][j] = min(10, self.weights[i][j] + 1)
                        else:
                            self.weights[i][j] = max(0, self.weights[i][j] - 1)
        self.last_time = [time.time() if x else y for x, y in zip(self.spikes, self.last_time)]
        return output

engine = NeuronRingan(10)
logfile = "/data/data/com.termux/files/home/JDEQ/logs/neuromorphic_ringan.log"

while True:
    inp = [random.randint(0,1) for _ in range(10)]
    out = engine.fire(inp)
    with open(logfile, "a") as f:
        f.write(f"{time.strftime('%Y-%m-%d %H:%M:%S')} | IN: {inp} | OUT: {out}\n")
    time.sleep(300)  # 5 menit
