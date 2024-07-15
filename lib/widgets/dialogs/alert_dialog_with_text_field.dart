import 'package:flutter/material.dart';
import 'package:recorder_summary/widgets/buttons/round_button.dart';
import 'package:recorder_summary/widgets/text_inputs/text_input_form.dart';

class AlertDialogWithTextField extends StatelessWidget {
  final String title;
  final String description;
  final String hint;
  final Icon icon;
  final TextEditingController controller;
  final VoidCallback onPressed;
  final String confirmButtonText;
  final bool showCancelButton;
  const AlertDialogWithTextField(
      {super.key,
      required this.title,
      required this.description,
      required this.hint,
      required this.controller,
      required this.onPressed,
      required this.icon,
      this.confirmButtonText = "Confirm",
      this.showCancelButton = true});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.zero,
      content: Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(10)),
          padding: const EdgeInsets.all(10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(title,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 20)),
              const SizedBox(height: 5),
              Text(description,
                  style: TextStyle(color: Theme.of(context).hintColor),
                  textAlign: TextAlign.center),
              const SizedBox(height: 10),
              TextInputForm(
                controller: controller,
                width: 400,
                hint: hint,
                prefixIcon: icon,
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (showCancelButton)
                    Expanded(
                        child: RoundButton(
                      title: "Cancel",
                      textColor: Theme.of(context).dialogBackgroundColor,
                      onPressed: () {
                        controller.clear();
                        Navigator.pop(context);
                      },
                    )),
                  if (showCancelButton) const SizedBox(width: 5),
                  Expanded(
                      child: RoundButton(
                          title: confirmButtonText,
                          textColor: Theme.of(context).dialogBackgroundColor,
                          onPressed: onPressed))
                ],
              )
            ],
          )),
    );
  }
}
