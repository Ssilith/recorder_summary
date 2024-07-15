// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:recorder_summary/auth/auth_page.dart';
import 'package:recorder_summary/auth/sign_up_page.dart';
import 'package:recorder_summary/main.dart';
import 'package:recorder_summary/providers/auth_provider.dart';
import 'package:recorder_summary/widgets/buttons/change_text_button.dart';
import 'package:recorder_summary/widgets/buttons/google_sign_in_button.dart';
import 'package:recorder_summary/widgets/buttons/round_button.dart';
import 'package:recorder_summary/widgets/dialogs/alert_dialog_with_text_field.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:recorder_summary/widgets/text_inputs/text_divider.dart';
import 'package:recorder_summary/widgets/text_inputs/text_input_form.dart';

class LoginPage extends StatefulWidget {
  final AuthProvider authProvider;
  const LoginPage({super.key, required this.authProvider});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text editing controllers
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _remindEmail = TextEditingController();

  // remeber me bool
  bool _rememberMe = true;

  // check if is loading
  bool isLoading = false;

  // forgot password dialog
  forgotPasswordWindow() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialogWithTextField(
          title: "Forgot your password?",
          description:
              "Write your email address and we will send you a reset link.",
          hint: "Email",
          controller: _remindEmail,
          icon: const Icon(Icons.email),
          confirmButtonText: "Send",
          onPressed: () async {
            try {
              await resetPassword(_remindEmail.text);
              message(context, 'Success', "Email was send successfully");
            } catch (e) {
              message(context, 'Failure', "Failed to send email");
            }
          },
        );
      },
    );
  }

  // reset password function
  resetPassword(String email) async {
    await widget.authProvider.resetPassword(email);
    _remindEmail.clear();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AuthPage(
      child: Column(
        children: [
          const SizedBox(height: 20),
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            const SizedBox(
                height: 250,
                child:
                    Center(child: Image(image: AssetImage("assets/logo.png"))))
          else
            const SizedBox(height: 30),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Login",
                    style:
                        TextStyle(fontSize: 35, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text("Please fill in the fields below.",
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 15),
                TextInputForm(
                  width: size.width * 0.9,
                  hint: "Email",
                  controller: _email,
                  prefixIcon: const Icon(Icons.email),
                ),
                const SizedBox(height: 15),
                TextInputForm(
                  width: size.width * 0.9,
                  hint: "Password",
                  controller: _password,
                  hideText: true,
                  prefixIcon: const Icon(Icons.lock),
                ),
                SizedBox(
                  width: size.width * 0.9,
                  child: Row(
                    children: [
                      Checkbox(
                          value: _rememberMe,
                          onChanged: (rememberMe) => setState(() {
                                _rememberMe = rememberMe ?? _rememberMe;
                              })),
                      const Expanded(
                          child: Text(
                        "Remember me",
                        style: TextStyle(fontSize: 16),
                      ))
                    ],
                  ),
                ),
              ],
            ),
          ),
          TextDivider(width: size.width * 0.9),
          const SizedBox(height: 15),
          GoogleSignInButton(
              width: size.width * 0.9,
              onPressed: () async {
                await widget.authProvider.signInWithGoogle(_rememberMe);
                if (widget.authProvider.user != null) {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (context) =>
                          MyHomePage(authProvider: widget.authProvider)));
                } else {
                  message(context, 'Failure', "Failed to log in");
                }
              }),
          const SizedBox(height: 20),
          Stack(
            children: [
              Center(
                child: RoundButton(
                  height: 60,
                  onPressed: () async {
                    setState(() => isLoading = true);
                    await widget.authProvider.signInWithEmailAndPassword(
                        _email.text, _password.text, _rememberMe);
                    if (widget.authProvider.user != null) {
                      setState(() => isLoading = false);
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                        builder: (context) =>
                            MyHomePage(authProvider: widget.authProvider),
                      ));
                    } else {
                      setState(() => isLoading = false);
                      message(context, 'Failure', "Failed to log in");
                    }
                  },
                  title: isLoading ? "" : "LOGIN",
                  textColor: Theme.of(context).scaffoldBackgroundColor,
                ),
              ),
              if (isLoading)
                SizedBox(
                  height: 60,
                  child: Center(
                      child: CircularProgressIndicator(
                    color: Theme.of(context).scaffoldBackgroundColor,
                  )),
                )
            ],
          ),
          TextButton(
              onPressed: forgotPasswordWindow,
              child: const Text("Forgot password?")),
          if (MediaQuery.of(context).viewInsets.bottom == 0) const Spacer(),
          ChangeTextButton(
            text: "Don't have an account?",
            buttonTitle: "Sign up",
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                builder: (context) =>
                    SingUpPage(authProvider: widget.authProvider))),
          ),
        ],
      ),
    );
  }
}
