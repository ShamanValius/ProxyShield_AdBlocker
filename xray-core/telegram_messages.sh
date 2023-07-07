#!/bin/bash

telegram_token=$(jq -r '.telegram_token' /opt/xray/default.json)
telegram_id=$(jq -r '.telegram_id' /opt/xray/default.json)

if [ $# -eq 1 ]; then
    text=$1
    curl -s -X POST -F "chat_id=$telegram_id" -F "text=$text" "https://api.telegram.org/bot$telegram_token/sendMessage" >/dev/null
elif [ $# -eq 2 ]; then
    text=$1
    file=$2

    if [ -f "$file" ]; then
        curl -s -X POST -F "chat_id=$telegram_id" -F "text=$text" "https://api.telegram.org/bot$telegram_token/sendMessage" >/dev/null
        curl -s -F "chat_id=$telegram_id" -F "photo=@$file" "https://api.telegram.org/bot$telegram_token/sendphoto" >/dev/null
    else
        echo "Файл не существует: $file"
    fi
else
    echo "Неверное количество параметров. Ожидается один параметр (текст) или два параметра (текст и файл)."
fi

exit 0