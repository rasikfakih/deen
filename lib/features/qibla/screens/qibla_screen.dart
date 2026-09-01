import 'package:flutter/material.dart';

class QiblaScreen extends StatelessWidget {
  const QiblaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Qibla')),
      body: Center(
        child: Text(
          'Qibla - Coming Soon',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
