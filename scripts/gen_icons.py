"""
マイフォーチューン占いアイコン生成スクリプト
ダーク神秘系・和風占いテイストのアイコンを7枚生成
"""
from PIL import Image, ImageDraw, ImageFont
import math, os, shutil

SIZE = 512
CORNER_RADIUS = 80

# 出力先
OUT_DIRS = [
    r'G:\マイドライブ\images\myfortune\icon',
    r'C:\Users\Administrator\OneDrive\subwork\smartphone\smart-claude-code\apps\myfortune\assets\icons',
]

# ── ヘルパー ─────────────────────────────────────────────

def make_gradient(w, h, top_color, bottom_color):
    """縦グラデーション背景"""
    img = Image.new('RGB', (w, h))
    draw = ImageDraw.Draw(img)
    for y in range(h):
        t = y / h
        r = int(top_color[0] + (bottom_color[0] - top_color[0]) * t)
        g = int(top_color[1] + (bottom_color[1] - top_color[1]) * t)
        b = int(top_color[2] + (bottom_color[2] - top_color[2]) * t)
        draw.line([(0, y), (w, y)], fill=(r, g, b))
    return img

def add_rounded_mask(img, radius):
    """角丸マスクを適用（JPG用に白背景に貼る）"""
    mask = Image.new('L', img.size, 0)
    d = ImageDraw.Draw(mask)
    d.rounded_rectangle([0, 0, img.width, img.height], radius=radius, fill=255)
    bg = Image.new('RGB', img.size, (20, 20, 46))
    bg.paste(img, mask=mask)
    return bg

def add_glow_circle(draw, cx, cy, r, color, alpha_max=120):
    """中心から外へ薄れるグロー円"""
    for i in range(r, 0, -4):
        alpha = int(alpha_max * (i / r))
        draw.ellipse([cx - i, cy - i, cx + i, cy + i],
                     outline=color + (alpha,), width=2)

def draw_stars(draw, n=30, color=(200, 180, 100, 80)):
    import random
    random.seed(42)
    for _ in range(n):
        x = random.randint(30, SIZE - 30)
        y = random.randint(30, SIZE - 30)
        r = random.randint(1, 3)
        alpha = random.randint(40, 150)
        draw.ellipse([x-r, y-r, x+r, y+r], fill=color[:3] + (alpha,))

def get_font(size):
    paths = [
        r'C:\Windows\Fonts\msgothic.ttc',
        r'C:\Windows\Fonts\meiryo.ttc',
        r'C:\Windows\Fonts\YuGothB.ttc',
        r'C:\Windows\Fonts\arial.ttf',
    ]
    for p in paths:
        if os.path.exists(p):
            try:
                return ImageFont.truetype(p, size)
            except Exception:
                continue
    return ImageFont.load_default()

def centered_text(draw, text, font, y, color, img_w=SIZE):
    bbox = draw.textbbox((0, 0), text, font=font)
    tw = bbox[2] - bbox[0]
    draw.text(((img_w - tw) / 2, y), text, font=font, fill=color)

def label_text(draw, label, font_size=32):
    font = get_font(font_size)
    gold = (212, 175, 55, 230)
    bbox = draw.textbbox((0, 0), label, font=font)
    tw = bbox[2] - bbox[0]
    # 下部に薄い帯
    draw.rectangle([0, SIZE - 90, SIZE, SIZE], fill=(10, 10, 30, 160))
    draw.text(((SIZE - tw) / 2, SIZE - 68), label, font=font, fill=gold)

# ── 各アイコン生成関数 ────────────────────────────────────

def make_bloodtype():
    """血液型占い: 赤い血滴 + 星座円"""
    base = make_gradient(SIZE, SIZE, (20, 10, 35), (50, 10, 20))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=50, color=(200, 160, 160, 60))
    # 星座円
    cx, cy = SIZE//2, SIZE//2 - 20
    for r in [180, 160]:
        d.ellipse([cx-r, cy-r, cx+r, cy+r], outline=(180, 80, 80, 120), width=2)
    # 12星座の点
    for i in range(12):
        angle = i * 30 * math.pi / 180
        px = cx + 170 * math.cos(angle)
        py = cy + 170 * math.sin(angle)
        d.ellipse([px-5, py-5, px+5, py+5], fill=(220, 120, 100, 200))
    # 血液の滴（ドロップ形）
    drop_cx, drop_cy = cx, cy
    # 丸部分
    d.ellipse([drop_cx-55, drop_cy-20, drop_cx+55, drop_cy+90],
              fill=(200, 30, 40, 240))
    # 上の尖り
    points = [(drop_cx, drop_cy - 90), (drop_cx - 50, drop_cy + 10), (drop_cx + 50, drop_cy + 10)]
    d.polygon(points, fill=(200, 30, 40, 240))
    # ハイライト
    d.ellipse([drop_cx-22, drop_cy-10, drop_cx+5, drop_cy+25],
              fill=(255, 130, 130, 160))
    # グロー
    add_glow_circle(d, cx, cy, 130, (200, 30, 40), 60)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, '血液型占い')
    return base

