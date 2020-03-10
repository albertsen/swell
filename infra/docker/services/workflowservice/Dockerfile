FROM node:alpine
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY app/ ./
EXPOSE 3000
ENV "NODE_PATH" "/app"
CMD [ "node", "services/workflowService.js" ]