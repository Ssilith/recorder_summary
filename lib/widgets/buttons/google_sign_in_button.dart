import 'package:flutter/material.dart';

class GoogleSignInButton extends StatelessWidget {
  final double width;
  final VoidCallback onPressed;
  const GoogleSignInButton(
      {super.key, required this.width, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 45,
      child: ElevatedButton.icon(
        icon: Image.asset('assets/google_logo.png', height: 24.0),
        label: const Text(
          'Sign in with Google',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.0),
          ),
          elevation: 0,
          side: BorderSide(
            color: Theme.of(context).hintColor,
          ),
        ),
        onPressed: onPressed,
      ),
    );
  }
}