def make_omikuji():
    """おみくじ: 竹筒 + 鳥居"""
    base = make_gradient(SIZE, SIZE, (15, 20, 40), (30, 15, 50))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=40, color=(200, 200, 160, 50))
    # 鳥居（背景シルエット）
    red = (180, 30, 20, 180)
    # 横棒2本
    d.rectangle([SIZE//2 - 110, 60, SIZE//2 + 110, 90], fill=red)
    d.rectangle([SIZE//2 - 90, 100, SIZE//2 + 90, 120], fill=red)
    # 柱2本
    d.rectangle([SIZE//2 - 100, 100, SIZE//2 - 75, 310], fill=red)
    d.rectangle([SIZE//2 + 75, 100, SIZE//2 + 100, 310], fill=red)
    # 竹筒（円柱）
    cx = SIZE // 2
    bx1, by1, bx2, by2 = cx - 55, 200, cx + 55, 400
    d.rectangle([bx1, by1, bx2, by2], fill=(100, 130, 80, 230))
    d.ellipse([bx1, by1 - 20, bx2, by1 + 20], fill=(80, 110, 60, 230))
    # 竹の節
    for y in [260, 320, 380]:
        d.rectangle([bx1, y, bx2, y + 8], fill=(70, 95, 50, 200))
    # おみくじ紙（白い紙が出ている）
    d.rectangle([cx - 15, 140, cx + 15, 230], fill=(240, 235, 210, 220))
    d.line([cx - 12, 160, cx + 12, 160], fill=(180, 60, 60, 200), width=2)
    d.line([cx - 12, 175, cx + 12, 175], fill=(180, 60, 60, 200), width=2)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, 'おみくじ')
    return base

def make_rune():
    """ルーン占い: 石板 + ルーン文字"""
    base = make_gradient(SIZE, SIZE, (25, 20, 40), (15, 15, 30))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=30, color=(180, 180, 220, 50))
    # 石板
    stone_color = (70, 65, 80, 240)
    stone_edge = (100, 95, 110, 200)
    d.rounded_rectangle([SIZE//2 - 120, 80, SIZE//2 + 120, 380],
                        radius=20, fill=stone_color, outline=stone_edge, width=3)
    # 石のテクスチャ（薄いひっかき傷）
    for y in range(100, 380, 20):
        d.line([SIZE//2 - 110, y, SIZE//2 + 110, y + 5],
               fill=(90, 85, 100, 60), width=1)
    # ルーン文字 ᚠ (Fehu) - 手書き風に直線で描く
    gold = (212, 175, 55, 240)
    cx, cy = SIZE//2, SIZE//2 - 30
    # メインの縦線
    d.line([cx, cy - 100, cx, cy + 100], fill=gold, width=8)
    # 右上への2本の斜め線
    d.line([cx, cy - 60, cx + 70, cy - 100], fill=gold, width=8)
    d.line([cx, cy - 10, cx + 70, cy - 50], fill=gold, width=8)
    # 装飾的なドット
    for angle in range(0, 360, 45):
        r = 130
        px = cx + r * math.cos(math.radians(angle))
        py = cy + r * math.sin(math.radians(angle))
        d.ellipse([px-4, py-4, px+4, py+4], fill=gold)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, 'ルーン占い')
    return base

def make_pastlife():
    """前世占い: 渦巻く時空ポータル + シルエット"""
    base = make_gradient(SIZE, SIZE, (10, 5, 30), (30, 20, 60))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=60, color=(180, 160, 220, 80))
    cx, cy = SIZE//2, SIZE//2 - 20
    # 渦巻き（同心円で表現）
    colors = [
        (140, 80, 200, 180), (100, 60, 180, 140),
        (170, 100, 220, 120), (80, 40, 160, 100),
    ]
    for i, (r, col) in enumerate(zip([160, 120, 80, 40], colors)):
        d.ellipse([cx-r, cy-r, cx+r, cy+r], outline=col, width=4)
    # 中心の輝き
    for r, alpha in [(50, 180), (30, 140), (15, 200)]:
        d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=(180, 130, 255, alpha))
    # 人のシルエット（古代）
    sh_x, sh_y = cx, cy + 160
    sc = (40, 30, 70, 200)
    d.ellipse([sh_x - 18, sh_y - 80, sh_x + 18, sh_y - 44], fill=sc)  # 頭
    d.rectangle([sh_x - 20, sh_y - 45, sh_x + 20, sh_y + 10], fill=sc)  # 胴体
    d.line([sh_x - 20, sh_y - 30, sh_x - 45, sh_y - 10], fill=sc, width=8)  # 左腕
    d.line([sh_x + 20, sh_y - 30, sh_x + 45, sh_y - 10], fill=sc, width=8)  # 右腕
    d.line([sh_x - 12, sh_y + 10, sh_x - 18, sh_y + 55], fill=sc, width=8)  # 左脚
    d.line([sh_x + 12, sh_y + 10, sh_x + 18, sh_y + 55], fill=sc, width=8)  # 右脚
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, '前世占い')
    return base

def make_horoscope():
    """ホロスコープ: 星座ホイール + 惑星"""
    base = make_gradient(SIZE, SIZE, (5, 10, 40), (20, 15, 60))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=80, color=(200, 200, 255, 70))
    cx, cy = SIZE//2, SIZE//2 - 10
    gold = (212, 175, 55)
    silver = (192, 192, 210)
    # 外周の大円
    d.ellipse([cx-190, cy-190, cx+190, cy+190], outline=gold+(150,), width=2)
    d.ellipse([cx-160, cy-160, cx+160, cy+160], outline=silver+(100,), width=1)
    d.ellipse([cx-130, cy-130, cx+130, cy+130], outline=gold+(80,), width=1)
    # 12宮の区切り線
    for i in range(12):
        angle = i * 30 * math.pi / 180
        x1 = cx + 130 * math.cos(angle)
        y1 = cy + 130 * math.sin(angle)
        x2 = cx + 190 * math.cos(angle)
        y2 = cy + 190 * math.sin(angle)
        d.line([x1, y1, x2, y2], fill=gold+(120,), width=1)
    # 星座の点（外周）
    for i in range(12):
        angle = (i * 30 + 15) * math.pi / 180
        px = cx + 175 * math.cos(angle)
        py = cy + 175 * math.sin(angle)
        d.ellipse([px-5, py-5, px+5, py+5], fill=gold+(200,))
    # 中央の十字線
    d.line([cx - 90, cy, cx + 90, cy], fill=silver+(150,), width=1)
    d.line([cx, cy - 90, cx, cy + 90], fill=silver+(150,), width=1)
    # 中心の太陽
    for r, col, a in [(38, (255, 200, 50), 220), (25, (255, 220, 100), 240), (12, (255, 240, 160), 255)]:
        d.ellipse([cx-r, cy-r, cx+r, cy+r], fill=col+(a,))
    # 光線
    for angle in range(0, 360, 45):
        r1, r2 = 42, 65
        x1 = cx + r1 * math.cos(math.radians(angle))
        y1 = cy + r1 * math.sin(math.radians(angle))
        x2 = cx + r2 * math.cos(math.radians(angle))
        y2 = cy + r2 * math.sin(math.radians(angle))
        d.line([x1, y1, x2, y2], fill=gold+(200,), width=2)
    # 惑星2〜3個
    for angle, r_orb, r_dot, col in [(60, 100, 8, (100, 150, 220, 220)),
                                      (200, 80, 6, (180, 100, 80, 220))]:
        px = cx + r_orb * math.cos(math.radians(angle))
        py = cy + r_orb * math.sin(math.radians(angle))
        d.ellipse([px-r_dot, py-r_dot, px+r_dot, py+r_dot], fill=col)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, 'ホロスコープ')
    return base

def make_fourpillars():
    """四柱推命: 四本の柱 + 東洋装飾"""
    base = make_gradient(SIZE, SIZE, (30, 10, 10), (20, 15, 30))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=25, color=(220, 180, 100, 50))
    red = (180, 30, 20, 230)
    gold = (212, 175, 55, 230)
    # 4本の柱
    pillar_xs = [120, 195, 270, 345]
    for px in pillar_xs:
        # 柱本体
        d.rectangle([px - 22, 150, px + 22, 360], fill=red)
        # 柱頭（上部の装飾）
        d.rectangle([px - 30, 130, px + 30, 158], fill=gold)
        d.rectangle([px - 35, 120, px + 35, 138], fill=red)
        # 柱脚
        d.rectangle([px - 28, 355, px + 28, 380], fill=gold)
    # 横梁（上部）
    d.rectangle([100, 100, SIZE - 100, 125], fill=red)
    d.rectangle([90, 85, SIZE - 90, 108], fill=gold)
    # 中央の「命」的な装飾（円+縦線）
    cx = SIZE // 2
    d.ellipse([cx - 40, 195, cx + 40, 275], fill=(40, 10, 10, 230),
              outline=gold, width=3)
    # 縦線（命の略字的）
    d.line([cx, 210, cx, 260], fill=gold, width=5)
    d.line([cx - 20, 225, cx + 20, 225], fill=gold, width=4)
    d.line([cx - 15, 242, cx + 15, 242], fill=gold, width=3)
    # 雲形装飾（上部）
    for x in [130, 195, 260, 325]:
        d.ellipse([x - 15, 65, x + 15, 90], fill=gold)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, '四柱推命')
    return base

