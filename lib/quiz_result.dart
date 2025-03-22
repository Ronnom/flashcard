import 'package:hive/hive.dart';

part 'quiz_result.g.dart';

@HiveType(typeId: 2)
class QuizResult {
  @HiveField(0)
  final double score;

  @HiveField(1)
  final DateTime date;

  QuizResult({required this.score, required this.date});
}
