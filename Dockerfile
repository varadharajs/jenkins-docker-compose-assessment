FROM node:20-alpine

WORKDIR /app

RUN apk update && apk upgrade --no-cache

COPY app/package*.json ./

RUN npm install --omit=dev

COPY app/ .

EXPOSE 3000

USER node

CMD ["node", "server.js"]
