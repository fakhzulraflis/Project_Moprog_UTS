import '../models/question.dart';
import 'api_service.dart';

class QuestionService {
  QuestionService._();

  static final Map<int, List<Question>> _cache = {};
  static final Map<int, Future<List<Question>>> _inflight = {};

  static List<Question>? peek(int lessonId) => _cache[lessonId];

  static Future<List<Question>> getQuestions(
    int lessonId, {
    bool forceRefresh = false,
  }) {
    if (!forceRefresh) {
      final cached = _cache[lessonId];

      if (cached != null) {
        return Future.value(cached);
      }

      final pending = _inflight[lessonId];

      if (pending != null) {
        return pending;
      }
    }

    final request = ApiService.getQuestions(lessonId)
        .then((questions) {
          if (questions.isNotEmpty) {
            _cache[lessonId] = questions;
          }

          return questions;
        })
        .whenComplete(() {
          _inflight.remove(lessonId);
        });

    _inflight[lessonId] = request;

    return request;
  }

  static Future<void> prefetch(Iterable<int> lessonIds) async {
    for (final id in lessonIds) {
      try {
        await getQuestions(id);
      } catch (_) {}
    }
  }

  static void clearCache([int? lessonId]) {
    if (lessonId == null) {
      _cache.clear();
    } else {
      _cache.remove(lessonId);
    }
  }
}
