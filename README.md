# 🚀 Node.js Multistage Docker Project

## 📁 Project Structure

```
multistage-docker-app/
├── Dockerfile
├── docker-compose.yml
├── .dockerignore
├── package.json
├── package-lock.json
└── index.js
```

---

## 📄 `package.json` (unchanged, but lockfile REQUIRED)

```json
{
  "name": "multistage-docker-app",
  "version": "1.0.0",
  "main": "index.js",
  "scripts": {
    "start": "node index.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
```

> Tip: Commit `package-lock.json` for reproducible, cache-friendly builds.

---

## 📄 `index.js` (adds /health + graceful shutdown)

```javascript
const express = require('express');
const app = express();

// Config via env (overrideable at runtime)
const PORT = process.env.PORT || 3000;
const MSG  = process.env.MESSAGE || 'Hello from Multistage Docker Build!';

// Routes
app.get('/', (_req, res) => res.send(MSG));
app.get('/health', (_req, res) => res.status(200).json({ status: 'ok' }));

const server = app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
});

// Graceful shutdown
const shutdown = (signal) => () => {
  console.log(`\n${signal} received, shutting down gracefully...`);
  server.close(() => {
    console.log('HTTP server closed.');
    process.exit(0);
  });
  // Force exit if not closed in time
  setTimeout(() => process.exit(1), 10000).unref();
};

['SIGTERM', 'SIGINT'].forEach(sig => process.on(sig, shutdown(sig)));
```

---

## 📄 `.dockerignore` (keeps image tiny & builds fast)

```
.git
node_modules
npm-debug.log
Dockerfile
docker-compose.yml
README.md
*.md
.env
.vscode
.DS_Store
```

---

## 📄 Multistage `Dockerfile` (fast, minimal, secure)

```dockerfile
# syntax=docker/dockerfile:1.7

############################
# Stage 1: Dependencies
############################
FROM node:20-alpine AS deps
WORKDIR /app

# Leverage BuildKit cache for npm
COPY package*.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci --omit=dev

############################
# Stage 2: Runtime
############################
FROM node:20-alpine AS runtime
WORKDIR /app

# Security: drop privileges
# Use the built-in 'node' user that exists in the official image
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
```

**Why these choices**

* `npm ci --omit=dev` → reproducible, lean dep tree.
* BuildKit cache → big speedups on repeated builds.
* Non-root `USER node` → safer containers.
* `HEALTHCHECK` → container orchestration can detect bad instances.
* COPY minimal files → smaller surface + better cache hits.

---

## 🧪 Compose for Local Dev (`docker-compose.yml`)

```yaml
version: "3.9"
services:
  app:
    build:
      context: .
    image: multistage-docker-app:latest
    container_name: multistage-app
    ports:
      - "3000:3000"
    environment:
      - PORT=3000
      - MESSAGE=Hello from Compose!
    # Better signal handling for Node:
    init: true
    restart: unless-stopped
```

---

## 🏗️ Build & Run

### Build (local)

```bash
docker build -t multistage-docker-app .
```

### Run (simple)

```bash
docker run -d --name my-multistage-app -p 3000:3000 --init multistage-docker-app
```

> `--init` adds a tiny init process for proper signal handling & zombie reaping.

### Run (with env override)

```bash
docker run -d --name my-multistage-app \
  -e PORT=3000 -e MESSAGE="Namaste, Atul!" \
  -p 3000:3000 --init multistage-docker-app
```

### Using Compose (recommended for dev)

```bash
docker compose up --build -d
docker compose logs -f app
```

Open:

* App: [http://localhost:3000](http://localhost:3000)
* Health: [http://localhost:3000/health](http://localhost:3000/health)

---

## ⚡ Faster, Smaller, Safer — Why This Is Better

* **Reproducible installs** with `npm ci` + lockfile.
* **Layer caching** via BuildKit cache mounts (faster rebuilds).
* **Non-root runtime** (`USER node`) for better security posture.
* **Health checks** for orchestration readiness & self-healing.
* **Config via env** so the same image works across dev/stage/prod.
* **Compose** for easy local workflows.

---

## 🧰 Nice Extras (optional)

* **Multi-arch build** (x86\_64 + arm64):

  ```bash
  docker buildx create --use
  docker buildx build --platform linux/amd64,linux/arm64 -t yourrepo/multistage-docker-app:latest --push .
  ```

* **Prod logging**: run with `--log-opt` (json-file max-size) or ship to stdout and aggregate in your platform.

* **Runtime flags**: add `NODE_OPTIONS=--max-old-space-size=256` etc. via env if needed.

---
