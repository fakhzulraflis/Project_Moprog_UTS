"""Mendeteksi mata terbuka tiap avatar (blob gelap yang punya highlight putih).

Hasilnya berupa fraksi (0..1) terhadap gambar yang sudah di-trim, plus warna
kulit di sekitar mata, untuk dipakai animasi kedip di Flutter.
Jalankan dari root proyek:  python tools/detect_eyes.py [--debug DIR]
"""
import glob
import os
import sys
from collections import deque

from PIL import Image, ImageDraw


def lum(p):
    return 0.299 * p[0] + 0.587 * p[1] + 0.114 * p[2]


# Jendela pencarian (fraksi x0,y0,x1,y1) untuk gambar yang blob matanya
# menyatu dengan outline kalau dicari di seluruh bagian atas.
HINTS = {
    'binbin_cardigan.png': (0.52, 0.36, 0.78, 0.52),
    'qua_scholar.png': (0.52, 0.26, 0.76, 0.40),
}


# Kotak mata manual (fraksi x0,y0,x1,y1) kalau deteksi otomatis meleset.
MANUAL = {
    'qua_chef.png': (0.695, 0.340, 0.771, 0.407),
}


def detect(path):
    manual = MANUAL.get(os.path.basename(path))
    hint = HINTS.get(os.path.basename(path))
    im = Image.open(path).convert('RGBA')
    w, h = im.size
    px = im.load()
    limit_y = int(h * 0.62)  # mata selalu ada di bagian atas gambar
    wx0, wy0, wx1, wy1 = (0, 0, w, limit_y) if not hint else (
        int(hint[0] * w), int(hint[1] * h), int(hint[2] * w), int(hint[3] * h))

    def dark(x, y):
        p = px[x, y]
        return p[3] > 200 and lum(p) < 85

    def white(x, y):
        p = px[x, y]
        return p[3] > 200 and min(p[:3]) > 235

    seen = set()
    best = None
    for y in range(wy0, wy1):
        for x in range(wx0, wx1):
            if (x, y) in seen or not dark(x, y):
                continue
            comp, q = [], deque([(x, y)])
            seen.add((x, y))
            while q:
                cx, cy = q.popleft()
                comp.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if wx0 <= nx < wx1 and wy0 <= ny < wy1 and (nx, ny) not in seen and dark(nx, ny):
                        seen.add((nx, ny))
                        q.append((nx, ny))
            if len(comp) < (40 if hint else 400) or len(comp) > 0.02 * w * h:
                continue
            xs = [c[0] for c in comp]
            ys = [c[1] for c in comp]
            x0, x1, y0, y1 = min(xs), max(xs), min(ys), max(ys)
            bw, bh = x1 - x0 + 1, y1 - y0 + 1
            # mata terbuka: relatif kompak (bukan garis tipis) dan ada putih di dalam bbox
            if bh < 0.55 * bw:
                continue
            has_white = any(white(xx, yy) for yy in range(y0, y1 + 1) for xx in range(x0, x1 + 1))
            if not has_white:
                continue
            score = len(comp)
            if best is None or score > best[0]:
                best = (score, x0, y0, x1, y1)
    if not best and not manual:
        return None

    if manual:
        best = (0, int(manual[0] * w), int(manual[1] * h), int(manual[2] * w) - 1, int(manual[3] * h) - 1)
    _, x0, y0, x1, y1 = best
    # warna sekitar mata (cincin 6px), abaikan piksel gelap/transparan
    ring = []
    m = 8
    for yy in range(max(0, y0 - m), min(h, y1 + m)):
        for xx in range(max(0, x0 - m), min(w, x1 + m)):
            if x0 <= xx <= x1 and y0 <= yy <= y1:
                continue
            p = px[xx, yy]
            if p[3] > 200 and lum(p) > 120 and min(p[:3]) < 235:
                ring.append(p[:3])
    ring.sort(key=lambda c: sum(c))
    skin = ring[len(ring) // 2] if ring else (255, 200, 40)
    return {
        'w': w, 'h': h,
        'box': (x0 / w, y0 / h, (x1 + 1) / w, (y1 + 1) / h),
        'skin': '0xFF%02X%02X%02X' % skin,
        'px': (x0, y0, x1, y1),
    }


if __name__ == '__main__':
    debug = sys.argv[sys.argv.index('--debug') + 1] if '--debug' in sys.argv else None
    here = os.path.dirname(__file__)
    for f in sorted(glob.glob(os.path.join(here, '..', 'assets', 'avatar', '*.png'))):
        r = detect(f)
        name = os.path.basename(f)
        if not r:
            print(name, 'TIDAK TERDETEKSI')
            continue
        b = r['box']
        print(f"{name}: size={r['w']}x{r['h']} box=({b[0]:.4f}, {b[1]:.4f}, {b[2]:.4f}, {b[3]:.4f}) skin={r['skin']}")
        if debug:
            im = Image.open(f).convert('RGBA')
            bg = Image.new('RGBA', im.size, (255, 240, 168, 255))
            bg.alpha_composite(im)
            d = ImageDraw.Draw(bg)
            d.rectangle(r['px'], outline=(255, 0, 255, 255), width=3)
            os.makedirs(debug, exist_ok=True)
            bg.convert('RGB').save(os.path.join(debug, name))
