// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/recorder/record_button.dart';
import 'package:recorder_summary/widgets/dialogs/alert_dialog_with_text_field.dart';
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
  TextEditingController renameController = TextEditingController();

  String? path;
  String? musicFile;

  // record
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isRecordingStopped = true;

  bool isLoading = true;
  late Directory appDirectory;

  // CHANGE TIMER TO PAUSABLE TIMER
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
    path = "${appDirectory.path}/newRecording.m4a";
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

  _startRecording() async {
    try {
      if (!isRecording) {
        await recorderController.record();

        recordingTimer = Timer.periodic(const Duration(seconds: 1), (Timer t) {
          setState(() {
            recordingDuration += const Duration(seconds: 1);
          });
        });

        setState(() {
          isRecording = true;
          isRecordingStopped = false;
          isRecordingCompleted = false;
        });
      }
    } catch (e) {
      message(context, 'Failure', 'Failed to start recording');
    }
  }

  _pauseOrContinueRecording() async {
    try {
      if (isRecording) {
        if (isRecordingStopped) {
          await recorderController.record();

          recordingTimer =
              Timer.periodic(const Duration(seconds: 1), (Timer t) {
            setState(() {
              recordingDuration += const Duration(seconds: 1);
            });
          });
          setState(() {
            isRecordingStopped = false;
          });
        } else {
          await recorderController.pause();

          recordingTimer?.cancel();
          setState(() {
            isRecordingStopped = true;
          });
        }
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  _stopRecording() async {
    try {
      if (isRecording) {
        await recorderController.stop();
        recordingTimer?.cancel();

        String? newName = await _showRenameDialog();
        if (newName != null && newName.trim().isNotEmpty) {
          String newPath = p.join(appDirectory.path, '$newName.m4a');
          await File(path!).rename(newPath);
          path = newPath;
        }

        setState(() {
          isRecording = false;
          isRecordingCompleted = true;
          isRecordingStopped = false;
          renameController.clear();
          recordingDuration = Duration.zero;
          recorderController.refresh();
          recorderController.reset();
          // playerController.release();
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
    playerController.release();
    playerController.dispose();
    super.dispose();
  }

  _showRenameDialog() {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialogWithTextField(
          title: "Rename recording",
          description: "Enter new file name",
          hint: "Name",
          controller: renameController,
          showCancelButton: false,
          onPressed: () {
            if (renameController.text.isEmpty) {
              message(context, 'Failure', 'Name cannot be empty');
            } else {
              Navigator.of(context).pop();
            }
          },
          icon: const Icon(Icons.text_format_rounded),
          confirmButtonText: "Save",
        );
      },
    );
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.file_upload_outlined),
                    onPressed: _pickFile,
                  ),
                  RecordButton(
                    isRecording: isRecording,
                    isRecordingStopped: isRecordingStopped,
                    onPressed: () {
                      if (!isRecording) {
                        _startRecording();
                      } else {
                        _pauseOrContinueRecording();
                      }
                    },
                  ),
                  if (isRecording)
                    IconButton(
                      icon: const Icon(Icons.stop),
                      onPressed: () async {
                        await _stopRecording();
                        await playerController.preparePlayer(
                            path: path!, shouldExtractWaveform: true);
                      },
                    )
                  else
                    IconButton(
                        icon: Icon(isRecordingStopped
                            ? Icons.play_arrow
                            : Icons.pause),
                        onPressed: () {
                          _startOrStopPlayer();
                        })
                ],
              ),
            ],
          );
  }
}
