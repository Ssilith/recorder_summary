import 'package:flutter/material.dart';

class BlankScaffold extends StatelessWidget {
  final Widget body;
  final bool showLeading;
  final Widget? floatingActionButton;
  const BlankScaffold(
      {super.key,
      required this.body,
      this.showLeading = false,
      this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    // scaffold decoration
    return Scaffold(
        floatingActionButton: floatingActionButton,
        body: Stack(children: [
          SizedBox(child: body),
          if (showLeading)
            Positioned(
              top: 50,
              left: 15,
              child: IconButton(
                icon: Ink(
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: Icon(Icons.arrow_back,
                        size: 35, color: Theme.of(context).primaryColor)),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
        ]));
  }
}
