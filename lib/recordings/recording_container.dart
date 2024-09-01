// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:recorder_summary/recorder/timer_container.dart';
import 'package:recorder_summary/recordings/main_recordings.dart';
import 'package:recorder_summary/recordings/play_icon.dart';
import 'package:recorder_summary/widgets/dialogs/alert_dialog_with_text_field.dart';
import 'package:recorder_summary/widgets/dialogs/my_alert_dialog.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:path/path.dart' as p;

class RecordingContainer extends StatefulWidget {
  final AudioRecording recording;
  final Directory appDirectory;
  final VoidCallback onDelete;
  const RecordingContainer({
    super.key,
    required this.recording,
    required this.appDirectory,
    required this.onDelete,
  });

  @override
  State<RecordingContainer> createState() => _RecordingContainerState();
}

class _RecordingContainerState extends State<RecordingContainer> {
  // dates
  String? formattedTime;
  late String formattedDate;

  // slider
  bool isExpanded = false;
  bool isPlaying = false;
  TextEditingController renameController = TextEditingController();

  @override
  void initState() {
    renameController.text = widget.recording.fileName.split('.').first;
    isPlaying = widget.recording.player.playing;
    formattedTime = _parseDurationToString(widget.recording.duration);
    formattedDate = _formatDate(widget.recording.creationDate);
    widget.recording.preparePlayer();
    super.initState();
  }

  @override
  void dispose() {
    widget.recording.player.dispose();
    super.dispose();
  }

  // show edit recording dialog
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
          onPressed: () async {
            if (renameController.text.isEmpty) {
              message(context, 'Failure', 'Name cannot be empty');
            } else {
              String newPath = p.join(
                  widget.appDirectory.path, "${renameController.text}.m4a");
              File newFile = await widget.recording.file.rename(newPath);
              widget.recording.file.rename(newPath);
              setState(() {
                widget.recording.file = newFile;
                widget.recording.fileName = "${renameController.text}.m4a";
              });
              Navigator.of(context).pop();
              message(context, 'Success', 'Name changed successfully',
                  SnackbarType.success);
            }
          },
          icon: const Icon(Icons.text_format_rounded),
          confirmButtonText: "Save",
        );
      },
    );
  }

  // show delete recording dialog
  _showDeleteDialog() {
    return showDialog(
        context: context,
        builder: (context) {
          return MyAlertDialog(
            title: "Delete recording",
            description:
                "Are you sure you wanna delete this recording? This action cannot be undone.",
            onPressed: () async {
              await widget.recording.file.delete();
              Navigator.of(context).pop();
              message(
                  context,
                  'Success',
                  "The recording has been successfully deleted",
                  SnackbarType.success);
              widget.onDelete();
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      child: Slidable(
        startActionPane: ActionPane(
          motion: const StretchMotion(),
          children: [
            // edit button
            IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: Theme.of(context).focusColor),
              child: SlidableAction(
                  borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      bottomLeft: Radius.circular(8)),
                  foregroundColor: Colors.white,
                  onPressed: (context) => _showRenameDialog(),
                  backgroundColor: Theme.of(context).colorScheme.onSecondary,
                  icon: Icons.edit,
                  label: "Edit"),
            ),
            // delete button
            IconTheme(
              data: IconTheme.of(context)
                  .copyWith(color: Theme.of(context).focusColor),
              child: SlidableAction(
                  borderRadius: const BorderRadius.only(
                      topRight: Radius.circular(8),
                      bottomRight: Radius.circular(8)),
                  foregroundColor: Colors.white,
                  onPressed: (context) => _showDeleteDialog(),
                  backgroundColor: Colors.red.shade400,
                  icon: Icons.delete,
                  label: "Delete "),
            ),
          ],
        ),
        child: GestureDetector(
          // hide slider
          onTap: () => setState(() => isExpanded = false),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color:
                  Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
            ),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isExpanded ? 105 : 65,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        // play / stop button
                        PlayIcon(
                          key: ValueKey(isPlaying),
                          isPlaying: isPlaying,
                          onTap: () async {
                            setState(() => isPlaying = !isPlaying);
                            if (widget.recording.player.playing) {
                              await widget.recording.player.pause();
                            } else {
                              setState(() => isExpanded = true);
                              await widget.recording.player.play();
                            }
                          },
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // file name
                                  Expanded(
                                    child: Text(
                                      widget.recording.fileName,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  ),
                                  GestureDetector(
                                      onTap: () {},
                                      child: Icon(MdiIcons.fileSendOutline,
                                          size: 22)),
                                ],
                              ),
                              const SizedBox(height: 5),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  // time
                                  Expanded(
                                    child: formattedTime != null
                                        ? Text(
                                            formattedTime!,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.start,
                                            style:
                                                const TextStyle(fontSize: 16),
                                          )
                                        : const SizedBox(),
                                  ),
                                  // date
                                  Text(
                                    formattedDate,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    if (isExpanded)
                      // slider
                      StreamBuilder(
                        stream: widget.recording.player.positionStream,
                        builder: (context, snapshot) {
                          final position =
                              snapshot.data?.inMilliseconds.toDouble() ?? 0;
                          final totalDuration = widget
                                  .recording.duration?.inMilliseconds
                                  .toDouble() ??
                              0;
                          return Slider(
                            min: 0,
                            max: totalDuration,
                            value: position < totalDuration
                                ? position
                                : totalDuration,
                            onChanged: (value) {
                              widget.recording.player
                                  .seek(Duration(milliseconds: value.round()));
                            },
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// parse duration to string MM:SS:MS
_parseDurationToString(Duration? duration) {
  var minutes = formatToTwoDigits(duration!.inMinutes.remainder(60));
  var seconds = formatToTwoDigits(duration.inSeconds.remainder(60));
  var milliseconds =
      formatToTwoDigits(duration.inMilliseconds.remainder(1000) ~/ 10);
  return "$minutes:$seconds.$milliseconds";
}

// parse date-time to string dd MMM yyyy
_formatDate(DateTime date) {
  final DateFormat formatter = DateFormat('dd MMM yyyy');
  return formatter.format(date);
}
