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

  @override
  void initState() {
    super.initState();
    flashcardBox = Hive.box<Flashcard>('flashcards');

    // Check if the flashcard box is empty and populate it with predefined vocabulary words
    if (flashcardBox.isEmpty) {
      _initializeFlashcards();
    }
  }

  void _initializeFlashcards() {
    try {
      flashcardBox.clear(); // Clear the box before adding new flashcards
      List<Flashcard> initialFlashcards = [
        Flashcard(
          category: 'Everyday Basics',
          question: 'Mother',
          answer: 'A female parent',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Father',
          answer: 'A male parent',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Brother',
          answer: 'A male sibling',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Sister',
          answer: 'A female sibling',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Good Morning',
          answer: 'Good Morning',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Good Night',
          answer: 'Good Night',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Good Afternoon',
          answer: 'Good Afternoon',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Thank You',
          answer: 'Thank You',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Bless You',
          answer: 'Bless You',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Excuse Me',
          answer: 'Excuse Me',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: 'Please',
          answer: 'Please',
        ),
        Flashcard(
          category: 'Everyday Basics',
          question: "You're Welcome",
          answer: "You're Welcome",
        ),
        Flashcard(category: 'Body Parts', question: 'Head', answer: 'Head'),
        Flashcard(
          category: 'Body Parts',
          question: 'Fore Head',
          answer: 'Fore Head',
        ),
        Flashcard(category: 'Body Parts', question: 'Eyes', answer: 'Eyes'),
        Flashcard(category: 'Body Parts', question: 'Nose', answer: 'Nose'),
        Flashcard(category: 'Body Parts', question: 'Ears', answer: 'Ears'),
        Flashcard(category: 'Body Parts', question: 'Mouth', answer: 'Mouth'),
        Flashcard(category: 'Body Parts', question: 'Lips', answer: 'Lips'),
        Flashcard(
          category: 'Body Parts',
          question: 'Fingers',
          answer: 'Fingers',
        ),
        Flashcard(category: 'Body Parts', question: 'Arms', answer: 'Arms'),
        Flashcard(category: 'Body Parts', question: 'Legs', answer: 'Legs'),
        Flashcard(category: 'Body Parts', question: 'Toes', answer: 'Toes'),
        Flashcard(category: 'Body Parts', question: 'Feet', answer: 'Feet'),
        Flashcard(category: 'Body Parts', question: 'Nails', answer: 'Nails'),
        Flashcard(category: 'Gender', question: 'Male', answer: 'Male'),
        Flashcard(category: 'Gender', question: 'Female', answer: 'Female'),
        Flashcard(category: 'Colors', question: 'Red', answer: 'Red'),
        Flashcard(category: 'Colors', question: 'Blue', answer: 'Blue'),
        Flashcard(category: 'Colors', question: 'Green', answer: 'Green'),
        Flashcard(category: 'Colors', question: 'Black', answer: 'Black'),
        Flashcard(category: 'Colors', question: 'Pink', answer: 'Pink'),
        Flashcard(category: 'Colors', question: 'Orange', answer: 'Orange'),
        Flashcard(category: 'Colors', question: 'Brown', answer: 'Brown'),
        Flashcard(category: 'Colors', question: 'Purple', answer: 'Purple'),
        Flashcard(category: 'Colors', question: 'Teal', answer: 'Teal'),
        Flashcard(category: 'Colors', question: 'Sky', answer: 'Light Blue'),
        Flashcard(category: 'Colors', question: 'Cyan', answer: 'Cyan'),
        Flashcard(category: 'Colors', question: 'Indigo', answer: 'Indigo'),
        Flashcard(category: 'Colors', question: 'Lime', answer: 'Lime'),
        Flashcard(category: 'Colors', question: 'Amber', answer: 'Amber'),
        Flashcard(category: 'Colors', question: 'BlueGrey', answer: 'BlueGrey'),
        Flashcard(category: 'Colors', question: 'Maroon', answer: 'Maroon'),
        Flashcard(category: 'Colors', question: 'Olive', answer: 'Olive'),
        Flashcard(category: 'Colors', question: 'Gold', answer: 'Gold'),
        Flashcard(category: 'Colors', question: 'Coral', answer: 'Coral'),
        Flashcard(category: 'Colors', question: 'Violet', answer: 'Violet'),
        Flashcard(category: 'Colors', question: 'Magenta', answer: 'Magenta'),
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
        flashcardBox.add(flashcard);
      }
      setState(() {}); // Rebuild the UI

      // Debug: Print all flashcards in the box
      debugPrint('Flashcards in the box:');
      for (var flashcard in flashcardBox.values) {
        debugPrint(
          '${flashcard.category}: ${flashcard.question} - ${flashcard.answer}',
        );
      }
    } catch (e) {
      debugPrint("Error initializing flashcards: $e");
    }
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
          child: _buildCategoryList(),
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
                onPressed: () => _speak(flashcard.question),
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
