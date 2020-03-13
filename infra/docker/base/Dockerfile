FROM node:13-alpine AS build-env
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY app/ ./
FROM gcr.io/distroless/nodejs
COPY --from=build-env /app /app
WORKDIR /app
EXPOSE 3000
ENV "NODE_PATH" "/app"