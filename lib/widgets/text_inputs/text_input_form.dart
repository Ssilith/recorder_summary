import 'package:flutter/material.dart';

class TextInputForm extends StatefulWidget {
  final double width;
  final String hint;
  final TextEditingController controller;
  final Icon? prefixIcon;
  final bool showAboveHint;
  final bool hideText;
  const TextInputForm({
    super.key,
    required this.width,
    required this.hint,
    required this.controller,
    this.prefixIcon,
    this.showAboveHint = false,
    this.hideText = false,
  });

  @override
  State<TextInputForm> createState() => _TextInputFormState();
}

class _TextInputFormState extends State<TextInputForm> {
  bool _obscured = true;

  void _toggleObscured() {
    setState(() {
      _obscured = !_obscured;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showAboveHint)
            Padding(
              padding: const EdgeInsets.only(left: 5.0),
              child: Text(widget.hint,
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600)),
            ),
          Stack(
            alignment: Alignment.centerRight,
            children: [
              TextField(
                obscureText: widget.hideText ? _obscured : false,
                controller: widget.controller,
                cursorColor: Theme.of(context).colorScheme.primary,
                decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    focusedBorder: OutlineInputBorder(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                        borderSide: BorderSide(
                            width: 2,
                            color: Theme.of(context).colorScheme.primary)),
                    focusColor: Theme.of(context).colorScheme.primary,
                    border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    hintText: widget.hint),
              ),
              if (widget.hideText)
                IconButton(
                  icon: Icon(
                    _obscured ? Icons.visibility_off : Icons.visibility,
                  ),
                  onPressed: _toggleObscured,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
