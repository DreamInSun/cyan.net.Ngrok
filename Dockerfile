#cyan-net-Ngrok

#===== Image information =====
FROM ubuntu:16.04
MAINTAINER DreamInSun<yancy_chen@hotmail.com>

#===== Environment =====
ENV		DOMAIN 		example.cyan.cc
ENV		HTTP_PORT	80
ENV 	HTTPS_PORT	443

#===== install dependencies =====
RUN apt update && apt install -y build-essential software-properties-common git

#===== install golang =====
RUN add-apt-repository ppa:longsleep/golang-backports && \
	apt-get update && \
	apt-get -y install golang-go

#===== clone ngrok source =====

# Clone Nrgok Git
RUN git clone https://github.com/inconshreveable/ngrok.git /opt/ngrok
WORKDIR /opt/ngrok

# Make Depence
RUN make deps && \
	make bin/go-bindata

# Prebuild Server 
RUN make release-server

ADD static_server.go /opt

# Entry Point
ADD entrypoint.sh /opt
RUN chmod a+x /opt/entrypoint.sh

#===== Copy Certs =====
ADD pre_build /pre_build

#===== Exppose =====
# DDNS port
EXPOSE 80
EXPOSE 443

# Ngrok port 
EXPOSE 4443
EXPOSE 4040

#===== Start =====
ENTRYPOINT ["/opt/entrypoint.sh"]
