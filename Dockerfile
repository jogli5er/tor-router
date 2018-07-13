FROM ubuntu:18.04

WORKDIR /app

EXPOSE 9050

EXPOSE 53

EXPOSE 9077

ENV PARENT_DATA_DIRECTORTY /var/lib/tor-router

ENV TOR_PATH /usr/bin/tor

ENV PATH $PATH:/app/bin 

ADD https://deb.nodesource.com/setup_8.x /tmp/nodejs_install

RUN apt-get update && apt-get -y install dirmngr

RUN gpg --keyserver keys.gnupg.net --recv A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 && gpg --export A3C4F0F979CAA22CDBA8F512EE8CBC9E886DDD89 | apt-key add -

RUN echo 'deb http://deb.torproject.org/torproject.org artful main\n\
\n\
deb-src http://deb.torproject.org/torproject.org artful main'\
>> /etc/apt/sources.list.d/tor.list

RUN bash /tmp/nodejs_install

RUN apt-get install -y nodejs tor git

RUN useradd -ms /bin/bash tor_router

RUN chown -hR tor_router:tor_router /app

USER tor_router

ADD package.json /app/package.json

RUN npm install

ADD . /app

ENV HOME /home/tor_router

ENTRYPOINT [ "tor-router" ]

CMD [ "-s", "-d", "-j", "10" ]
