# Node.js Multistage Docker App

## Build
```bash
git clone https://github.com/atulkamble/docker-multistage-nodejs-app.git
cd docker-multistage-nodejs-app
docker build -t atuljkamble/multistage-docker-app .
docker push atuljkamble/multistage-docker-app
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
