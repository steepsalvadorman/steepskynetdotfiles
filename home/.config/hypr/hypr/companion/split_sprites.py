from PIL import Image
import os

SPRITE_DIR = "/home/steepskynet/.config/hypr/companion/sprites"
OUT_DIR = "/home/steepskynet/.config/hypr/companion/frames"
os.makedirs(OUT_DIR, exist_ok=True)

for name in ["idle", "dance", "stress"]:
    path = os.path.join(SPRITE_DIR, f"{name}.png")
    if not os.path.exists(path): continue
    
    img = Image.open(path)
    w = img.width // 2
    h = img.height // 2
    
    frame_idx = 0
    for row in range(2):
        for col in range(2):
            box = (col * w, row * h, (col + 1) * w, (row + 1) * h)
            frame = img.crop(box)
            # Scale down nicely for waybar if needed, though waybar 'size' parameter handles it
            frame.save(os.path.join(OUT_DIR, f"{name}_{frame_idx}.png"))
            frame_idx += 1
print("Sprites splitted successfully!")
