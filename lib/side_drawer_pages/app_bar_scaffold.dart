import 'package:flutter/material.dart';

class AppBarScaffold extends StatelessWidget {
  final Widget body;
  final String? title;
  const AppBarScaffold({super.key, required this.body, this.title});

  @override
  Widget build(BuildContext context) {
    // about us and contact us app bar decoration
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, size: 35, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          centerTitle: true,
          title: Text(title ?? ""),
          backgroundColor: Theme.of(context).colorScheme.onSecondary,
        ),
        body: body);
  }
}
