import 'package:flutter/material.dart';

import 'home.dart';

void main() {
  runApp(const NotesApp());
}

class NotesApp extends StatelessWidget {
  const NotesApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = ColorScheme.fromSeed(
      seedColor: const Color(0xff286654),
      brightness: Brightness.light,
    );
    return MaterialApp(
      title: 'Заметки',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: colors,
        fontFamily: 'Roboto',
        useMaterial3: true,
        splashFactory: InkRipple.splashFactory,
        inputDecorationTheme: const InputDecorationTheme(
          border: OutlineInputBorder(),
        ),
      ),
      home: const NotesPage(),
    );
  }
}
