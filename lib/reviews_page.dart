import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'flashcards.dart';

class ReviewPage extends StatefulWidget {
  const ReviewPage({super.key});

  @override
  _ReviewPageState createState() => _ReviewPageState();
}

class _ReviewPageState extends State<ReviewPage> {
  late Box<Flashcard> flashcardBox;
  final Map<int, bool> _isFlippedMap = {};
  List<int> _shuffledKeys = []; // Store the shuffled keys
  bool _isShuffled = false; // Track if we're in shuffled mode
  int _currentIndex = 0; // Keep track of the current flashcard index

  @override
  void initState() {
    super.initState();
    flashcardBox = Hive.box<Flashcard>('flashcards');
  }

  void _toggleFlip(int index) {
    setState(() {
      _isFlippedMap[index] = !(_isFlippedMap[index] ?? false);
    });
  }

  void _shuffleFlashcards() {
    if (flashcardBox.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No flashcards to shuffle!')),
      );
      return;
    }

    setState(() {
      if (!_isShuffled) {
        // Create a list of all flashcard keys
        _shuffledKeys = List.generate(
          flashcardBox.length,
          (i) => flashcardBox.keyAt(i) as int,
        );

        // Shuffle the list
        _shuffledKeys.shuffle();
        _isShuffled = true;
      } else {
        // Turn off shuffling
        _isShuffled = false;
        _shuffledKeys = [];
      }
      // Reset to first card
      _currentIndex = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isShuffled ? 'Flashcards shuffled!' : 'Returned to original order',
        ),
      ),
    );
  }

  void _nextCard() {
    if (flashcardBox.isEmpty) return;

    setState(() {
      _currentIndex = (_currentIndex + 1) % _getFlashcardsToShow().length;
      // Reset flip state when changing cards
      final currentKey = _getFlashcardsToShow()[_currentIndex].key;
      _isFlippedMap[currentKey] = false;
    });
  }

  void _previousCard() {
    if (flashcardBox.isEmpty) return;

    setState(() {
      _currentIndex =
          (_currentIndex - 1 + _getFlashcardsToShow().length) %
          _getFlashcardsToShow().length;
      // Reset flip state when changing cards
      final currentKey = _getFlashcardsToShow()[_currentIndex].key;
      _isFlippedMap[currentKey] = false;
    });
  }

  // Helper to get the list of flashcards to show
  List<MapEntry<int, Flashcard>> _getFlashcardsToShow() {
    List<MapEntry<int, Flashcard>> flashcardsToShow = [];

    if (_isShuffled && _shuffledKeys.isNotEmpty) {
      // Use shuffled keys
      for (var key in _shuffledKeys) {
        final flashcard = flashcardBox.get(key);
        if (flashcard != null) {
          flashcardsToShow.add(MapEntry(key, flashcard));
        }
      }
    } else {
      // Use normal order
      for (int i = 0; i < flashcardBox.length; i++) {
        final key = flashcardBox.keyAt(i);
        final flashcard = flashcardBox.getAt(i);
        if (flashcard != null) {
          flashcardsToShow.add(MapEntry(key, flashcard));
        }
      }
    }

    return flashcardsToShow;
  }

  @override
  Widget build(BuildContext context) {
    if (flashcardBox.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text(
            'Review Flashcards 🎨',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.deepPurple,
          centerTitle: true,
          elevation: 0,
        ),
        body: const Center(
          child: Text(
            'No flashcards to review!',
            style: TextStyle(fontSize: 24, color: Colors.deepPurple),
          ),
        ),
      );
    }

    // Get current flashcards
    final flashcardsToShow = _getFlashcardsToShow();

    // Make sure current index is valid
    if (_currentIndex >= flashcardsToShow.length) {
      _currentIndex = 0;
    }

    final entry = flashcardsToShow[_currentIndex];
    final key = entry.key;
    final flashcard = entry.value;
    final isFlipped = _isFlippedMap[key] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Review Flashcards 🎨',
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
            tooltip: _isShuffled ? 'Reset Order' : 'Shuffle Flashcards',
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
            // Card counter
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Card ${_currentIndex + 1} of ${flashcardsToShow.length}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                ),
              ),
            ),

            // Flashcard
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: GestureDetector(
                  onTap: () => _toggleFlip(key),
                  child: FlipCard(
                    isFlipped: isFlipped,
                    front: _FlashcardFront(flashcard: flashcard),
                    back: _FlashcardBack(flashcard: flashcard),
                  ),
                ),
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: _previousCard,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Previous'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                  ElevatedButton.icon(
                    onPressed: _nextCard,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FlipCard extends StatelessWidget {
  final bool isFlipped;
  final Widget front;
  final Widget back;

  const FlipCard({
    super.key,
    required this.isFlipped,
    required this.front,
    required this.back,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: isFlipped ? 180 : 0),
      duration: const Duration(milliseconds: 300),
      builder: (context, double value, child) {
        // For the flip effect, we need to show different sides at different angles
        if (value >= 90) {
          // Show back
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY((180 - value) * 3.1415927 / 180),
            child: back,
          );
        } else {
          // Show front
          return Transform(
            alignment: Alignment.center,
            transform:
                Matrix4.identity()
                  ..setEntry(3, 2, 0.001) // Perspective
                  ..rotateY(-value * 3.1415927 / 180),
            child: front,
          );
        }
      },
    );
  }
}

class _FlashcardFront extends StatelessWidget {
  final Flashcard flashcard;

  const _FlashcardFront({required this.flashcard, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              flashcard.category,
              style: TextStyle(fontSize: 18, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    flashcard.question,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tap to flip",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FlashcardBack extends StatelessWidget {
  final Flashcard flashcard;

  const _FlashcardBack({required this.flashcard, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Colors.deepPurple,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: Text(
                    flashcard.answer,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Tap to flip back",
              style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
