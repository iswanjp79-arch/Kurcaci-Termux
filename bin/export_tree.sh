#!/data/data/com.termux/files/usr/bin/bash
TREE_FILE="$HOME/JDEQ/TREE_L/tree_manifest.json"
mkdir -p ~/JDEQ/TREE_L

# Rekam struktur folder dan symlink
echo "{" > $TREE_FILE
echo '"source":"VIVO_Y28_64bit",' >> $TREE_FILE
echo '"timestamp":"'$(date)'",' >> $TREE_FILE
echo '"layers":{' >> $TREE_FILE

for L in SSOT CONSTITUTION router cognitive DAL SECURITY GOVERNANCE bridge; do
  echo "\"$L\":\"$(ls ~/JDEQ/$L/ 2>/dev/null | tr '\n' ' ')\"," >> $TREE_FILE
done

echo '"bin":"$(ls ~/JDEQ/bin/ | grep -E "auto_heal|reality|narrative|dual|lock|sync" | tr "\n" " ")"' >> $TREE_FILE
echo '}}' >> $TREE_FILE

echo "✅ Tree L1-L8 diekspor: $TREE_FILE"
# Kirim ke Infinix jika online
ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1 && \
  scp -P 8022 $TREE_FILE 100.103.39.81:~/JDEQ_CLONE/TREE_L/ 2>/dev/null && \
  echo "✅ Tree terkirim ke Infinix"
