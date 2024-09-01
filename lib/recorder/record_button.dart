import 'package:flutter/material.dart';
import 'package:recorder_summary/recorder/main_recorder.dart';

class RecordButton extends StatelessWidget {
  final RecordingState recordingState;
  final VoidCallback onPressed;
  const RecordButton(
      {super.key, required this.recordingState, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    // record button decoration
    return (recordingState != RecordingState.recording &&
            recordingState != RecordingState.paused)
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
              child: Icon(
                  recordingState != RecordingState.paused
                      ? Icons.pause
                      : Icons.play_arrow,
                  size: 35),
            ),
            color: Colors.black,
            onPressed: onPressed,
          );
  }
}
