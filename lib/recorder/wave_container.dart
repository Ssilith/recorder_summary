import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter/material.dart';
import 'package:recorder_summary/side_drawer.dart';

class WaveContainer extends StatelessWidget {
  final bool isPlayer;
  final PlayerController? playerController;
  final RecorderController recorderController;
  const WaveContainer(
      {super.key,
      required this.isPlayer,
      required this.playerController,
      required this.recorderController});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    // wave decoration
    return ChangeBackgroundColor(children: [
      SizedBox(
        height: 120,
        child: isPlayer
            ? playerController != null
                // player wave decoration
                ? AudioFileWaveforms(
                    enableSeekGesture: true,
                    size: Size(size.width, 120),
                    playerController: playerController!,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                    margin: const EdgeInsets.symmetric(horizontal: 15),
                    playerWaveStyle: PlayerWaveStyle(
                      showSeekLine: true,
                      seekLineColor: Colors.white,
                      liveWaveColor: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : Container(
                    width: size.width,
                    height: 120,
                    decoration:
                        BoxDecoration(borderRadius: BorderRadius.circular(10)),
                  )
            // record wave decoration
            : AudioWaveforms(
                enableGesture: true,
                shouldCalculateScrolledPosition: true,
                size: Size(size.width, 120),
                recorderController: recorderController,
                waveStyle: WaveStyle(
                    waveColor: Theme.of(context).colorScheme.primary,
                    showMiddleLine: true,
                    middleLineThickness: 1,
                    labelSpacing: BorderSide.strokeAlignOutside,
                    middleLineColor: Colors.white),
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(10)),
                margin: const EdgeInsets.symmetric(horizontal: 15),
              ),
      ),
    ]);
  }
}
