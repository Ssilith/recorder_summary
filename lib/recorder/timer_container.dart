import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audio_waveforms/audio_waveforms.dart';

class TimerContainer extends StatefulWidget {
  final bool isPlayer;
  final RecorderController recorderController;
  final PlayerController? playerController;
  const TimerContainer(
      {super.key,
      required this.recorderController,
      required this.playerController,
      required this.isPlayer});

  @override
  State<TimerContainer> createState() => _TimerContainerState();
}

class _TimerContainerState extends State<TimerContainer> {
  Duration duration = Duration.zero;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    if (!widget.isPlayer) {
      _setRecordControllerDuration();
    }
  }

  _setRecordControllerDuration() {
    // update timer every 50 ms
    timer = Timer.periodic(const Duration(milliseconds: 50), (Timer t) {
      if (mounted) {
        setState(() => duration = widget.recorderController.elapsedDuration);
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.isPlayer
        ? StreamBuilder(
            stream: widget.playerController?.onCurrentDurationChanged,
            builder: (context, snapshot) {
              final duration = Duration(milliseconds: snapshot.data ?? 0);
              return buildContainer(duration);
            },
          )
        : buildContainer(duration);
  }

  // container style
  Widget buildContainer(Duration duration) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: buildStyledTimerText(duration),
    );
  }

  formatToTwoDigits(int duration) {
    return duration.toString().padLeft(2, '0');
  }

  Widget buildStyledTimerText(Duration duration) {
    // format the duration to show minutes, seconds, and fraction of miliseconds
    final minutes = formatToTwoDigits(duration.inMinutes.remainder(60));
    final seconds = formatToTwoDigits(duration.inSeconds.remainder(60));
    final milliseconds =
        formatToTwoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);

    String formattedTime = "$minutes:$seconds.$milliseconds";
    List<InlineSpan> spans = [];
    bool encounteredNonZero = false;

    // iterate over each character in the formatted time string
    for (int i = 0; i < formattedTime.length; i++) {
      String char = formattedTime[i];

      if (char == ':' || char == '.') {
        // apply style to timer
        spans.add(TextSpan(
          text: char,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 40,
            fontWeight: FontWeight.bold,
            fontFamily: 'Monospace',
          ),
        ));
        continue;
      }

      // check if the character is a zero
      bool isZero = char == '0';

      // update the bool
      if (!isZero && !encounteredNonZero) {
        encounteredNonZero = true;
      }

      // determine the color
      Color textColor =
          isZero && !encounteredNonZero ? Colors.grey : Colors.white;

      spans.add(TextSpan(
        text: char,
        style: TextStyle(
          color: textColor,
          fontSize: 40,
          fontWeight: FontWeight.bold,
          fontFamily: 'Monospace',
        ),
      ));
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }
}
