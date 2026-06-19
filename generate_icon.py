from PIL import Image
import os

os.makedirs('assets/icon', exist_ok=True)

icon = Image.open('test_icon.png').convert("RGBA")
# Background color: light blue (like in the welcome page)
bg = Image.new('RGBA', (1024, 1024), '#EAEFFD')

r, g, b, a = icon.split()
# Icon color: dark blue
color_layer = Image.new('RGBA', icon.size, '#1A237E')
color_layer.putalpha(a)

colored_icon = color_layer.resize((800, 800), Image.Resampling.LANCZOS)

offset = ((1024 - 800) // 2, (1024 - 800) // 2)
bg.paste(colored_icon, offset, colored_icon)

bg.save('assets/icon/app_icon.png')
print('Icon saved to assets/icon/app_icon.png')
