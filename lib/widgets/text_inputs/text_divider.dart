import 'package:flutter/material.dart';

class TextDivider extends StatelessWidget {
  final String text;
  final double width;
  const TextDivider({super.key, this.text = 'or', this.width = 400});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Row(
        children: [
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).hintColor,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              text,
              style: const TextStyle(fontSize: 16),
            ),
          ),
          Expanded(
            child: Divider(
              thickness: 1,
              color: Theme.of(context).hintColor,
            ),
          ),
        ],
      ),
    );
  }
}
