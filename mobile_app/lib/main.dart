import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:math' as math;

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MindWellApp());
}

final ThemeData appTheme = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF4F46E5),
    primary: const Color(0xFF4F46E5),
    secondary: const Color(0xFFEEF2FF),
    error: const Color(0xFFD93025),
    surface: const Color(0xFFFEFAF6),
  ),
  scaffoldBackgroundColor: const Color(0xFFFEFAF6),
  cardColor: const Color(0xFFFFFFFF),
  textTheme: GoogleFonts.interTextTheme().copyWith(
    displayLarge: GoogleFonts.lora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937)),
    headlineSmall: GoogleFonts.lora(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937)),
    titleLarge: GoogleFonts.lora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF1F2937)),
    bodyLarge: GoogleFonts.inter(
        fontSize: 16, color: const Color(0xFF1F2937), height: 1.6),
    bodyMedium: GoogleFonts.inter(
        fontSize: 14, color: const Color(0xFF6B7280)),
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: const Color(0xFFFFFFFF),
    surfaceTintColor: Colors.transparent,
    elevation: 1,
    iconTheme: const IconThemeData(color: Color(0xFF4F46E5)),
    titleTextStyle: GoogleFonts.lora(
      color: const Color(0xFF1F2937),
      fontSize: 22,
      fontWeight: FontWeight.w600,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF4F46E5),
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 14),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      textStyle: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w600),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF4F46E5), width: 2),
    ),
  ),
);

class MindWellApp extends StatelessWidget {
  const MindWellApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MindWell',
      theme: appTheme,
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
    );
  }
}

class MindWellLogo extends StatefulWidget {
  final double size;
  const MindWellLogo({super.key, this.size = 40});

  @override
  State<MindWellLogo> createState() => _MindWellLogoState();
}

class _MindWellLogoState extends State<MindWellLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * math.pi,
          child: child,
        );
      },
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: LogoPainter(color: Theme.of(context).primaryColor),
      ),
    );
  }
}

