FROM ubuntu:16.04

# install dependencies (make, add-apt-repository, git)
RUN apt update && apt install -y build-essential software-properties-common git

# install golang
RUN add-apt-repository ppa:longsleep/golang-backports && \
	apt-get update && \
	apt-get -y install golang-go

# clone ngrok source
RUN cd /opt &&\
	git clone https://github.com/inconshreveable/ngrok.git ngrok && \
	cd ngrok && \
	make deps && \
	make bin/go-bindata


ADD static_server.go /opt
ADD entrypoint.sh /opt

ENTRYPOINT ["/opt/entrypoint.sh"]
