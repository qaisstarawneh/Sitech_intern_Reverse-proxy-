FROM node:16.0.0-slim@sha256:72f3771ce23f359ab17776aeff1a59d5ed309d00dbfa3259664c5e8a7cdefddb 
WORKDIR /usr/src/app

COPY package*.json ./
RUN npm install
COPY . .
RUN useradd -r -s /bin/false qais
USER qais
ENTRYPOINT [ "node", "server.js" ]
