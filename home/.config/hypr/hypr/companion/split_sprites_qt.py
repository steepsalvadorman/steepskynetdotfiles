import sys
import os
from PyQt6.QtWidgets import QApplication
from PyQt6.QtGui import QPixmap
from PyQt6.QtCore import QRect

app = QApplication(sys.argv)

SPRITE_DIR = "/home/steepskynet/.config/hypr/companion/sprites"
OUT_DIR = "/home/steepskynet/.config/hypr/companion/frames"
os.makedirs(OUT_DIR, exist_ok=True)

for name in ["idle", "dance", "stress"]:
    path = os.path.join(SPRITE_DIR, f"{name}.png")
    if not os.path.exists(path): continue
    
    img = QPixmap(path)
    w = img.width() // 2
    h = img.height() // 2
    
    frame_idx = 0
    for row in range(2):
        for col in range(2):
            frame = img.copy(QRect(col * w, row * h, w, h))
            frame.save(os.path.join(OUT_DIR, f"{name}_{frame_idx}.png"))
            frame_idx += 1

print("Sprites splitted successfully!")
