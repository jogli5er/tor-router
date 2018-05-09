FROM node:9.7

WORKDIR /app

EXPOSE 9050

EXPOSE 53

EXPOSE 9077

ENV PATH $PATH:/app/bin

RUN apt update && apt -y install dirmngr

RUN apt install -y tor git

ADD package.json /app/package.json

RUN npm install

ADD . /app

ENTRYPOINT [ "tor-router" ]

CMD [ "-s", "-d", "-j", "1" ]