#!/data/data/com.termux/files/usr/bin/bash
# FALLBACK API – GANTI MICO_URL KE DEEPSEEK JIKA QWEN CRASH

cd ~/JDEQ || exit
cp mico_chat.py mico_chat.py.bak.fallback

sed -i 's|MICO_URL = .*|MICO_URL = "https://api.deepseek.com/v1/chat/completions"|' mico_chat.py
sed -i 's|"model": "Qwen2.5-3B-Instruct-Q4_K_M.gguf"|"model": "deepseek-chat"|' mico_chat.py

# Tambahkan header Authorization (tempatkan di fungsi tanya)
echo "⚠️  Anda HARUS mengisi API key di mico_chat.py (cari 'Authorization')."
echo "   Contoh: 'Authorization': 'Bearer sk-...'"
echo "✅ Fallback API siap."
