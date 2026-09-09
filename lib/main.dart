import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'HomePage.dart';
import 'AuthPage.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _initialized = false;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    initializeData();
  }

  void initializeData() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      setState(() {
        _initialized = true;
      });
    } catch (e) {
      debugPrint("Initialization Error: $e");
      setState(() {
        _error = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error) {
      return MaterialApp(
        home: Scaffold(
          body: Center(child: Text("Error during initialization. Please restart.")),
        ),
      );
    }

    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(child: CircularProgressIndicator(color: Colors.black)),
        ),
      );
    }

    return MaterialApp(
      title: 'Event Booking',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: const HomePage(),
    );
  }
}
