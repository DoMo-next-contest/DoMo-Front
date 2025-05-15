import 'package:domo/models/task.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// subtask_persistence.dart
class SubtaskPersistence {
  static Future<void> save(Subtask sub) async {
    final prefs = await SharedPreferences.getInstance();
    final keyBase = 'sub_${sub.id}_';
    final elapsedMs = sub.elapsed.inMilliseconds;
    await prefs.setInt('${keyBase}elapsed', elapsedMs);
    await prefs.setBool('${keyBase}running', sub.runningSince != null);
    if (sub.runningSince != null) {
      await prefs.setInt(
        '${keyBase}startAt',
        DateTime.now().millisecondsSinceEpoch,
      );
    }
  }

  static Future<void> load(Subtask sub) async {
    final prefs = await SharedPreferences.getInstance();
    final keyBase = 'sub_${sub.id}_';
    final saved = prefs.getInt('${keyBase}elapsed') ?? 0;
    final wasRun = prefs.getBool('${keyBase}running') ?? false;
    sub.actualDuration = Duration(milliseconds: saved);

    if (wasRun) {
      final startAt = prefs.getInt('${keyBase}startAt');
      if (startAt != null) {
        final extra = DateTime.now().millisecondsSinceEpoch - startAt;
        sub.actualDuration += Duration(milliseconds: extra);
        sub.start();
      }
    }
  }
}
