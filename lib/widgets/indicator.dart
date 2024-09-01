import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class Indicator extends StatelessWidget {
  final double size;
  final Color? color;
  const Indicator({super.key, this.size = 40, this.color});

  @override
  Widget build(BuildContext context) {
    // indicator decoration
    return LoadingAnimationWidget.staggeredDotsWave(
        color: color ?? Theme.of(context).colorScheme.primary, size: size);
  }
}
