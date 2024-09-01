// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:recorder_summary/auth/auth_page.dart';
import 'package:recorder_summary/providers/auth_provider.dart';
import 'package:recorder_summary/widgets/buttons/change_text_button.dart';
import 'package:recorder_summary/widgets/buttons/round_button.dart';
import 'package:recorder_summary/widgets/message.dart';
import 'package:recorder_summary/widgets/text_inputs/text_input_form.dart';

class SingUpPage extends StatefulWidget {
  final AuthProvider authProvider;
  const SingUpPage({super.key, required this.authProvider});

  @override
  State<SingUpPage> createState() => _SingUpPageState();
}

class _SingUpPageState extends State<SingUpPage> {
  // text editing controllers
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _repeatPassword = TextEditingController();

  // sign up function
  signUp(String email, String password, String repeatPassword) async {
    if (password != repeatPassword) {
      message(context, 'Failure', "The passwords are not identical");
      return;
    }
    await widget.authProvider.signUp(email, password);
    Navigator.of(context).pop();
    message(context, 'Success', "The account has been successfully created",
        SnackbarType.success);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AuthPage(
      showLeading: true,
      child: Column(
        children: [
          const SizedBox(height: 20),
          // image
          if (MediaQuery.of(context).viewInsets.bottom == 0)
            SizedBox(
                height: 250,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: SvgPicture.asset("assets/sing_up.svg"),
                  ),
                ))
          else
            const SizedBox(height: 80),
          Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Sign Up",
                    style:
                        TextStyle(fontSize: 35, fontWeight: FontWeight.w600)),
                const SizedBox(height: 5),
                Text("Please fill in the fields below.",
                    style: TextStyle(color: Theme.of(context).hintColor)),
                const SizedBox(height: 15),
                // email input
                TextInputForm(
                  width: size.width * 0.9,
                  hint: "Email",
                  controller: _email,
                  prefixIcon: const Icon(Icons.email),
                ),
                // password input
                Padding(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    child: TextInputForm(
                      width: size.width * 0.9,
                      hint: "Password",
                      hideText: true,
                      controller: _password,
                      prefixIcon: const Icon(Icons.lock),
                    )),
                // repeat password input
                TextInputForm(
                  width: size.width * 0.9,
                  hint: "Repeat password",
                  hideText: true,
                  controller: _repeatPassword,
                  prefixIcon: const Icon(Icons.lock),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // sign up button
          RoundButton(
            height: 60,
            onPressed: () async {
              try {
                await signUp(_email.text, _password.text, _repeatPassword.text);
              } catch (e) {
                message(context, 'Failure', "Failed to sign up");
              }
            },
            title: "SIGN UP",
            textColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          const Spacer(),
          // log in button
          ChangeTextButton(
            text: "Have an account?",
            buttonTitle: "Log in",
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