class LogoPainter extends CustomPainter {
  final Color color;
  LogoPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.12;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      -math.pi / 2,
      1.8 * math.pi,
      false,
      paint,
    );

    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.35, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signIn(Future<UserCredential?> Function() signInMethod) async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    try {
      await signInMethod();
      if (mounted) setState(() => _isLoading = false);
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred.';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'An unknown error occurred: $e';
        _isLoading = false;
      });
    }
  }

  Future<UserCredential?> _signUp() {
    return FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<UserCredential?> _logIn() {
    return FirebaseAuth.instance.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
    );
  }

  Future<UserCredential?> _signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return null;
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      setState(() {
        _errorMessage = "Google Sign In Error: $e";
        _isLoading = false;
      });
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(30.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const MindWellLogo(size: 60),
                const SizedBox(height: 10),
                Text('MindWell',
                    style: GoogleFonts.lora(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1F2937))),
                const SizedBox(height: 10),
                Text('Welcome! Sign in to continue.',
                    style: Theme.of(context).textTheme.bodyMedium),
                const SizedBox(height: 40),
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                const SizedBox(height: 20),
                if (_errorMessage.isNotEmpty)
                  Text(
                    _errorMessage,
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                const SizedBox(height: 20),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _signIn(_logIn),
                              child: const Text('Log In'),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () => _signIn(_signUp),
                              style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.secondary,
                                foregroundColor: Theme.of(context).primaryColor,
                              ),
                              child: const Text('Sign Up'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const Text('or'),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => _signIn(_signInWithGoogle),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1F2937),
                          side: const BorderSide(
                              color: Color(0xFFE5E7EB), width: 1),
                          minimumSize: const Size(double.infinity, 50),
                        ),
                        icon: Image.network(
                            'https://cdn-icons-png.flaticon.com/512/300/300221.png',
                            height: 20.0),
                        label: const Text('Sign in with Google'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final User? user = FirebaseAuth.instance.currentUser;
  final dbRef = FirebaseDatabase.instance.ref();

  final DateFormat _dateTimeFormatter = DateFormat('MMM d, yyyy, h:mm a');

  String _getMoodEmoji(int mood) {
    const emojis = {1: '😥', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
    return emojis[mood] ?? '❓';
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn().signOut();
  }

  void _openFeedbackPage() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const FeedbackPage()),
    );
  }

  void _openNewEntrySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const NewEntrySheet(),
    );
  }

  void _deleteEntry(String key) {
    if (user == null) return;
    dbRef.child('entries/${user!.uid}/$key').remove();
  }

  @override
  Widget build(BuildContext context) {
    if (user == null) return const AuthWrapper();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const MindWellLogo(size: 24),
            const SizedBox(width: 8),
            Text('MindWell',
                style: GoogleFonts.lora(fontWeight: FontWeight.w700)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.feedback_outlined),
            tooltip: 'Submit Feedback',
            onPressed: _openFeedbackPage,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Log Out',
            onPressed: _signOut,
          ),
        ],
      ),
      body: StreamBuilder<DatabaseEvent>(
        stream: dbRef
            .child('entries/${user!.uid}')
            .orderByChild('timestamp')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final List<Map<dynamic, dynamic>> entries = [];
          Map<String, int> tagCounts = {};
          double totalMood = 0;

          if (snapshot.hasData && snapshot.data!.snapshot.value != null) {
            final allEntriesMap = Map<String, dynamic>.from(
                snapshot.data!.snapshot.value as Map);
            final sortedEntries = allEntriesMap.entries.toList()
              ..sort((a, b) => (b.value['timestamp'] as int)
                  .compareTo(a.value['timestamp'] as int));

            for (var entryData in sortedEntries) {
              final entry = Map<dynamic, dynamic>.from(entryData.value);
              entry['key'] = entryData.key;
              entries.add(entry);

              totalMood += (entry['mood'] as num);
              if (entry['tags'] != null) {
                if (entry['tags'] is List) {
                  for (var tag in entry['tags']) {
                    tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
                  }
                } else if (entry['tags'] is Map) {
                  for (var tag in (entry['tags'] as Map).values) {
                    tagCounts[tag] = (tagCounts[tag] ?? 0) + 1;
                  }
                }
              }
            }
          }

          final double avgMood =
              entries.isEmpty ? 0 : totalMood / entries.length;
          String commonTag = '--';
          if (tagCounts.isNotEmpty) {
            commonTag = tagCounts.entries
                .reduce((a, b) => a.value > b.value ? a : b)
                .key;
          }
          final List<Map<dynamic, dynamic>> chartEntries =
              List.from(entries.reversed);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Text(
                'Welcome, ${user?.displayName ?? user?.email?.split('@')[0] ?? ''}!',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              const SizedBox(height: 24),

              // --- NEW ENTRY CARD (Full Width) ---
              GestureDetector(
                onTap: _openNewEntrySheet,
                child: Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.secondary,
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_circle_outline,
                            size: 40, color: Theme.of(context).primaryColor),
                        const SizedBox(height: 16),
                        Text('New Check-in',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: 18)),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- MOOD CHART CARD (Full Width) ---
              Card(
                elevation: 0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mood Trends',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontSize: 18)),
                      const SizedBox(height: 16),
                      // Give chart fixed height so it doesn't collapse
                      SizedBox(
                        height: 200,
                        child: MoodLineChart(entries: chartEntries),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // --- FACTORS & INSIGHTS (Row for Tablet, Col for Mobile) ---
              LayoutBuilder(
                builder: (context, constraints) {
                  // If width is small, stack them. If wide, put side by side.
                  if (constraints.maxWidth < 600) {
                     return Column(
                       children: [
                         _buildFactorsCard(tagCounts),
                         const SizedBox(height: 16),
                         _buildInsightsCard(entries.length, avgMood, commonTag),
                       ],
                     );
                  } else {
                     return Row(
                       crossAxisAlignment: CrossAxisAlignment.start,
                       children: [
                         Expanded(child: _buildFactorsCard(tagCounts)),
                         const SizedBox(width: 16),
                         Expanded(child: _buildInsightsCard(entries.length, avgMood, commonTag)),
                       ],
                     );
                  }
                },
              ),

              const SizedBox(height: 32),
              Text('Past Entries',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 16),
              if (entries.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Text('No entries yet.',
                        style: TextStyle(fontSize: 16, color: Colors.grey)),
                  ),
                )
              else
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    final entry = entries[index];
                    List<dynamic> tags = [];
                    if (entry['tags'] is List) {
                      tags = entry['tags'];
                    } else if (entry['tags'] is Map) {
                      tags = (entry['tags'] as Map).values.toList();
                    }

                    return Card(
                      elevation: 0,
                      color: Colors.white,
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${_getMoodEmoji(entry['mood'])} Mood: ${entry['mood']}',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleLarge
                                          ?.copyWith(fontSize: 18),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _dateTimeFormatter.format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              entry['timestamp'])),
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium,
                                    ),
                                  ],
                                ),
                                IconButton(
                                  icon: Icon(Icons.delete_outline,
                                      color: Theme.of(context)
                                          .colorScheme
                                          .error),
                                  onPressed: () => _deleteEntry(entry['key']),
                                ),
                              ],
                            ),
                            if (entry['text'] != null &&
                                entry['text'].isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(entry['text'],
                                  style: Theme.of(context).textTheme.bodyLarge),
                            ],
                            if (tags.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8.0,
                                runSpacing: 4.0,
                                children: tags.map((tag) => Chip(
                                      label: Text(tag.toString()),
                                      backgroundColor: Theme.of(context)
                                          .colorScheme
                                          .secondary,
                                      labelStyle: TextStyle(
                                          color: Theme.of(context).primaryColor,
                                          fontWeight: FontWeight.w500),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 2),
                                    )).toList(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openNewEntrySheet,
        backgroundColor: Theme.of(context).primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  // Helper Widget for Factors (Pie Chart)
  Widget _buildFactorsCard(Map<String, int> tagCounts) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Factors',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 18)),
            const SizedBox(height: 16),
            // Fixed height for chart container
            SizedBox(
               height: 150,
               child: InteractivePieChart(tagCounts: tagCounts)
            ),
          ],
        ),
      ),
    );
  }

  // Helper Widget for Insights
  Widget _buildInsightsCard(int entryCount, double avgMood, String commonTag) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text('Insights',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontSize: 18)),
             const SizedBox(height: 16),
             AnalyticsStatItem(
                  label: 'Entries',
                  value: entryCount.toString()),
             const SizedBox(height: 12),
             AnalyticsStatItem(
                  label: 'Avg Mood',
                  value:
                      '${_getMoodEmoji(avgMood.round())} ${avgMood.toStringAsFixed(1)}'),
             const SizedBox(height: 12),
             AnalyticsStatItem(
                  label: 'Top Tag', value: commonTag),
          ],
        ),
      ),
    );
  }
}

