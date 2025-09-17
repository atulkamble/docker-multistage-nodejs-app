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
