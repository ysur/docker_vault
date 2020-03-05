## CONFIG LOCAL ENV
echo "[*] Config local environment..."
export VAULT_ADDR=http://127.0.0.1:8200
alias vault="docker-compose --no-ansi exec -e VAULT_CLI_NO_COLOR=1 -e VAULT_ADDR=$VAULT_ADDR vault vault \"\$@\""

## INIT VAULT
echo "[*] Init vault..."
vault operator init -address=${VAULT_ADDR} > ./_data/keys.txt
export VAULT_TOKEN=$(grep 'Initial Root Token:' ./_data/keys.txt | awk '{print substr($NF, 1, length($NF)-1)}')

## UNSEAL VAULT
echo "[*] Unseal vault..."
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 1:' ./_data/keys.txt | awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 2:' ./_data/keys.txt | awk '{print $NF}')
vault operator unseal -address=${VAULT_ADDR} $(grep 'Key 3:' ./_data/keys.txt | awk '{print $NF}')

## AUTH
echo "[*] Auth..."
vault login -address=${VAULT_ADDR} token=${VAULT_TOKEN}

## CREATE USER
echo "[*] Create user... Remember to change the defaults!!"
vault auth enable  -address=${VAULT_ADDR} userpass
vault policy write -address=${VAULT_ADDR} admin ./config/admin.hcl
vault write -address=${VAULT_ADDR} auth/userpass/users/webui password=webui policies=admin

## CREATE BACKUP TOKEN
echo "[*] Create backup token..."
vault token create -address=${VAULT_ADDR} -display-name="backup_token" | awk '/token/{i++}i==2' | awk '{print "backup_token: " $2}' >> ./_data/keys.txt

## Secrets engine
echo "[*] Creating new kv secrets engine..."
vault secrets enable -address=${VAULT_ADDR} -path=assessment -description="Secrets used in the assessment" kv
vault write  -address=${VAULT_ADDR} assessment/server1_ad value1=name value2=pwd

## READ/WRITE
# $ vault write -address=${VAULT_ADDR} secret/api-key value=12345678
# $ vault read -address=${VAULT_ADDR} secret/api-key