class NewEntrySheet extends StatefulWidget {
  const NewEntrySheet({super.key});

  @override
  State<NewEntrySheet> createState() => _NewEntrySheetState();
}

class _NewEntrySheetState extends State<NewEntrySheet> {
  double _mood = 3.0;
  final _textController = TextEditingController();
  final Map<String, bool> _tags = {
    'School': false,
    'Friends': false,
    'Family': false,
    'Health': false,
    'Work': false,
    'Other': false,
  };
  bool _isLoading = false;

  Future<void> _saveEntry() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => _isLoading = true);

    final List<String> selectedTags = [];
    _tags.forEach((tag, isSelected) {
      if (isSelected) selectedTags.add(tag);
    });

    final newEntry = {
      'mood': _mood.toInt(),
      'text': _textController.text.trim(),
      'tags': selectedTags,
      'timestamp': ServerValue.timestamp,
    };

    try {
      await FirebaseDatabase.instance
          .ref('entries/${user.uid}')
          .push()
          .set(newEntry);

      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving entry: $e')),
        );
      }
    }
  }

  String _getEmoji(int mood) {
    const emojis = {1: '😥', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
    return emojis[mood] ?? '❓';
  }

  String _getMoodText(int mood) {
    const labels = {
      1: 'Awful',
      2: 'Not Great',
      3: 'Okay',
      4: 'Good',
      5: 'Amazing'
    };
    return labels[mood] ?? '...';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
          20, 20, 20, 20 + MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('New Check-in',
                style: Theme.of(context).textTheme.displayLarge),
            const SizedBox(height: 24),
            Row(
              children: [
                Text('I am feeling ',
                    style: Theme.of(context).textTheme.titleLarge),
                Text(_getMoodText(_mood.round()),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold)),
              ],
            ),
            Slider(
              value: _mood,
              min: 1,
              max: 5,
              divisions: 4,
              label: _getEmoji(_mood.round()),
              onChanged: (value) => setState(() => _mood = value),
            ),
            Center(
                child: Text(_getEmoji(_mood.round()),
                    style: const TextStyle(fontSize: 40))),
            const SizedBox(height: 24),
            Text('What\'s on your mind?',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8.0,
              children: _tags.keys.map((tag) {
                return FilterChip(
                  label: Text(tag),
                  selected: _tags[tag]!,
                  onSelected: (isSelected) =>
                      setState(() => _tags[tag] = isSelected),
                  selectedColor: Theme.of(context).colorScheme.secondary,
                  checkmarkColor: Theme.of(context).primaryColor,
                  labelStyle: TextStyle(
                      color: _tags[tag]!
                          ? Theme.of(context).primaryColor
                          : Theme.of(context).textTheme.bodyMedium?.color),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _textController,
              decoration: const InputDecoration(
                  labelText: 'Private journal entry (optional)'),
              maxLines: 4,
            ),
            const SizedBox(height: 30),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              ElevatedButton(
                onPressed: _saveEntry,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Save Entry'),
              ),
          ],
        ),
      ),
    );
  }
}

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  final _controller = TextEditingController();
  bool _isLoading = false;

  Future<void> _submitFeedback() async {
    final User? user = FirebaseAuth.instance.currentUser;
    
    // VALIDATION: Check if feedback is empty
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Please write some feedback before submitting.'),
              backgroundColor: Colors.orange),
      );
      return;
    }

    if (user == null) return;

    setState(() => _isLoading = true);

    final feedbackData = {
      'uid': user.uid,
      'email': user.email,
      'message': _controller.text.trim(),
      'timestamp': ServerValue.timestamp,
    };

    try {
      await FirebaseDatabase.instance
          .ref('feedback')
          .push()
          .set(feedbackData);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Thank you! Your feedback has been submitted.'),
              backgroundColor: Colors.green),
        );
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Submit Feedback')),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text("Have a bug report or a feature idea? We'd love to hear it!",
              style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 24),
          TextField(
            controller: _controller,
            decoration: const InputDecoration(
                labelText: 'Your Feedback',
                hintText: 'Please be as detailed as possible...'),
            maxLines: 8,
          ),
          const SizedBox(height: 24),
          if (_isLoading)
            const Center(child: CircularProgressIndicator())
          else
            ElevatedButton(
              onPressed: _submitFeedback,
              style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50)),
              child: const Text('Submit Feedback'),
            ),
        ],
      ),
    );
  }
}

