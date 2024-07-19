import 'package:flutter/material.dart';

class PlayIcon extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onTap;
  const PlayIcon({super.key, required this.onTap, required this.isPlaying});

  @override
  State<PlayIcon> createState() => _PlayIconState();
}

class _PlayIconState extends State<PlayIcon> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 35,
            height: 35,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white),
            ),
          ),
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: Icon(
              widget.isPlaying ? Icons.pause : Icons.play_arrow,
              size: 20,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
