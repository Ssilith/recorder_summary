import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';
import 'package:flutter/material.dart';

// snackbar
message(BuildContext context, String title, String description,
    [String type = 'failure']) {
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

Function parseContentType(String type) {
  switch (type.toLowerCase()) {
    case 'success':
      return ElegantNotification.success;
    case 'failure':
      return ElegantNotification.error;
    case 'help':
      return ElegantNotification.info;
    default:
      return ElegantNotification.error;
  }
}
