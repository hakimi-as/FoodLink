import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb; // 1. IMPORT THIS for Web check

// ... other imports ...
import 'providers/auth_provider.dart';
import 'providers/feed_provider.dart';
import 'providers/donation_provider.dart';
import 'providers/theme_provider.dart';
import 'views/login_screen.dart';
import 'views/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 2. UPDATED INITIALIZATION LOGIC
  if (kIsWeb) {
    // WEB: You MUST paste your keys here. 
    // Get these from Firebase Console -> Project Settings -> Your Apps -> Web (</>)
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBLDskxbQLyZkkylyJy_K59snweq4bAbWA", 
        appId: "1:669111875092:web:6483be85eac9ab57185901", 
        messagingSenderId: "669111875092", 
        projectId: "mysavefood-4bfd6", 
        storageBucket: "mysavefood-4bfd6.firebasestorage.app", 
      ),
    );
  } else {
    // ANDROID/iOS: Auto-configured via google-services.json
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => FeedProvider()),
        ChangeNotifierProvider(create: (_) => DonationProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      // Use Consumer to listen to theme changes
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MySaveFood',
            debugShowCheckedModeBanner: false,
            
            // LIGHT THEME DEFINITION
            theme: ThemeData(
              primarySwatch: Colors.orange,
              scaffoldBackgroundColor: Colors.white,
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                foregroundColor: Colors.black, // Dark text on light bar
                elevation: 0,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                selectedItemColor: Colors.orange,
                unselectedItemColor: Colors.grey,
              ),
            ),

            // DARK THEME DEFINITION
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              primarySwatch: Colors.orange,
              scaffoldBackgroundColor: const Color(0xFF121212),
              appBarTheme: const AppBarTheme(
                backgroundColor: Color(0xFF1F1F1F),
                foregroundColor: Colors.white,
              ),
              cardColor: const Color(0xFF1F1F1F),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                backgroundColor: Color(0xFF1F1F1F),
                selectedItemColor: Colors.orange,
                unselectedItemColor: Colors.grey,
              ),
            ),

            // Connect the mode
            themeMode: themeProvider.themeMode,
            
            home: const AuthWrapper(),
          );
        },
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    return authProvider.currentUserModel == null ? const LoginScreen() : const HomeScreen();
  }
}