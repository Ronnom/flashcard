import 'package:hive/hive.dart';

part 'flashcards.g.dart';

@HiveType(typeId: 0) // Assign a unique typeId
class Flashcard extends HiveObject {
  @HiveField(0)
  String category; // New field for category

  @HiveField(1)
  String question;

  @HiveField(2)
  String answer;

  @HiveField(3)
  bool isCorrect; // If user answered correctly

  @HiveField(4)
  String? userAnswer; // Store user answer

  Flashcard({
    required this.category, // Add category to the constructor
    required this.question,
    required this.answer,
    this.isCorrect = false,
    this.userAnswer,
  });
}
