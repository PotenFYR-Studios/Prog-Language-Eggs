import os
from http.server import HTTPServer, BaseHTTPRequestHandler
import json
from datetime import datetime

PORT = int(os.environ.get("SERVER_PORT", os.environ.get("PORT", 8080)))

class RequestHandler(BaseHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        response = {
            "status": "online",
            "message": "Hello from PotenFYR Python Egg!",
            "python_version": os.sys.version,
            "timestamp": datetime.utcnow().isoformat()
        }
        self.wfile.write(json.dumps(response, indent=2).encode('utf-8'))

print(f"[PotenFYR] Python HTTP server listening on port {PORT}")
httpd = HTTPServer(('0.0.0.0', PORT), RequestHandler)
httpd.serve_forever()
