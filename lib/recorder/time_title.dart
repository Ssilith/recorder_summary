import 'package:flutter/material.dart';

class TimeTitle extends StatelessWidget {
  final Duration timeDuration;
  const TimeTitle({super.key, required this.timeDuration});

  @override
  Widget build(BuildContext context) {
    return Text(
        'Playback Time: ${timeDuration.inMinutes}:${(timeDuration.inSeconds % 60).toString().padLeft(2, '0')}');
  }
}
