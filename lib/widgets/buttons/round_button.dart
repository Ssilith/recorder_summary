import 'package:flutter/material.dart';

class RoundButton extends StatelessWidget {
  final String title;
  final Function() onPressed;
  final Color? buttonColor;
  final Color textColor;
  final double width;
  final double? height;
  const RoundButton(
      {super.key,
      required this.title,
      required this.onPressed,
      this.buttonColor,
      this.textColor = Colors.white,
      this.width = 200,
      this.height});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        width: width,
        height: height,
        child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  buttonColor ?? Theme.of(context).colorScheme.primary,
            ),
            onPressed: onPressed,
            child: Text(title,
                style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16))));
  }
}
