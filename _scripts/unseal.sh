## CONFIG LOCAL ENV
echo "[*] Config local environment..."
export VAULT_ADDR=http://127.0.0.1:8200
alias vault="docker-compose --no-ansi exec -e VAULT_CLI_NO_COLOR=1 -e VAULT_ADDR=$VAULT_ADDR vault vault \"\$@\""

## UNSEAL VAULT
echo "[*] Unseal vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' ./_data/keys.txt | awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' ./_data/keys.txt | awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' ./_data/keys.txt | awk '{print $NF}')
