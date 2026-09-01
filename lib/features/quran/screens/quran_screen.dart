import 'package:flutter/material.dart';

class QuranScreen extends StatelessWidget {
  const QuranScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Quran')),
      body: Center(
        child: Text(
          'Quran - Coming Soon',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
