import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'flashcards.dart';

class FlashcardPage extends StatefulWidget {
  const FlashcardPage({super.key});

  @override
  _FlashcardPageState createState() => _FlashcardPageState();
}

class _FlashcardPageState extends State<FlashcardPage> {
  late Box<Flashcard> flashcardBox;
  final FlutterTts flutterTts = FlutterTts();
  List<int> _shuffledKeys = []; // Store the shuffled keys
  bool _isShuffled = false; // Track if we're in shuffled mode
  bool _isInitialized = false; // Track initialization state

  @override
  void initState() {
    super.initState();
    _loadFlashcards();
  }

  // Added separate loading function for clarity
  Future<void> _loadFlashcards() async {
    flashcardBox = Hive.box<Flashcard>('flashcards');

    // Debug: Print current state of the box
    debugPrint('Current flashcard count: ${flashcardBox.length}');

    // TEMPORARY: Force reinitialization for testing
    // Remove this line after confirming changes are working
    await flashcardBox.clear();

    // Check if the flashcard box is empty and populate it
    if (flashcardBox.isEmpty) {
      await _initializeFlashcards();
    }

    // Debug: Verify data after initialization
    debugPrint('Flashcard count after init: ${flashcardBox.length}');

    // Set state to trigger UI rebuild
    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  Future<void> _initializeFlashcards() async {
    try {
      debugPrint('Initializing flashcards...');
      await flashcardBox.clear(); // Clear the box before adding new flashcards

      List<Flashcard> initialFlashcards = [
        Flashcard(
          category: 'Everyday Basics',
          question: 'A female parent',
          answer: 'Mother',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'A male parent',
          answer: 'Father',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'A male sibling',
          answer: 'Brother',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'A female sibling',
          answer: 'Sister',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'How do you greet someone in the morning?',
          answer: 'Good Morning',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'What do you say when to your family before you sleep?',
          answer: 'Good Night',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question:
              'How do you greet someone in the afternoon?', // Fixed typo: "fo" to "do"
          answer: 'Good Afternoon',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'What are you going to say after someone did you a favor?',
          answer: 'Thank You',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'What are you going to say when someone sneezes?',
          answer: 'Bless You',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'What to say when someone is blocking your way?',
          answer: 'Excuse Me',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question:
              'What are you going to say when you ask someone to do something for you?',
          answer: 'Please',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: "What are you going to say when someone says thank you?",
          answer: "You're Welcome",
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'Where is your brain located at?',
          answer: 'Head',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to see?',
          answer: 'Eyes',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to smell?',
          answer: 'Nose',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to hear?',
          answer: 'Ears',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to speak?',
          answer: 'Mouth',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to lift things?',
          answer: 'Arms',
        ),
        Flashcard(
          category: 'Body Parts',
          question: 'What body part do you use to walk?',
          answer: 'Legs',
        ),
        Flashcard(
          category: 'Gender',
          question: 'What is a boy called?',
          answer: 'Male',
        ),
        Flashcard(
          category: 'Gender',
          question: 'What is a girl called?',
          answer: 'Female',
        ),
        Flashcard(category: 'Numbers', question: '1', answer: 'One'),
        Flashcard(category: 'Numbers', question: '2', answer: 'Two'),
        Flashcard(category: 'Numbers', question: '3', answer: 'Three'),
        Flashcard(category: 'Numbers', question: '4', answer: 'Four'),
        Flashcard(category: 'Numbers', question: '5', answer: 'Five'),
        Flashcard(category: 'Numbers', question: '6', answer: 'Six'),
        Flashcard(category: 'Numbers', question: '7', answer: 'Seven'),
        Flashcard(category: 'Numbers', question: '8', answer: 'Eight'),
        Flashcard(category: 'Numbers', question: '9', answer: 'Nine'),
        Flashcard(category: 'Numbers', question: '10', answer: 'Ten'),
        Flashcard(category: 'Numbers', question: '11', answer: 'Eleven'),
      ];

      for (var flashcard in initialFlashcards) {
        await flashcardBox.add(flashcard);
      }

      // Debug: Print some sample flashcards to verify
      debugPrint('Sample flashcards added:');
      for (int i = 0; i < min(5, flashcardBox.length); i++) {
        final flashcard = flashcardBox.getAt(i);
        debugPrint(
          '${flashcard?.category}: ${flashcard?.question} - ${flashcard?.answer}',
        );
      }
    } catch (e) {
      debugPrint("Error initializing flashcards: $e");
    }
  }

  // Helper function to get min value
  int min(int a, int b) {
    return a < b ? a : b;
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
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isShuffled ? 'Flashcards shuffled!' : 'Returned to original order',
        ),
      ),
    );
  }

  // Added method to force reload flashcards (for testing)
  void _forceReloadFlashcards() {
    setState(() {
      _loadFlashcards();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Flashcards reloaded!')));
  }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Flashcards 🎨',
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
          // Added reload button for testing
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _forceReloadFlashcards,
            tooltip: 'Reload Flashcards',
          ),
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
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child:
              !_isInitialized
                  ? const Center(child: CircularProgressIndicator())
                  : _buildCategoryList(),
        ),
      ),
    );
  }

  Widget _buildCategoryList() {
    // Map of colors for the color category
    final Map<String, Color> colorMap = {
      'Red': Colors.red,
      'Blue': Colors.blue,
      'Green': Colors.green,
      'Black': Colors.black,
      'Pink': Colors.pink,
      'Orange': Colors.orange,
      'Brown': Colors.brown,
      'Purple': Colors.purple,
      'Teal': Colors.teal,
      'Sky': Colors.lightBlue,
      'Cyan': Colors.cyan,
      'Indigo': Colors.indigo,
      'Lime': Colors.lime,
      'Amber': Colors.amber,
      'BlueGrey': Colors.blueGrey,
      'Maroon': Color(0xFF800000),
      'Olive': Color(0xFF808000),
      'Gold': Color(0xFFFFD700),
      'Coral': Colors.deepOrange,
      'Violet': Color(0xFF8B00FF),
      'Magenta': Colors.purpleAccent,
    };

    // Get the flashcards in the correct order (shuffled or not)
    List<Flashcard> flashcardsToShow = [];

    if (_isShuffled && _shuffledKeys.isNotEmpty) {
      // Use shuffled keys
      for (var key in _shuffledKeys) {
        final flashcard = flashcardBox.get(key);
        if (flashcard != null) {
          flashcardsToShow.add(flashcard);
        }
      }
    } else {
      // Use normal order
      flashcardsToShow = flashcardBox.values.toList();
    }

    // Group flashcards by category
    Map<String, List<Flashcard>> groupedFlashcards = {};
    for (var flashcard in flashcardsToShow) {
      if (!groupedFlashcards.containsKey(flashcard.category)) {
        groupedFlashcards[flashcard.category] = [];
      }
      groupedFlashcards[flashcard.category]!.add(flashcard);
    }

    // Build list of categories and their flashcards
    List<Widget> categoryWidgets = [];

    groupedFlashcards.forEach((category, flashcards) {
      categoryWidgets.add(
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            category,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      );

      // Add all flashcards for this category
      for (var flashcard in flashcards) {
        bool isColors = flashcard.category == 'Colors';
        Color? cardColor = isColors ? colorMap[flashcard.question] : null;

        categoryWidgets.add(
          Card(
            color: cardColor,
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            elevation: 5.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                flashcard.question,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isColors ? Colors.white : Colors.black,
                ),
              ),
              subtitle: Text(
                flashcard.answer,
                style: TextStyle(
                  fontSize: 16,
                  color:
                      isColors ? Colors.white.withAlpha(204) : Colors.grey[700],
                ),
              ),
              trailing: IconButton(
                icon: Icon(
                  Icons.volume_up,
                  color: isColors ? Colors.white : Colors.black,
                ),
                onPressed: () => _speak(flashcard.answer), // Read the answer
                tooltip: 'Read Aloud',
              ),
            ),
          ),
        );
      }
    });

    if (categoryWidgets.isEmpty) {
      return Center(
        child: Text(
          'No flashcards available!',
          style: TextStyle(fontSize: 20, color: Colors.deepPurple),
        ),
      );
    }

    return ListView(children: categoryWidgets);
  }
}
