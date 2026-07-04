import 'package:arif_quiz/features/journey/data/journey_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

abstract class JourneyState {}

class JourneyInitial extends JourneyState {}

class JourneyLoading extends JourneyState {}

class JourneyLoaded extends JourneyState {
  final JourneyMapModel map;
  JourneyLoaded(this.map);
}

class JourneyError extends JourneyState {
  final String message;
  JourneyError(this.message);
}

class JourneyController extends ChangeNotifier {
  final JourneyRepository _repo;

  JourneyState _state = JourneyInitial();
  JourneyState get state => _state;

  bool get isLoading => _state is JourneyLoading;
  JourneyMapModel? get map => _state is JourneyLoaded ? (_state as JourneyLoaded).map : null;
  String? get error => _state is JourneyError ? (_state as JourneyError).message : null;

  JourneyController(this._repo);

  Future<void> load() async {
    _emit(JourneyLoading());
    try {
      _emit(JourneyLoaded(await _repo.getMap()));
    } catch (_) {
      _emit(JourneyError('Impossible de charger le parcours.'));
    }
  }

  /// Rechargement silencieux après un niveau terminé (garde la map affichée si l'appel échoue).
  Future<void> refresh() async {
    try {
      _emit(JourneyLoaded(await _repo.getMap()));
    } catch (_) {/* on garde l'état courant */}
  }

  void _emit(JourneyState s) {
    _state = s;
    notifyListeners();
  }
}
