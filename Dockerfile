FROM node:carbon

ENV TOR_VER="release-0.3.3"

ENV TERM=xterm\
	TOR_DIR=/tor

RUN apt update && \
	build_temps="build-essential automake libssl-dev zlib1g-dev libevent-dev libseccomp-dev dh-apparmor dh-systemd git" && \
	build_deps="libseccomp2 libevent-2.0-5 zlib1g  ca-certificates pwgen init-system-helpers" && \
	DEBIAN_FRONTEND=noninteractive apt-get -y --no-install-recommends install $build_deps $build_temps && \
	mkdir /src && \
	cd /src && \
	git clone https://git.torproject.org/tor.git && \
	cd tor && \
	git checkout ${TOR_VER} && \
	./autogen.sh && \
	./configure --disable-asciidoc && \
	make && \
	make install && \
	apt-get -y purge --auto-remove $build_temps && \
	apt-get -y --no-install-recommends install $build_deps && \
	apt-get clean && rm -r /var/lib/apt/lists/* && \
	rm -rf /src/*

RUN mkdir ${TOR_DIR}

WORKDIR /app

EXPOSE 9050

EXPOSE 53

EXPOSE 9077

ENV PATH $PATH:/app/bin

RUN apt update && apt -y install dirmngr

RUN apt install -y -qq git

ADD package.json /app/package.json

RUN npm install

ADD . /app

ENTRYPOINT [ "tor-router" ]

CMD [ "-s", "-d", "-j", "10" ]
