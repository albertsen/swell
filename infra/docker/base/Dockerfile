FROM node:13-alpine AS build-env
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY app/ ./