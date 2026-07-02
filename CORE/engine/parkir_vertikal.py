import os, json

PARKIR_STATE = os.path.expanduser("~/JDEQ/CORE_ENGINE/parkir_state.json")

# Status modul: bisa diowahi manual utawa dening MICO
default_state = {
    "wbs": "SIAGA",
    "cpm": "SIAGA",
    "rab": "SIAGA",
    "evm": "SIAGA",
    "dashboard": "AKTIF",
    "supervisor": "AKTIF"
}

if not os.path.isfile(PARKIR_STATE):
    with open(PARKIR_STATE, "w") as f:
        json.dump(default_state, f, indent=2)
    print("✔ Parkir state awal digawe.")

def set_status(modul, status):
    valid = ["AKTIF", "SIAGA", "TIDUR", "ARSIP"]
    if status not in valid:
        return False
    with open(PARKIR_STATE, "r") as f:
        state = json.load(f)
    if modul in state:
        state[modul] = status
        with open(PARKIR_STATE, "w") as f:
            json.dump(state, f, indent=2)
        return True
    return False
