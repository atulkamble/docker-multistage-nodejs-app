# syntax=docker/dockerfile:1.7

############################
# Stage 1: Dependencies
############################
FROM node:20-alpine AS deps
WORKDIR /app

# Copy ONLY package.json so we don't rely on a lockfile
COPY package.json ./

# Use cached npm directory for faster rebuilds
RUN --mount=type=cache,target=/root/.npm \
    npm install --omit=dev

############################
# Stage 2: Runtime
############################
FROM node:20-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Bring in production node_modules from deps stage
COPY --from=deps /app/node_modules ./node_modules

# Copy app source
COPY --chown=node:node index.js package.json ./

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT}/health || exit 1

EXPOSE 3000
USER node

CMD ["node", "index.js"]
