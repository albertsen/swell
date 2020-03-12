FROM swell-base AS build-env
FROM gcr.io/distroless/nodejs
COPY --from=build-env /app /app
WORKDIR /app
EXPOSE 3000
ENV "NODE_PATH" "/app"
CMD ["services/workflowService.js"]