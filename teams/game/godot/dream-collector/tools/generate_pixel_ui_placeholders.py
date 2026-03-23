#!/usr/bin/env python3
"""
Generate pixel-art UI PNGs for Dream Collector.

Target style: match the provided sample screenshot:
- warm parchment/beige panels
- thick dark-brown outline
- subtle inner highlight + drop shadow
- saturated, clean button fills (blue / gold) with bevel

Run from project root:
  python3 tools/generate_pixel_ui_placeholders.py
"""
import os
import struct

# Sample-matching palette (RGB)
# (Keep limited colors for crisp pixel look)
PALETTE = {
    # Dark bars / background
    "bar_dark": (0x1E, 0x1E, 0x24),      # near-black
    "bar_dark_2": (0x2A, 0x2A, 0x32),    # slightly lighter
    # Parchment panel
    "panel": (0xE8, 0xDC, 0xC8),         # beige
    "panel_hi": (0xF2, 0xEB, 0xD8),      # inner highlight
    "panel_lo": (0xD9, 0xCC, 0xB7),      # inner shade
    # Outline / shadow
    "outline": (0x2C, 0x24, 0x16),       # dark brown/near-black
    "shadow": (0x14, 0x14, 0x18),        # drop shadow
    # Accents
    "gold": (0xE8, 0xA8, 0x4A),          # warm gold/orange
    "gold_lo": (0xC4, 0x89, 0x2E),       # darker gold
    "blue": (0x6B, 0x8C, 0xBE),          # saturated soft blue
    "blue_hi": (0x86, 0xA6, 0xD6),       # highlight
    "green": (0x6D, 0xB1, 0x52),         # status green
    "red": (0xC4, 0x3C, 0x3C),           # status red
    "white": (0xFF, 0xFF, 0xFF),
    "transparent": (0, 0, 0, 0),
}

BASE = os.path.join(os.path.dirname(__file__), "..", "assets", "ui", "pixel")

def write_png(path, width, height, pixel_fn):
    """Write a minimal PNG (no PIL). pixel_fn(x, y) -> (r,g,b) or (r,g,b,a)."""
    def rgba(x, y):
        p = pixel_fn(x, y)
        # support RGB, RGBA, or nested ((r,g,b),a)
        if isinstance(p, tuple) and len(p) == 2 and isinstance(p[0], tuple) and len(p[0]) == 3:
            (r, g, b), a = p
            return (r, g, b, a)
        # if pixel_fn already returned a 4-tuple, trust it
        if isinstance(p, tuple) and len(p) == 4:
            return p
        if len(p) == 3:
            return (*p, 255)
        return p

    raw = bytearray()
    for y in range(height):
        raw.append(0)  # filter byte
        for x in range(width):
            r, g, b, a = rgba(x, y)
            raw.extend((r, g, b, a))

    # PNG signature
    signature = b'\x89PNG\r\n\x1a\n'

    def chunk(ctype, data):
        chunk_data = ctype + data
        return struct.pack(">I", len(data)) + chunk_data + struct.pack(">I", 0xFFFFFFFF & __import__("zlib").crc32(chunk_data))

    ihdr = struct.pack(">IIBBBBB", width, height, 8, 6, 0, 0, 0)  # 8bit RGBA
    idat = __import__("zlib").compress(raw, 9)
    iend = b""

    png = signature + chunk(b"IHDR", ihdr) + chunk(b"IDAT", idat) + chunk(b"IEND", iend)
    os.makedirs(os.path.dirname(path), exist_ok=True)
    with open(path, "wb") as f:
        f.write(png)

def _rgba(rgb, a=255):
    # accept RGB or RGBA inputs
    if isinstance(rgb, tuple) and len(rgb) == 4:
        return rgb
    return (*rgb, a)

