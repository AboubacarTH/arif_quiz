# -*- coding: utf-8 -*-
"""Le graphique de mise en avant : 1024x500, obligatoire sur une fiche Play.

Il s'affiche en tete de page et dans les listes de recommandation, souvent
recadre : le texte reste donc loin des bords et rien d'essentiel ne touche les
coins.
"""
import os
import sys

from PIL import Image, ImageDraw, ImageFont

sys.stdout.reconfigure(encoding='utf-8', errors='replace')

HERE = os.path.dirname(os.path.abspath(__file__))
FONTS = r'C:\FlutterProjects\arif_quiz\assets\fonts'
ICON = r'C:\FlutterProjects\arif_quiz\assets\images'

BG = (20, 17, 13)
IVORY = (255, 247, 230)
MUTED = (201, 188, 160)
RUST = (194, 65, 12)
GOLD = (234, 179, 8)

W, H = 1024, 500


def font(name, size):
    return ImageFont.truetype(os.path.join(FONTS, name), size)


def build(locale, title, tagline, out_name):
    canvas = Image.new('RGB', (W, H), BG)
    draw = ImageDraw.Draw(canvas)

    # Une bande rouille a gauche : la marque de l'app, sans degrade.
    draw.rectangle([0, 0, 14, H], fill=RUST)

    title_font = font('Nunito-ExtraBold.ttf', 78)
    tag_font = font('Nunito-Regular.ttf', 34)

    x = 86
    draw.text((x, 150), title, font=title_font, fill=IVORY)
    draw.text((x, 258), tagline, font=tag_font, fill=MUTED)

    # Les sept modes, en pastilles : c'est ce qui distingue l'app.
    dots = [
        (RUST, 'Classic'),
        ((239, 68, 68), 'Survival'),
        ((234, 179, 8), 'Speed'),
        ((2, 132, 199), 'Precision'),
        ((21, 128, 61), 'Streak'),
        ((15, 118, 110), 'Time Attack'),
        ((124, 58, 237), 'Jokers'),
    ]
    # Sur deux rangs : les sept sur une seule ligne debordaient du cadre, et
    # Play recadre les bords de ce visuel.
    small = font('Nunito-Bold.ttf', 21)
    limit = W - 110
    cx, cy = x, 344
    for color, label in dots:
        w = draw.textlength(label, font=small) + 44
        if cx + w > limit:
            cx, cy = x, cy + 60
        draw.rounded_rectangle([cx, cy, cx + w, cy + 48], radius=24,
                               outline=color, width=2)
        draw.ellipse([cx + 15, cy + 18, cx + 27, cy + 30], fill=color)
        draw.text((cx + 35, cy + 12), label, font=small, fill=color)
        cx += w + 12

    out = os.path.join(HERE, locale, out_name)
    os.makedirs(os.path.dirname(out), exist_ok=True)
    canvas.save(out, 'PNG')
    print('%s/%s  (%dx%d)' % (locale, out_name, W, H))


build('en', 'ArifQuiz', 'Quizzes, seven game modes, and friends to beat.',
      '00_feature_graphic.png')
