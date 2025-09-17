# Node.js Multistage Docker App
```
git clone https://github.com/atulkamble/docker-multistage-nodejs-app.git
cd docker-multistage-nodejs-app

# Download and install nvm:
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash

# in lieu of restarting the shell
\. "$HOME/.nvm/nvm.sh"

# Download and install Node.js:
nvm install 22

# Verify the Node.js version:
node -v # Should print "v22.19.0".

# Verify npm version:
npm -v # Should print "10.9.3".

npm install express 

node index.js 

http://instance-ip:3000 
```

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

// References: https://learn.microsoft.com/en-us/windows/dev-environment/javascript/nodejs-beginners-tutorial
