import 'package:flutter/material.dart';

class RecordButton extends StatelessWidget {
  final bool isRecordingStopped;
  final bool isRecording;
  final VoidCallback onPressed;
  const RecordButton(
      {super.key,
      required this.isRecordingStopped,
      required this.onPressed,
      required this.isRecording});

  @override
  Widget build(BuildContext context) {
    return !isRecording
        ? IconButton(
            icon: Ink(
              decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white, width: 2)),
              child: const Icon(Icons.circle, size: 35),
            ),
            color: Colors.red,
            onPressed: onPressed,
          )
        : IconButton(
            icon: Ink(
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(color: Colors.white, width: 2)),
              child: Icon(!isRecordingStopped ? Icons.pause : Icons.play_arrow,
                  size: 35),
            ),
            color: Colors.black,
            onPressed: onPressed,
          );
  }
}
