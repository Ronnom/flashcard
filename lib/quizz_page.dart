import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'flashcards.dart';
import 'quiz_result.dart'; // Import the QuizResult model

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Box<Flashcard> flashcardBox;
  late Box<QuizResult> quizResultsBox; // Box for storing quiz results
  Map<dynamic, String> userAnswers = {};
  final FlutterTts flutterTts = FlutterTts();
  List<MapEntry<dynamic, Flashcard>> _quizCards = [];
  int _currentCardIndex = 0;
  bool _canSwipe = false;
  int _correctAnswers = 0; // Track correct answers
  static const int _quizSize = 10; // Fixed quiz size of 10 flashcards

  @override
  void initState() {
    super.initState();
    flashcardBox = Hive.box<Flashcard>('flashcards');
    quizResultsBox = Hive.box<QuizResult>(
      'quizResults',
    ); // Initialize quiz results box
    _selectRandomFlashcards();
  }

  // Function to select 10 random flashcards for the quiz
  void _selectRandomFlashcards() {
    if (flashcardBox.isEmpty) {
      return;
    }

    // Create a list of all flashcard entries
    List<MapEntry<dynamic, Flashcard>> allCards = [];
    for (var i = 0; i < flashcardBox.length; i++) {
      var key = flashcardBox.keyAt(i);
      var flashcard = flashcardBox.getAt(i);
      if (flashcard != null) {
        allCards.add(MapEntry(key, flashcard));
      }
    }

    // Shuffle all cards
    allCards.shuffle();

    // Take only the first 10 cards (or less if there aren't 10)
    _quizCards = allCards.take(_quizSize).toList();

    setState(() {
      _currentCardIndex = 0;
      _correctAnswers = 0;
      userAnswers = {};
      _canSwipe = false;
    });
  }

  // Function to read aloud the question
  Future<void> _speak(String text) async {
    try {
      await flutterTts.setLanguage("en-US");
      await flutterTts.setPitch(1.0);
      await flutterTts.setSpeechRate(0.5);
      await flutterTts.speak(text);
    } catch (e) {
      debugPrint("Error in TTS: $e");
    }
  }

  // Function to submit the quiz and calculate results
  void submitQuiz() {
    if (_quizCards.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards available for the quiz')),
      );
      return;
    }

    int correctAnswers = 0;
    int totalAnswered = 0;

    for (var entry in _quizCards) {
      var key = entry.key;
      var flashcard = entry.value;

      if (userAnswers.containsKey(key)) {
        totalAnswered++;
        bool isCorrect =
            flashcard.answer.trim().toLowerCase() ==
            userAnswers[key]?.trim().toLowerCase();

        flashcard.isCorrect = isCorrect;
        flashcard.userAnswer = userAnswers[key] ?? '';
        flashcard.save();

        if (isCorrect) {
          correctAnswers++;
        }
      }
    }

    // Prevent division by zero
    double progress =
        _quizCards.isNotEmpty ? (correctAnswers / _quizCards.length) * 100 : 0;

    // Store the quiz result
    quizResultsBox.add(QuizResult(score: progress, date: DateTime.now()));

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text(
              'Quiz Results 🎉',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.deepPurple,
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You scored ${progress.toStringAsFixed(1)}%! 🏆',
                  style: const TextStyle(fontSize: 20, color: Colors.green),
                ),
                const SizedBox(height: 8),
                Text(
                  'Answered $totalAnswered out of ${_quizCards.length} questions',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _selectRandomFlashcards(); // Generate a new quiz set
                },
                child: const Text(
                  'New Quiz',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'OK',
                  style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                ),
              ),
            ],
          ),
    );

    setState(() {}); // Refresh UI
  }

  // Move to next card
  void _nextCard() {
    if (_currentCardIndex < _quizCards.length - 1) {
      setState(() {
        _currentCardIndex++;
        _canSwipe = false; // Reset swipe permission for new card
      });
    } else {
      // At the end of the quiz
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text(
                'Congratulations! 🎉',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
              content: const Text(
                'You have completed the quiz! Great job!',
                style: TextStyle(fontSize: 18, color: Colors.black87),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    submitQuiz(); // Automatically show the quiz results
                  },
                  child: const Text(
                    'OK',
                    style: TextStyle(fontSize: 18, color: Colors.deepPurple),
                  ),
                ),
              ],
            ),
      );
    }
  }

  // Calculate current progress percentage
  double _calculateProgress() {
    if (_quizCards.isEmpty) return 0.0;

    // Count correct answers
    _correctAnswers = 0;
    for (var entry in _quizCards) {
      var key = entry.key;
      if (userAnswers.containsKey(key)) {
        var flashcard = entry.value;
        bool isCorrect =
            flashcard.answer.trim().toLowerCase() ==
            userAnswers[key]?.trim().toLowerCase();
        if (isCorrect) {
          _correctAnswers++;
        }
      }
    }

    return (_quizCards.isNotEmpty)
        ? (_correctAnswers / _quizCards.length) * 100
        : 0.0;
  }

  // Handle answer selection - now with auto-advance for wrong answers
  void _handleAnswerSelection(dynamic key, String choice, Flashcard flashcard) {
    if (!_canSwipe) {
      setState(() {
        userAnswers[key] = choice;
        bool isCorrect =
            flashcard.answer.trim().toLowerCase() ==
            choice.trim().toLowerCase();

        if (isCorrect) {
          // If correct, allow user to manually advance
          _canSwipe = true;
        } else {
          // If incorrect, show brief feedback then automatically advance
          Future.delayed(const Duration(milliseconds: 800), () {
            if (_currentCardIndex < _quizCards.length - 1) {
              setState(() {
                _currentCardIndex++;
              });
            } else {
              // Last question and wrong answer, show results
              submitQuiz();
            }
          });
        }

        // Recalculate progress after answer
        _calculateProgress();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (flashcardBox.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Fun Quiz 🎨',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
        ),
        body: const Center(
          child: Text('No flashcards available. Please add some first!'),
        ),
      );
    }

    // Check if we need to generate quiz cards
    if (_quizCards.isEmpty) {
      _selectRandomFlashcards();
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fun Quiz 🎨'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Ensure index is within bounds
    if (_currentCardIndex >= _quizCards.length) {
      _currentCardIndex = _quizCards.length - 1;
    }

    final entry = _quizCards[_currentCardIndex];
    final key = entry.key;
    final flashcard = entry.value;
    final List<String> choices = _generateChoices(flashcard);

    // Check if answer is correct
    String? selectedAnswer = userAnswers[key];
    bool hasAnswered = selectedAnswer != null;
    bool isCorrect =
        hasAnswered &&
        flashcard.answer.trim().toLowerCase() ==
            selectedAnswer.trim().toLowerCase();

    // Calculate current progress
    double progressPercentage = _calculateProgress();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Fun Quiz 🎨',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _selectRandomFlashcards,
            tooltip: 'New Random Quiz',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.purple[100]!, Colors.blue[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Question ${_currentCardIndex + 1} of ${_quizCards.length}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Progress bar
                  Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey.shade200,
                    ),
                    child: Row(
                      children: [
                        Container(
                          width:
                              MediaQuery.of(context).size.width *
                              0.9 *
                              (progressPercentage / 100),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: LinearGradient(
                              colors: [
                                Colors.green.shade300,
                                Colors.green.shade500,
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Progress percentage
                  Text(
                    'Progress: ${progressPercentage.toStringAsFixed(1)}% ($_correctAnswers correct out of ${_quizCards.length})',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.deepPurple.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            // Swipeable card area
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (_canSwipe) {
                    if (details.primaryVelocity! < 0) {
                      // Swipe left-to-right: next card
                      _nextCard();
                    }
                  } else if (isCorrect) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Swipe left to continue!'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                  }
                },
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isCorrect ? Colors.green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Category and swipe indicator
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.deepPurple.shade50,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(20),
                              topRight: Radius.circular(20),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                flashcard.category,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.deepPurple.shade800,
                                ),
                              ),
                              if (_canSwipe)
                                Row(
                                  children: const [
                                    Text('Swipe to continue'),
                                    Icon(
                                      Icons.swipe_left,
                                      color: Colors.deepPurple,
                                    ),
                                  ],
                                ),
                            ],
                          ),
                        ),
                        // Question area
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      flashcard.question,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up,
                                      color: Colors.blue,
                                      size: 28,
                                    ),
                                    onPressed: () => _speak(flashcard.question),
                                    tooltip: 'Read Aloud',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              // Feedback area that appears after answering
                              if (isCorrect)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.green.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          'Correct! Swipe left for next question',
                                          style: TextStyle(
                                            color: Colors.green.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              if (hasAnswered && !isCorrect)
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: Colors.red.shade300,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      const SizedBox(width: 8),
                                      const Text(
                                        'Moving to next question...',
                                        style: TextStyle(
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                        // Answer choices
                        Expanded(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                            ),
                            child: Column(
                              children:
                                  choices.map((choice) {
                                    bool isSelected =
                                        userAnswers[key] == choice;
                                    bool isThisChoiceCorrect =
                                        flashcard.answer.trim().toLowerCase() ==
                                        choice.trim().toLowerCase();

                                    // Determine button color based on answer state
                                    Color buttonColor;
                                    if (isSelected && isThisChoiceCorrect) {
                                      buttonColor = Colors.green;
                                    } else if (isSelected &&
                                        !isThisChoiceCorrect) {
                                      buttonColor = Colors.red;
                                    } else {
                                      buttonColor = Colors.orange.shade100;
                                    }

                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 8.0,
                                      ),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          if (!hasAnswered) {
                                            // Only allow selection if not already answered
                                            _handleAnswerSelection(
                                              key,
                                              choice,
                                              flashcard,
                                            );
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: buttonColor,
                                          minimumSize: const Size(
                                            double.infinity,
                                            50,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 16,
                                            vertical: 12,
                                          ),
                                        ),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Expanded(
                                              child: Text(
                                                choice,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  color:
                                                      isSelected
                                                          ? Colors.white
                                                          : Colors.black87,
                                                ),
                                              ),
                                            ),
                                            if (isSelected &&
                                                isThisChoiceCorrect)
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                              ),
                                            if (isSelected &&
                                                !isThisChoiceCorrect)
                                              const Icon(
                                                Icons.close,
                                                color: Colors.white,
                                              ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }).toList(),
                            ),
                          ),
                        ),
                        // Navigation buttons
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton.icon(
                                onPressed: _canSwipe ? _nextCard : null,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(
                                    255,
                                    133,
                                    166,
                                    153,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Function to generate multiple-choice answers
  List<String> _generateChoices(Flashcard flashcard) {
    // Get all possible answers from the flashcard box
    List<String> allAnswers = flashcardBox.values.map((f) => f.answer).toList();
    allAnswers.remove(flashcard.answer); // Remove the correct answer

    // Ensure there are at least 3 other answers
    if (allAnswers.length < 3) {
      allAnswers.addAll([
        'Option 1',
        'Option 2',
        'Option 3',
      ]); // Fallback options
    }

    allAnswers.shuffle();
    List<String> choices = allAnswers.take(3).toList();
    choices.add(flashcard.answer);
    choices.shuffle();
    return choices;
  }
}
