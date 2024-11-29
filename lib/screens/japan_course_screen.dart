import 'package:flutter/material.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'quiz_japanese.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class JapaneseCoursePage extends StatefulWidget {
  @override
  _JapaneseCoursePageState createState() => _JapaneseCoursePageState();
}

class _JapaneseCoursePageState extends State<JapaneseCoursePage> {
  int currentIndex = 0;
  late PageController _pageController;
  List<Map<String, dynamic>> favoriteCourses = [];
  late List<bool> checkedStatus;

  final List<Map<String, dynamic>> courses = [
    {
      'title': 'Hiragana & Katakana',
      'description': 'Learn the basic Japanese alphabets to start your journey.',
      'icon': 'book', // Icon as string
      'link': 'https://youtu.be/hQzRdI14Z8g'
    },
    {
      'title': 'Basic Greetings',
      'description': 'Learn essential phrases to greet and introduce yourself.',
      'icon': 'handshake',
      'link': 'https://youtu.be/ql2qtZZOxsQ'
    },
    {
      'title': 'Essential Grammar',
      'description': 'Understand the fundamental grammar rules of Japanese.',
      'icon': 'edit_note',
      'link': 'https://youtu.be/k5w-F64P8mI'
    },
    {
      'title': 'Pronunciation Tips',
      'description': 'Get tips to pronounce Japanese words correctly.',
      'icon': 'record_voice_over',
      'link': 'https://youtu.be/aHwvTpByJX8'
    },
    {
      'title': 'Quiz',
      'description': 'Let’s put your knowledge to the test!',
      'icon': 'quiz',
      'link': null
    },
  ];

  @override
  void initState() {
    super.initState();
    checkedStatus = List<bool>.filled(courses.length, false);
    _pageController =
        PageController(viewportFraction: 0.8, initialPage: currentIndex);
    _loadProgress();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      checkedStatus = List<bool>.generate(
        courses.length,
        (index) => prefs.getBool('japanese_course_$index') ?? false,
      );
    });
  }

  Future<void> _saveProgress() async {
    final prefs = await SharedPreferences.getInstance();
    for (int i = 0; i < checkedStatus.length; i++) {
      await prefs.setBool('japanese_course_$i', checkedStatus[i]);
    }
  }

  void updateProgress(bool isChecked, int index) {
    setState(() {
      checkedStatus[index] = isChecked;
    });
    _saveProgress();
  }

  Future<void> openURLForMobile(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch URL: $url')),
      );
    }
  }

  Future<void> _updateWishlist(Map<String, dynamic> course) async {
    try {
      // Get the current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception("User not logged in");
      }

      // Reference to the user document in Firestore
      DocumentReference userDoc = FirebaseFirestore.instance.collection('users').doc(currentUser.uid);

      // Update wishlist in Firestore
      if (favoriteCourses.contains(course)) {
        favoriteCourses.remove(course);
        await userDoc.update({
          'wishlist': FieldValue.arrayRemove([course]),
        });
      } else {
        favoriteCourses.add(course);
        await userDoc.update({
          'wishlist': FieldValue.arrayUnion([course]),
        });
      }
      setState(() {}); // Update UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating wishlist: $e')),
      );
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.book;
      case 'handshake':
        return Icons.handshake;
      case 'edit_note':
        return Icons.edit_note;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final completedCourses = checkedStatus.where((status) => status).length;
    final progress = completedCourses / courses.length;

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            color: const Color(0xFF4B61DD),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Polylingo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        favoriteCourses.contains(courses[currentIndex])
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.white,
                      ),
                      onPressed: () async {
                        await _updateWishlist(courses[currentIndex]);
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Image.asset(
                          'assets/japan_flag.png',
                          height: 32,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                              },
                              child: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 20),
                            ),
                            const SizedBox(width: 8),
                            const Text(
                              'Japanese',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  '4 Lessons   ·   1 Quiz',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
          // Body
          Expanded(
            child: Container(
              color: Colors.white,
              child: Column(
                children: [
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: courses.length,
                      onPageChanged: (index) {
                        setState(() {
                          currentIndex = index;
                        });
                      },
                      itemBuilder: (context, index) {
                        return Transform.scale(
                          scale: index == currentIndex ? 1 : 0.9,
                          child: CourseCard(
                            title: courses[index]['title']!,
                            description: courses[index]['description']!,
                            icon: courses[index]['icon'],
                            isChecked: checkedStatus[index],
                            onChecked: (value) {
                              updateProgress(value, index);
                            },
                            link: courses[index]['link'],
                            onQuizPressed: index == courses.length - 1
                                ? () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              QuizJapanesePage()),
                                    );
                                  }
                                : null,
                            onOpenURL: openURLForMobile,
                          ),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 32, vertical: 16),
                    child: Column(
                      children: [
                        Text(
                          '$completedCourses of ${courses.length} completed',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 8),
                        LinearPercentIndicator(
                          lineHeight: 8.0,
                          percent: progress,
                          backgroundColor: Colors.grey[300],
                          progressColor: const Color(0xFF4B61DD),
                          barRadius: const Radius.circular(8),
                        ),
                      ],
                    ),
                  ),
                  // Page indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      courses.length,
                      (index) => AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 10,
                        width: currentIndex == index ? 12 : 8,
                        decoration: BoxDecoration(
                          color: currentIndex == index
                              ? const Color(0xFF4B61DD)
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CourseCard extends StatelessWidget {
  final String title;
  final String description;
  final String icon;
  final bool isChecked;
  final String? link;
  final Function(bool) onChecked;
  final VoidCallback? onQuizPressed;
  final Function(String) onOpenURL;

  const CourseCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isChecked,
    required this.onChecked,
    this.link,
    this.onQuizPressed,
    required this.onOpenURL,
  });

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'book':
        return Icons.book;
      case 'handshake':
        return Icons.handshake;
      case 'edit_note':
        return Icons.edit_note;
      case 'record_voice_over':
        return Icons.record_voice_over;
      case 'quiz':
        return Icons.quiz;
      default:
        return Icons.help_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(_getIconData(icon), color: const Color(0xFFA6C4E5), size: 100),
              const Spacer(),
              Checkbox(
                value: isChecked,
                onChanged: (value) {
                  onChecked(value ?? false);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFFA6C4E5),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              description,
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ),
          const Spacer(),
          Container(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (link != null) {
                  onOpenURL(link!);
                } else if (onQuizPressed != null) {
                  onQuizPressed!();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[100],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'S t a r t',
                style: TextStyle(
                  color: Color(0xFF4B5ECE),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
