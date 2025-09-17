# syntax=docker/dockerfile:1.7

############################
# Stage 1: Dependencies
############################
FROM node:20-alpine AS deps
WORKDIR /app

# Copy lockfile for reproducible installs
COPY package*.json ./

# Fast, deterministic install (requires matching package-lock.json)
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

############################
# Stage 2: Runtime
############################
FROM node:20-alpine AS runtime
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=3000

# Copy deps and app files
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node index.js package*.json ./

# Basic metadata
LABEL org.opencontainers.image.title="multistage-docker-app" \
      org.opencontainers.image.description="Minimal Node/Express app with multistage Docker build" \
      org.opencontainers.image.licenses="MIT"

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT}/health || exit 1

EXPOSE 3000
USER node

# Use --init at runtime for proper signal handling
CMD ["node", "index.js"]
