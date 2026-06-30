#!/usr/bin/env python3
"""HTTPS reverse proxy for Ollama — no external dependencies."""

import ssl, os, urllib.request, urllib.error
from http.server import HTTPServer, BaseHTTPRequestHandler

BACKEND = os.environ.get("BACKEND", "http://localhost:11434")
PORT    = int(os.environ.get("PORT", "8443"))
DOMAIN  = os.environ.get("DOMAIN", "4ride.online")
SSL_DIR = os.path.join(os.path.dirname(__file__), "ssl")
CERT    = os.path.join(SSL_DIR, "fullchain.pem")
KEY     = os.path.join(SSL_DIR, "key.pem")

SKIP_HEADERS = {'host', 'connection', 'transfer-encoding', 'keep-alive'}

class ProxyHandler(BaseHTTPRequestHandler):
    def proxy(self):
        url = BACKEND + self.path
        length = int(self.headers.get('Content-Length', 0))
        body = self.rfile.read(length) if length else None
        headers = {k: v for k, v in self.headers.items() if k.lower() not in SKIP_HEADERS}
        headers['Host'] = 'localhost'
        req = urllib.request.Request(url, data=body, headers=headers, method=self.command)
        try:
            with urllib.request.urlopen(req, timeout=120) as resp:
                self.send_response(resp.status)
                for k, v in resp.headers.items():
                    if k.lower() not in SKIP_HEADERS:
                        self.send_header(k, v)
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(resp.read())
        except urllib.error.HTTPError as e:
            self.send_response(e.code)
            self.end_headers()
            self.wfile.write(e.read())
        except Exception as e:
            self.send_response(502)
            self.end_headers()
            self.wfile.write(f"Proxy error: {e}".encode())

    do_GET = do_POST = do_PUT = do_DELETE = do_OPTIONS = do_HEAD = proxy

    def log_message(self, fmt, *args):
        print(f"  {self.address_string()} → {args[0]} {args[1]}")


def gen_cert():
    os.makedirs(SSL_DIR, exist_ok=True)
    ret = os.system(
        f'openssl req -x509 -newkey rsa:2048 -keyout "{KEY}" -out "{CERT}" '
        f'-days 365 -nodes -subj "/CN={DOMAIN}" 2>/dev/null'
    )
    if ret != 0:
        raise RuntimeError("openssl failed — is openssl installed?")


if __name__ == '__main__':
    if not os.path.exists(CERT) or not os.path.exists(KEY):
        print("[*] Generating self-signed certificate...")
        gen_cert()
        print(f"[*] Certificate saved to {SSL_DIR}/")

    ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_SERVER)
    ctx.load_cert_chain(CERT, KEY)

    server = HTTPServer(('0.0.0.0', PORT), ProxyHandler)
    server.socket = ctx.wrap_socket(server.socket, server_side=True)

    print(f"[*] HTTPS proxy: https://0.0.0.0:{PORT} → {BACKEND}")
    print(f"[*] Public URL: https://{DOMAIN} (after router change 443 → {PORT})")
    print("[*] Ctrl+C to stop\n")
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        print("\n[*] Stopped.")
