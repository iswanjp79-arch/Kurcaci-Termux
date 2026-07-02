#!/data/data/com.termux/files/usr/bin/bash
echo "============================================"
echo " VERIFIKASI TREE L1-L8 (VIVO vs INFINIX)"
echo "============================================"
echo "VIVO (64-bit):"
for L in SSOT CONSTITUTION router cognitive DAL SECURITY GOVERNANCE bridge; do
  echo "  L-$L: $(ls ~/JDEQ/$L/ 2>/dev/null | wc -l) file"
done

echo ""
echo "INFINIX (32-bit):"
if ping -c 1 -W 1 100.103.39.81 > /dev/null 2>&1; then
  ssh -p 8022 100.103.39.81 'for L in SSOT CONSTITUTION router cognitive DAL SECURITY GOVERNANCE bridge; do echo "  L-$L: $(ls ~/JDEQ_CLONE/$L/ 2>/dev/null | wc -l) file"; done' 2>/dev/null || echo "  ⚠️ SSH gagal"
else
  echo "  ⚠️ Infinix offline — verifikasi nanti"
fi
echo "============================================"
