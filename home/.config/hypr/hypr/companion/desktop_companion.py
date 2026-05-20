#!/usr/bin/env python3
"""
Desktop Companion Chibi — Mascota reactiva de escritorio para Hyprland.
Reacciona al estado del sistema: idle, bailando con música, estresada con CPU alto.
"""

import sys
import os
import subprocess
import re

from PyQt6.QtWidgets import QApplication, QLabel, QWidget, QMenu
from PyQt6.QtCore import Qt, QTimer, QPoint, QRect, QSize
from PyQt6.QtGui import QPixmap, QCursor, QAction, QMouseEvent

SPRITE_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), "sprites")

# ── Configuración ──
SPRITE_SIZE = 150          # Tamaño del chibi en pantalla (px)
FRAME_COUNT = 4            # 2x2 grid → 4 frames
ANIM_INTERVAL_MS = 300     # Velocidad de animación (ms por frame)
POLL_INTERVAL_MS = 2000    # Cada cuanto revisar estado del sistema (ms)
CPU_THRESHOLD = 75         # % de CPU para activar modo "stress"


class DesktopCompanion(QWidget):
    def __init__(self):
        super().__init__()

        # ── Configurar ventana transparente sin bordes ──
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint
            | Qt.WindowType.WindowStaysOnTopHint
            | Qt.WindowType.Tool  # No aparece en la barra de tareas
        )
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setAttribute(Qt.WidgetAttribute.WA_ShowWithoutActivating)
        self.setFixedSize(SPRITE_SIZE, SPRITE_SIZE)

        # ── Label para mostrar el sprite ──
        self.sprite_label = QLabel(self)
        self.sprite_label.setFixedSize(SPRITE_SIZE, SPRITE_SIZE)
        self.sprite_label.setScaledContents(True)

        # ── Cargar sprite sheets ──
        self.sprites = {}
        self.load_sprites()

        # ── Estado ──
        self.current_state = "idle"
        self.current_frame = 0
        self.frames = {state: [] for state in self.sprites}
        self.extract_frames()

        # ── Drag support ──
        self.drag_offset = QPoint()

        # ── Posición inicial: esquina inferior derecha ──
        screen = QApplication.primaryScreen()
        if screen:
            geo = screen.availableGeometry()
            self.move(geo.width() - SPRITE_SIZE - 20, geo.height() - SPRITE_SIZE - 60)

        # ── Timer de animación ──
        self.anim_timer = QTimer(self)
        self.anim_timer.timeout.connect(self.next_frame)
        self.anim_timer.start(ANIM_INTERVAL_MS)

        # ── Timer de polling del sistema ──
        self.poll_timer = QTimer(self)
        self.poll_timer.timeout.connect(self.poll_system_state)
        self.poll_timer.start(POLL_INTERVAL_MS)

        # ── CPU tracking ──
        self.last_idle = 0
        self.last_total = 0
        self._init_cpu()

        # Mostrar primer frame
        self.update_sprite()
        self.show()

    # ────────────────────────────────────────────
    #  Carga de Sprites
    # ────────────────────────────────────────────
    def load_sprites(self):
        """Cargar las imágenes de sprite sheets desde el directorio de sprites."""
        for name in ("idle", "dance", "stress"):
            path = os.path.join(SPRITE_DIR, f"{name}.png")
            if os.path.exists(path):
                self.sprites[name] = QPixmap(path)
            else:
                print(f"[companion] Sprite no encontrado: {path}")

    def extract_frames(self):
        """Extraer frames individuales de cada sprite sheet (2x2 grid)."""
        for state, sheet in self.sprites.items():
            w = sheet.width() // 2
            h = sheet.height() // 2
            for row in range(2):
                for col in range(2):
                    frame = sheet.copy(QRect(col * w, row * h, w, h))
                    scaled = frame.scaled(
                        QSize(SPRITE_SIZE, SPRITE_SIZE),
                        Qt.AspectRatioMode.KeepAspectRatio,
                        Qt.TransformationMode.SmoothTransformation,
                    )
                    self.frames[state].append(scaled)

    # ────────────────────────────────────────────
    #  Animación
    # ────────────────────────────────────────────
    def next_frame(self):
        """Avanzar al siguiente frame de la animación."""
        frames = self.frames.get(self.current_state, [])
        if not frames:
            return
        self.current_frame = (self.current_frame + 1) % len(frames)
        self.update_sprite()

    def update_sprite(self):
        """Actualizar el pixmap visible."""
        frames = self.frames.get(self.current_state, [])
        if frames:
            self.sprite_label.setPixmap(frames[self.current_frame])

    def set_state(self, new_state: str):
        """Cambiar de estado de animación (idle/dance/stress)."""
        if new_state != self.current_state and new_state in self.frames:
            self.current_state = new_state
            self.current_frame = 0
            # Ajustar velocidad según estado
            if new_state == "dance":
                self.anim_timer.setInterval(200)  # Más rápido bailando
            elif new_state == "stress":
                self.anim_timer.setInterval(150)  # Frenético
            else:
                self.anim_timer.setInterval(ANIM_INTERVAL_MS)
            self.update_sprite()

    # ────────────────────────────────────────────
    #  Polling del Sistema
    # ────────────────────────────────────────────
    def _init_cpu(self):
        """Inicializar el primer estado de CPU."""
        try:
            with open("/proc/stat", "r") as f:
                parts = list(map(int, f.readline().split()[1:5]))
            self.last_idle = parts[3]
            self.last_total = sum(parts)
        except Exception:
            pass

    def get_cpu_usage(self) -> int:
        """Obtener uso de CPU porcentual desde /proc/stat."""
        try:
            with open("/proc/stat", "r") as f:
                parts = list(map(int, f.readline().split()[1:5]))
            idle = parts[3]
            total = sum(parts)
            d_idle = idle - self.last_idle
            d_total = total - self.last_total
            self.last_idle = idle
            self.last_total = total
            if d_total == 0:
                return 0
            return int((1 - d_idle / d_total) * 100)
        except Exception:
            return 0

    def is_music_playing(self) -> bool:
        """Verificar si hay música reproduciéndose usando playerctl."""
        try:
            result = subprocess.run(
                ["playerctl", "status"],
                capture_output=True,
                text=True,
                timeout=1,
            )
            return result.stdout.strip() == "Playing"
        except Exception:
            return False

    def poll_system_state(self):
        """Determinar el estado actual del sistema y cambiar la animación."""
        cpu = self.get_cpu_usage()

        if cpu >= CPU_THRESHOLD:
            self.set_state("stress")
        elif self.is_music_playing():
            self.set_state("dance")
        else:
            self.set_state("idle")

    # ────────────────────────────────────────────
    #  Drag & Drop (arrastrar la mascota)
    # ────────────────────────────────────────────
    def mousePressEvent(self, event: QMouseEvent):
        if event.button() == Qt.MouseButton.LeftButton:
            self.drag_offset = event.pos()

    def mouseMoveEvent(self, event: QMouseEvent):
        if event.buttons() & Qt.MouseButton.LeftButton:
            self.move(self.mapToParent(event.pos() - self.drag_offset))

    # ────────────────────────────────────────────
    #  Menú contextual (clic derecho)
    # ────────────────────────────────────────────
    def contextMenuEvent(self, event):
        menu = QMenu(self)
        menu.setStyleSheet("""
            QMenu {
                background: rgba(17, 17, 27, 0.9);
                color: #cdd6f4;
                border: 1px solid rgba(255,255,255,0.1);
                border-radius: 6px;
                padding: 4px;
                font-family: 'Inter', sans-serif;
                font-size: 12px;
            }
            QMenu::item:selected {
                background: rgba(137, 180, 250, 0.3);
                border-radius: 4px;
            }
        """)

        action_idle = QAction("💤 Idle", self)
        action_idle.triggered.connect(lambda: self.set_state("idle"))
        menu.addAction(action_idle)

        action_dance = QAction("💃 Bailar", self)
        action_dance.triggered.connect(lambda: self.set_state("dance"))
        menu.addAction(action_dance)

        action_stress = QAction("🔥 Estrés", self)
        action_stress.triggered.connect(lambda: self.set_state("stress"))
        menu.addAction(action_stress)

        menu.addSeparator()

        action_quit = QAction("✕ Cerrar Companion", self)
        action_quit.triggered.connect(QApplication.quit)
        menu.addAction(action_quit)

        menu.exec(event.globalPos())


def main():
    # Deshabilitar fractional scaling warnings en Wayland
    os.environ.setdefault("QT_QPA_PLATFORM", "wayland")

    app = QApplication(sys.argv)
    app.setApplicationName("desktop-companion")
    app.setDesktopFileName("desktop-companion")

    companion = DesktopCompanion()

    # Pin the window via hyprctl after it's shown
    QTimer.singleShot(500, lambda: subprocess.Popen(
        ["hyprctl", "dispatch", "pin", "class:desktop-companion"]
    ))

    sys.exit(app.exec())


if __name__ == "__main__":
    main()
