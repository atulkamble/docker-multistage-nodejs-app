# syntax=docker/dockerfile:1.7

############################
# Stage 1: Dependencies
############################
FROM node:20-alpine AS deps
WORKDIR /app

# Leverage BuildKit cache for npm
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm       npm ci --omit=dev

############################
# Stage 2: Runtime
############################
FROM node:20-alpine AS runtime
WORKDIR /app

# Security: drop privileges
ENV NODE_ENV=production
ENV PORT=3000

# Copy only what we need, keep ownership minimal
COPY --from=deps /app/node_modules ./node_modules
COPY --chown=node:node index.js package*.json ./

# Labels (OCI)
LABEL org.opencontainers.image.source="https://example.com/your-repo" \
      org.opencontainers.image.title="multistage-docker-app" \
      org.opencontainers.image.description="Minimal Node/Express app with multistage Docker build" \
      org.opencontainers.image.licenses="MIT"

# Healthcheck (busybox wget available in Alpine)
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 \
  CMD wget -qO- http://127.0.0.1:${PORT}/health || exit 1

EXPOSE 3000
USER node

# Use tini-like init with docker run --init (recommended)
CMD ["node", "index.js"]