def panel_frame(path, w, h, r=8, shadow=2):
    """
    Rounded-ish pixel frame with:
    - 2px outline
    - 1px inner highlight (top/left)
    - 1px inner shade (bottom/right)
    - 2px drop shadow (bottom/right)
    """
    outline = PALETTE["outline"]
    fill = PALETTE["panel"]
    hi = PALETTE["panel_hi"]
    lo = PALETTE["panel_lo"]
    sh = PALETTE["shadow"]

    def in_round_corner(x, y, cx, cy, rad):
        # simple squared distance for pixel rounding
        dx = x - cx
        dy = y - cy
        return dx * dx + dy * dy <= rad * rad

    def is_outside_rounded_rect(x, y):
        # outer rect bounds
        if x < 0 or y < 0 or x >= w or y >= h:
            return True
        # handle 4 corners
        if x < r and y < r:
            return not in_round_corner(x, y, r - 1, r - 1, r - 1)
        if x >= w - r and y < r:
            return not in_round_corner(x, y, w - r, r - 1, r - 1)
        if x < r and y >= h - r:
            return not in_round_corner(x, y, r - 1, h - r, r - 1)
        if x >= w - r and y >= h - r:
            return not in_round_corner(x, y, w - r, h - r, r - 1)
        return False

    def pixel(x, y):
        # shadow behind
        if shadow > 0:
            sx, sy = x - shadow, y - shadow
            if 0 <= sx < w and 0 <= sy < h and not is_outside_rounded_rect(sx, sy):
                # draw shadow only if current pixel is outside main shape
                if is_outside_rounded_rect(x, y):
                    return _rgba(sh, 200)

        if is_outside_rounded_rect(x, y):
            return _rgba(PALETTE["transparent"], 0)

        # outline thickness 2
        if x < 2 or y < 2 or x >= w - 2 or y >= h - 2:
            return _rgba(outline)

        # inner bevel: highlight top/left, shade bottom/right
        if x == 2 or y == 2:
            return _rgba(hi)
        if x == w - 3 or y == h - 3:
            return _rgba(lo)

        return _rgba(fill)

    write_png(path, w, h, pixel)

def button_bevel(path, w, h, kind="blue"):
    outline = PALETTE["outline"]
    if kind == "gold":
        base = PALETTE["gold"]
        top = PALETTE["white"]
        bot = PALETTE["gold_lo"]
    elif kind == "green":
        base = PALETTE["green"]
        top = PALETTE["white"]
        bot = (0x4A, 0x9B, 0x5C)
    elif kind == "red":
        base = PALETTE["red"]
        top = PALETTE["white"]
        bot = (0x92, 0x2A, 0x2A)
    else:
        base = PALETTE["blue"]
        top = PALETTE["blue_hi"]
        bot = (0x4C, 0x6F, 0xA6)

    def pixel(x, y):
        # simple rounded rectangle feel
        if x < 2 or y < 2 or x >= w - 2 or y >= h - 2:
            return _rgba(outline)
        # bevel
        if x == 2 or y == 2:
            return _rgba(top)
        if x == w - 3 or y == h - 3:
            return _rgba(bot)
        return _rgba(base)

    write_png(path, w, h, pixel)

def bar_track(path, w, h):
    outline = PALETTE["outline"]
    fill = PALETTE["bar_dark_2"]
    def pixel(x, y):
        if x < 2 or y < 2 or x >= w - 2 or y >= h - 2:
            return _rgba(outline)
        return _rgba(fill)
    write_png(path, w, h, pixel)

def bar_fill(path, w, h, color_key="green"):
    outline = PALETTE["outline"]
    color = PALETTE.get(color_key, PALETTE["green"])
    hi = PALETTE["white"]
    def pixel(x, y):
        if x < 2 or y < 2 or x >= w - 2 or y >= h - 2:
            return _rgba(outline)
        if y == 2:
            return _rgba(hi)
        return _rgba(color)
    write_png(path, w, h, pixel)

def slot_frame(path, size, edge_rgb, fill_rgb):
    outline = PALETTE["outline"]
    hi = PALETTE["panel_hi"]
    def pixel(x, y):
        if x < 2 or y < 2 or x >= size - 2 or y >= size - 2:
            return _rgba(outline)
        if x < 5 or y < 5 or x >= size - 5 or y >= size - 5:
            return _rgba(edge_rgb)
        if x == 5 or y == 5:
            return _rgba(hi)
        return _rgba(fill_rgb)
    write_png(path, size, size, pixel)

