# Node.js Multistage Docker App

## Build
```bash
docker build -t multistage-docker-app .
```

## Run
```bash
docker run -d --name my-multistage-app -p 3000:3000 --init multistage-docker-app
```

## Compose
```bash
docker compose up --build -d
```

- App: http://localhost:3000
- Health: http://localhost:3000/health
