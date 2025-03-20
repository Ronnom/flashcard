import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'flashcards.dart';

class QuizPage extends StatefulWidget {
  const QuizPage({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<QuizPage> {
  late Box<Flashcard> flashcardBox;
  Map<dynamic, String> userAnswers = {};
  final FlutterTts flutterTts = FlutterTts();
  List<dynamic> _shuffledKeys = [];
  bool _isShuffled = false;
  int _currentCardIndex = 0;
  bool _canSwipe = false;

  @override
  void initState() {
    super.initState();
    flashcardBox = Hive.box<Flashcard>('flashcards');
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

  // New function to shuffle flashcards
  void _shuffleFlashcards() {
    if (flashcardBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards to shuffle!')),
      );
      return;
    }

    if (!_isShuffled) {
      // Create a list of all flashcard keys
      _shuffledKeys = [];
      for (var i = 0; i < flashcardBox.length; i++) {
        _shuffledKeys.add(flashcardBox.keyAt(i));
      }

      // Shuffle the list
      _shuffledKeys.shuffle();
      _isShuffled = true;
    } else {
      // Turn off shuffling
      _isShuffled = false;
      _shuffledKeys = [];
    }

    setState(() {
      // Reset to first card and clear answers when shuffling
      _currentCardIndex = 0;
      _canSwipe = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isShuffled
              ? 'Quiz questions shuffled!'
              : 'Returned to original order',
        ),
      ),
    );
  }

  // Function to submit the quiz and calculate results
  void submitQuiz() {
    if (flashcardBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards available for the quiz')),
      );
      return;
    }

    int correctAnswers = 0;
    int totalAnswered = 0;

    // Get the list of flashcard keys based on current mode (shuffled or not)
    List<dynamic> keys =
        _isShuffled ? _shuffledKeys : flashcardBox.keys.toList();

    for (var key in keys) {
      final flashcard = flashcardBox.get(key);
      if (flashcard != null && userAnswers.containsKey(key)) {
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
        keys.length > 0 ? (correctAnswers / keys.length) * 100 : 0;

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
                  'Answered $totalAnswered out of ${keys.length} questions',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
            actions: [
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
    if (!_canSwipe) return;

    List<dynamic> keys =
        _isShuffled ? _shuffledKeys : flashcardBox.keys.toList();

    if (_currentCardIndex < keys.length - 1) {
      setState(() {
        _currentCardIndex++;
        _canSwipe = false; // Reset swipe permission for new card
      });
    } else {
      // At the end of the deck
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('End of Quiz'),
              content: const Text(
                'You have reached the end of the quiz. Would you like to see your results?',
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    submitQuiz();
                  },
                  child: const Text('See Results'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    setState(() {
                      _currentCardIndex = 0; // Reset to beginning
                      _canSwipe = false;
                    });
                  },
                  child: const Text('Start Over'),
                ),
              ],
            ),
      );
    }
  }

  // Move to previous card
  void _previousCard() {
    setState(() {
      if (_currentCardIndex > 0) {
        _currentCardIndex--;
      }
    });
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

    // Get the current flashcard
    List<MapEntry<dynamic, Flashcard>> flashcardsToShow = [];

    if (_isShuffled && _shuffledKeys.isNotEmpty) {
      for (var key in _shuffledKeys) {
        var flashcard = flashcardBox.get(key);
        if (flashcard != null) {
          flashcardsToShow.add(MapEntry(key, flashcard));
        }
      }
    } else {
      for (var i = 0; i < flashcardBox.length; i++) {
        var key = flashcardBox.keyAt(i);
        var flashcard = flashcardBox.getAt(i);
        if (flashcard != null) {
          flashcardsToShow.add(MapEntry(key, flashcard));
        }
      }
    }

    // Safety check
    if (flashcardsToShow.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Fun Quiz 🎨'),
          backgroundColor: Colors.deepPurple,
        ),
        body: const Center(child: Text('No flashcards available')),
      );
    }

    // Ensure index is within bounds
    if (_currentCardIndex >= flashcardsToShow.length) {
      _currentCardIndex = flashcardsToShow.length - 1;
    }

    final entry = flashcardsToShow[_currentCardIndex];
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

    // Allow swiping if answer is correct
    if (isCorrect && !_canSwipe) {
      setState(() {
        _canSwipe = true;
      });
    }

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
            icon: Icon(
              _isShuffled ? Icons.sort : Icons.shuffle,
              color: Colors.white,
            ),
            onPressed: _shuffleFlashcards,
            tooltip: _isShuffled ? 'Reset Order' : 'Shuffle Questions',
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
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Question ${_currentCardIndex + 1} of ${flashcardsToShow.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
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
                    } else if (details.primaryVelocity! > 0 &&
                        _currentCardIndex > 0) {
                      // Swipe right-to-left: previous card
                      _previousCard();
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
                                        'Try again',
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
                                          if (!_canSwipe) {
                                            // Only allow selection if not ready to swipe
                                            setState(() {
                                              userAnswers[key] = choice;
                                            });
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
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                onPressed:
                                    _currentCardIndex > 0
                                        ? _previousCard
                                        : null,
                                icon: const Icon(Icons.arrow_back),
                                label: const Text('Previous'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple.shade300,
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: _canSwipe ? _nextCard : null,
                                icon: const Icon(Icons.arrow_forward),
                                label: const Text('Next'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepPurple,
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
      floatingActionButton: FloatingActionButton(
        onPressed: submitQuiz,
        backgroundColor: Colors.deepPurple,
        elevation: 5,
        tooltip: 'Submit Quiz',
        child: const Icon(Icons.check, color: Colors.white),
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
