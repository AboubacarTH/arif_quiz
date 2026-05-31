import 'package:arif_quiz/features/quiz/data/quiz_repository.dart';
import 'package:arif_quiz/shared/models/models.dart';
import 'package:flutter/foundation.dart';

abstract class QuizListState {}
class QuizListInitial extends QuizListState {}
class QuizListLoading extends QuizListState {}
class QuizListLoaded extends QuizListState {
  final List<QuizModel> quizzes;
  final bool hasMore;
  final int total;
  QuizListLoaded({required this.quizzes, required this.hasMore, required this.total});
}
class QuizListError extends QuizListState {
  final String message;
  QuizListError(this.message);
}

class QuizListController extends ChangeNotifier {
  final QuizRepository _repo;

  QuizListState _state = QuizListInitial();
  QuizListState get state => _state;

  bool get isLoading => _state is QuizListLoading;
  List<QuizModel> get quizzes => _state is QuizListLoaded ? (_state as QuizListLoaded).quizzes : [];
  bool get hasMore        => _state is QuizListLoaded ? (_state as QuizListLoaded).hasMore : false;
  String? get error       => _state is QuizListError ? (_state as QuizListError).message : null;

  // Filters
  int? categoryId;
  String? difficulty;
  String search = '';
  int _page = 1;
  bool _loadingMore = false;
  bool get loadingMore => _loadingMore;

  QuizListController(this._repo);

  Future<void> load({bool reset = true}) async {
    if (reset) {
      _page = 1;
      _emit(QuizListLoading());
    }
    try {
      final res = await _repo.getQuizzes(
        categoryId: categoryId,
        difficulty: difficulty,
        search: search.isEmpty ? null : search,
        page: _page,
      );
      final current = (!reset && _state is QuizListLoaded)
          ? (_state as QuizListLoaded).quizzes
          : <QuizModel>[];
      _emit(QuizListLoaded(
        quizzes: [...current, ...res.quizzes],
        hasMore: _page < res.lastPage,
        total: res.total,
      ));
    } catch (_) {
      _emit(QuizListError('Failed to load quizzes.'));
    }
  }

  Future<void> loadMore() async {
    if (!hasMore || _loadingMore) return;
    _loadingMore = true;
    notifyListeners();
    _page++;
    await load(reset: false);
    _loadingMore = false;
    notifyListeners();
  }

  void applyFilter({int? catId, String? diff, String? q}) {
    categoryId = catId;
    difficulty = diff;
    search = q ?? '';
    load();
  }

  void _emit(QuizListState s) { _state = s; notifyListeners(); }
}
