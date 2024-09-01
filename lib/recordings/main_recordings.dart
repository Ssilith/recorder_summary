import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:recorder_summary/recordings/recording_container.dart';
import 'package:recorder_summary/recordings/search_bar_container.dart';
import 'package:recorder_summary/widgets/indicator.dart';

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
  // search string
  String searchString = "";
  TextEditingController searchController = TextEditingController();

  // app directory
  Directory? appDirectory;

  // recordings
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

  // check if is searched and filter returning proper list
  List<AudioRecording> _getSearchedList() {
    if (searchString != "") {
      List<AudioRecording> searchList = [];
      searchList.addAll(recordingList);

      List<AudioRecording> listData = searchList
          .where((item) => item.fileName
              .toString()
              .toLowerCase()
              .contains(searchString.toLowerCase()))
          .toList();

      return listData;
    }
    return recordingList;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getRecordingList,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: Indicator());
        } else if (snapshot.hasError) {
          return const Center(
              child: Text('An error occurred. Please try again later.'));
        } else if (snapshot.data!.isEmpty) {
          recordingList = [];
          return const Center(child: Text('No recordings found.'));
        } else {
          recordingList = snapshot.data;
          // all recordings
          return Column(
            children: [
              // search recordings
              SearchBarContainer(
                searchController: searchController,
                onChanged: (search) => setState(() => searchString = search),
              ),
              // recordings list
              Expanded(
                child: ListView(
                    shrinkWrap: true,
                    children: _getSearchedList()
                        .map((recording) => RecordingContainer(
                            recording: recording,
                            appDirectory: appDirectory!,
                            onDelete: () {
                              setState(() {
                                // clear search
                                searchString = "";
                                searchController.text = "";
                                searchController.clear();

                                // delete recording
                                _getSearchedList().removeWhere((element) =>
                                    element.fileName == recording.fileName);
                              });
                            }))
                        .toList()),
              )
            ],
          );
        }
      },
    );
  }
}
