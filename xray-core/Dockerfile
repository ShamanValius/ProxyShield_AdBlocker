FROM ubuntu:22.04

# Установить зависимости
RUN apt-get update && \
	DEBIAN_FRONTEND=noninteractive apt-get install -y  \
	tzdata \
	curl \
	jq \
	openssl \
	qrencode \
	unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Установить часовой пояс
RUN ln -fs /usr/share/zoneinfo/UTC /etc/localtime && \
    dpkg-reconfigure --frontend noninteractive tzdata

# установка Xray-ядра
RUN curl -L -H "Cache-Control: no-cache" -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/download/v1.8.3/Xray-linux-64.zip && \
    unzip /tmp/xray.zip -d /opt/xray/ && \
    rm /tmp/xray.zip && \
    chmod +x /opt/xray/xray 

#конфигурация xray-reality
COPY ./config.json /opt/xray/config.json
COPY ./default.json /opt/xray/default.json
COPY ./configuration.sh /opt/xray/configuration.sh
RUN chmod +x /opt/xray/configuration.sh && \
	/opt/xray/configuration.sh

# Телеграм сообщение с конфигом для клиента
COPY ./telegram_messages.sh /opt/xray/telegram_messages.sh
RUN chmod +x /opt/xray/telegram_messages.sh

# # Запустить Xray-ядро и отправить сообщение
# CMD /opt/xray/telegram_messages.sh $(cat ./opt/xray/URL_CONFIG_KLIENT.txt) /opt/xray/qr.png && /opt/xray/xray -config /opt/xray/config.json

# Запустить Xray-ядро без отправки сообщения
CMD cat ./opt/xray/URL_CONFIG_KLIENT.txt && \
	qrencode -s 120 -t ANSIUTF8 $(cat /opt/xray/URL_CONFIG_KLIENT.txt) && \
	/opt/xray/xray -config /opt/xray/config.json

EXPOSE 3971


