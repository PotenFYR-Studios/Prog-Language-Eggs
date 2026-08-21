const http = require('http');

const port = process.env.SERVER_PORT || process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR Universal Programming Language Eggs!',
    runtime: `Node.js ${process.version}`,
    timestamp: new Date().toISOString()
  }, null, 2));
});

server.listen(port, '0.0.0.0', () => {
  console.log(`[PotenFYR] Node.js server listening on port ${port}`);
});
