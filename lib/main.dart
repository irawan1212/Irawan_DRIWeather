import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/onboard_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ),
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Weather App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: const Color(0xFFECF3F9),
      ),
      home: const OnboardScreen(),
    );
  }
}
