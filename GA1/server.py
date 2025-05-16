from http.server import HTTPServer, BaseHTTPRequestHandler
import json
import os
import time
from urllib.parse import parse_qs

# Simple in-memory database for scores
scores = []
SCORES_FILE = "scores.json"

# Load scores from file if it exists
def load_scores():
    global scores
    try:
        if os.path.exists(SCORES_FILE):
            with open(SCORES_FILE, 'r') as f:
                scores = json.load(f)
    except Exception as e:
        print(f"Error loading scores: {e}")
        scores = []

# Save scores to file
def save_scores():
    try:
        with open(SCORES_FILE, 'w') as f:
            json.dump(scores, f)
    except Exception as e:
        print(f"Error saving scores: {e}")

# Load scores at startup
load_scores()


class GameServer(BaseHTTPRequestHandler):
    def do_OPTIONS(self):
        self.send_response(200)
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        self.end_headers()
    
    def do_GET(self):
        if self.path == '/scores':
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            
            # Sort scores by score value (descending)
            sorted_scores = sorted(scores, key=lambda x: x['score'], reverse=True)
            # Return top 10 scores
            top_scores = sorted_scores[:10]
            
            self.wfile.write(json.dumps(top_scores).encode())
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/plain')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(b'Not Found')
    
    def do_POST(self):
        if self.path == '/scores':
            content_length = int(self.headers['Content-Length'])
            post_data = self.rfile.read(content_length)
            
            try:
                data = json.loads(post_data.decode('utf-8'))
                name = data.get('name', '').strip()
                score = data.get('score', 0)
                
                # Validate data
                if not name or not isinstance(score, int):
                    self.send_response(400)
                    self.send_header('Content-type', 'application/json')
                    self.send_header('Access-Control-Allow-Origin', '*')
                    self.end_headers()
                    self.wfile.write(json.dumps({'error': 'Invalid data'}).encode())
                    return
                
                # Add timestamp
                timestamp = int(time.time())
                
                # Add score to database
                new_score = {
                    'name': name[:10],  # Limit name length
                    'score': score,
                    'timestamp': timestamp
                }
                scores.append(new_score)
                
                # Save scores to file
                save_scores()
                
                # Return success response
                self.send_response(201)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'success': True}).encode())
                
            except json.JSONDecodeError:
                self.send_response(400)
                self.send_header('Content-type', 'application/json')
                self.send_header('Access-Control-Allow-Origin', '*')
                self.end_headers()
                self.wfile.write(json.dumps({'error': 'Invalid JSON'}).encode())
        else:
            self.send_response(404)
            self.send_header('Content-type', 'text/plain')
            self.send_header('Access-Control-Allow-Origin', '*')
            self.end_headers()
            self.wfile.write(b'Not Found')

def run_server(port=8000):
    server_address = ('', port)
    httpd = HTTPServer(server_address, GameServer)
    print(f"Starting server on port {port}...")
    httpd.serve_forever()

if __name__ == '__main__':
    run_server()