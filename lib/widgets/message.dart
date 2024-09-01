import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

enum SnackbarType { success, failure, help }

// snackbar
message(BuildContext context, String title, String description,
    [SnackbarType type = SnackbarType.failure]) {
  Function function = parseContentType(type);
  function(
          position: Alignment.bottomCenter,
          animation: AnimationType.fromBottom,
          title: Text(
            title,
            style: const TextStyle(
                fontWeight: FontWeight.bold, color: Colors.black),
          ),
          description:
              Text(description, style: const TextStyle(color: Colors.black)))
      .show(context);
}

// parse enum to ElegantNotification
Function parseContentType(SnackbarType type) {
  switch (type) {
    case SnackbarType.success:
      return ElegantNotification.success;
    case SnackbarType.failure:
      return ElegantNotification.error;
    case SnackbarType.help:
      return ElegantNotification.info;
    default:
      return ElegantNotification.error;
  }
}