class AnalyticsStatItem extends StatelessWidget {
  final String label;
  final String value;

  const AnalyticsStatItem({
    super.key,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Theme.of(context).primaryColor,
                  fontFamily: GoogleFonts.inter().fontFamily,
                  fontSize: 20)),
        ),
      ],
    );
  }
}

class MoodLineChart extends StatelessWidget {
  final List<Map<dynamic, dynamic>> entries;
  const MoodLineChart({super.key, required this.entries});

  @override
  Widget build(BuildContext context) {
    final List<FlSpot> spots = entries.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), (e.value['mood'] as num).toDouble());
    }).toList();

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: Theme.of(context).primaryColor,
            barWidth: 4,
            isStrokeCapRound: true,
            dotData: const FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                const emojis = {1: '😥', 2: '😕', 3: '😐', 4: '😊', 5: '😄'};
                return Text(emojis[value.toInt()] ?? '',
                    style: const TextStyle(fontSize: 14));
              },
            ),
          ),
          topTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles:
              const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withValues(alpha: 0.1))),
        borderData: FlBorderData(show: false),
        minY: 1,
        maxY: 5,
      ),
    );
  }
}

// NEW INTERACTIVE PIE CHART
class InteractivePieChart extends StatefulWidget {
  final Map<String, int> tagCounts;
  const InteractivePieChart({super.key, required this.tagCounts});

  @override
  State<InteractivePieChart> createState() => _InteractivePieChartState();
}

class _InteractivePieChartState extends State<InteractivePieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final List<PieChartSectionData> sections =
        widget.tagCounts.entries.toList().asMap().entries.map((e) {
      final isTouched = e.key == touchedIndex;
      final fontSize = isTouched ? 16.0 : 0.0; // Hide text unless touched
      final radius = isTouched ? 50.0 : 40.0;
      
      final colors = [
        const Color(0xFF4F46E5),
        const Color(0xFFE17055),
        const Color(0xFFFBBF24),
        const Color(0xFF10B981),
        const Color(0xFF6366F1),
        const Color(0xFF9CA3AF)
      ];

      return PieChartSectionData(
        color: colors[e.key % colors.length],
        value: e.value.value.toDouble(),
        title: '${e.value.value}',
        radius: radius,
        titleStyle: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
            color: Colors.white),
      );
    }).toList();

    return Row(
      children: [
        SizedBox(
          height: 150,
          width: 150,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              sections: sections.isEmpty
                  ? [
                      PieChartSectionData(
                          value: 1,
                          color: Colors.grey[200],
                          title: '',
                          radius: 40)
                    ]
                  : sections,
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 30,
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 4,
            children: widget.tagCounts.keys.map((key) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(width: 8, height: 8, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(key, style: const TextStyle(fontSize: 12)),
                ],
              );
            }).toList(),
          ),
        )
      ],
    );
  }
}