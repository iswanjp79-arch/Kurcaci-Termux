from fastapi import FastAPI
app = FastAPI()

@app.get("/")
def home():
    return {"status": "MICO-JDEQ ONLINE", "version": "V7"}

@app.get("/health")
def health():
    import os
    return {
        "ssot": os.path.exists(os.path.expanduser("~/JDEQ/SSOT")),
        "kernel": "active",
        "vivo": "100.123.232.84",
        "infinix": "100.103.39.81"
    }
