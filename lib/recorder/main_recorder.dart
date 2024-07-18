// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/recorder/record_button.dart';
import 'package:recorder_summary/recorder/timer_container.dart';
import 'package:recorder_summary/recorder/wave_container.dart';
import 'package:recorder_summary/widgets/dialogs/alert_dialog_with_text_field.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:path/path.dart' as p;

enum RecordingState { idle, recording, paused, finished, playing }

class MainRecorder extends StatefulWidget {
  const MainRecorder({super.key});

  @override
  State<MainRecorder> createState() => _MainRecorderState();
}

class _MainRecorderState extends State<MainRecorder> {
  // controllers
  late final RecorderController recorderController;
  PlayerController? playerController;
  TextEditingController renameController = TextEditingController();

  // paths
  String? path;
  String? musicFile;
  late Directory appDirectory;

  // record state management
  RecordingState recordingState = RecordingState.idle;

  // ui loading state
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getDirectory();
    _initialiseControllers();
  }

  // retrieve the directory for output path
  _getDirectory() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    setState(() => isLoading = false);
  }

  // initialize controller settings
  _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  // start the recording process
  _startRecording() async {
    if (recordingState != RecordingState.recording) {
      try {
        // stop the player
        await playerController?.stopPlayer();
        // start recording
        await recorderController.record();
        setState(() => recordingState = RecordingState.recording);
      } catch (e) {
        message(context, 'Failure', 'Failed to start recording');
      }
    }
  }

  // toggle the recording state between pause and continue
  _pauseOrContinueRecording() async {
    if (recordingState == RecordingState.paused ||
        recordingState == RecordingState.recording) {
      try {
        if (recordingState == RecordingState.paused) {
          // start the recorder
          await recorderController.record();
          setState(() => recordingState = RecordingState.recording);
        } else {
          // pause the recorder
          await recorderController.pause();
          setState(() => recordingState = RecordingState.paused);
        }
      } catch (e) {
        message(context, "Failure", "Error in handling recording");
      }
    }
  }

  // stop the recording and handles file renaming and preparation for playback
  _stopRecording() async {
    try {
      if (recordingState == RecordingState.recording ||
          recordingState == RecordingState.paused) {
        path = await recorderController.stop();
        await _handleRecordingCompletion();
        setState(() {
          recordingState = RecordingState.finished;
          renameController.clear();
          recorderController.refresh();
          recorderController.reset();
        });
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  // prepare player and add listener to change recording state
  _initialisePlayerController() async {
    playerController = PlayerController();
    await playerController?.preparePlayer(
        path: path!, shouldExtractWaveform: true);

    playerController?.onPlayerStateChanged.listen((state) {
      if (state == PlayerState.stopped && mounted) {
        setState(() {
          recordingState = RecordingState.idle;
        });
      }
    });
  }

  // handle file renaming and checks for file existence
  _handleRecordingCompletion() async {
    // ensure the recorded file exists
    if (!File(path!).existsSync()) {
      message(context, "Error", "Original file does not exist.");
      return;
    }

    bool isNameCorrect = false;

    // handle file renaming
    do {
      await _showRenameDialog();
      String? newName = renameController.text;
      if (newName.isEmpty) {
        message(
            context, "Failure", "Name cannot be empty or renaming cancelled.");
        break;
      } else {
        String newPath = p.join(appDirectory.path, "$newName.m4a");

        // create directory if it does not exist
        String directoryPath = p.dirname(newPath);
        if (!Directory(directoryPath).existsSync()) {
          await Directory(directoryPath).create(recursive: true);
        }

        // check if file with new name already exists
        if (File(newPath).existsSync()) {
          message(context, "Failure", "File already exists with this name.");
        } else {
          try {
            await File(path!).rename(newPath);
            path = newPath;
            setState(() {
              isNameCorrect = true;
            });
          } catch (e) {
            message(context, "Error", "Failed to rename file");
            break;
          }
        }
      }
    } while (!isNameCorrect);

    // if renaming was successful prepare the player
    if (isNameCorrect) {
      try {
        _initialisePlayerController();
      } catch (e) {
        message(context, "Failure", "Error preparing player");
      }
    }
  }

  // start or stop player
  _startOrStopPlayer() async {
    try {
      if (recordingState == RecordingState.finished ||
          recordingState == RecordingState.playing) {
        if (playerController != null) {
          if (playerController!.playerState.isPlaying) {
            // pause the player
            await playerController?.pausePlayer();
            setState(() => recordingState = RecordingState.finished);
          } else {
            // start the player
            await playerController?.startPlayer();
            setState(() => recordingState = RecordingState.playing);
          }
        }
      } else {
        message(context, "Failure", "Error in preparing player");
      }
    } catch (e) {
      message(context, "Failure", "Error in handling recording");
    }
  }

  // open a file picker to select an audio file for playback
  _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        try {
          setState(() {
            path = result.files.single.path;
          });
          _initialisePlayerController();
          setState(() => recordingState = RecordingState.finished);
        } catch (e) {
          setState(() => recordingState = RecordingState.idle);
          message(context, "Failure", "An error occured");
        }
      } else {
        message(context, "Failure", "File not picked");
      }
    } catch (e) {
      message(context, "Failure", "Error picking file");
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    playerController?.release();
    playerController?.dispose();
    super.dispose();
  }

  // display a dialog for renaming the recording.
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
    return isLoading
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TimerContainer(
                isPlayer: (recordingState == RecordingState.finished ||
                    recordingState == RecordingState.playing),
                recorderController: recorderController,
                playerController: playerController,
              ),
              WaveContainer(
                isPlayer: (recordingState == RecordingState.finished ||
                    recordingState == RecordingState.playing),
                playerController: playerController,
                recorderController: recorderController,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  IconButton(
                    icon: const Icon(Icons.file_upload_outlined),
                    onPressed: _pickFile,
                  ),
                  RecordButton(
                    recordingState: recordingState,
                    onPressed: () {
                      if (recordingState != RecordingState.recording) {
                        _startRecording();
                      } else {
                        _pauseOrContinueRecording();
                      }
                    },
                  ),
                  if (recordingState == RecordingState.recording ||
                      recordingState == RecordingState.paused)
                    IconButton(
                        icon: const Icon(Icons.stop), onPressed: _stopRecording)
                  else if (recordingState == RecordingState.finished ||
                      recordingState == RecordingState.playing)
                    IconButton(
                        icon: Icon(recordingState == RecordingState.finished &&
                                recordingState != RecordingState.playing
                            ? Icons.play_arrow
                            : Icons.pause),
                        onPressed: _startOrStopPlayer)
                  else
                    const SizedBox(width: 50),
                ],
              ),
            ],
          );
  }
}
