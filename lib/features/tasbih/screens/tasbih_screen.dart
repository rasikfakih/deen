import 'package:flutter/material.dart';

class TasbihScreen extends StatelessWidget {
  const TasbihScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Tasbih')),
      body: Center(
        child: Text(
          'Tasbih - Coming Soon',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
