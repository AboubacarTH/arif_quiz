import 'package:arif_quiz/features/journey/presentation/map/journey_region.dart';
import 'package:flutter_test/flutter_test.dart';

/// Le parcours est évolutif : l'admin peut créer autant de niveaux qu'il veut.
/// Ces tests verrouillent la seule chose qui garantit que la map encaisse
/// n'importe quel nombre — le rebouclage des régions et le changement de tour.
void main() {
  group('Bandes', () {
    test('une bande porte cinq niveaux, la derniere peut etre incomplete', () {
      expect(JourneyRegions.bandsFor(1), 1);
      expect(JourneyRegions.bandsFor(5), 1);
      expect(JourneyRegions.bandsFor(6), 2);
      expect(JourneyRegions.bandsFor(30), 6);
      expect(JourneyRegions.bandsFor(31), 7);
    });

    test('une map vide occupe quand meme une bande', () {
      expect(JourneyRegions.bandsFor(0), 1);
    });
  });

  group('Rebouclage', () {
    test('les six premieres bandes montrent six decors differents', () {
      final ids = [
        for (var band = 0; band < JourneyRegions.count; band++)
          JourneyRegions.regionForBand(band).id,
      ];
      expect(ids.toSet().length, JourneyRegions.count,
          reason: 'aucun decor ne doit se repeter dans un tour');
    });

    test('la septieme bande revient au premier decor, au tour suivant', () {
      final first = JourneyRegions.regionForBand(0);
      final seventh = JourneyRegions.regionForBand(JourneyRegions.count);

      expect(seventh.id, first.id);
      expect(JourneyRegions.tourForBand(0), 0);
      expect(JourneyRegions.tourForBand(JourneyRegions.count), 1);
    });

    test('le decor reboucle mais la lumiere change a chaque tour', () {
      final ambiences = [
        for (var tour = 0; tour < JourneyAmbience.values.length; tour++)
          JourneyAmbience.forTour(tour),
      ];
      expect(ambiences.toSet().length, JourneyAmbience.values.length);

      // 6 decors x 4 ambiances : le premier vrai doublon n'arrive qu'ensuite.
      const distinctBands = 6 * 4;
      expect(JourneyRegions.regionForBand(distinctBands).id,
          JourneyRegions.regionForBand(0).id);
      expect(JourneyAmbience.forTour(JourneyRegions.tourForBand(distinctBands)),
          JourneyAmbience.forTour(JourneyRegions.tourForBand(0)));
    });

    test('un numero de niveau tres eleve reste placable', () {
      // 500 niveaux : rien ne doit deborder ni renvoyer un index invalide.
      const level = 500;
      final band = (level - 1) ~/ kAnchorsPerRegion;
      final anchor = JourneyRegions.regionForBand(band)
          .anchors[(level - 1) % kAnchorsPerRegion];

      expect(anchor.dx, inInclusiveRange(0, 1));
      expect(anchor.dy, inInclusiveRange(0, 1));
    });
  });

  group('Ancres', () {
    test('chaque region porte exactement cinq ancres, rangees du bas au haut',
        () {
      for (final region in JourneyRegions.all) {
        expect(region.anchors.length, kAnchorsPerRegion,
            reason: 'region ${region.id}');
        for (var i = 1; i < region.anchors.length; i++) {
          expect(region.anchors[i].dy, lessThan(region.anchors[i - 1].dy),
              reason: 'region ${region.id}, ancre $i doit etre plus haut');
        }
      }
    });

    test('aucune ancre ne touche le bord', () {
      for (final region in JourneyRegions.all) {
        for (final a in region.anchors) {
          expect(a.dx, inExclusiveRange(0.05, 0.95));
          expect(a.dy, inExclusiveRange(0.05, 0.95));
        }
      }
    });
  });

  group('Illustrations', () {
    test('aucune region ne reference d art tant qu on n en a pas depose', () {
      for (final region in JourneyRegions.all) {
        expect(region.artLight, isNull, reason: region.id);
        expect(region.artDark, isNull, reason: region.id);
      }
    });
  });
}
