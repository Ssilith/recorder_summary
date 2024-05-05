import 'package:flutter/material.dart';
import 'package:recorder_summary/auth/blank_scaffold.dart';

class AuthPage extends StatelessWidget {
  final Widget child;
  final bool showLeading;
  const AuthPage({super.key, required this.child, this.showLeading = false});

  @override
  Widget build(BuildContext context) {
    return BlankScaffold(
      showLeading: showLeading,
      body: LayoutBuilder(builder: (context, constraint) {
        return SingleChildScrollView(
            child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraint.maxHeight),
                child: IntrinsicHeight(
                  child: child,
                )));
      }),
    );
  }
}
