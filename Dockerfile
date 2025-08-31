# Use Node.js 22 on Alpine
FROM node:22-alpine

# Install dependencies
RUN apk add --no-cache \
    graphicsmagick \
    git \
    openssh \
    tzdata \
    tini \
    bash \
    openssl \
    ca-certificates \
    libc6-compat \
    python3 \
    make \
    g++

# Create app dir
WORKDIR /data

# Install n8n globally
RUN npm install -g n8n

# Create user
#RUN  sudo addgroup -S node && sudo adduser -S node -G node
USER node

# Expose port
EXPOSE 5678

# Start n8n
ENTRYPOINT ["tini", "--", "n8n"]
