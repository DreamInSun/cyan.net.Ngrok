#!/bin/bash

set -ex

#========== Environment Checking ==========
if [ -z $DOMAIN ]; then
    echo '$DOMAIN must be set'
    exit 1
fi

#========== Generate certs is not exist ==========
if [ ! -d "/data/$DOMAIN/certs" ]; then
	mkdir -p /data/$DOMAIN/certs && cd /data/$DOMAIN/certs
	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$DOMAIN" -days 5000 -out rootCA.pem
	openssl genrsa -out device.key 2048
	openssl req -new -key device.key -subj "/CN=$DOMAIN" -out device.csr
	openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000
fi

#========== Build server ==========
# cd /opt/ngrok && make release-server

#========== build client ==========
cp /data/$DOMAIN/certs/rootCA.pem assets/client/tls/ngrokroot.crt
for os in "darwin" "linux" "windows"; do
    for arch in "amd64"; do
        GOOS=$os GOARCH=$arch make release-client
    done
done

mkdir -p /data/$DOMAIN/bin
cp /opt/ngrok/bin/ngrok  /data/$DOMAIN/bin/ngrok-linux-amd64
cp /opt/ngrok/bin/ngrokd /data/$DOMAIN/bin/ngrokd-linux-amd64
for os in "darwin" "linux" "windows"; do
    for arch in "amd64"; do
        if [ -e /opt/ngrok/bin/${os}_${arch}/ngrok ]; then
            cp /opt/ngrok/bin/${os}_${arch}/ngrok /data/$DOMAIN/bin/ngrok-${os}-${arch}
        fi
    done
done

#========== Start server ==========
nohup go run /opt/static_server.go >> static_server.log 2>&1 &

./bin/ngrokd -tlsKey=/data/${DOMAIN}/certs/device.key \
    -tlsCrt=/data/${DOMAIN}/certs/device.crt \
    -domain="${DOMAIN}" \
    -httpAddr=":${HTTP_PORT}" \
    -httpsAddr=":${HTTPS_PORT}"