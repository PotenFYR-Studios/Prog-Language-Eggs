const port = Number(process.env.SERVER_PORT || process.env.PORT || 8080);

console.log(`[PotenFYR] Bun HTTP server listening on port ${port}`);

Bun.serve({
  port: port,
  fetch(req) {
    return new Response(JSON.stringify({
      status: "online",
      message: "Hello from PotenFYR Bun Egg!",
      runtime: `Bun ${Bun.version}`,
      url: req.url,
      timestamp: new Date().toISOString()
    }, null, 2), {
      headers: { "Content-Type": "application/json" }
    });
  }
});
