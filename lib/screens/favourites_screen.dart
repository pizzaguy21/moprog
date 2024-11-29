import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'japan_course_screen.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({Key? key}) : super(key: key);

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  List<Map<String, dynamic>> _wishlistCourses = [];

  @override
  void initState() {
    super.initState();
    _fetchWishlist();
  }

  Future<void> _fetchWishlist() async {
    try {
      // Get current user
      User? currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) throw Exception("User not logged in");

      // Fetch wishlist from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();

      if (userDoc.exists) {
        List<dynamic> wishlist = userDoc['wishlist'] ?? [];
        setState(() {
          _wishlistCourses = List<Map<String, dynamic>>.from(wishlist);
        });
      }
    } catch (e) {
      print("Error fetching wishlist: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error fetching wishlist: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Header dengan warna biru
          Container(
            color: const Color(0xFF4B61DD),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 45),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header atas (Polylingo dan Translate Icon)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Polylingo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.g_translate, color: Colors.white),
                      onPressed: () {}, // Optional: Add language translation
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Judul Favourites
                const Text(
                  'Favourites',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          // Daftar Favourites
          Expanded(
            child: _wishlistCourses.isEmpty
                ? const Center(
                    child: Text(
                      "Your wishlist is empty.",
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: ListView.builder(
                      itemCount: _wishlistCourses.length,
                      itemBuilder: (context, index) {
                        final course = _wishlistCourses[index];
                        return GestureDetector(
                          onTap: () {
                            if (course['title'] == 'Hiragana & Katakana' ||
                                course['title'] == 'Quiz' || // Example logic
                                course['title'].contains("Japanese")) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => JapaneseCoursePage(),
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: const Color(0xFFD6E0FF),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  _getIconData(course['icon']),
                                  color: Colors.blue,
                                  size: 30,
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: Text(
                                    course['title'],
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
    );
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
}
