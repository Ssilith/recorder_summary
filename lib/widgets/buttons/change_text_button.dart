import 'package:flutter/material.dart';

class ChangeTextButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String buttonTitle;
  final String text;
  final EdgeInsetsGeometry textPadding;
  final EdgeInsetsGeometry widgetPadding;
  const ChangeTextButton({
    super.key,
    required this.onPressed,
    required this.buttonTitle,
    this.textPadding = const EdgeInsets.only(left: 3),
    required this.text,
    this.widgetPadding = const EdgeInsets.only(bottom: 15.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: widgetPadding,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(fontSize: 14, color: Theme.of(context).hintColor),
          ),
          const SizedBox(width: 5),
          TextButton(
            style: TextButton.styleFrom(
                padding: textPadding,
                minimumSize: const Size(50, 20),
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                alignment: Alignment.centerLeft),
            onPressed: onPressed,
            child: Text(
              buttonTitle,
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
