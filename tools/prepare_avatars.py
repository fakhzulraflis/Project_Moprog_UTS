"""Menyiapkan aset avatar untuk animasi.

Untuk setiap PNG di assets/avatar/:
  1. memotong padding transparan (supaya ukuran antar karakter konsisten),
  2. mencari mata terbuka (untuk animasi kedip) atau, kalau tidak ada,
     pipi blush (untuk animasi pipi memerah),
  3. menulis lib/services/avatar_metrics.dart berisi rasio gambar dan posisi
     fitur wajah dalam fraksi 0..1.

Jalankan dari root proyek setiap kali aset avatar diganti:
    python tools/prepare_avatars.py
"""
import glob
import os
from collections import deque

from PIL import Image

from detect_eyes import detect

ROOT = os.path.join(os.path.dirname(__file__), '..')
AVATAR_DIR = os.path.join(ROOT, 'assets', 'avatar')
OUT = os.path.join(ROOT, 'lib', 'services', 'avatar_metrics.dart')

# Jendela pencarian blush (fraksi x0,y0,x1,y1) untuk karakter tanpa mata terbuka.
BLUSH_WINDOW = (0.15, 0.22, 0.85, 0.48)


def trim(path):
    im = Image.open(path).convert('RGBA')
    bbox = im.getchannel('A').point(lambda a: 255 if a > 8 else 0).getbbox()
    if bbox and bbox != (0, 0) + im.size:
        im.crop(bbox).save(path, optimize=True)
        print('  trim', os.path.basename(path), im.size, '->', (bbox[2] - bbox[0], bbox[3] - bbox[1]))


def is_pink(p):
    return p[3] > 200 and p[0] > 235 and 110 < p[1] < 185 and 110 < p[2] < 195 and p[0] - p[1] > 60


def detect_blush(path):
    im = Image.open(path).convert('RGBA')
    w, h = im.size
    px = im.load()
    x0w, y0w = int(BLUSH_WINDOW[0] * w), int(BLUSH_WINDOW[1] * h)
    x1w, y1w = int(BLUSH_WINDOW[2] * w), int(BLUSH_WINDOW[3] * h)
    seen, boxes = set(), []
    for y in range(y0w, y1w):
        for x in range(x0w, x1w):
            if (x, y) in seen or not is_pink(px[x, y]):
                continue
            comp, q = [], deque([(x, y)])
            seen.add((x, y))
            while q:
                cx, cy = q.popleft()
                comp.append((cx, cy))
                for nx, ny in ((cx + 1, cy), (cx - 1, cy), (cx, cy + 1), (cx, cy - 1)):
                    if x0w <= nx < x1w and y0w <= ny < y1w and (nx, ny) not in seen and is_pink(px[nx, ny]):
                        seen.add((nx, ny))
                        q.append((nx, ny))
            if len(comp) < 150:
                continue
            xs = [c[0] for c in comp]
            ys = [c[1] for c in comp]
            boxes.append((min(xs) / w, min(ys) / h, (max(xs) + 1) / w, (max(ys) + 1) / h))
    return sorted(boxes)[:2]


def rect(b):
    return 'Rect.fromLTRB(%.4f, %.4f, %.4f, %.4f)' % b


def main():
    files = sorted(glob.glob(os.path.join(AVATAR_DIR, '*.png')))
    for f in files:
        trim(f)

    entries = []
    for f in files:
        key = os.path.splitext(os.path.basename(f))[0]
        w, h = Image.open(f).size
        eye = detect(f)
        parts = ['aspect: %.4f' % (w / h)]
        if eye:
            parts.append('eye: ' + rect(eye['box']))
            parts.append('skin: Color(%s)' % eye['skin'])
            note = 'mata'
        else:
            blush = detect_blush(f)
            if blush:
                parts.append('blush: [%s]' % ', '.join(rect(b) for b in blush))
            note = 'blush x%d' % len(blush)
        print(f'  {key}: {w}x{h} -> {note}')
        entries.append("  '%s': AvatarMetrics(%s)," % (key, ', '.join(parts)))

    with open(OUT, 'w', encoding='utf-8', newline='\n') as fh:
        fh.write('// DIBUAT OTOMATIS oleh tools/prepare_avatars.py. Jangan diedit manual;\n')
        fh.write('// jalankan ulang skrip tersebut kalau aset di assets/avatar/ diganti.\n')
        fh.write("import 'package:flutter/painting.dart';\n\n")
        fh.write('// Ukuran dan posisi fitur wajah (fraksi 0..1 dari gambar yang sudah di-trim).\n')
        fh.write('class AvatarMetrics {\n')
        fh.write('  final double aspect; // lebar / tinggi\n')
        fh.write('  final Rect? eye; // mata yang terbuka (untuk animasi kedip)\n')
        fh.write('  final Color skin; // warna kulit di sekitar mata\n')
        fh.write('  final List<Rect> blush; // pipi (untuk karakter tanpa mata terbuka)\n\n')
        fh.write('  const AvatarMetrics({\n')
        fh.write('    required this.aspect,\n')
        fh.write('    this.eye,\n')
        fh.write('    this.skin = const Color(0xFFFFC832),\n')
        fh.write('    this.blush = const [],\n')
        fh.write('  });\n')
        fh.write('}\n\n')
        fh.write('const Map<String, AvatarMetrics> avatarMetrics = {\n')
        fh.write('\n'.join(entries) + '\n')
        fh.write('};\n')
    print('ditulis', os.path.relpath(OUT, ROOT))


if __name__ == '__main__':
    main()