def main():
    # Panels
    panel_frame(os.path.join(BASE, "panels", "panel_frame.png"), 64, 64, r=10, shadow=2)
    panel_frame(os.path.join(BASE, "panels", "panel_dark.png"), 64, 64, r=10, shadow=2)
    panel_frame(os.path.join(BASE, "panels", "modal_frame.png"), 64, 64, r=10, shadow=2)
    panel_frame(os.path.join(BASE, "panels", "tooltip_frame.png"), 48, 32, r=8, shadow=2)
    panel_frame(os.path.join(BASE, "hud", "hud_frame.png"), 64, 32, r=8, shadow=2)
    panel_frame(os.path.join(BASE, "hud", "hud_pill.png"), 48, 24, r=8, shadow=2)
    panel_frame(os.path.join(BASE, "hud", "section_header.png"), 64, 24, r=8, shadow=2)

    # Buttons
    button_bevel(os.path.join(BASE, "buttons", "btn_primary.png"), 128, 40, "gold")
    button_bevel(os.path.join(BASE, "buttons", "btn_secondary.png"), 128, 40, "blue")
    button_bevel(os.path.join(BASE, "buttons", "btn_green.png"), 128, 40, "green")
    button_bevel(os.path.join(BASE, "buttons", "btn_red.png"), 128, 40, "red")
    button_bevel(os.path.join(BASE, "buttons", "btn_purple.png"), 128, 40, "blue")
    button_bevel(os.path.join(BASE, "buttons", "btn_disabled.png"), 128, 40, "blue")

    # Bars
    bar_track(os.path.join(BASE, "bars", "bar_track.png"), 64, 24)
    bar_fill(os.path.join(BASE, "bars", "bar_fill_hp.png"), 64, 24, "green")
    bar_fill(os.path.join(BASE, "bars", "bar_fill_mana.png"), 64, 24, "primary")
    bar_fill(os.path.join(BASE, "bars", "bar_fill_exp.png"), 64, 24, "gold_dark")
    bar_fill(os.path.join(BASE, "bars", "bar_fill_atb.png"), 64, 24, "primary")  # ATB bar

    # Slots
    slot_frame(os.path.join(BASE, "slots", "slot_empty.png"), 48, PALETTE["panel_lo"], PALETTE["panel"])
    slot_frame(os.path.join(BASE, "slots", "slot_normal.png"), 48, PALETTE["blue"], PALETTE["panel"])
    slot_frame(os.path.join(BASE, "slots", "slot_rare.png"), 48, PALETTE["blue_hi"], PALETTE["panel"])
    slot_frame(os.path.join(BASE, "slots", "slot_epic.png"), 48, (0x8B, 0x5A, 0x9B), PALETTE["panel"])
    slot_frame(os.path.join(BASE, "slots", "slot_legend.png"), 48, PALETTE["gold"], PALETTE["panel"])

    # Tabs
    panel_frame(os.path.join(BASE, "tabs", "tab_bar_frame.png"), 128, 48, r=10, shadow=2)
    panel_frame(os.path.join(BASE, "tabs", "tab_active_bg.png"), 64, 40, r=10, shadow=2)

    # Lists
    panel_frame(os.path.join(BASE, "lists", "list_item_normal.png"), 64, 48, r=8, shadow=2)
    panel_frame(os.path.join(BASE, "lists", "list_item_rare.png"), 64, 48, r=8, shadow=2)
    panel_frame(os.path.join(BASE, "lists", "list_item_legend.png"), 64, 48, r=8, shadow=2)

    # Cards (simple frames by type color)
    def card_edge(name, r, g, b):
        def px(x, y):
            if x < 2 or y < 2 or x >= 64 - 2 or y >= 80 - 2:
                return _rgba(PALETTE["outline"])
            if x < 6 or y < 6 or x >= 64 - 6 or y >= 80 - 6:
                return _rgba((r, g, b))
            return _rgba(PALETTE["panel"])
        write_png(os.path.join(BASE, "cards", name + ".png"), 64, 80, px)
    card_edge("card_attack", *PALETTE["red"])
    card_edge("card_skill", *PALETTE["green"])
    card_edge("card_power", *PALETTE["blue"])
    card_edge("card_curse", *PALETTE["gold"])
    panel_frame(os.path.join(BASE, "cards", "card_cost_badge.png"), 24, 24, r=6, shadow=1)

    # Misc
    def divider_gold_px(x, y):
        return _rgba(PALETTE["gold"]) if y < 3 else (0, 0, 0, 0)
    write_png(os.path.join(BASE, "misc", "divider_gold.png"), 64, 4, divider_gold_px)
    def divider_subtle_px(x, y):
        return _rgba(PALETTE["outline"], 120)
    write_png(os.path.join(BASE, "misc", "divider_subtle.png"), 64, 2, divider_subtle_px)

    # Popup overlay (soft dark vignette)
    def popup_overlay(x, y):
        a = 140
        if x < 8 or x >= 56 or y < 8 or y >= 56:
            a = 200
        if x < 4 or x >= 60 or y < 4 or y >= 60:
            a = 230
        return (*PALETTE["shadow"], a)
    write_png(os.path.join(BASE, "misc", "popup_overlay.png"), 64, 64, popup_overlay)

    # Mana circle (track + fill)
    def circle_track(x, y):
        cx, cy = 32, 32
        d = (x - cx) ** 2 + (y - cy) ** 2
        if d > 30 ** 2 or d < 24 ** 2:
            return (0, 0, 0, 0)
        if d > 28 ** 2 or d < 26 ** 2:
            return _rgba(PALETTE["outline"])
        return _rgba(PALETTE["bar_dark_2"])
    write_png(os.path.join(BASE, "misc", "mana_circle_track.png"), 64, 64, circle_track)
    def circle_fill(x, y):
        cx, cy = 32, 32
        d = (x - cx) ** 2 + (y - cy) ** 2
        if d > 24 ** 2:
            return (0, 0, 0, 0)
        if d > 22 ** 2:
            return _rgba(PALETTE["outline"])
        if y < 26 and d < 18 ** 2:
            return _rgba(PALETTE["white"])
        return _rgba(PALETTE["blue"])
    write_png(os.path.join(BASE, "misc", "mana_circle_fill.png"), 64, 64, circle_fill)
    # Coin badge (circle)
    def coin(x, y):
        if (x - 16) ** 2 + (y - 16) ** 2 > 14 ** 2:
            return (0, 0, 0, 0)
        # rim + fill
        d = (x - 16) ** 2 + (y - 16) ** 2
        if d > 12 ** 2:
            return _rgba(PALETTE["outline"])
        if d < 9 ** 2 and y < 14:
            return _rgba(PALETTE["white"])
        return _rgba(PALETTE["gold"])
    write_png(os.path.join(BASE, "badges", "coin_badge.png"), 32, 32, coin)

    # Notification badge (small red circle)
    def notif(x, y):
        cx, cy = 16, 16
        d = (x - cx) ** 2 + (y - cy) ** 2
        if d > 14 ** 2:
            return (0, 0, 0, 0)
        if d > 12 ** 2:
            return _rgba(PALETTE["outline"])
        if y < 12 and d < 10 ** 2:
            return _rgba(PALETTE["white"])
        return _rgba(PALETTE["red"])
    write_png(os.path.join(BASE, "badges", "notif_badge.png"), 32, 32, notif)

    # Level badge (gold rim + parchment fill)
    def level_badge(x, y):
        cx, cy = 16, 16
        d = (x - cx) ** 2 + (y - cy) ** 2
        if d > 14 ** 2:
            return (0, 0, 0, 0)
        if d > 12 ** 2:
            return _rgba(PALETTE["outline"])
        if d > 10 ** 2:
            return _rgba(PALETTE["gold"])
        if y < 12 and d < 8 ** 2:
            return _rgba(PALETTE["white"])
        return _rgba(PALETTE["panel"])
    write_png(os.path.join(BASE, "badges", "level_badge.png"), 32, 32, level_badge)

    # Scroll button (gold chevron button)
    def scroll_btn(x, y):
        if x < 2 or y < 2 or x >= 30 or y >= 30:
            return _rgba(PALETTE["outline"])
        if x == 2 or y == 2:
            return _rgba(PALETTE["white"])
        if x == 29 or y == 29:
            return _rgba(PALETTE["gold_lo"])
        if 10 <= x <= 22 and 12 <= y <= 18 and abs((x - 16)) <= (y - 12):
            return _rgba(PALETTE["outline"])
        return _rgba(PALETTE["gold"])
    write_png(os.path.join(BASE, "badges", "scroll_btn.png"), 32, 32, scroll_btn)

    # Icons (BottomNav) — 32x32, 이미지와 동일 스타일
    ICONS_DIR = os.path.join(BASE, "icons")
    outline = PALETTE["outline"]
    brown = (0x6B, 0x55, 0x3D)  # 갈색 건물
    grey_blade = (0x7A, 0x7A, 0x85)
    light_hilt = (0xC4, 0x89, 0x2E)
    dark_hilt = (0x5C, 0x45, 0x2A)
    gold_helmet = PALETTE["gold"]
    orange_arrow = (0xE8, 0x78, 0x28)

    def icon_shop(x, y):
        # 갈색 상점 건물 + 노란 천막 + 어두운 입구
        if x < 2 or y < 2 or x >= 30 or y >= 30:
            return _rgba(outline)
        # 노란 천막 (이미지: yellow awning)
        if 5 <= y <= 11 and 6 <= x <= 25:
            return _rgba(PALETTE["gold"])
        if y == 12 and 5 <= x <= 26:
            return _rgba(outline)
        # 갈색 건물 몸체
        if 13 <= y <= 28 and 7 <= x <= 24:
            if 18 <= y <= 27 and 13 <= x <= 18:
                return _rgba(PALETTE["bar_dark"])  # 어두운 입구
            if x == 7 or x == 24 or y == 13 or y == 28:
                return _rgba(outline)
            if x == 8 or y == 14:
                return _rgba(PALETTE["panel_hi"])
            return _rgba(brown)
        return (0, 0, 0, 0)

    def icon_character(x, y):
        # 황금 기사 투구 (golden knight helmet), 어두운 바이저·측면
        cx, cy = 16, 14
        # 투구 둥근 형태 (타원)
        if 6 <= y <= 24 and 8 <= x <= 24:
            if y <= 10:  # 꼭대기
                if 12 <= x <= 20 and (x - 16) ** 2 + (y - 8) ** 2 <= 36:
                    return _rgba(outline if (x - 16) ** 2 + (y - 8) ** 2 >= 25 else gold_helmet)
            if 11 <= y <= 13:  # 바이저 (어두운 가로 띠)
                if 9 <= x <= 23:
                    return _rgba(outline)
            if 14 <= y <= 24:
                if x in (8, 24) or y == 24:
                    return _rgba(outline)
                if x == 9 or y == 15:
                    return _rgba(PALETTE["panel_hi"])
                return _rgba(gold_helmet)
        return (0, 0, 0, 0)

    def icon_cards(x, y):
        # 녹색 육각형 + 주황 위 화살표 + 금색 테두리 (progression)
        cx, cy = 16, 16
        dy = abs(y - cy)
        w = 10 - dy // 2
        in_hex = abs(x - cx) <= w and dy <= 10
        if in_hex:
            if abs(x - cx) >= 8 or dy >= 8:
                return _rgba(outline)
            if 12 <= y <= 17 and abs(x - 16) <= (17 - y):
                return _rgba(orange_arrow)
            return _rgba(PALETTE["green"])
        if 3 <= y <= 29 and 5 <= x <= 27:
            if dy >= 9 or abs(x - cx) >= w + 1:
                return _rgba(PALETTE["gold"])
        return (0, 0, 0, 0)

    def icon_upgrade_crossed(x, y):
        # 교차 검 두 자루 (픽셀)
        if x < 2 or y < 2 or x >= 30 or y >= 30:
            return _rgba(outline)
        # 대각선 \ (좌상→우하, 2px 두께)
        for i in range(24):
            xx, yy = 6 + i, 6 + i
            if xx <= x <= xx + 2 and yy <= y <= yy + 2:
                return _rgba(light_hilt if i < 2 or i > 21 else grey_blade)
        # 대각선 / (우상→좌하)
        for i in range(24):
            xx, yy = 25 - i, 6 + i
            if xx <= x <= xx + 2 and yy <= y <= yy + 2:
                return _rgba(dark_hilt if i < 2 or i > 21 else grey_blade)
        return (0, 0, 0, 0)

    def icon_home(x, y):
        # 집 (지붕 + 베이지 몸체 + 문)
        if 7 <= y <= 26 and 8 <= x <= 24:
            if y <= 13:
                if abs(x - 16) + (y - 7) <= 8:
                    return _rgba(outline if y == 7 or abs(x - 16) + (y - 7) == 8 else PALETTE["gold"])
            else:
                if x in (8, 24) or y in (14, 26):
                    return _rgba(outline)
                if x == 9 or y == 15:
                    return _rgba(PALETTE["white"])
                if 18 <= y <= 26 and 14 <= x <= 17:
                    return _rgba(PALETTE["bar_dark_2"])
                return _rgba(PALETTE["panel"])
        return (0, 0, 0, 0)

    def icon_locked(x, y):
        # 회색 자물쇠 (grey padlock, dark outline)
        if x < 2 or y < 2 or x >= 30 or y >= 30:
            return _rgba(outline)
        grey = (0x88, 0x88, 0x8A)
        # 몸체 (둥근 사각)
        if 14 <= y <= 28 and 10 <= x <= 22:
            if 14 <= y <= 16 and 12 <= x <= 20:
                return _rgba(outline)  # 상단 아치
            if x in (10, 22) or y == 28:
                return _rgba(outline)
            return _rgba(grey)
        if 18 <= y <= 28 and 14 <= x <= 18:
            return _rgba(outline)
        return (0, 0, 0, 0)

    write_png(os.path.join(ICONS_DIR, "icon_nav_shop.png"), 32, 32, icon_shop)
    write_png(os.path.join(ICONS_DIR, "icon_nav_character.png"), 32, 32, icon_character)
    write_png(os.path.join(ICONS_DIR, "icon_nav_cards.png"), 32, 32, icon_cards)
    write_png(os.path.join(ICONS_DIR, "icon_nav_upgrade.png"), 32, 32, icon_upgrade_crossed)
    write_png(os.path.join(ICONS_DIR, "icon_nav_home.png"), 32, 32, icon_home)
    write_png(os.path.join(ICONS_DIR, "icon_nav_locked.png"), 32, 32, icon_locked)

    # 장비 슬롯 타입 아이콘 (무기/방어구/반지/목걸이) — 24x24
    def icon_weapon(x, y):
        # 검 실루엣
        if x < 1 or y < 1 or x >= 23 or y >= 23:
            return (0, 0, 0, 0)
        if 10 <= x <= 13 and 4 <= y <= 20:
            return _rgba(grey_blade)
        if 8 <= x <= 15 and 18 <= y <= 22:
            return _rgba(light_hilt)
        if 10 <= x <= 13 and 2 <= y <= 5:
            return _rgba(outline)
        return (0, 0, 0, 0)

    def icon_armor(x, y):
        # 방패/갑옷 실루엣
        if x < 1 or y < 1 or x >= 23 or y >= 23:
            return (0, 0, 0, 0)
        if 6 <= x <= 17 and 4 <= y <= 20:
            if x in (6, 17) or y in (4, 20):
                return _rgba(outline)
            if x == 7 or y == 5:
                return _rgba(PALETTE["panel_hi"])
            return _rgba(PALETTE["blue"])
        return (0, 0, 0, 0)

    def icon_ring(x, y):
        # 반지 (원형)
        cx, cy = 12, 12
        d = (x - cx) ** 2 + (y - cy) ** 2
        if 4 ** 2 <= d <= 9 ** 2:
            return _rgba(outline)
        if d < 4 ** 2:
            return _rgba(gold_helmet)
        return (0, 0, 0, 0)

    def icon_necklace(x, y):
        # 목걸이 펜던트 (실 + 금 펜던트)
        if 11 <= x <= 13 and 4 <= y <= 18:
            return _rgba(outline)
        if 10 <= x <= 14 and 16 <= y <= 20:
            if 11 <= x <= 13 and 17 <= y <= 19:
                return _rgba(gold_helmet)
            if x in (10, 14) or y in (16, 20):
                return _rgba(outline)
        return (0, 0, 0, 0)

    write_png(os.path.join(ICONS_DIR, "icon_equip_weapon.png"), 24, 24, icon_weapon)
    write_png(os.path.join(ICONS_DIR, "icon_equip_armor.png"), 24, 24, icon_armor)
    write_png(os.path.join(ICONS_DIR, "icon_equip_ring.png"), 24, 24, icon_ring)
    write_png(os.path.join(ICONS_DIR, "icon_equip_necklace.png"), 24, 24, icon_necklace)

    print("Placeholder pixel UI PNGs written to", BASE)

if __name__ == "__main__":
    main()
