#!/bin/bash

set -ex

#========== Environment Checking ==========
if [ -z $DOMAIN ]; then
    echo '$DOMAIN must be set'
    exit 1
fi

#========== Generate certs is not exist ==========
export CERTS_PATH=/data/$DOMAIN/certs
export CLIENT_PATH=/data/$DOMAIN/bin

#Copy prepared certs to data
cp /certs /data

#If domain certs not exsits create one
if [ ! -d $CERTS_PATH ]; then
	mkdir -p $CERTS_PATH && cd $CERTS_PATH
	openssl genrsa -out rootCA.key 2048
	openssl req -x509 -new -nodes -key rootCA.key -subj "/CN=$DOMAIN" -days 5000 -out rootCA.pem
	openssl genrsa -out device.key 2048
	openssl req -new -key device.key -subj "/CN=$DOMAIN" -out device.csr
	openssl x509 -req -in device.csr -CA rootCA.pem -CAkey rootCA.key -CAcreateserial -out device.crt -days 5000
	rm -f $CERTS_PATH/build.lock
fi

#========== Build server ==========
cd /opt/ngrok
# make release-server

#========== build client ==========

mkdir -p assets/client/tls/
cp $CERTS_PATH/rootCA.pem assets/client/tls/ngrokroot.crt
for os in "darwin" "linux"; do
    for arch in "amd64"; do
        GOOS=$os GOARCH=$arch make release-client
    done
done

mkdir -p /data/$DOMAIN/bin
cp /opt/ngrok/bin/ngrok  $CLIENT_PATH/ngrok-linux-amd64
cp /opt/ngrok/bin/ngrokd $CLIENT_PATH/ngrokd-linux-amd64
for os in "darwin" "linux"; do
    for arch in "amd64"; do
        if [ -e /opt/ngrok/bin/${os}_${arch}/ngrok ]; then
            cp /opt/ngrok/bin/${os}_${arch}/ngrok $CLIENT_PATH/ngrok-${os}-${arch}
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