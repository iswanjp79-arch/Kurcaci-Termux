"""Lapis 1 – Lingkungan Hidup JDEQ (OS, Runtime, Database)"""
import os, platform, sys, sqlite3

def get_env_info():
    return {
        "os": platform.system(),
        "os_version": platform.version(),
        "python": sys.version,
        "termux": os.path.isdir("/data/data/com.termux/files"),
        "debian_proot": os.path.isdir("/data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/debian"),
        "sqlite": sqlite3.sqlite_version
    }

def check_storage():
    stat = os.statvfs("/data/data/com.termux/files/home")
    total = stat.f_frsize * stat.f_blocks
    free = stat.f_frsize * stat.f_bavail
    return {
        "total_gb": total / (1024**3),
        "free_gb": free / (1024**3),
        "used_percent": round((1 - free/total) * 100, 1) if total else 0
    }

if __name__ == "__main__":
    print("ENV:", get_env_info())
    print("STORAGE:", check_storage())
