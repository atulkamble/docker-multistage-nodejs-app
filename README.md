**Node.js multistage Docker project** 

---

## 📦 Project Structure:

```
multistage-docker-app/
├── Dockerfile
├── package.json
├── package-lock.json
└── index.js
```

---

## 📄 Example `package.json`

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

---

## 📄 Example `index.js`

```javascript
const express = require('express');
const app = express();
const PORT = process.env.PORT || 3000;

app.get('/', (req, res) => {
  res.send('Hello from Multistage Docker Build!');
});

app.listen(PORT, () => {
  console.log(`App running on port ${PORT}`);
});
```

---

## 📄 Multistage `Dockerfile`

```dockerfile
# Stage 1: Build Stage
FROM node:20-alpine as builder

WORKDIR /app

# Copy package files and install dependencies
COPY package*.json ./
RUN npm install --production

# Copy source code
COPY . .

# Stage 2: Production Stage
FROM node:20-alpine

WORKDIR /app

# Copy dependencies from build stage
COPY --from=builder /app/node_modules ./node_modules
COPY --from=builder /app/index.js .
COPY --from=builder /app/package*.json ./

# Expose port
EXPOSE 3000

# Command to run app
CMD ["node", "index.js"]
```

---

## 📦 Build & Run Instructions

**Build the Docker Image:**

```bash
docker build -t multistage-docker-app .
```

**Run the Docker Container:**

```bash
docker run -d -p 3000:3000 --name my-multistage-app multistage-docker-app
```

Visit: [http://localhost:3000](http://localhost:3000)

---

## ✅ Why Multistage?

* **Smaller final images** — no dev dependencies or build tools.
* **Clean separation** of build vs runtime.
* **Improved security** — production image has only what it needs.

