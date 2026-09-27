import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/home_page.dart';
import 'screens/login_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF0F0F0E),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFFD4A853),
          surface: Color(0xFF1A1A18),
        ),
        textTheme: GoogleFonts.dmSansTextTheme().apply(
          bodyColor: const Color(0xFFF0EDE6),
          displayColor: const Color(0xFFF0EDE6),
        ),
      ),
      home: const _AuthGate(),
    );
  }
}

class _AuthGate extends StatefulWidget {
  const _AuthGate();

  @override
  State<_AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<_AuthGate> {
  bool _splashDone = false;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // If splash hasn't finished, ALWAYS show splash — no matter what.
        if (!_splashDone) {
          return _SplashScreen(
            onFinished: () {
              if (mounted) setState(() => _splashDone = true);
            },
          );
        }

        // Splash is done. Now wait for auth to resolve.
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _SplashScreen(); // stay on splash, no callback
        }

        if (snapshot.hasData) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

class _SplashScreen extends StatefulWidget {
  final VoidCallback? onFinished;
  const _SplashScreen({this.onFinished});

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _reveal;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _reveal = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _controller.forward().whenComplete(() {
      // Hold on the fully-revealed text for a moment, then notify parent.
      Future.delayed(const Duration(milliseconds: 700), () {
        widget.onFinished?.call();
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0E),
      body: Center(
        child: AnimatedBuilder(
          animation: _reveal,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.centerLeft,
                widthFactor: _reveal.value,
                child: child,
              ),
            );
          },
          child: Text(
            'MealWise',
            style: GoogleFonts.dmSerifDisplay(
              fontSize: 44,
              color: const Color(0xFFD4A853),
              height: 1.0,
            ),
          ),
        ),
      ),
    );
  }
}