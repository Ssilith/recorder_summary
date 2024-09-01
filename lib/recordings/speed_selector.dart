import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SpeedSelector extends StatefulWidget {
  final AudioPlayer player;
  const SpeedSelector({super.key, required this.player});

  @override
  State<SpeedSelector> createState() => _SpeedSelectorState();
}

class _SpeedSelectorState extends State<SpeedSelector> {
  double currentSpeed = 1.0;
  List<double> speedValues = [0.5, 1.0, 1.5, 2.0];

  @override
  Widget build(BuildContext context) {
    // menu button with speed values
    return PopupMenuButton<double>(
        initialValue: currentSpeed,
        onSelected: (double value) {
          setState(() {
            currentSpeed = value;
            widget.player.setSpeed(value);
          });
        },
        child: Text('${currentSpeed}x ',
            style: const TextStyle(fontWeight: FontWeight.bold)),
        itemBuilder: (BuildContext context) => speedValues
            .map(
              (value) => PopupMenuItem<double>(
                value: value,
                child: Text('${value}x'),
              ),
            )
            .toList());
  }
}
