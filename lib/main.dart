import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/intro_page.dart';

const _darkSystemUiOverlay = SystemUiOverlayStyle(
  statusBarColor: Color(0xFF272F33),
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
  systemNavigationBarColor: Color(0xFF272F33),
  systemNavigationBarIconBrightness: Brightness.light,
);

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(_darkSystemUiOverlay);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: _darkSystemUiOverlay,
        child: child ?? const SizedBox.shrink(),
      ),
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFF272F33),
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: _darkSystemUiOverlay,
        ),
      ),
      debugShowCheckedModeBanner: false,
      home: const IntroPage(),
    );
  }
}
