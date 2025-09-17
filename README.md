# Node.js Multistage Docker App — Updated Code

## Build
```bash
docker build -t atuljkamble/multistage-docker-app .
```

## Run
```bash
docker run -d --name multistage-app -p 3000:3000 --init atuljkamble/multistage-docker-app
```

## Compose
```bash
docker compose up --build -d
```

- App: http://localhost:3000
- Health: http://localhost:3000/health
