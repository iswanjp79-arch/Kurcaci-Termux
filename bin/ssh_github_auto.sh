#!/data/data/com.termux/files/usr/bin/bash
# Auto-rolling SSH key untuk GitHub
for KEY in ~/.ssh/id_ed25519_jdeq ~/.ssh/id_ed25519; do
    echo "Mencoba kunci: $KEY"
    ssh -i "$KEY" -o IdentitiesOnly=yes -T git@github.com 2>&1 | grep -q "successfully authenticated" && {
        echo "✅ Kunci valid: $KEY"
        git config --global core.sshCommand "ssh -i $KEY -o IdentitiesOnly=yes"
        exit 0
    }
done
echo "❌ Tidak ada kunci yang valid."