def make_calendar():
    """縁起カレンダー: カレンダー + 吉日の赤印"""
    base = make_gradient(SIZE, SIZE, (10, 20, 40), (25, 15, 45))
    overlay = Image.new('RGBA', (SIZE, SIZE), (0, 0, 0, 0))
    d = ImageDraw.Draw(overlay)
    draw_stars(d, n=35, color=(200, 200, 160, 50))
    # カレンダー本体
    cal_l, cal_t, cal_r, cal_b = 80, 100, SIZE - 80, SIZE - 100
    d.rounded_rectangle([cal_l, cal_t, cal_r, cal_b],
                        radius=12, fill=(30, 35, 60, 230),
                        outline=(80, 100, 140, 200), width=2)
    # ヘッダー（月名エリア）
    d.rounded_rectangle([cal_l, cal_t, cal_r, cal_t + 70],
                        radius=12, fill=(50, 40, 80, 240))
    # カレンダーリングの穴
    for x in [160, 256, 352]:
        d.ellipse([x - 12, cal_t - 15, x + 12, cal_t + 15],
                  fill=(30, 35, 60, 240), outline=(100, 120, 160, 180), width=3)
    gold = (212, 175, 55, 230)
    # ヘッダーのテキスト代わり（横線）
    for y_offset in [20, 35]:
        d.line([cal_l + 40, cal_t + y_offset, cal_r - 40, cal_t + y_offset],
               fill=gold, width=2 if y_offset == 20 else 1)
    # グリッド線
    cell_w = (cal_r - cal_l) / 7
    cell_h = 55
    grid_top = cal_t + 80
    for col in range(1, 7):
        x = cal_l + col * cell_w
        d.line([x, grid_top, x, cal_b - 10], fill=(60, 80, 100, 100), width=1)
    for row in range(1, 5):
        y = grid_top + row * cell_h
        d.line([cal_l + 10, y, cal_r - 10, y], fill=(60, 80, 100, 100), width=1)
    # 吉日の赤丸マーク（3〜4か所）
    auspicious = [(1, 0), (3, 1), (5, 2), (1, 3)]
    for col, row in auspicious:
        cell_cx = cal_l + (col + 0.5) * cell_w
        cell_cy = grid_top + (row + 0.5) * cell_h
        r = 20
        d.ellipse([cell_cx - r, cell_cy - r, cell_cx + r, cell_cy + r],
                  fill=(200, 30, 30, 200), outline=(240, 80, 60, 240), width=2)
    # 吉の字的な×印（金）
    lucky_col, lucky_row = 5, 0
    lx = cal_l + (lucky_col + 0.5) * cell_w
    ly = grid_top + (lucky_row + 0.5) * cell_h
    r2 = 22
    d.ellipse([lx - r2, ly - r2, lx + r2, ly + r2],
              fill=(180, 140, 20, 200), outline=gold, width=3)
    base.paste(overlay, mask=overlay.split()[3])
    d2 = ImageDraw.Draw(base)
    label_text(d2, '縁起カレンダー')
    return base

# ── メイン ──────────────────────────────────────────────

ICONS = [
    ('icon_bloodtype.jpg',  make_bloodtype),
    ('icon_omikuji.jpg',    make_omikuji),
    ('icon_rune.jpg',       make_rune),
    ('icon_pastlife.jpg',   make_pastlife),
    ('icon_horoscope.jpg',  make_horoscope),
    ('icon_fourpillars.jpg',make_fourpillars),
    ('icon_calendar.jpg',   make_calendar),
]

def save_icon(img, filename):
    # 角丸適用
    img = add_rounded_mask(img, CORNER_RADIUS)
    for out_dir in OUT_DIRS:
        path = os.path.join(out_dir, filename)
        img.save(path, 'JPEG', quality=92)
        print(f'  OK {path}')

if __name__ == '__main__':
    print(f'アイコン生成開始 ({len(ICONS)}枚)')
    for filename, gen_fn in ICONS:
        print(f'\n[{filename}]')
        img = gen_fn()
        save_icon(img, filename)
    print('\nDone! All icons generated.')
