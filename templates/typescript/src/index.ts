import * as http from 'http';

const port = process.env.SERVER_PORT || process.env.PORT || 8080;

const server = http.createServer((req, res) => {
  res.writeHead(200, { 'Content-Type': 'application/json' });
  res.end(JSON.stringify({
    status: 'online',
    message: 'Hello from PotenFYR TypeScript Egg!',
    runtime: `Node.js ${process.version} with TypeScript`,
    timestamp: new Date().toISOString()
  }, null, 2));
});

server.listen(Number(port), '0.0.0.0', () => {
  console.log(`[PotenFYR] TypeScript server listening on port ${port}`);
});
