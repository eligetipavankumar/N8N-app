# Stage 1: Build dependencies
FROM node:22-alpine AS build

# Install build tools only here
RUN apk add --no-cache python3 make g++ git

WORKDIR /data
RUN npm install -g n8n

# Stage 2: Runtime image
FROM node:22-alpine

# Install only runtime deps
RUN apk add --no-cache graphicsmagick tzdata tini bash openssl ca-certificates

WORKDIR /data

# Copy n8n from build stage
COPY --from=build /usr/local/lib/node_modules /usr/local/lib/node_modules
COPY --from=build /usr/local/bin /usr/local/bin

USER node
EXPOSE 5678
ENTRYPOINT ["tini", "--", "n8n"]
