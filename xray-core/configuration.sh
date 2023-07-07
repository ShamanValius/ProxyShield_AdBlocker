#!/bin/bash

# Извлеките нужные переменные с помощью jq
name=$(jq -r '.name' /opt/xray/default.json)
email=$(jq -r '.email' /opt/xray/default.json)
port=$(jq -r '.port' /opt/xray/default.json)
sni=$(jq -r '.sni' /opt/xray/default.json)
path=$(jq -r '.path' /opt/xray/default.json)

# Генерация нужных переменных
keys=$(/opt/xray/xray x25519)
pk=$(echo "$keys" | awk '/Private key:/ {print $3}')
pub=$(echo "$keys" | awk '/Public key:/ {print $3}')
serverIp=$(curl -s ipv4.wtfismyip.com/text)
uuid=$(/opt/xray/xray uuid)
shortId=$(openssl rand -hex 8)

# Чтение шаблона
json=$(cat /opt/xray/config.json)

# Создание и запись конфигурационного файла
newJson=$(echo "$json" | jq \
    --arg pk "$pk" \
    --arg uuid "$uuid" \
    --arg port "$port" \
    --arg sni "$sni" \
    --arg path "$path" \
    --arg email "$email" \
    '.inbounds[0].port= '"$(expr "$port")"' |
     .inbounds[0].settings.clients[0].email = $email |
     .inbounds[0].settings.clients[0].id = $uuid |
     .inbounds[0].streamSettings.realitySettings.dest = $sni + ":443" |
     .inbounds[0].streamSettings.realitySettings.serverNames = ["'$sni'"] |
     .inbounds[0].streamSettings.realitySettings.privateKey = $pk |
     .inbounds[0].streamSettings.realitySettings.shortIds = ["'$shortId'"]')

echo "$newJson" | tee /opt/xray/config.json >/dev/null

# Создание переменной окружения конфигурационной ссылки для клиента
url=$"vless://$uuid@$serverIp:$port?type=tsp&security=reality&encryption=tls&alpn="h2"&pbk=$pub&flow="xtls-rprx-vision"&fp=chrome&path=$path&sni=$sni&sid=$shortId#$name"
echo $url > /opt/xray/URL_CONFIG_KLIENT.txt
qrencode -s 50 -o /opt/xray/qr.png "$url"

exit 0