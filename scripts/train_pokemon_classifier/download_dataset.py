"""
Downloads official Pokemon artwork for Gen 1 (IDs 1-151) from PokeAPI sprites.
Composites transparent backgrounds over white and saves to dataset/.

Usage:
    pip install -r requirements.txt
    python download_dataset.py
"""
import time
import requests
from pathlib import Path
from PIL import Image
from io import BytesIO

DATASET_DIR = Path('dataset')
BASE_URL = 'https://raw.githubusercontent.com/PokeAPI/sprites/master/sprites/pokemon/other/official-artwork/{}.png'
NUM_POKEMON = 151


def composite_on_white(rgba_image: Image.Image) -> Image.Image:
    background = Image.new('RGB', rgba_image.size, (255, 255, 255))
    if rgba_image.mode == 'RGBA':
        background.paste(rgba_image, mask=rgba_image.split()[3])
    else:
        background.paste(rgba_image.convert('RGB'))
    return background


def download_sprites():
    DATASET_DIR.mkdir(exist_ok=True)
    session = requests.Session()

    for i in range(1, NUM_POKEMON + 1):
        out_path = DATASET_DIR / f'{i:03d}.png'
        if out_path.exists():
            print(f'  [{i:3d}/{NUM_POKEMON}] already exists, skipping')
            continue

        url = BASE_URL.format(i)
        try:
            response = session.get(url, timeout=15)
            response.raise_for_status()

            raw = Image.open(BytesIO(response.content)).convert('RGBA')
            rgb = composite_on_white(raw)
            rgb.save(out_path)
            print(f'  [{i:3d}/{NUM_POKEMON}] downloaded')
        except Exception as e:
            print(f'  [{i:3d}/{NUM_POKEMON}] FAILED: {e}')

        time.sleep(0.1)  # polite rate limit

    downloaded = len(list(DATASET_DIR.glob('*.png')))
    print(f'\nDone: {downloaded}/{NUM_POKEMON} images in {DATASET_DIR}/')


if __name__ == '__main__':
    download_sprites()
