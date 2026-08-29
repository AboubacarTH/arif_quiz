# -*- coding: utf-8 -*-
"""Compose les visuels Play Store a partir des captures brutes.

Une capture brute ne fait pas un visuel de fiche : elle est au format de
l'appareil (1080x2460, soit 1:2,28 — au-dela du 2:1 que Play accepte), elle
montre la barre d'etat du telephone (heure, notifications, batterie) et elle
n'annonce rien. Chaque image est donc recadree, posee sur le fond de l'app et
surmontee d'une phrase qui dit ce qu'on regarde.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFilter, ImageFont

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HERE = os.path.dirname(os.path.abspath(__file__))
RAW = os.path.join(HERE, 'raw')
FONTS = r'C:\FlutterProjects\arif_quiz\assets\fonts'

# ── La palette de l'app ────────────────────────────────────────────────────
BG = (20, 17, 13)           # #14110D — le fond sombre
IVORY = (255, 247, 230)     # #FFF7E6
MUTED = (201, 188, 160)     # #C9BCA0
RUST = (194, 65, 12)        # #C2410C
BORDER = (58, 50, 40)

# ── Le format ──────────────────────────────────────────────────────────────
W, H = 1080, 1920           # 9:16, accepte par Play
SHOT_W = 840
SHOT_RADIUS = 44
MARGIN = 72

# Zones a flouter dans une capture donnee : (x0, y0, x1, y1) en pixels source.
# L'adresse e-mail du proprietaire du compte n'a rien a faire sur une fiche
# publique.
REDACT = {
    '07_profile.png': [(300, 715, 790, 780)],
}


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def wrap(draw, text, fnt, max_width):
    """Coupe le texte a la largeur donnee, mot par mot."""
    words, lines, line = text.split(), [], ''
    for word in words:
        probe = (line + ' ' + word).strip()
        if draw.textlength(probe, font=fnt) <= max_width:
            line = probe
        else:
            if line:
                lines.append(line)
            line = word
    if line:
        lines.append(line)
    return lines


def rounded(image, radius):
    mask = Image.new('L', image.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        [0, 0, image.size[0] - 1, image.size[1] - 1], radius=radius, fill=255)
    out = Image.new('RGBA', image.size, (0, 0, 0, 0))
    out.paste(image, (0, 0), mask)
    return out


def compose(raw_name, headline, subline, out_name, crop_top):
    canvas = Image.new('RGB', (W, H), BG)
    draw = ImageDraw.Draw(canvas)

    # ── Le titre ───────────────────────────────────────────────────────────
    title_font = font('Nunito-ExtraBold.ttf', 66)
    sub_font = font('Nunito-Regular.ttf', 38)

    y = 118
    for line in wrap(draw, headline, title_font, W - 2 * MARGIN):
        draw.text((MARGIN, y), line, font=title_font, fill=IVORY)
        y += 82

    y += 14
    for line in wrap(draw, subline, sub_font, W - 2 * MARGIN):
        draw.text((MARGIN, y), line, font=sub_font, fill=MUTED)
        y += 52

    # Un trait rouille sous le titre : la seule marque de couleur de la zone.
    draw.rounded_rectangle([MARGIN, y + 24, MARGIN + 96, y + 32],
                           radius=4, fill=RUST)

    # La capture commence sous le texte, pas a une hauteur fixe : sans quoi un
    # titre court laissait un trou et un titre long venait le toucher.
    shot_top = y + 96

    # ── La capture ─────────────────────────────────────────────────────────
    shot = Image.open(os.path.join(RAW, raw_name)).convert('RGB')

    for box in REDACT.get(raw_name, []):
        region = shot.crop(box).filter(ImageFilter.GaussianBlur(18))
        shot.paste(region, box[:2])

    available = H - shot_top
    src_height = int(available * shot.width / SHOT_W)
    shot = shot.crop((0, crop_top, shot.width,
                      min(crop_top + src_height, shot.height)))
    shot = shot.resize(
        (SHOT_W, int(shot.height * SHOT_W / shot.width)), Image.LANCZOS)

    framed = rounded(shot, SHOT_RADIUS)
    x = (W - SHOT_W) // 2
    canvas.paste(framed, (x, shot_top), framed)

    # Un liseré discret : le fond du visuel et celui de l'app sont le meme
    # noir, sans quoi la capture se fondrait dans la page.
    draw.rounded_rectangle(
        [x, shot_top, x + SHOT_W - 1, shot_top + framed.height - 1],
        radius=SHOT_RADIUS, outline=BORDER, width=2)

    out = os.path.join(HERE, 'en', out_name)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    canvas.save(out, 'PNG')
    print('%s  (%dx%d)' % (out_name, W, H))


SHOTS = [
    ('01_home.png', 'A new challenge every day',
     'Daily challenge, streaks, XP and levels — one tap from home.',
     '01_home.png', 92),
    ('03c_modes_new.png', 'Seven ways to play',
     'Precision, Streak, Time Attack, Jokers — same quiz, new game.',
     '02_modes.png', 250),
    ('04_play.png', 'Beat the clock',
     'One tap to answer, instant feedback, explanations after.',
     '03_play.png', 92),
    ('05_journey.png', 'Climb the journey map',
     'Unlock levels, earn stars, go further into the map.',
     '04_journey.png', 92),
    ('02_quizzes.png', 'Hundreds of quizzes',
     'Search, filter by category and difficulty, and play.',
     '05_quizzes.png', 92),
    ('07_profile.png', 'Every point you earn, tracked',
     'Levels, accuracy, streaks and achievements.',
     '06_profile.png', 92),
]

for raw, head, sub, out, crop in SHOTS:
    compose(raw, head, sub, out, crop)

print('\n%d visuels dans store/en' % len(SHOTS))
