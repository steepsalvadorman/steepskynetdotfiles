#!/usr/bin/env python3
import curses
import os
import sys
import time
import subprocess
import threading
import random
import urllib.request
import urllib.parse
import json

# Color pairs
COLOR_CYAN = 1
COLOR_MAGENTA = 2
COLOR_YELLOW = 3
COLOR_GRAY = 4
COLOR_RED = 5
COLOR_GREEN = 6

class DashboardTUI:
    def __init__(self):
        self.running = True
        self.active_panel = 0  # 0: Power, 1: Radio, 2: Anime
        
        # CPU Governor
        self.governor = "powersave"
        
        # Lo-Fi Radio
        self.stations = [
            ("Lofi Girl Hip Hop", "https://stream.zeno.fm/0r0xa792kwzuv"),
            ("Synthwave Retro", "https://stream.zeno.fm/46a8157776828"),
            ("Lofi Girl Jazz-Hop", "https://stream.zeno.fm/75h49112kwzuv")
        ]
        self.active_station_idx = 0
        self.radio_status = "Stopped"
        self.mpv_process = None
        
        # Anime Searcher
        self.anime_query = ""
        self.anime_status = "Listo para buscar."
        self.anime_results = []
        self.anime_menu_idx = 0
        
        # Navigation Indices
        self.power_menu_idx = 0   # 0: powersave, 1: performance
        self.radio_menu_idx = 0   # 0-2: Stations

    def start_threads(self):
        # Thread to check governor periodically
        threading.Thread(target=self.update_governor_loop, daemon=True).start()

    def update_governor_loop(self):
        while self.running:
            self.update_governor()
            time.sleep(2.0)

    def update_governor(self):
        try:
            with open("/sys/devices/system/cpu/cpu0/cpufreq/scaling_governor", "r") as f:
                self.governor = f.read().strip()
        except:
            pass

    def change_governor(self, stdscr, gov):
        # 1. Suspend curses cleanly and restore terminal modes
        stdscr.keypad(False)
        curses.echo()
        curses.nocbreak()
        curses.endwin()
        
        # 2. Reset terminal cursor and clear layout artifacts
        sys.stdout.write("\033[H\033[2J\033[3J")
        sys.stdout.flush()
        
        # 3. Draw password prompt cleanly on stdout
        print("=" * 60)
        print(f" CONFIGURANDO MÓDULO DE PODER: {gov.upper()} ".center(60))
        print(" Se requiere autenticación para cambiar el Gobernador de CPU.".center(60))
        print("=" * 60 + "\n")
        
        # Run pkexec synchronously
        cmd = f'pkexec sh -c "echo {gov} | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor"'
        subprocess.run(cmd, shell=True)
        
        # 4. Resume curses cleanly
        curses.cbreak()
        curses.noecho()
        stdscr.keypad(True)
        stdscr.refresh()
        stdscr.touchwin()
        
        # Update the governor value immediately
        self.update_governor()

    def toggle_radio(self):
        if self.radio_status == "Playing":
            self.stop_radio()
        else:
            self.play_radio()

    def play_radio(self):
        self.stop_radio()
        url = self.stations[self.active_station_idx][1]
        def _task():
            self.radio_status = "Playing"
            self.mpv_process = subprocess.Popen(
                ["mpv", "--no-video", url],
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
            self.mpv_process.wait()
            self.radio_status = "Stopped"
        threading.Thread(target=_task, daemon=True).start()

    def stop_radio(self):
        if self.mpv_process:
            self.mpv_process.terminate()
            self.mpv_process = None
        self.radio_status = "Stopped"

    # Anime Search Mechanism
    def search_anime_prompt(self, stdscr):
        # Suspend curses briefly to print a clean line or do it inside curses
        # Curses text prompt is cleaner inside curses:
        curses.curs_set(1)
        curses.echo()
        
        h, w = stdscr.getmaxyx()
        prompt_y = 11
        prompt_x = 12
        
        # Clear prompt area
        stdscr.addstr(prompt_y, prompt_x, " " * (w - prompt_x - 3), curses.color_pair(COLOR_CYAN))
        stdscr.addstr(prompt_y, prompt_x, "Anime: ", curses.color_pair(COLOR_CYAN) | curses.A_BOLD)
        stdscr.refresh()
        
        try:
            query_bytes = stdscr.getstr(prompt_y, prompt_x + 7, 30)
            self.anime_query = query_bytes.decode('utf-8').strip()
        except:
            self.anime_query = ""
            
        curses.noecho()
        curses.curs_set(0)
        
        if self.anime_query:
            self.search_anime_async(self.anime_query)

    def search_anime_async(self, query):
        self.anime_status = "Buscando en MyAnimeList..."
        self.anime_results = []
        self.anime_menu_idx = 0
        
        def _task():
            try:
                url = f"https://api.jikan.moe/v4/anime?q={urllib.parse.quote(query)}&limit=4"
                req = urllib.request.Request(url, headers={'User-Agent': 'Mozilla/5.0'})
                with urllib.request.urlopen(req, timeout=5) as response:
                    data = json.loads(response.read().decode('utf-8'))
                    results = data.get("data", [])
                    
                    parsed_results = []
                    for item in results:
                        title = item.get("title", "Sin título")
                        year = item.get("year") or "N/A"
                        rating = item.get("rating") or "N/A"
                        # Clean rating string (take first word)
                        rating = rating.split()[0] if rating != "N/A" else "N/A"
                        
                        trailer_url = item.get("trailer", {}).get("url", None)
                        parsed_results.append({
                            "title": title,
                            "year": year,
                            "rating": rating,
                            "url": trailer_url
                        })
                    self.anime_results = parsed_results
                    if parsed_results:
                        self.anime_status = f"Encontrados: {len(parsed_results)} resultados."
                    else:
                        self.anime_status = "No se encontraron resultados."
            except Exception as e:
                self.anime_status = f"Error en búsqueda Jikan API."
                
        threading.Thread(target=_task, daemon=True).start()

    def play_anime_trailer(self, stdscr, item):
        url = item.get("url")
        if not url:
            self.anime_status = "¡Sin trailer de video disponible!"
            return
            
        # 1. Suspend curses cleanly and restore terminal modes
        stdscr.keypad(False)
        curses.echo()
        curses.nocbreak()
        curses.endwin()
        
        # 2. Reset terminal cursor and clear layout artifacts
        sys.stdout.write("\033[H\033[2J\033[3J")
        sys.stdout.flush()
        
        print("=" * 60)
        print(f" REPRODUCIENDO TRAILER EN TERMINAL: {item['title'].upper()} ".center(60))
        print(" Controles: [Espacio] Pausa  [↔] Retroceder/Avanzar  [q] Salir".center(60))
        print("=" * 60 + "\n")
        
        # Run mpv inside this terminal with True Color Terminal (tct) rendering!
        subprocess.run(['mpv', '--vo=tct', '--hwdec=auto', url])
        
        # 3. Resume curses cleanly
        curses.cbreak()
        curses.noecho()
        stdscr.keypad(True)
        stdscr.refresh()
        stdscr.touchwin()
        self.anime_status = "Reproducción finalizada."

    # Helper function to write text with a CRT TV scanline effect (dim even rows)
    def addstr_scanline(self, stdscr, y, x, text, attr=0):
        try:
            if y % 2 == 0:
                stdscr.addstr(y, x, text, attr | curses.A_DIM)
            else:
                stdscr.addstr(y, x, text, attr)
        except curses.error:
            pass

    # Helper function to write single characters with a CRT TV scanline effect
    def addch_scanline(self, stdscr, y, x, char, attr=0):
        try:
            if y % 2 == 0:
                stdscr.addch(y, x, char, attr | curses.A_DIM)
            else:
                stdscr.addch(y, x, char, attr)
        except curses.error:
            pass

    def draw_border_box(self, stdscr, y, x, h, w, title, is_active=False):
        color = curses.color_pair(COLOR_CYAN if is_active else COLOR_GRAY)
        if is_active:
            color |= curses.A_BOLD
            
        # Draw corners
        self.addch_scanline(stdscr, y, x, '┌', color)
        self.addch_scanline(stdscr, y, x + w - 1, '┐', color)
        self.addch_scanline(stdscr, y + h - 1, x, '└', color)
        self.addch_scanline(stdscr, y + h - 1, x + w - 1, '┘', color)
        
        # Draw lines
        for dx in range(1, w - 1):
            self.addch_scanline(stdscr, y, x + dx, '─', color)
            self.addch_scanline(stdscr, y + h - 1, x + dx, '─', color)
        for dy in range(1, h - 1):
            self.addch_scanline(stdscr, y + dy, x, '│', color)
            self.addch_scanline(stdscr, y + dy, x + w - 1, '│', color)
            
        # Title
        title_str = f" {title} "
        self.addstr_scanline(stdscr, y, x + 2, title_str, color)

    def draw_spectrum(self, stdscr, y, x, width):
        if self.radio_status != "Playing":
            wave = " ▃ ▃ ▃ ▃ ▃ ▃ ▃ ▃ ▃ ▃ "[:width]
            self.addstr_scanline(stdscr, y, x, wave, curses.color_pair(COLOR_GRAY))
            return
            
        # Generate random shifting waveform
        chars = [" ", " ", "▂", "▃", "▄", "▅", "▆", "▇", "█"]
        wave = "".join(random.choice(chars) for _ in range(width))
        self.addstr_scanline(stdscr, y, x, wave, curses.color_pair(COLOR_MAGENTA) | curses.A_BOLD)

    def draw(self, stdscr):
        stdscr.erase()
        h, w = stdscr.getmaxyx()
        
        if w < 78 or h < 20:
            stdscr.addstr(0, 0, "Terminal pequeña! Redimensiona a min 80x20.", curses.color_pair(COLOR_RED))
            stdscr.refresh()
            return

        # Retro Header Title (Cyber-Deck)
        title_art = " ☢☣ CYBER-DECK 80 // RETRO MAINFRAME TERMINAL ☣☢ "
        self.addstr_scanline(stdscr, 1, (w - len(title_art)) // 2, title_art, curses.color_pair(COLOR_MAGENTA) | curses.A_BOLD)
        
        # 1. TOP LEFT PANEL: Power Module (CPU Governor)
        self.draw_border_box(stdscr, 3, 2, 7, 36, "MÓDULO DE PODER [F1]", self.active_panel == 0)
        
        self.addstr_scanline(stdscr, 4, 4, "Gobernador Activo CPU:", curses.color_pair(COLOR_MAGENTA) | curses.A_BOLD)
        
        gov_modes = ["powersave", "performance"]
        for idx, mode in enumerate(gov_modes):
            indicator = "◆" if self.governor == mode else "◇"
            style = curses.A_BOLD if self.governor == mode else curses.A_NORMAL
            color = COLOR_GREEN if self.governor == mode else COLOR_GRAY
            
            selected = "► " if (self.active_panel == 0 and self.power_menu_idx == idx) else "  "
            self.addstr_scanline(stdscr, 5 + idx, 5, f"{selected}{indicator} {mode.upper()}", curses.color_pair(color) | style)

        # 2. TOP RIGHT PANEL: Lo-Fi Radio Deck
        self.draw_border_box(stdscr, 3, 40, 7, 37, "SINTONIZADOR FM/AM LO-FI [F2]", self.active_panel == 1)
        
        status_color = COLOR_GREEN if self.radio_status == "Playing" else COLOR_RED
        self.addstr_scanline(stdscr, 4, 42, f"FM: {self.radio_status.upper()}", curses.color_pair(status_color) | curses.A_BOLD)
        self.draw_spectrum(stdscr, 4, 55, 20)
        
        # Station List
        for idx, (name, _) in enumerate(self.stations):
            is_active_station = (idx == self.active_station_idx)
            marker = "► " if (self.active_panel == 1 and self.radio_menu_idx == idx) else "  "
            dot = "● " if is_active_station else "○ "
            style = curses.color_pair(COLOR_CYAN if (self.active_panel == 1 and self.radio_menu_idx == idx) else COLOR_GRAY)
            if self.active_panel == 1 and self.radio_menu_idx == idx:
                style |= curses.A_BOLD
            if is_active_station and self.radio_status == "Playing":
                style |= curses.A_REVERSE
                
            self.addstr_scanline(stdscr, 5 + idx, 42, f"{marker}{dot}{name:<16}", style)

        # 3. BOTTOM PANEL: Buscador de Anime (Jikan MyAnimeList API)
        self.draw_border_box(stdscr, 10, 2, 9, 75, "BUSCADOR ANIME TERMINAL [F3]", self.active_panel == 2)
        
        # Search query info
        search_label = f"Buscar: [{self.anime_query if self.anime_query else 'Presiona s para escribir'}]"
        self.addstr_scanline(stdscr, 11, 4, search_label, curses.color_pair(COLOR_YELLOW) | curses.A_BOLD)
        self.addstr_scanline(stdscr, 11, 44, f"Estado: {self.anime_status}", curses.color_pair(COLOR_GRAY))
        
        # Draw search results
        if not self.anime_results:
            self.addstr_scanline(stdscr, 13, 15, "-- INGRESE UNA BÚSQUEDA USANDO LA TECLA 's' --", curses.color_pair(COLOR_GRAY) | curses.A_DIM)
        else:
            for idx, item in enumerate(self.anime_results):
                is_selected = (self.active_panel == 2 and self.anime_menu_idx == idx)
                marker = "► " if is_selected else "  "
                
                title_clean = item["title"][:28]
                info_str = f"{title_clean:<28} | Año: {item['year']:<5} | Clas: {item['rating']:<5}"
                
                color = COLOR_CYAN if is_selected else COLOR_GRAY
                style = curses.color_pair(color)
                if is_selected:
                    style |= curses.A_BOLD
                    
                # Highlight if trailer exists
                trailer_indicator = " [🎬 VIDEO]" if item["url"] else " [NO VID]"
                
                self.addstr_scanline(stdscr, 13 + idx, 4, f"{marker}{info_str}{trailer_indicator}", style)

        # Instruction Bar
        inst_str = " [Tab]: Deck  [s]: Escribir Anime  [↕]: Seleccionar  [Enter]: Cargar  [q]: Apagar "
        self.addstr_scanline(stdscr, 19, (w - len(inst_str)) // 2, inst_str, curses.color_pair(COLOR_GRAY) | curses.A_REVERSE)
        
        stdscr.refresh()

    def main_loop(self, stdscr):
        # Initialize standard curses parameters
        curses.curs_set(0)
        stdscr.nodelay(True)
        stdscr.keypad(True)
        
        # Colors definition
        curses.start_color()
        try:
            curses.use_default_colors()
        except:
            pass
        curses.init_pair(COLOR_CYAN, curses.COLOR_CYAN, -1)
        curses.init_pair(COLOR_MAGENTA, curses.COLOR_MAGENTA, -1)
        curses.init_pair(COLOR_YELLOW, curses.COLOR_YELLOW, -1)
        curses.init_pair(COLOR_GRAY, 8 if curses.COLORS >= 16 else curses.COLOR_WHITE, -1)
        curses.init_pair(COLOR_RED, curses.COLOR_RED, -1)
        curses.init_pair(COLOR_GREEN, curses.COLOR_GREEN, -1)
        
        self.start_threads()
        
        while self.running:
            self.draw(stdscr)
            
            try:
                ch = stdscr.getch()
            except:
                ch = -1
                
            if ch == ord('q') or ch == 27:  # q or Esc
                self.running = False
                break
                
            elif ch == 9:  # Tab
                self.active_panel = (self.active_panel + 1) % 3
                
            # Quick Panel Navigation via F1, F2, F3 keys!
            elif ch == curses.KEY_F1:
                self.active_panel = 0
            elif ch == curses.KEY_F2:
                self.active_panel = 1
            elif ch == curses.KEY_F3:
                self.active_panel = 2
                
            elif ch == ord('s'):
                # Suspend current panel and trigger prompt
                self.active_panel = 2
                self.search_anime_prompt(stdscr)
                
            elif ch in [curses.KEY_UP, ord('k')]:
                if self.active_panel == 0:
                    self.power_menu_idx = (self.power_menu_idx - 1) % 2
                elif self.active_panel == 1:
                    self.radio_menu_idx = (self.radio_menu_idx - 1) % 3
                elif self.active_panel == 2:
                    if self.anime_results:
                        self.anime_menu_idx = (self.anime_menu_idx - 1) % len(self.anime_results)
                    
            elif ch in [curses.KEY_DOWN, ord('j')]:
                if self.active_panel == 0:
                    self.power_menu_idx = (self.power_menu_idx + 1) % 2
                elif self.active_panel == 1:
                    self.radio_menu_idx = (self.radio_menu_idx + 1) % 3
                elif self.active_panel == 2:
                    if self.anime_results:
                        self.anime_menu_idx = (self.anime_menu_idx + 1) % len(self.anime_results)
                        
            elif ch in [10, 13, curses.KEY_ENTER]:  # Enter
                if self.active_panel == 0:
                    target_gov = "powersave" if self.power_menu_idx == 0 else "performance"
                    if self.governor != target_gov:
                        self.change_governor(stdscr, target_gov)
                elif self.active_panel == 1:
                    if self.radio_menu_idx == self.active_station_idx:
                        self.toggle_radio()
                    else:
                        self.active_station_idx = self.radio_menu_idx
                        self.play_radio()
                elif self.active_panel == 2:
                    if self.anime_results:
                        selected_anime = self.anime_results[self.anime_menu_idx]
                        self.play_anime_trailer(stdscr, selected_anime)
                        
            time.sleep(0.08) # 80ms refresh to keep VU spectrum extremely smooth
            
        self.stop_radio()

def main():
    tui = DashboardTUI()
    try:
        os.environ.setdefault('ESCDELAY', '25') # Make Esc key super responsive
        curses.wrapper(tui.main_loop)
    except KeyboardInterrupt:
        tui.stop_radio()
    finally:
        print("Hasta luego, Hacker!")

if __name__ == "__main__":
    main()
