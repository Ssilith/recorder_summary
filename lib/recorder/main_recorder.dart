// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:path/path.dart' as p;

class MainRecorder extends StatefulWidget {
  const MainRecorder({super.key});

  @override
  State<MainRecorder> createState() => _MainRecorderState();
}

class _MainRecorderState extends State<MainRecorder> {
  late final RecorderController recorderController;
  PlayerController playerController = PlayerController();

  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  bool isRecordingStopped = false;
  late Directory appDirectory;

  Timer? recordingTimer;
  Duration recordingDuration = Duration.zero;

  Timer? playbackTimer;
  Duration playbackDuration = Duration.zero;

  @override
  void initState() {
    super.initState();
    _getDirectory();
    _initialiseControllers();
  }

  // directory for output path
  _getDirectory() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    setState(() {
      isLoading = false;
    });
  }

  // controller settings
  _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..sampleRate = 44100;
  }

  // refresh
  _refreshWave() {
    recorderController.refresh();
  }

  // record or stop recording
  _startOrStopRecording() async {
    try {
      if (isRecording) {
        await recorderController.stop();
        recordingTimer?.cancel();

        // Rename logic with debug
        String? newName = await _showRenameDialog();
        if (newName != null && newName.trim().isNotEmpty) {
          String newPath = p.join(appDirectory.path, '$newName.m4a');
          await File(path!).rename(newPath);
          path = newPath;
        }
        await playerController.preparePlayer(
            path: path!, shouldExtractWaveform: true);

        setState(() {
          isRecordingCompleted = true;
          isRecording = false;
          isRecordingStopped = false;
          recordingDuration = Duration.zero;

          recorderController.refresh();
        });
      } else {
        if (isRecordingCompleted) {
          recorderController.reset();
        }
        path = p.join(
            appDirectory.path, '${DateTime.now().millisecondsSinceEpoch}.m4a');
        await recorderController.record(path: path);
        recordingTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            recordingDuration += const Duration(seconds: 1);
          });
        });
        setState(() {
          isRecording = true;
          isRecordingCompleted = false;
          isRecordingStopped = false;
          playerController.release();
        });
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  // pause or play recording
  _pauseOrPlayRecording() async {
    try {
      if (isRecordingStopped) {
        // Resume recording
        await recorderController.record();
        // Restart the timer as recording resumes
        recordingTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            recordingDuration += const Duration(seconds: 1);
          });
        });
        setState(() {
          isRecordingStopped = false;
        });
      } else {
        // Pause recording
        await recorderController.pause();
        // Stop the timer as recording pauses
        recordingTimer?.cancel();
        setState(() {
          isRecordingStopped = true;
        });
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  // start or stop player
  _startOrStopPlayer() async {
    try {
      if (isRecordingCompleted) {
        if (playerController.playerState.isPlaying) {
          // Pause the player
          playerController.pausePlayer();
          // Stop the timer when the player is paused
          playbackTimer?.cancel();
          setState(() {});
        } else {
          // Start the player
          playerController.startPlayer();
          // Reset the playback duration when starting from pause or stop
          playbackDuration = Duration.zero;
          // Start a new timer to update playback duration
          playbackTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
            if (playerController.playerState.isPlaying) {
              setState(() {
                playbackDuration += const Duration(seconds: 1);
              });
            } else {
              // Stop the timer if playback is paused/stopped externally
              playbackTimer?.cancel();
            }
          });
          setState(() {});
        }
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  // open a file
  _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
      _refreshWave();
      setState(() {});
    } else {
      message(context, "Failure", "File not picked");
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    playerController.dispose();

    playerController.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text('Recording Time: $recordingDuration'),
              Text(
                  'Playback Time: ${playbackDuration.inMinutes}:${(playbackDuration.inSeconds % 60).toString().padLeft(2, '0')}'),

              isRecordingCompleted
                  ? AudioFileWaveforms(
                      enableSeekGesture: true,
                      size: Size(size.width, 120),
                      playerController: playerController,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                      playerWaveStyle: PlayerWaveStyle(
                        showSeekLine: true,
                        seekLineColor: Colors.white,
                        liveWaveColor: Theme.of(context).colorScheme.primary,
                      ),
                    )
                  : AudioWaveforms(
                      enableGesture: true,
                      shouldCalculateScrolledPosition: true,
                      size: Size(size.width, 100),
                      recorderController: recorderController,
                      waveStyle: WaveStyle(
                        waveColor: Theme.of(context).colorScheme.primary,
                        extendWaveform: true,
                        showMiddleLine: false,
                        showDurationLabel: true,
                        showHourInDuration: true,
                        durationLinesColor: Colors.white,
                        durationLinesHeight: 15,
                        middleLineThickness: 1,
                        durationStyle: const TextStyle(color: Colors.white),
                        labelSpacing: BorderSide.strokeAlignOutside,
                      ),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10)),
                      margin: const EdgeInsets.symmetric(horizontal: 15),
                    ),
              // const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.file_upload_outlined),
                    onPressed: _pickFile,
                  ),
                  IconButton(
                    icon: Ink(
                      decoration: BoxDecoration(
                          color: isRecording ? Colors.white : Colors.red,
                          borderRadius: BorderRadius.circular(100),
                          border: Border.all(color: Colors.white, width: 2)),
                      child: Icon(isRecording ? Icons.stop : Icons.circle,
                          size: 35),
                    ),
                    color: isRecording ? Colors.black : Colors.red,
                    onPressed: _startOrStopRecording,
                  ),
                  IconButton(
                      icon: Icon(
                          isRecordingStopped ? Icons.play_arrow : Icons.pause),
                      onPressed: () {
                        if (isRecording) {
                          _pauseOrPlayRecording();
                        } else if (isRecordingCompleted) {
                          _startOrStopPlayer();
                        }
                      })
                ],
              ),
            ],
          );
  }

  Future<String?> _showRenameDialog() async {
    TextEditingController renameController = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rename Recording'),
          content: TextField(
            controller: renameController,
            decoration: const InputDecoration(
              hintText: 'Enter new file name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                Navigator.of(context).pop(renameController.text);
              },
            ),
          ],
        );
      },
    );
  }
}
