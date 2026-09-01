import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Text(
          'Home - Coming Soon',
          style: textTheme.titleLarge,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
