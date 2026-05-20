#!/usr/bin/env python3
import http.server
import json
import subprocess
import urllib.parse
import re
import time

# Variables globales para calcular el uso de CPU de forma precisa
last_idle = 0
last_total = 0

class DashboardHandler(http.server.BaseHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Access-Control-Allow-Origin', '*')
        self.send_header('Access-Control-Allow-Methods', 'GET, OPTIONS')
        self.send_header('Access-Control-Allow-Headers', 'Content-Type')
        http.server.BaseHTTPRequestHandler.end_headers(self)

    def do_OPTIONS(self):
        self.send_response(200)
        self.end_headers()

    def do_GET(self):
        parsed_url = urllib.parse.urlparse(self.path)
        path = parsed_url.path
        query = urllib.parse.parse_qs(parsed_url.query)

        if path == '/sys':
            cpu = get_cpu_usage()
            ram = get_ram_usage()
            temp = get_temp()
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            self.wfile.write(json.dumps({'cpu': cpu, 'ram': ram, 'temp': temp}).encode())
        elif path == '/volume/up':
            subprocess.run(['wpctl', 'set-volume', '-l', '1.0', '@DEFAULT_AUDIO_SINK@', '5%+'])
            self.send_ok()
        elif path == '/volume/down':
            subprocess.run(['wpctl', 'set-volume', '@DEFAULT_AUDIO_SINK@', '5%-'])
            self.send_ok()
        elif path == '/volume/mute':
            subprocess.run(['wpctl', 'set-mute', '@DEFAULT_AUDIO_SINK@', 'toggle'])
            self.send_ok()
        elif path == '/brightness/up':
            # Subir brillo alternando entre los perfiles creados
            subprocess.run(['wlr-randr', '--output', 'DP-1', '--brightness', '1.0'])
            self.send_ok()
        elif path == '/brightness/down':
            # Bajar brillo
            subprocess.run(['wlr-randr', '--output', 'DP-1', '--brightness', '0.4'])
            self.send_ok()
        elif path == '/wallpaper/next':
            subprocess.Popen(['/home/steepskynet/.config/hypr/scripts/wallhaven.sh'])
            self.send_ok()
        elif path == '/anime/play':
            url = query.get('url', [''])[0]
            if url:
                # Abrir mpv en segundo plano con aceleración de video
                subprocess.Popen(['mpv', '--ytdl-format=bestvideo[height<=1080]+bestaudio/best', '--hwdec=auto', url])
            self.send_ok()
        else:
            self.send_response(404)
            self.end_headers()

    def send_ok(self):
        self.send_response(200)
        self.send_header('Content-type', 'application/json')
        self.end_headers()
        self.wfile.write(json.dumps({'status': 'ok'}).encode())

def get_cpu_usage():
    global last_idle, last_total
    try:
        with open('/proc/stat', 'r') as f:
            line = f.readline()
        parts = list(map(int, line.split()[1:5]))
        idle = parts[3]
        total = sum(parts)
        
        # Calcular delta de uso de CPU
        diff_idle = idle - last_idle
        diff_total = total - last_total
        
        last_idle = idle
        last_total = total
        
        if diff_total == 0:
            return 0
        return int((1 - diff_idle / diff_total) * 100)
    except:
        return 0

def get_ram_usage():
    try:
        with open('/proc/meminfo', 'r') as f:
            content = f.read()
        mem_total = int(re.search(r'MemTotal:\s+(\d+)', content).group(1))
        mem_avail = int(re.search(r'MemAvailable:\s+(\d+)', content).group(1))
        return int((1 - mem_avail / mem_total) * 100)
    except:
        return 0

def get_temp():
    try:
        with open('/sys/class/thermal/thermal_zone0/temp', 'r') as f:
            temp = int(f.read().strip())
        return int(temp / 1000)
    except:
        # Fallback a thermal_zone1 si existe
        try:
            with open('/sys/class/thermal/thermal_zone1/temp', 'r') as f:
                temp = int(f.read().strip())
            return int(temp / 1000)
        except:
            return 45

if __name__ == '__main__':
    # Registrar primer estado de CPU
    get_cpu_usage()
    time.sleep(0.05)
    server = http.server.HTTPServer(('127.0.0.1', 8000), DashboardHandler)
    server.serve_forever()
