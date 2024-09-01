import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/recordings/recording_container.dart';

// recording data class
class AudioRecording {
  File file;
  String fileName;
  Duration? duration;
  DateTime creationDate;
  String path;
  late AudioPlayer player;

  preparePlayer() async {
    await player.setFilePath(file.path);
  }

  AudioRecording(
      {required this.file,
      this.duration,
      required this.fileName,
      required this.creationDate,
      required this.path}) {
    player = AudioPlayer();
  }
}

class MainRecordings extends StatefulWidget {
  const MainRecordings({super.key});

  @override
  State<MainRecordings> createState() => _MainRecordingsState();
}

class _MainRecordingsState extends State<MainRecordings> {
  Directory? appDirectory;
  Future? getRecordingList;
  List<AudioRecording> recordingList = [];

  @override
  initState() {
    getRecordingList = _listRecordings();
    super.initState();
  }

  // get all recordings
  _listRecordings() async {
    // retrieve the directory
    appDirectory = await getApplicationDocumentsDirectory();

    List<FileSystemEntity> files = appDirectory!.listSync();
    List<AudioRecording> recordings = [];

    // find files and parse to AudioRecording class
    for (FileSystemEntity entity in files) {
      if (entity is File && entity.path.endsWith('.m4a')) {
        FileStat fileStat = await entity.stat();
        DateTime creationDate = fileStat.changed;
        Duration? duration = await _getAudioDuration(entity.path);

        recordings.add(AudioRecording(
          file: entity,
          fileName: entity.path.split('/').last,
          duration: duration,
          creationDate: creationDate,
          path: entity.path,
        ));
      }
    }

    return recordings;
  }

  // get audio duration
  _getAudioDuration(String filePath) async {
    final player = AudioPlayer();
    try {
      await player.setFilePath(filePath);
      return player.duration;
    } catch (e) {
      return null;
    } finally {
      player.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRecordingList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SizedBox(
            height: 60,
            child: Center(child: CircularProgressIndicator()),
          );
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('An error occurred. Please try again later.'));
        } else if (snapshot.data!.isEmpty) {
          recordingList = [];
          return const Center(child: Text('No recordings found.'));
        } else {
          recordingList = snapshot.data;
          // all recordings
          return ListView.builder(
              shrinkWrap: true,
              itemCount: recordingList.length,
              itemBuilder: (context, index) {
                return RecordingContainer(
                  recording: recordingList[index],
                  appDirectory: appDirectory!,
                  onDelete: () => setState(() => recordingList.removeAt(index)),
                );
              });
        }
      },
    );
  }
}
