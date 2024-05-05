import 'package:flutter/material.dart';
import 'package:recorder_summary/widgets/buttons/round_button.dart';

class MyAlertDialog extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onPressed;
  const MyAlertDialog(
      {super.key,
      required this.title,
      required this.description,
      required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style:
                    const TextStyle(fontWeight: FontWeight.w600, fontSize: 20)),
            const SizedBox(height: 5),
            Text(description,
                style: TextStyle(color: Theme.of(context).hintColor),
                textAlign: TextAlign.center),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                    child: RoundButton(
                  title: "Cancel",
                  textColor: Theme.of(context).dialogBackgroundColor,
                  onPressed: () => Navigator.pop(context),
                )),
                const SizedBox(width: 20),
                Expanded(
                    child: RoundButton(
                        title: "Confirm",
                        textColor: Theme.of(context).dialogBackgroundColor,
                        onPressed: onPressed)),
              ],
            )
          ],
        ));
  }
}
