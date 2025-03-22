import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'flashcards.dart';
import 'quiz_result.dart';
import 'reviews_page.dart' as review;
import 'quizz_page.dart';
import 'page_flashcard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(FlashcardAdapter());
  Hive.registerAdapter(QuizResultAdapter());
  await Hive.openBox<Flashcard>('flashcards');
  await Hive.openBox<QuizResult>('quizResults');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Flashcard for Nursery English",
      theme: ThemeData(
        primarySwatch: Colors.purple,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'ComicNeue',
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontFamily: 'FredokaOne',
            fontWeight: FontWeight.bold,
            color: Colors.purple,
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlue[200]!, Colors.blue[100]!],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Title
                const Text(
                  'Word Adventure! 🎓',
                  style: TextStyle(
                    fontSize: 32.0,
                    fontFamily: 'FredokaOne',
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
                const SizedBox(height: 30.0),

                // Main menu buttons
                Expanded(
                  child: ListView(
                    children: [
                      _buildButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, animation, __) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: const FlashcardPage(),
                                );
                              },
                            ),
                          );
                        },
                        backgroundColor: Colors.purple[300]!,
                        icon: Icons.edit_outlined,
                        label: 'Practice Words',
                        description: 'Learn new words with fun flashcards!',
                        emoji: '🎨',
                      ),

                      _buildButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, animation, __) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: review.ReviewPage(),
                                );
                              },
                            ),
                          );
                        },
                        backgroundColor: Colors.blue[300]!,
                        icon: Icons.auto_stories_rounded,
                        label: 'My Flashcards',
                        description: 'Review all the words you\'ve learned!',
                        emoji: '📚',
                      ),

                      _buildButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (_, animation, __) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: QuizPage(),
                                );
                              },
                            ),
                          );
                        },
                        backgroundColor: Colors.green[300]!,
                        icon: Icons.extension_rounded,
                        label: 'Fun Quiz',
                        description: 'Test what you\'ve learned with a game!',
                        emoji: '🎮',
                      ),
                    ],
                  ),
                ),

                // Quiz results section
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Your Achievements ',
                            style: TextStyle(
                              fontSize: 24.0,
                              fontFamily: 'FredokaOne',
                              fontWeight: FontWeight.bold,
                              color: Colors.purple,
                            ),
                          ),
                          Text('🏆', style: TextStyle(fontSize: 28)),
                        ],
                      ),
                      SizedBox(
                        height: 150,
                        child: ValueListenableBuilder(
                          valueListenable:
                              Hive.box<QuizResult>('quizResults').listenable(),
                          builder: (context, Box<QuizResult> box, _) {
                            var quizResults = box.values.toList();

                            if (quizResults.isEmpty) {
                              return const Center(
                                child: Text(
                                  'Take a quiz to see your results here!',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                              );
                            }

                            return ListView.builder(
                              padding: const EdgeInsets.only(top: 8),
                              itemCount: quizResults.length,
                              itemBuilder: (context, index) {
                                var result = quizResults[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  elevation: 4.0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: _getScoreColor(
                                        result.score,
                                      ),
                                      child: Text(
                                        '${result.score.round()}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      _getScoreMessage(result.score),
                                      style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      'Date: ${_formatDate(result.date)}',
                                      style: const TextStyle(fontSize: 14.0),
                                    ),
                                    trailing: _getScoreEmoji(result.score),
                                  ),
                                );
                              },
                            );
                          },
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
    );
  }

  Widget _buildButton({
    required VoidCallback onPressed,
    required Color backgroundColor,
    required IconData icon,
    required String label,
    required String description,
    required String emoji,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onPressed,
        child: Container(
          height: 100,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: backgroundColor.withOpacity(0.5),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(width: 16),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Center(
                  child: Icon(icon, size: 32, color: backgroundColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                  ],
                ),
              ),
              Text(emoji, style: const TextStyle(fontSize: 30)),
              const SizedBox(width: 16),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${months[date.month - 1]} ${date.day}';
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.purple;
    if (score >= 80) return Colors.indigo;
    if (score >= 70) return Colors.blue;
    if (score >= 60) return Colors.green;
    return Colors.orange;
  }

  String _getScoreMessage(double score) {
    if (score >= 90) return 'Awesome!';
    if (score >= 80) return 'Great job!';
    if (score >= 70) return 'Good work!';
    if (score >= 60) return 'Nice try!';
    return 'Keep practicing!';
  }

  Widget _getScoreEmoji(double score) {
    String emoji;
    if (score >= 90)
      emoji = '🌟';
    else if (score >= 80)
      emoji = '🎉';
    else if (score >= 70)
      emoji = '😊';
    else if (score >= 60)
      emoji = '👍';
    else
      emoji = '💪';

    return Text(emoji, style: const TextStyle(fontSize: 24));
  }
}
