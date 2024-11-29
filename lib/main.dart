import 'package:flutter/material.dart';
import 'screens/landing_page.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/favourites_screen.dart';
import 'screens/personal_screen.dart';
import 'screens/accsecurity_screen.dart';
import 'screens/about_screen.dart';
import 'screens/appset_screen.dart';
import 'screens/verification_screen.dart';
import 'screens/forgotpw_screen.dart';
import 'screens/setnewpw_screen.dart';
import 'screens/verifycodepw_screen.dart';
import 'screens/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Pastikan widget binding sudah diinisialisasi
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase sebelum menjalankan aplikasi
  await Firebase.initializeApp();


  runApp(const PolylingoApp());
}

class PolylingoApp extends StatelessWidget {
  const PolylingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Polylingo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF4B61DD),
        scaffoldBackgroundColor: const Color(0xFF4B61DD),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF4B61DD),
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4B61DD),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF4B61DD).withOpacity(0.1),
          labelStyle: const TextStyle(color: Color(0xFF4B61DD)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/landing': (context) => const LandingPage(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),        
        '/home': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
          return HomeScreen(
            username: args['username'],
            email: args['email'],
          );
        },
        '/favourites': (context) => const FavouritesScreen(),
        '/personal': (context) => const PersonalScreen(),
        '/accountSecurities': (context) {
          final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

          if (args == null || !args.containsKey('email')) {
            throw Exception("Email argument is required for this screen.");
          }

          return AccountSecuritiesScreen(
            email: args['email'] ?? 'unknown@example.com', // Default jika null
            phoneNumber: args['phoneNumber'], // Tetap nullable
          );
        },
        '/about': (context) => const AboutScreen(),
        '/appSettings': (context) => const AppSetScreen(),
        '/verification': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return VerificationScreen(
            email: args['email'],  // Passing email argument to VerificationScreen
          );
        },
        '/forgotpassword': (context) => const ForgotPasswordScreen(),
        '/verify-code': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          final email = args['email']; // Ambil nilai email dari Map
          return VerifyCodePWScreen(email: email); // Passing email ke VerifyCodePWScreen
        },
        '/set-new-password': (context) => SetNewPasswordScreen(),
      },
      // Default page if the route does not exist
      onUnknownRoute: (settings) => MaterialPageRoute(
        builder: (context) => const LandingPage(),
      ),
    );
  }
}